## Run emulator with DNS manually
it can be used to fix Wifi connection problem
```shell
# https://stackoverflow.com/questions/44535500/internet-stopped-working-on-android-emulator-mac-os
$ cd ${ANDROID_HOME}/emulator
$ ./emulator -list-avds # list avd names
$ ./emulator -avd Pixel_4_API_30 -dns-server 8.8.8.8 # start avd named Pixel_4_API_30 

# shortcut: ${ANDROID_HOME}/emulator/emulator -avd Pixel_4_API_30 -dns-server 8.8.8.8
```
