import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:overlaytest/true_caller_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  requestOverlayPermission();
}

Future<void> requestOverlayPermission() async {
  bool granted = await FlutterOverlayWindow.isPermissionGranted();
  if (!granted) {
    await FlutterOverlayWindow.requestPermission();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? latestMessageFromOverlay;


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print("App is CLOSIIN... topp");

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // Handle when the app goes into background
      print("Overlay App is in background... topp");
      showOverlay(context);
    } else if (state == AppLifecycleState.resumed) {
      // Handle when the app returns to the foreground
      print("Overlay App is back to foreground... topp");
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print(" app is INITINNN topp");

    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameHome,
    );
    log("$res: OVERLAY");
    _receivePort.listen((message) {
      log("Message from OVERLAY: $message");
      setState(() {
        latestMessageFromOverlay = 'Latest Message From Overlay: $message';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  Offset offset = const Offset(20, 40);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    print("APP DESTROYED");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      print("App is closing...");


    } else if (state == AppLifecycleState.paused) {
      print("App is in background...");


    }

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Overlay Example")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed:() {
                requestPermission();
              }, child: Text("Request Permission")),
              ElevatedButton(
                onPressed: ()  {
                  showOverlay(context);
                },
                child: const Text("Show Overlay"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FlutterOverlayWindow.closeOverlay();
                },
                child: const Text("Close Overlay"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showOverlay(context)async{
  bool? permissionGranted =
  await FlutterOverlayWindow.isPermissionGranted();

  if (permissionGranted!) {
    await FlutterOverlayWindow.showOverlay(
      alignment: OverlayAlignment.center,
      height: (MediaQuery.of(context).size.height * 0.6).toInt(),
      width: WindowSize.matchParent,
      overlayContent: "truecaller_overlay", // Unique name
      enableDrag: true,
      visibility: NotificationVisibility.visibilityPublic,
    );
  }
}

void requestPermission()async{
  bool? permissionGranted =
      await FlutterOverlayWindow.isPermissionGranted();
  if (!permissionGranted) {
    permissionGranted =
        await FlutterOverlayWindow.requestPermission();
  }
}
/// The entry point for the overlay window.



void overlayMain() {
  runApp(const OverlayApp());
}

/// The UI displayed in the overlay window.
class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print(" app is INITINNN");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print("App is CLOSIIN...");

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // Handle when the app goes into background
      print("Overlay App is in background...");
    } else if (state == AppLifecycleState.resumed) {
      // Handle when the app returns to the foreground
      print("Overlay App is back to foreground...");
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: TrueCallerOverlay(),
      ),
    );
  }
}