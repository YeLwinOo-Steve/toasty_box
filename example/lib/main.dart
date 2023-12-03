import 'package:flutter/material.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toasty Box Example'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.tonal(
              onPressed: () {
                ToastService.showToast(
                  context,
                  length: ToastLength.medium,
                  expandedHeight: 100,
                  message: "This is a message toast 👋😎!"
                );
              },
              child: const Text('Show Message Toast'),
            ),
            const SizedBox(height: 50,),
            FilledButton(
              onPressed: () {
                ToastService.showToast(
                  context,
                  length: ToastLength.ages,
                  expandedHeight: 150,
                  child: ListTile(
                    leading: const SizedBox(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.celebration,
                        color: Colors.deepOrange,
                        size: 30,
                      ),
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Hi there!'),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${++i}',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text('This is my beautiful toast'),
                  ),
                );
              },
              child: const Text('Show Widget Toast'),
            ),
          ],
        ),
      ),
    );
  }
}
