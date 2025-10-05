import 'package:flutter/material.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          primary: Colors.black,
          seedColor: Colors.black,
        ),
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
  var tag = 0;

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
            FilledButton(
              onPressed: () {
                tag = tag + 1;
                ToastService.showToast(
                  context,
                  tag: tag,
                  isClosable: true,
                  isAutoDismiss: false,
                  backgroundColor: Colors.teal.shade500,
                  shadowColor: Colors.teal.shade200,
                  length: ToastLength.medium,
                  expandedHeight: 100,
                  message: "This is a message toast 👋😎!$tag",
                  leading: const Icon(Icons.messenger),
                  slideCurve: Curves.elasticInOut,
                  positionCurve: Curves.bounceOut,
                  dismissDirection: DismissDirection.none,
                );
              },
              child: const Text('Show Message Toast'),
            ),
            const SizedBox(
              height: 50,
            ),
            FilledButton(
              onPressed: () {
                ToastService.showWidgetToast(
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
            const SizedBox(
              height: 50,
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ToastService.showSuccessToast(
                  context,
                  length: ToastLength.medium,
                  expandedHeight: 100,
                  message: "This is a success toast 🥂!",
                );
              },
              child: const Text('Show success toast'),
            ),
            const SizedBox(
              height: 50,
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ToastService.showWarningToast(
                  context,
                  length: ToastLength.medium,
                  expandedHeight: 100,
                  message: "This is a warning toast!",
                );
              },
              child: const Text('Show warning toast'),
            ),
            const SizedBox(
              height: 50,
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ToastService.showErrorToast(
                  context,
                  length: ToastLength.medium,
                  expandedHeight: 100,
                  message: "This is an error toast!",
                );
              },
              child: const Text('Show error toast'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ToastService.dismiss(tag: 1);
              },
              child: const Text('dismiss toast'),
            ),
          ],
        ),
      ),
    );
  }
}
