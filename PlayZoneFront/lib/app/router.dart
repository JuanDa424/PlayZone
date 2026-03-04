import 'package:go_router/go_router.dart';
import 'package:play_zone1/models/usuario.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'recover_page.dart';
import 'main_page.dart';
import '../app/main_admin_canchas.dart';
import '../app/main_admin_app.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/registro', builder: (context, state) => const RegisterPage()),
    GoRoute(path: '/recuperar', builder: (context, state) => const RecoverPage()),

    // ROL: CLIENTE
    GoRoute(
      path: '/main',
      builder: (context, state) {
        final usuario = state.extra as Usuario;
        return MainPage(usuario: usuario);
      },
    ),

    // ROL: CANCHA_ADMIN ✅ ahora pasa el usuario correctamente
    GoRoute(
      path: '/main_admin_canchas',
      builder: (context, state) {
        final usuario = state.extra as Usuario;
        return PropietarioAdminPage(usuario: usuario);
      },
    ),

    // ROL: APP_ADMIN
    GoRoute(
      path: '/main_admin_app',
      builder: (context, state) => const MainAdminAppPage(),
    ),
  ],
);