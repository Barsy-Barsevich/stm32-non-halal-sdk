# STM32 SDK

## Abstract
Supported targets:
- `STM32H745`;
- `STM32H7B0`.

## Usage
Simplified structure of repository is shown below.
```
XXX/yourproject
├─ ...

stm32-none-halal-sdk
├─ examples
├─ linkerscript
├─ startup
├─ stm32h7xx_hal
|  ├─ inc
|  ├─ src
├─ system
├─ Makefile
```

Building `Core` libraries (including HAL):
```
make build-libs TARGET=STM32H745 -j$(nproc)
```

Building the project (replace `STM32H745` to your microcontroller name):
```
make build-project project=../XXX/yourproject TARGET=STM32H745
```

Disassembly of built project:
```
make disasm-project project=../XXX/yourproject
```

Uploading the binary (the microcontroller should be in BOOT mode):
```
make upload-boot project=../XXX/yourproject
```

## Installing
Preinstall necessary packets first:
```
sudo apt install make gawk gcc-arm-none-eabi dfu-util
```

Then you can clone repository
```
git clone https://github.com/Barsy-Barsevich/stm32-none-halal-sdk.git
cd stm32-none-halal-sdk
```