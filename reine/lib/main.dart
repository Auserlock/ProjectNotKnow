import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reine/notifiers/global_notifiers.dart';
import 'package:reine/views/insert.dart';
import 'package:reine/views/search.dart';
import 'package:reine/views/settings.dart';
import 'package:window_manager/window_manager.dart';

import 'views/views.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(800, 600));

  runApp(
    ChangeNotifierProvider<GlobalNotifiers>(
        create: (context) => GlobalNotifiers(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Consumer<GlobalNotifiers>(
      builder: (context, globalNotifier, child) => MaterialApp(
            title: 'Reine',
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blueAccent, brightness: Brightness.dark),
              useMaterial3: true,
            ),
            themeMode: globalNotifier.currentTheme,
            debugShowCheckedModeBanner: false,
            home: const MyHomePage(title: ''),
          ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var globalNotifier = Provider.of<GlobalNotifiers>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(globalNotifier.currentPageName),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            const DrawerHeader(
              margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Text('Options'),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Insert'),
                    onTap: () {
                      setState(() {
                        globalNotifier.setCurrentPage(CurrentView.insert);
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Search'),
                    onTap: () {
                      setState(() {
                        globalNotifier.setCurrentPage(CurrentView.search);
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('Settings'),
                    onTap: () {
                      setState(() {
                        globalNotifier.setCurrentPage(CurrentView.settings);
                        Navigator.pop(context);
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.all(16.0)),
            IndexedStack(
              index: globalNotifier.currentPage.index,
              children: const [
                InsertView(),
                SearchView(),
                SettingsView(),
              ],
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
          ],
        ),
      ),
    );
  }
}
