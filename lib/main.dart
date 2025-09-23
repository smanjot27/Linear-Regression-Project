import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showImageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Image Preview'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Changed from Image.network to Image.asset
                // and updated the image path to 'IMG_0341.jpeg'.
                // Removed loadingBuilder and errorBuilder as they are not applicable for Image.asset.
                Image.asset(
                  'assets/IMG_0341.jpeg',
                  // Ensure 'IMG_0341.jpeg' is correctly specified in pubspec.yaml under assets:
                  // For example:
                  // flutter:
                  //   assets:
                  //     - IMG_0341.jpeg
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom UI Application'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showImageDialog(context),
          child: const Text('Show Image Dialog'),
        ),
      ),
    );
  }
}