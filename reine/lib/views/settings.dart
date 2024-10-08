import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';

import '../notifiers/global_notifiers.dart';
import '../notifiers/preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<StatefulWidget> createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var globalNotifier = Provider.of<GlobalNotifiers>(context);
    var screenHeight = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.topCenter,
      height: screenHeight - 120,
      width: 800,
      child: SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(),
            1: IntrinsicColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(children: [
              Padding(
                padding: EdgeInsets.only(left: 32.0, bottom: 16.0),
                child: Text('Language'),
              ),
              Padding(
                  padding: EdgeInsets.only(right: 32.0, bottom: 16.0),
                  child: Text("WIP"))
            ]),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 32.0, top: 16.0, bottom: 16.0),
                  child: Text('Theme'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 32.0, top: 16.0, bottom: 16.0),
                  child: DropdownButton<ThemeMode>(
                    value: globalNotifier.currentTheme,
                    alignment: AlignmentDirectional.center,
                    autofocus: false,
                    isExpanded: true,
                    onChanged: (ThemeMode? theme) {
                      globalNotifier.setTheme(theme!);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        alignment: AlignmentDirectional.center,
                        child: Text('System', style: TextStyle(fontSize: 12.0)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        alignment: AlignmentDirectional.center,
                        child: Text('Light', style: TextStyle(fontSize: 12.0)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        alignment: AlignmentDirectional.center,
                        child: Text('Dark', style: TextStyle(fontSize: 12.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 32.0, top: 16.0, bottom: 16.0),
                  child: Text('Background'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 32.0, top: 16.0, bottom: 16.0),
                  child: DropdownButton<BackgroundMode>(
                    value: globalNotifier.currentBackgroundMode,
                    alignment: AlignmentDirectional.center,
                    autofocus: false,
                    isExpanded: true,
                    onChanged: (BackgroundMode? backgroundMode) {
                      globalNotifier.setBackgroundMode(backgroundMode!);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: BackgroundMode.defaultMode,
                        alignment: AlignmentDirectional.center,
                        child:
                            Text('Default', style: TextStyle(fontSize: 12.0)),
                      ),
                      DropdownMenuItem(
                        value: BackgroundMode.pureColor,
                        alignment: AlignmentDirectional.center,
                        child: Text('Pure Color',
                            style: TextStyle(fontSize: 12.0)),
                      ),
                      DropdownMenuItem(
                        value: BackgroundMode.image,
                        alignment: AlignmentDirectional.center,
                        child: Text('Image', style: TextStyle(fontSize: 12.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (globalNotifier.currentBackgroundMode ==
                BackgroundMode.pureColor)
              TableRow(
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 32.0, top: 16.0, bottom: 16.0),
                    child: Text('Background Color'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 32.0, top: 16.0, bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor:
                                      globalNotifier.currentBackgroundColor,
                                  onColorChanged: (Color color) {
                                    globalNotifier.setBackgroundColor(color);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Pick a color'),
                    ),
                  ),
                ],
              ),
            if (globalNotifier.currentBackgroundMode == BackgroundMode.image)
              TableRow(
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 32.0, top: 16.0, bottom: 16.0),
                    child: Text('Background Image'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 32.0, top: 16.0, bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        var imagePath = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );

                        if (imagePath != null) {
                          globalNotifier.setBackgroundImage(imagePath);
                        }
                      },
                      child: const Text('Pick an image'),
                    ),
                  ),
                ],
              ),
            if (globalNotifier.currentBackgroundMode == BackgroundMode.image)
              TableRow(
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.only(left: 32.0, top: 16.0, bottom: 16.0),
                    child: Text('Background Image Fit Mode'),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          right: 32.0, top: 16.0, bottom: 16.0),
                      child: DropdownButton<BoxFit>(
                        value: globalNotifier.currentBackgroundImageFit,
                        alignment: AlignmentDirectional.center,
                        autofocus: false,
                        isExpanded: true,
                        onChanged: (BoxFit? fit) {
                          globalNotifier.setBackgroundImageFit(fit!);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: BoxFit.contain,
                            alignment: AlignmentDirectional.center,
                            child: Text('Contain',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: BoxFit.cover,
                            alignment: AlignmentDirectional.center,
                            child:
                                Text('Cover', style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: BoxFit.fill,
                            alignment: AlignmentDirectional.center,
                            child:
                                Text('Fill', style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: BoxFit.fitHeight,
                            alignment: AlignmentDirectional.center,
                            child: Text('Fit Height',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: BoxFit.fitWidth,
                            alignment: AlignmentDirectional.center,
                            child: Text('Fit Width',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: BoxFit.none,
                            alignment: AlignmentDirectional.center,
                            child:
                                Text('None', style: TextStyle(fontSize: 12.0)),
                          ),
                          DropdownMenuItem(
                            value: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.center,
                            child: Text('Scale Down',
                                style: TextStyle(fontSize: 12.0)),
                          ),
                        ],
                      )),
                ],
              ),
            if (globalNotifier.currentBackgroundMode == BackgroundMode.image)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 32.0, top: 16.0, bottom: 16.0),
                    child: Text(
                        'Background Image Opacity: ${(globalNotifier.currentBackgroundImageOpacity * 100).toStringAsFixed(0)}%'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 32.0, top: 16.0, bottom: 16.0),
                    child: Slider(
                      value: globalNotifier.currentBackgroundImageOpacity * 100,
                      onChanged: (double opacity) {
                        globalNotifier.setBackgroundImageOpacity(opacity / 100);
                      },
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                    ),
                  ),
                ],
              ),
            if (globalNotifier.currentBackgroundMode == BackgroundMode.image)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 32.0, top: 16.0, bottom: 16.0),
                    child: Text(
                        'Background Image Blurriness: ${globalNotifier.currentBackgroundImageBlurriness.toStringAsFixed(1)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 32.0, top: 16.0, bottom: 16.0),
                    child: Slider(
                      value: globalNotifier.currentBackgroundImageBlurriness,
                      onChanged: (double blurriness) {
                        globalNotifier.setBackgroundImageBlurriness(blurriness);
                      },
                      min: 0.0,
                      max: 20.0,
                      divisions: 200,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
