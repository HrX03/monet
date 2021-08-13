import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:monet/monet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MonetProvider? _monet;
  List<MonetPalette> get palettes {
    // This call will get the platform wallpaper colors if it runs on Android,
    // else it will derive a palette based on Colors.purple
    final MonetColors colors = _monet!.getColors(Colors.purple);

    return [
      colors.accent1,
      colors.accent2,
      colors.accent3,
      colors.neutral1,
      colors.neutral2,
    ];
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _monet = await MonetProvider.newInstance();
    // We add a listener to refresh the ui if we get new colors from the wallpaper.
    _monet!.addListener(() => setState(() {}));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Monet example app'),
        ),
        body: _monet != null
            ? ListView.builder(
                itemBuilder: (context, index) {
                  final int currentKey =
                      palettes.first.colors.keys.toList()[index];

                  return SizedBox(
                    height: 80,
                    child: Row(
                      children: palettes.mapIndexed((index, e) {
                        final Color color = e[currentKey]!;
                        final Brightness colorBrightness =
                            ThemeData.estimateBrightnessForColor(color);

                        final String paletteName;

                        switch (index) {
                          case 0:
                            paletteName = "accent1";
                            break;
                          case 1:
                            paletteName = "accent2";
                            break;
                          case 2:
                            paletteName = "accent3";
                            break;
                          case 3:
                            paletteName = "neutral1";
                            break;
                          case 4:
                            paletteName = "neutral2";
                            break;
                          default:
                            paletteName = "unknown";
                            break;
                        }

                        return Expanded(
                          child: SizedBox.expand(
                            child: Material(
                              color: color,
                              child: Center(
                                child: Text(
                                  "$paletteName\n$currentKey",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorBrightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
                itemCount: 13,
              )
            : const Center(child: Text("Monet isn't ready yet.")),
      ),
    );
  }
}
