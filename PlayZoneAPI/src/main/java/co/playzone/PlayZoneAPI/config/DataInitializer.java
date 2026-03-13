package co.playzone.PlayZoneAPI.config;

import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class DataInitializer implements ApplicationRunner {

	@Autowired
	private RolRepositorio rolRepositorio;

	@Autowired
	private UsuariosRepositorio usuariosRepositorio;

	@Autowired
	private PasswordEncoder passwordEncoder;

	@Override
	public void run(ApplicationArguments args) {
		// 1. Crear roles si no existen
		Rol cliente = crearRolSiNoExiste("CLIENTE", "Cliente");
		Rol canchaAdmin = crearRolSiNoExiste("CANCHA_ADMIN", "Administrador de Cancha");
		Rol appAdmin = crearRolSiNoExiste("APP_ADMIN", "Administrador de la Aplicación");

		// 2. Crear usuarios de prueba si no existen
		crearUsuarioSiNoExiste("Admin App", "admin@playzone.co", "3001000001", "admin123", appAdmin);
		crearUsuarioSiNoExiste("Admin Cancha", "cancha@playzone.co", "3001000002", "cancha123", canchaAdmin);
		crearUsuarioSiNoExiste("Cliente Prueba", "cliente@playzone.co", "3001000003", "cliente123", cliente);
	}

	private Rol crearRolSiNoExiste(String codigo, String nombre) {
		return rolRepositorio.findByCodigo(codigo).orElseGet(() -> {
			Rol rol = new Rol();
			rol.setCodigo(codigo);
			rol.setNombre(nombre);
			Rol saved = rolRepositorio.save(rol);
			return saved;
		});
	}

	private void crearUsuarioSiNoExiste(String nombre, String correo, String telefono, String password, Rol rol) {
		if (!usuariosRepositorio.existsByCorreo(correo)) {
			Usuarios u = new Usuarios(nombre, correo, telefono, passwordEncoder.encode(password), rol);
			u.setEmailVerified(true);
			usuariosRepositorio.save(u);
		}
	}
}