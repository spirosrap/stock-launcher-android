# Stock Launcher

A 13 KB Android app whose only job is to get a Pixel back to the stock
Pixel Launcher from inside another launcher (Omalauncher).

Android lets an app ask to become the default home app, but never to hand
that role to a different app. Pixel Launcher never asks for itself, so the
fastest legitimate route back is the system's "Default home app" screen.
Tapping this app's icon opens that screen directly, shows a reminder toast,
and exits. From there one tap on "Pixel Launcher" switches back.

No permissions, no network, no UI of its own.

## Build

Built without Gradle on a machine with the Android SDK (`build.sh`
expects `/opt/homebrew/share/android-commandlinetools`, build-tools 36.0.0,
platform android-36 and OpenJDK 21; override with `ANDROID_HOME` /
`JAVA_HOME`). It runs aapt2, javac, d8, zipalign and apksigner, and creates a
debug keystore in `dist/` on first use.

```sh
./build.sh                      # -> dist/StockLauncher.apk
adb install -r dist/StockLauncher.apk
```

Keep the same keystore between builds or `adb install -r` will refuse the
update.
