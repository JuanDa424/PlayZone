package co.playzone.PlayZoneAPI.controller;

import java.time.LocalDateTime;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;
import co.playzone.PlayZoneAPI.dto.AuthResponseDTO;
import co.playzone.PlayZoneAPI.dto.auth.AuthenticationResponse;
import co.playzone.PlayZoneAPI.dto.auth.LoginRequest;
import co.playzone.PlayZoneAPI.dto.auth.RegisterRequest;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import co.playzone.PlayZoneAPI.security.JwtService;
import co.playzone.PlayZoneAPI.service.AuthenticationService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

	private final AuthenticationService authenticationService;
	private final AuthenticationManager authenticationManager;
	private final JwtService jwtService;
	private final UsuariosRepositorio usuariosRepositorio;

	public AuthController(AuthenticationService authenticationService, AuthenticationManager authenticationManager,
			JwtService jwtService, UsuariosRepositorio usuariosRepositorio) {
		this.authenticationService = authenticationService;
		this.authenticationManager = authenticationManager;
		this.jwtService = jwtService;
		this.usuariosRepositorio = usuariosRepositorio;
	}

	@PostMapping("/register")
	public ResponseEntity<AuthenticationResponse> register(@Valid @RequestBody RegisterRequest request) {
		Usuarios user = authenticationService.createUser(request);

		// Enviar código de verificación al correo
		authenticationService.sendVerificationCode(user);

		// No hacemos login automático si queremos obligar a verificar
		AuthenticationResponse response = new AuthenticationResponse();
		response.setToken(""); // Token vacío hasta que verifique
		return ResponseEntity.ok(response);
	}

	@PostMapping("/login")
	public ResponseEntity<AuthResponseDTO> login(@RequestBody LoginRequest request) {
		Authentication auth = authenticationManager
				.authenticate(new UsernamePasswordAuthenticationToken(request.getCorreo(), request.getPassword()));

		Usuarios usuario = (Usuarios) auth.getPrincipal();

		if (!usuario.isEmailVerified()) {
			throw new RuntimeException("EMAIL_NOT_VERIFIED");
		}

		String token = jwtService.generateToken(usuario);

		AuthResponseDTO dto = new AuthResponseDTO();
		dto.setId(usuario.getId());
		dto.setNombre(usuario.getNombre());
		dto.setCorreo(usuario.getCorreo());
		dto.setRole(usuario.getRol().getCodigo());
		dto.setJwtToken(token);

		return ResponseEntity.ok(dto);
	}

	@PostMapping("/resend-verification")
	public ResponseEntity<?> resendVerification(@RequestBody Map<String, String> request) {
		String email = request.get("email");
		authenticationService.resendVerificationCode(email);
		return ResponseEntity.ok(Map.of("message", "Verification code sent"));
	}

	@PostMapping("/verify-code")
	public ResponseEntity<?> verifyCode(@RequestBody Map<String, String> request) {
		String email = request.get("email");
		String code = request.get("code");

		Usuarios user = usuariosRepositorio.findByCorreo(email)
				.orElseThrow(() -> new RuntimeException("User not found"));

		if (user.isEmailVerified()) {
			return ResponseEntity.badRequest().body(Map.of("message", "Email already verified"));
		}

		if (!code.equals(user.getVerificationCode())) {
			return ResponseEntity.badRequest().body(Map.of("message", "Invalid code"));
		}

		if (user.getVerificationExpiry().isBefore(LocalDateTime.now())) {
			return ResponseEntity.badRequest().body(Map.of("message", "Code expired"));
		}

		user.setEmailVerified(true);
		user.setVerificationCode(null);
		user.setVerificationExpiry(null);
		usuariosRepositorio.save(user);

		return ResponseEntity.ok(Map.of("message", "Email verified successfully"));
	}
}