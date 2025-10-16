package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.auth.RegisterRequest;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.service.AuthenticationService;
import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/api/admin/users")
public class AdminController {

	private final AuthenticationService authenticationService;

	// Inyección manual por constructor
	public AdminController(AuthenticationService authenticationService) {
		this.authenticationService = authenticationService;
	}

	@PostMapping
	// LÍNEA DE SEGURIDAD CLAVE: Solo usuarios con rol 'APP_ADMIN' pueden ejecutar
	// este método.
	@PreAuthorize("hasRole('APP_ADMIN')")
	public ResponseEntity<Usuarios> createAdminUser(@Valid @RequestBody RegisterRequest request) {
		// Llama al mismo servicio que usa el registro público
		Usuarios newUser = authenticationService.createUser(request);
		return ResponseEntity.ok(newUser);
	}
}