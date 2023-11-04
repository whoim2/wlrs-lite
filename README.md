# wlrs-lite
Experimental RC control&amp;telemetry system

НЕ ВКЛЮЧАЙТЕ РАДИОМОДУЛИ БЕЗ АНТЕНН! Это приведет к поломке.

### Дисклеймер
Это экспериментальная система радиоуправления, находящая в стадиях разработки и тестирования. За любое ее использование несете ответственность только вы. Соблюдайте законодательство вашей страны в плане использования радиоэфира и воздушного пространства. При первых тестах примите меры к сохранению вашего оборудования в случаях отказа радио. Автор не несет никакой ответственности за использование этой системы кем-бы то ни было.

### Общая информация
Система радиоуправления хоббийного направления, поддерживающая SBUS и MAVLINK v1, также Frsky S.Port на TX (требует тестов и отладки).
Построена на esp32s2 (например плата lolin s2 mini) и радиомодуле с чипом sx1278 (например, e32-400m20s).
Пока завязана на 433 диапазон, при наличии желающих тестить создам и на 868/915. В первую очередь система позиционируется как дальнобойная для самолетов либо других не-спортивных БПЛА, где наличие небольших задержек некритично, но важна максимальная дальность. Для прочих - существует elrs, которая подойдёт больше.

Поддерживает режим LRS (выше дальность) и Sport (выше частота обмена данным) в FSK. Экспериментально добавлен режим Ultra Long (ulrs) в LORA с параметрами 125кгц/7sf/5cr, имеющий самые большие задержки, но в теории обеспечивающий самую высокую дальность. Начиная с версии 006, добавлен режим LoraFast с шириной канала 250кгц, что позволило поднять скорость обновления. Список режимов тестовый, для сбора информации о преимуществах и недостатках каждого, и может расширяться на основе обратной связи от пользователей.
Также для всех вариантов есть режим RX SILENT, отключающий передачу от RX на TX и как следствие - телеметрию.

Внимание! В скоростных режимах радиомодули нагреваются при передаче, проверяйте температуру! При необходимости установите радиаторы и даже кулер на TX. Максимальное значение мощности для 30s модулей (1вт) - число 17. Для 20s (0.1вт) - 20. Минимум есть смысл ставить не ниже 10.

Тайминг передачи каждого фрейма для LRS: 68мс без rx_silent и 32мс при rx_silent, для Sport режима 48 и 22мс. Для ULRS это предварительно 106мс / 48мс, LoraFast 86/40 мс.
Каналы 1-4 передаются каждый фрейм, 5-8 каждый второй, 9-16 каждый четвертый.
Частота выдачи SBUS на RX: 10мс.
Некоторый набор данных mavlink парсится RX частью, передается по частям на TX и там восстанавливается. Набор данных можно расширить по запросу.

RSSI нелинеен, к значению полученному с модуля (~ -100..0) добавляется цифра 100 и записывается в канал. Начиная с версии 006 есть чекбокс для установки scale 1000..2000 для inav/beta. Предполагается, что пользователь настроит на столе параметры канала средствами прошивки так, чтобы при рядом лежащих модулях rssi был 100%.
```
alt, relative_alt;
vx, vy, vz;
roll, pitch, yaw, rollspeed, pitchspeed, yawspeed;
hdg;
battery_remaining;
current_battery, voltage_battery, cpu_load, drop_rate_comm;
lat, lon, gps_alt;
satellites_visible, fix_type;
cog, vel;
rssi, base_mode, system_status;
```
### Подключение модуля
Распиновка подключения радиомодуля к плате esp32s2:
```
MISO_PIN  37
MOSI_PIN  35
SCK_PIN   36
CS_PIN    34
DIO0_PIN  21 //он же BUSY
RST_PIN   38
DIO1_PIN  33
RXEN_PIN  40
TXEN_PIN  39
GND       GND
VCC       VBUS
```
Питание 5в подавать через разъем USB или пины VBUS/GND. Светодиод на LOLIN S2 MINI подключен к GPIO2.

