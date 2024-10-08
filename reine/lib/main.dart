import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reine/notifiers/global_notifiers.dart';
import 'package:reine/views/insert.dart';
import 'package:reine/views/search.dart';
import 'package:reine/views/settings.dart';
import 'package:window_manager/window_manager.dart';

import 'notifiers/preferences.dart';
import 'views/views.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(800, 600));

  runApp(
    ChangeNotifierProvider<GlobalNotifiers>(
        create: (context) => GlobalNotifiers()..initApp(),
        child: const MyApp()),
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

    var backgroundColor =
        globalNotifier.currentBackgroundMode == BackgroundMode.pureColor
            ? globalNotifier.currentBackgroundColor
            : null;

    var backgroundImage =
        globalNotifier.currentBackgroundMode == BackgroundMode.image
            ? DecorationImage(
                image: globalNotifier.currentBackgroundImage,
                fit: globalNotifier.currentBackgroundImageFit,
              )
            : null;

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
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: backgroundImage != null
                ? BoxDecoration(image: backgroundImage)
                : null,
          ),
          if (backgroundImage != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: globalNotifier.currentBackgroundImageBlurriness,
                    sigmaY: globalNotifier.currentBackgroundImageBlurriness),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
                      1 - globalNotifier.currentBackgroundImageOpacity),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(16.0)),
                IndexedStack(
                  alignment: Alignment.center,
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
        ],
      ),
    );
  }
}
