package co.playzone.PlayZoneAPI.service;

import co.playzone.PlayZoneAPI.dto.auth.LoginRequest;
import co.playzone.PlayZoneAPI.dto.auth.RegisterRequest;
import co.playzone.PlayZoneAPI.model.Rol; // Asumiendo que tienes una entidad Rol
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import co.playzone.PlayZoneAPI.security.JwtService;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthenticationService {

	private final UsuariosRepositorio usuariosRepository;
	private final RolRepositorio rolRepository; // Asegúrate de crear este repositorio
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;
	private final AuthenticationManager authenticationManager;

	public AuthenticationService(UsuariosRepositorio usuariosRepository, RolRepositorio rolRepository,
			PasswordEncoder passwordEncoder, JwtService jwtService, AuthenticationManager authenticationManager) {

		// Asignación de cada campo final
		this.usuariosRepository = usuariosRepository;
		this.rolRepository = rolRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtService = jwtService;
		this.authenticationManager = authenticationManager;
	}

	// MÉTODO GENÉRICO PARA CREAR CUALQUIER USUARIO
	public Usuarios createUser(RegisterRequest request) {

		System.out.println(request.getRolNombre());
		// 1. Buscar el Rol solicitado (APP_ADMIN, CANCHA_ADMIN, CLIENTE)
		Rol rolSolicitado = rolRepository.findByCodigo(request.getRolNombre())
				.orElseThrow(() -> new RuntimeException("Rol no válido: " + request.getRolNombre()));

		var user = new Usuarios(null, // 1. Long id: null, ya que la BD lo genera (IDENTITY)
				request.getNombre(), // 2. String nombre: Del request
				request.getCorreo(), // 3. String correo: Del request
				request.getTelefono(), // 4. String telefono: Del request (debe estar en el DTO)
				passwordEncoder.encode(request.getPassword()), // 5. String password: Encriptada
				rolSolicitado, // 6. Rol rol: El objeto Rol encontrado
				LocalDateTime.now() // 7. LocalDateTime fechaRegistro: La fecha actual
		);

		// 3. Guardar el usuario en la BD
		return usuariosRepository.save(user);
	}

	// --- Lógica de LOGIN ---
	public String login(LoginRequest request) {

		System.out.println("ENTRA EN EL SERVICIO DE LOGIN");
		try {
			// 1. Autenticar credenciales usando el AuthenticationManager
			System.out.println("ENTRA AL TRY");
			authenticationManager
					.authenticate(new UsernamePasswordAuthenticationToken(request.getCorreo(), request.getPassword()));
			System.out.println(request.getCorreo());
			System.out.println(request.getPassword());

		} catch (AuthenticationException e) {
			// Capturamos cualquier error de autenticación (contraseña incorrecta, usuario
			// no existe)
			// y lo relanzamos como una excepción que Spring manejará (ej. 401 Unauthorized)
			throw new BadCredentialsException("Correo o contraseña incorrectos.", e);
		}

		// 2. Si la autenticación fue exitosa, cargar el usuario de la BD
		// Usamos 'var user = (Usuarios) ...' para mayor seguridad en el tipo si fuera
		// necesario,
		// pero con 'var' basta si el repositorio devuelve el tipo correcto.
		Usuarios user = usuariosRepository.findByCorreo(request.getCorreo()).orElseThrow(); // Ya sabemos que existe, si
																							// AuthenticationManager no
																							// lanzó error

		// 3. Generar el Token JWT
		return jwtService.generateToken(user);
	}
}