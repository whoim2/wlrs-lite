SET PORT=COM41
SET PART=TX
%AppData%\..\Local\Arduino15\packages\esp32\tools\esptool_py\4.5.1/esptool.exe --chip esp32s2 --port %PORT% --baud 921600 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 bootloader.bin 0x8000 partitions.bin 0xe000 boot_app0.bin 0x10000 wlrs-lite_%PART%_lolin_s2_mini.bin

pause 0
