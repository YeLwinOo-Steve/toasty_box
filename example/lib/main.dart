import 'package:flutter/material.dart';
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
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ToastService.showToast(
              context,
              child: const ListTile(
                leading: Icon(Icons.celebration),
                title: Text('Hi there!'),
                subtitle: Text('This is my beautiful toast'),
              ),
            );
          },
          child: const Text('Toast'),
        ),
      ),
    );
  }
}
