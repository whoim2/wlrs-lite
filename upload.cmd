@echo off
SetLocal
SET /P PORT="ENTER COM-PORT NUM FOR ESP32C2 (e.g. "21") : [Enter]>"
SET /P Q="Select part to flash: 1 - TX / 2 - RX : [Enter]>"
if /i "%Q%"=="1" (
    echo Select TX
    SET PART=TX
) else if /i "%Q%"=="2" (
    echo Select RX
    SET PART=RX
) else (
    echo Invalid choice
    goto end
)


esptool.exe --chip esp32s2 --port COM%PORT% --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 bootloader.bin 0x8000 partitions.bin 0xe000 boot_app0.bin 0x10000 wlrs-lite_%PART%_lolin_s2_mini.bin

:end
pause 0
