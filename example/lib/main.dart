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

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Toast Example'),
      ),
      body: Center(
        child: FilledButton.tonal(
          onPressed: () {
            ToastService.showToast(context, 'Hello, Custom Toast!');
          },
          child: const Text('Show Custom Toast'),
        ),
      ),
    );
  }
}
