# wlrs-lite
RC control&amp;telemetry system

Система радиоуправления хоббийного направления, поддерживающая SBUS и MAVLINK v1.
Построена на esp32s2 (например плата lolin mini) и радиомодуле с чипом sx1278 (например, e32-400m20s).

Поддерживает режим LRS (выше дальность) и Sport (выше частота обмена данным). 
Также для обоих вариантов есть режим RX SILENT, отключающий передачу от RX на TX и как следствие - телеметрию.
Тайминг передачи каждого фрейма для LRS: 70мс без rx_silent и 32мс при rx_silent, для Sport режима 40 и 22мс.
Каналы 1-4 передаются каждый фрейм, 5-8 каждый второй, 9-16 каждый четвертый.
Частота выдачи SBUS на RX: 8мс.

Распиновка подключения модуля к плате:
```
MISO_PIN  37
MOSI_PIN  35
SCK_PIN   36
CS_PIN    34
DIO0_PIN  21
RST_PIN   38
DIO1_PIN  33
RXEN_PIN  40
TXEN_PIN  39
GND   GND
VBUS  VCC
```
Питание 5в подавать через разъем USB или пины VBUS/GND.

Пины на плате подписаны сзади, имеется ввиду маркировка GPIO а не ног процессора.
Включена отладочная информация через USB (CDC, компорт в системе). Имейте ввиду, при больших объемах информации, выводимой в терминал, платы могут перезагружаться иногда. Без подключенной к com-порту программы терминала (например PuTTy) проблемы нет.

Для прошивки подайте питание на плату с зажатой кнопкой BOOT, отредактируйте (upload.cmd)[upload.cmd], укажите порт платы (смотреть в диспетчере задач) и заливаемую часть, где TX это наземный модуль, а RX -воздушный и запустите (upload.cmd)[upload.cmd]. Для установки драйверов lolin s2 mini я использовал zadig и тип драйвера CDC как для режима загрузки, так и для дебага (нормального).

SBUS пины: 18 на TX модуле (вход), 17 на RX модуле (выход).
MAVLINK пины: 11 на TX модуле (выход), 10 на RX модуле (вход).
Имейте ввиду, все пины esp32s2 рассчитаны на 3.3в! Если ваша аппаратура управления либо её приемник (использование wlrs-tx как ретранслятора) а также полетный контроллер имеют выход 5в, понадобится как минимум резисторный делитель!

Для входа в режим конфигуратора на TX подайте питание и в течение секунды нажмите кнопку BOOT, как загорится светодиод - отпустите. Если не отпустить в течение 1,5 сек - произойдет сброс настроек до заводских.
В режиме конфигурирования TX модуль создает wifi точку доступа с именем WLRS-TX и паролем 12345678. Подключившись к ней, нужно перейти в браузере по адресу 192.168.4.1 и настроить как нужно конфигурацию, нажать save, после чего не отключая TX модуль подать питание на RX и нажать в течение секунды кнопку BOOT.
RX модуль должен синхронизировать настройки с TX после чего перезагрузить себя и TX.
Мигание светодиода два раза в секунду означает режим failsafe для обоих модулей при отключенном rx silent и только для RX при включенном. Быстрая смена состояния светодиода означает установку линка и передачу данных.

Вопросы и пожелания в чатик: https://t.me/savelylive

![wm](https://github.com/whoim2/wlrs-lite/blob/main/wm.jpg?raw=true)
