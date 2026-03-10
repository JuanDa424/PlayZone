// co/playzone/PlayZoneAPI/controller/RecuperarPasswordController.java
package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.service.RecuperarPasswordServicio;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class RecuperarPasswordController {

	private final RecuperarPasswordServicio servicio;

	public RecuperarPasswordController(RecuperarPasswordServicio servicio) {
		this.servicio = servicio;
	}

	// ── 1. Solicitar código ───────────────────────────────────────
	// POST /api/auth/recuperar-password
	// Body: { "correo": "usuario@mail.com" }
	@PostMapping("/recuperar-password")
	public ResponseEntity<String> solicitarCodigo(@RequestBody Map<String, String> body) {
		try {
			String correo = body.get("correo");
			if (correo == null || correo.isBlank())
				return ResponseEntity.badRequest().body("El correo es requerido.");
			servicio.solicitarCodigo(correo.trim().toLowerCase());
			return ResponseEntity.ok("Código enviado al correo.");
		} catch (RuntimeException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		}
	}

	// ── 2. Verificar código ───────────────────────────────────────
	// POST /api/auth/verificar-codigo-reset
	// Body: { "correo": "...", "codigo": "123456" }
	@PostMapping("/verificar-codigo-reset")
	public ResponseEntity<String> verificarCodigo(@RequestBody Map<String, String> body) {
		try {
			String correo = body.get("correo");
			String codigo = body.get("codigo");
			boolean valido = servicio.verificarCodigo(correo.trim().toLowerCase(), codigo);
			if (valido)
				return ResponseEntity.ok("Código válido.");
			return ResponseEntity.badRequest().body("Código inválido o expirado.");
		} catch (Exception e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		}
	}

	// ── 3. Cambiar contraseña ─────────────────────────────────────
	// POST /api/auth/cambiar-password
	// Body: { "correo": "...", "codigo": "123456", "nuevaPassword": "..." }
	@PostMapping("/cambiar-password")
	public ResponseEntity<String> cambiarPassword(@RequestBody Map<String, String> body) {
		try {
			String correo = body.get("correo");
			String codigo = body.get("codigo");
			String nuevaPassword = body.get("nuevaPassword");
			servicio.cambiarPassword(correo.trim().toLowerCase(), codigo, nuevaPassword);
			return ResponseEntity.ok("Contraseña actualizada correctamente.");
		} catch (RuntimeException e) {
			return ResponseEntity.badRequest().body(e.getMessage());
		}
	}
}