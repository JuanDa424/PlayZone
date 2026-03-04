package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.auth.AuthenticationResponse;
import co.playzone.PlayZoneAPI.dto.auth.LoginRequest;
import co.playzone.PlayZoneAPI.dto.auth.RegisterRequest;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import co.playzone.PlayZoneAPI.security.JwtService;
import co.playzone.PlayZoneAPI.service.AuthenticationService;
import co.playzone.PlayZoneAPI.dto.AuthResponseDTO;

import jakarta.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.authentication.AuthenticationManager;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

	private static final Logger logger = LoggerFactory.getLogger(AdminController.class);

	private final AuthenticationService authenticationService;
	private final AuthenticationManager authenticationManager;
	private final JwtService jwtService; // O tu servicio de JWT
	private final UsuariosRepositorio usuariosRepositorio; // O tu repositorio de usuarios

	// --- CONSTRUCTOR CORREGIDO ---
	public AuthController(AuthenticationService authenticationService, AuthenticationManager authenticationManager,
			JwtService jwtService, UsuariosRepositorio usuariosRepositorio) {
		// Asignación de TODOS los campos 'final'
		this.authenticationService = authenticationService;
		this.authenticationManager = authenticationManager;
		this.jwtService = jwtService;
		this.usuariosRepositorio = usuariosRepositorio;
	}

	// --- ENDPOINT DE REGISTRO PÚBLICO ---
	@PostMapping("/register")
	public ResponseEntity<AuthenticationResponse> register(@Valid @RequestBody RegisterRequest request) {
		// 1. Crear el usuario
		System.out.println("ENTRA AL METODO CREAR");
		authenticationService.createUser(request);

		// 2. Crear el objeto LoginRequest de manera tradicional
		// Asumiendo que tienes un constructor o setters en LoginRequest
		LoginRequest loginReq = new LoginRequest(request.getCorreo(), request.getPassword());

		// 3. Autenticar y generar el token JWT
		String token = authenticationService.login(loginReq);

		// 4. Retornar el token al cliente creando AuthenticationResponse de manera
		// tradicional
		AuthenticationResponse response = new AuthenticationResponse();
		response.setToken(token); // Asumiendo que usas un setter

		return ResponseEntity.ok(response);
	}

	// --- ENDPOINT DE INICIO DE SESIÓN ---
	@PostMapping("/login")
	public ResponseEntity<AuthResponseDTO> login(@RequestBody LoginRequest request) {
		// 1. Autenticar y obtener el objeto Authentication
		Authentication authentication = authenticationManager
				.authenticate(new UsernamePasswordAuthenticationToken(request.getCorreo(), request.getPassword()));

		// 2. Obtener la entidad Usuario (la que implementa UserDetails)
		Usuarios usuario = (Usuarios) authentication.getPrincipal();

		// 3. Generar el token
		String token = jwtService.generateToken(usuario);

		// 4. CONSTRUIR EL DTO DE RESPUESTA
		AuthResponseDTO responseDTO = new AuthResponseDTO();
		responseDTO.setId(usuario.getId());
		responseDTO.setNombre(usuario.getNombre());
		responseDTO.setCorreo(usuario.getCorreo());

		// El rol viene de getAuthorities (que ya tiene el prefijo ROLE_ que debes
		// quitar)
		String role = usuario.getRol().getCodigo(); // Asumo que getRol() te da el objeto
		responseDTO.setRole(role);

		responseDTO.setJwtToken(token); // El token completo

		// 5. Devolver el DTO con el código 200
		return ResponseEntity.ok(responseDTO);
	}
}