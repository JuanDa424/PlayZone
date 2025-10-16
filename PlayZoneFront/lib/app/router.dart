import 'package:go_router/go_router.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'recover_page.dart';
import 'main_page.dart'; 
// Asumo que estos son los nombres correctos de tus clases en los archivos importados
import '../app/main_admin_canchas.dart';
import '../app/main_admin_app.dart'; 


final router = GoRouter(
  routes: [
    // 1. Rutas de Autenticación y Home (Se mantienen sin cambios)
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/recuperar',
      builder: (context, state) => const RecoverPage(),
    ),
    
    // --- RUTAS DE APLICACIÓN TRAS EL LOGIN (Redirigidas por Rol) ---
    
    // 2. Ruta para el ROL 'CLIENTE' (Default)
    // Coincide con el `case 'CLIENTE'` o `default` en LoginPage
    GoRoute(
      path: '/main', 
      builder: (context, state) => const MainPage()
    ),

    // 3. Ruta para el ROL 'CANCHA_ADMIN'
    // Coincide con el `case 'CANCHA_ADMIN'` en LoginPage
    GoRoute(
      path: '/main_admin_canchas',
      // NOTA: Cambié 'PropietarioAdminPage()' por el nombre del widget en tu archivo
      // Si tu widget se llama 'MainAdminCanchasPage', ajústalo aquí.
      builder: (context, state) => const PropietarioAdminPage(), 
    ),

    // 4. Ruta para el ROL 'APP_ADMIN'
    // Coincide con el `case 'APP_ADMIN'` en LoginPage
    GoRoute(
      path: '/main_admin_app',
      // NOTA: Cambié 'MainAdminAppPage()' por el nombre del widget en tu archivo
      // Si tu widget se llama 'MainAdminAppPage', ajústalo aquí.
      builder: (context, state) => const MainAdminAppPage(),
    ),
  ],
);