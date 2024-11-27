import 'package:flutter/material.dart';
import 'package:rubiks_cube/cube_painter.dart';

import 'rubiks_cube.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FlutterFun  Rubik\'s Cube'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  FlutterCube cube = FlutterCube();

  static const Duration duration = Duration(milliseconds: 250);
  late final AnimationController controller;
  late final Animation animation;

  bool isScrambling = false;
  RubiksAxis animateAxis = RubiksAxis.x;
  int animateLayer = 0;
  double animateDirection = 1.0;

  bool showSettings = false;
  bool settingsElasticScramble = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    controller.addStatusListener(handleAnimationCompleted);
    animation = Tween<double>(begin: 0, end: 90)
        .chain(CurveTween(
            curve: settingsElasticScramble
                ? Curves.elasticOut
                : Curves.elasticOut))
        .animate(controller);
    animation.addListener(() {
      setState(() {
        cube.animateRotate(
            animateAxis, animateLayer, animateDirection * animation.value);
      });
    });
    //animation.
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleAnimationCompleted(AnimationStatus status) {
    if (status.isCompleted) {
      cube.finishRotate(animateAxis, animateLayer, animateDirection * 90.0);
      controller.reset();
      if (isScrambling) {
        newScramble();
      }
    }
  }

  void reset() {
    setState(() {
      controller.reset();
      isScrambling = false;
      cube.reset();
    });
  }

  void startScrambling() {
    setState(() {
      isScrambling = true;
      newScramble();
    });
  }

  void stopScrambling() {
    setState(() {
      isScrambling = false;
    });
  }

  void newScramble() {
    controller.reset();
    animateAxis = RubiksAxis.values[Random().nextInt(RubiksAxis.values.length)];
    animateLayer = Random().nextInt(3) - 1;
    animateDirection = (Random().nextInt(2) == 0) ? -1.0 : 1.0;
    controller.forward();
  }

  void animateTest() {
    // setState(() {
    //   cube.animateRotate(RubiksAxis.x, 1, 45.0);
    // });

    controller.forward();
    //controller.dispose();
  }

  void gotoSettings() {
    setState(() {
      showSettings = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: showSettings
            // Following is settings screen
            ? settingsPage(context)
            // Following is main window
            : cubePage(),
      ),
    );
  }

  Center cubePage() {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30),
          Expanded(
            child: CubeWidget(cube),
          ),
          Row(children: <Widget>[
            const SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  animateTest();
                },
                child: const Text('F1')),
            const Spacer(),
            ElevatedButton(onPressed: () {}, child: const Text('F2')),
            const Spacer(),
            ElevatedButton(onPressed: () {}, child: const Text('F3')),
            const Spacer(),
            ElevatedButton(onPressed: () {}, child: const Text('F4')),
            const Spacer(),
            ElevatedButton(onPressed: () {}, child: const Icon(Icons.undo)),
            const SizedBox(width: 10),
          ]),
          const SizedBox(height: 30),
          Row(children: <Widget>[
            const SizedBox(width: 10),
            isScrambling
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // background
                      foregroundColor: Colors.yellow, // foreground
                    ),
                    onPressed: stopScrambling,
                    icon: const Icon(Icons.pause),
                    label: const Text('Scramble'))
                : ElevatedButton.icon(
                    onPressed: startScrambling,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Scramble')),
            const SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  reset();
                },
                child: const Text('Reset')),
            const Spacer(),
            ElevatedButton(
                onPressed: gotoSettings, child: const Icon(Icons.settings)),
            const SizedBox(width: 10),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Column settingsPage(BuildContext context) {
    return Column(children: [
      Row(children: <Widget>[
        IconButton(
            onPressed: () {
              setState(() {
                showSettings = false;
              });
            },
            icon: Icon(Icons.keyboard_arrow_left)),
        const SizedBox(width: 10),
        Text("Settings", style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(
            onPressed: () {
              setState(() {
                showSettings = false;
              });
            },
            icon: Icon(Icons.close)),
      ]),
      Row(children: <Widget>[
        const Text('Show borders'),
        const Spacer(),
        Switch(
          value: cube.showBorders,
          onChanged: (bool value) {
            setState(() {
              cube.showBorders = value;
            });
          },
        ),
      ]),
      Row(children: <Widget>[
        const Text('Show back faces'),
        const Spacer(),
        Switch(
          value: cube.showBackfaces,
          onChanged: (bool value) {
            setState(() {
              cube.showBackfaces = value;
            });
          },
        ),
      ]),
      Row(children: <Widget>[
        const Text('Two color cube'),
        const Spacer(),
        Switch(
          value: cube.showTwoColors,
          onChanged: (bool value) {
            setState(() {
              cube.showTwoColors = value;
            });
          },
        ),
      ]),
      Row(children: <Widget>[
        const Text('Elastic scramble'),
        const Spacer(),
        Switch(
          value: settingsElasticScramble,
          onChanged: (bool value) {
            setState(() {
              settingsElasticScramble = value;
            });
          },
        ),
      ]), //settingsElasticScramble
      TextFormField(
        decoration: const InputDecoration(
          hintText: 'create macro with U,R,F, .... and \'',
          labelText: 'Macro F1',
        ),
        onSaved: (String? value) {
          // This optional block of code can be used to run
          // code when the user saves the form.
        },
        // validator: (String? value) {
        //   return (value != null && value.contains('@'))
        //       ? 'Do not use the @ char.'
        //       : null;
        // },
      )
    ]);
  }
}
