import 'package:flutter/material.dart';
import 'app/bootstrap.dart';
import 'app/router.dart';
import 'shared/brand.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await bootstrap();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CO', null); 
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
      debugShowCheckedModeBanner: false,

    );
  }
}
