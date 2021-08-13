# Flutter monet

A library to get wallpaper colors using monet on Android or generate them using a primary color.

The Android platform implementation uses [MonetCompat](https://github.com/KieronQuinn/MonetCompat) to get the colors and to handle older Android versions.
The library also provides a dart implementation of [kdrag0n monet engine](https://github.com/kdrag0n/android12-extensions/tree/main/app/src/main/java/dev/kdrag0n/android12ext/monet) to derive colors from a provided color.

## Getting Started

For Android apps targeting version 8.0 and up no setup is required, however if you wish to support lower versions some steps are required.

1. Create a new class, call it however you want (possibly something Application related) and extend `MonetApplication`.
This is the application class from the example, you can use it as is easily enough.

    ```kotlin
    . . .
    import hrx.plugin.monet.MonetApplication

    class CustomApplication : MonetApplication()
    ```

2. Use the new application class in the AndroidManifest. To do so, just add `android:name` to the manifest `application` entry. This snippet is derived from the example app as before.
    ```xml
        <application
            android:name=".CustomApplication"
            ...>
    ```

3. (Optional) Request the `READ_EXTERNAL_STORAGE` permission. In some older version of Android sometimes it was required to have the `READ_EXTERNAL_STORAGE` permission in order to get the wallpaper. If you omit said permission, nothing terribly bad will happen as the underlying lib will use default colors, so it will not error out.
To add the permission, add `
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />` to the `AndroidManifest`

## Using the library
You should use `MonetProvider` to get a working monet implementation.

First of all, get a new instance:
```dart
final MonetProvider monet = await MonetProvider.newInstance();
```

It's recommended to store this instance somewhere accessible in the entire app.

After you've got the instance, you can get the colors by calling `getColors`
```dart
// The color parameter is needed to handle cases where there are no platform colors available, such as unsupported platforms.
final MonetColors colors = monet.getColors(Colors.blue);
```

Once you got the colors, you can use them as you wish to. `MonetColors` contains five palettes as required by the monet specification. Each shade is derived from the base color with slight variations. For example, you can get the palette directly derived from the primary color by calling `colors.accent1`.
```dart
final MonetPalette accent1 = colors.accent1;
```

From the palette you can access a total of 13 shades, varying in lightness. You can use these in combination with a `ColorScheme` for example.
```dart
ColorScheme.light(
    secondary: accent1.shade500,
    background: accent1.shade200,
    surface: accent1.shade100,
);
```

You can find a simple example on the [example folder](https://github.com/HrX03/monet/tree/main/example/) and some docs on the class definitions themselves