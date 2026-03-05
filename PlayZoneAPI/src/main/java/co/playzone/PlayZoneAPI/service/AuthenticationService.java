package co.playzone.PlayZoneAPI.service;

import java.time.LocalDateTime;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import co.playzone.PlayZoneAPI.dto.auth.LoginRequest;
import co.playzone.PlayZoneAPI.dto.auth.RegisterRequest;
import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import co.playzone.PlayZoneAPI.security.JwtService;

@Service
public class AuthenticationService {

	private final UsuariosRepositorio usuariosRepository;
	private final RolRepositorio rolRepository;
	private final PasswordEncoder passwordEncoder;
	private final JwtService jwtService;
	private final AuthenticationManager authenticationManager;
	private final EmailService emailService; // Debes tener un servicio que envíe mails

	public AuthenticationService(UsuariosRepositorio usuariosRepository, RolRepositorio rolRepository,
			PasswordEncoder passwordEncoder, JwtService jwtService, AuthenticationManager authenticationManager,
			EmailService emailService) {
		this.usuariosRepository = usuariosRepository;
		this.rolRepository = rolRepository;
		this.passwordEncoder = passwordEncoder;
		this.jwtService = jwtService;
		this.authenticationManager = authenticationManager;
		this.emailService = emailService;
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

	public void sendVerificationCode(Usuarios user) {
		String code = generate6DigitCode();
		user.setVerificationCode(code);
		user.setVerificationExpiry(LocalDateTime.now().plusMinutes(10));
		usuariosRepository.save(user);

		emailService.sendVerificationEmail(user.getCorreo(), code);
	}

	public void resendVerificationCode(String email) {
		Usuarios user = usuariosRepository.findByCorreo(email)
				.orElseThrow(() -> new RuntimeException("User not found"));

		if (user.isEmailVerified()) {
			throw new RuntimeException("Email already verified");
		}

		sendVerificationCode(user);
	}

	private String generate6DigitCode() {
		int number = (int) (Math.random() * 900000) + 100000;
		return String.valueOf(number);
	}

	public String login(LoginRequest request) {
		authenticationManager
				.authenticate(new UsernamePasswordAuthenticationToken(request.getCorreo(), request.getPassword()));

		Usuarios user = usuariosRepository.findByCorreo(request.getCorreo()).orElseThrow();

		if (!user.isEmailVerified()) {
			throw new RuntimeException("EMAIL_NOT_VERIFIED");
		}

		return jwtService.generateToken(user);
	}
}