SBUS пины: 18 на TX модуле (вход), 17 на RX модуле (выход).
MAVLINK пины: 11 на TX модуле (выход), 10 на RX модуле (вход), baud настраивается в конфиг-режиме.
S.Port на TX: 9.

Имейте ввиду, все пины esp32s2 рассчитаны на 3.3в! Если ваша аппаратура управления либо её приемник (использование wlrs-tx как ретранслятора) а также полетный контроллер имеют выход 5в, понадобится как минимум резисторный делитель!

Пины на плате подписаны сзади, имеется ввиду маркировка GPIO а не ног процессора.

### Прошивка
Необходимо установить [python](https://www.python.org/) (3.7 и 3.12 проверены), pip и модуль pyserial (`pip install pyserial`). Можно для проверки ввести pip list. и убедиться, что модуль загружен. Далее установить драйвер виртуального com порта (USB CDC) через [zadig](https://zadig.akeo.ie/). Возможно, придется его установить как в режиме загрузки прошивки esp, так и после (в обычном режиме). Появившиеся после подключения lolin s2 mini устройства должны быть опознаны как COM-порты в диспетчере устройств.

Для прошивки подайте питание на плату с зажатой кнопкой BOOT, запустите upload.cmd, укажите порт платы (смотреть в диспетчере задач) и заливаемую часть, где TX это наземный модуль, а RX -воздушный. Для установки драйверов lolin s2 mini я использовал zadig и тип драйвера CDC как для режима загрузки, так и для дебага (нормального).

### Дебаг
Включена отладочная информация через USB (CDC, компорт в системе). Имейте ввиду, при больших объемах информации, выводимой в терминал, платы могут перезагружаться. В некоторых режимах при подключении терминала и выдаче дебаг-сообщений может быть нестабильной связь - боролся за каждую миллисекунду. Без подключенной к com-порту программы терминала (например PuTTy) проблем в этом направлении не обнаружено.

### Конфигурирование и бинд
Для входа в режим конфигуратора на TX подайте питание и в течение секунды нажмите и удерживайте кнопку BOOT, как загорится светодиод - отпустите. Если не отпустить в течение 1,5 сек, произойдет сброс настроек до заводских и перезагрузка устройства.
В режиме конфигурирования TX модуль создает wifi точку доступа (2.4ггц) с именем `WLRS-TX` и паролем `12345678`. Подключившись к ней, нужно перейти в браузере по адресу `http://192.168.4.1` и настроить как нужно конфигурацию, нажать save, после чего не отключая TX модуль подать питание на RX и нажать и удерживать в течение секунды кнопку BOOT, отпустить после того как загорится светодиод.
RX модуль должен синхронизировать настройки с TX после чего перезагрузить себя и TX.
Мигание светодиода два раза в секунду означает режим failsafe для обоих модулей при отключенном rx silent и только для RX при включенном. Быстрая смена состояния светодиода означает установку линка и передачу данных.

### OTA (обновление по воздуху)
Доступно с прошивки v003.

Общий принцип: подключаемся к точке доступа WLRS-TX или WLRS-RX, переходим по адресу `http://192.168.4.1/ota`, на страничке выбираем соответствующий файл обновления прошивки .bin и жмем upload fw. Процесс занимает полминуты, устройство перезагрузится автоматически. В usb serial выдаст сообщение об успехе или ошибке. Также будет сброшена на дефолт конфигурация, ее потребуется настроить заново.
Модуль TX доступен к OTA в режиме конфигурации (зажать после подачи питания кнопку пока не загорится светодиод).
Модуль RX вводится в OTA так: после подачи питания зажимаем кнопку, держим около 2,5 секунд, в процессе светодиод загорается, затем коротко моргнет и продолжит гореть, после чего кнопку можно отпустить.

Вопросы и пожелания в чатик: [https://t.me/savelylive](https://t.me/savelylive)

![ex](https://github.com/whoim2/wlrs-lite/blob/main/Screenshot_2.png?raw=true)

![wm](https://github.com/whoim2/wlrs-lite/blob/main/wm.jpg?raw=true)
