import 'package:flutter/material.dart';
import 'app/bootstrap.dart';
import 'app/router.dart';
import 'shared/brand.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const PlayZoneApp());
}

class PlayZoneApp extends StatelessWidget {
  const PlayZoneApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlayZone',
      theme: Brand.theme(),
      routerConfig: router,
    );
  }
}
