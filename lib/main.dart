import 'package:cameraapp/screens/camerascrn.dart';
import 'package:cameraapp/screens/database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await createDatabase();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CameraScrn(),
  ));
}
