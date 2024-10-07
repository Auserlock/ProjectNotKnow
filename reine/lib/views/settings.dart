import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reine/notifiers/global_notifiers.dart';

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
    return Column(
      children: [
        Row(
          children: [
            const Padding(padding: EdgeInsets.all(16.0)),
            const Text('Theme'),
            const Padding(padding: EdgeInsets.all(16.0)),
            DropdownButton<ThemeMode>(
              value: globalNotifier.currentTheme,
              alignment: AlignmentDirectional.center,
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
          ],
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
