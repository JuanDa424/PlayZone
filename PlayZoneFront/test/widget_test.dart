import 'package:flutter_test/flutter_test.dart';
import 'package:play_zone/main.dart';

void main() {
  testWidgets('Login carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PlayZoneApp());
    expect(find.text('Iniciar sesión'), findsOneWidget);
    // Puedes agregar más expectativas del login aquí.
  });
}
