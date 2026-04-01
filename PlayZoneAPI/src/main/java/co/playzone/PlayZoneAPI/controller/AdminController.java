// co/playzone/PlayZoneAPI/controller/AdminController.java
package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.AdminReservaDTO;
import co.playzone.PlayZoneAPI.dto.AdminStatsDTO;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

	private final UsuariosRepositorio usuariosRepo;
	private final CanchasRepositorio canchasRepo;
	private final ReservasRepositorio reservasRepo;

	@Autowired
	private RolRepositorio rolRepositorio;
	@Autowired
	private PasswordEncoder passwordEncoder;

	public AdminController(UsuariosRepositorio usuariosRepo, CanchasRepositorio canchasRepo,
			ReservasRepositorio reservasRepo) {
		this.usuariosRepo = usuariosRepo;
		this.canchasRepo = canchasRepo;
		this.reservasRepo = reservasRepo;
	}

	// ── GET /api/admin/stats ──────────────────────────────────────
	@GetMapping("/stats")
	public ResponseEntity<AdminStatsDTO> getStats() {
		long totalUsuarios = usuariosRepo.count();
		long totalCanchas = canchasRepo.count();

		List<Reservas> todasReservas = reservasRepo.findAll();
		long totalReservas = todasReservas.size();

		LocalDate hoy = LocalDate.now();
		long reservasHoy = todasReservas.stream().filter(r -> hoy.equals(r.getFechaReserva())).count();

		long reservasActivas = todasReservas.stream().filter(r -> "RESERVADO".equalsIgnoreCase(r.getEstado())).count();

		long reservasCanceladas = todasReservas.stream().filter(r -> "CANCELADA".equalsIgnoreCase(r.getEstado()))
				.count();

		BigDecimal ingresosTotales = todasReservas.stream().filter(r -> !"CANCELADA".equalsIgnoreCase(r.getEstado()))
				.map(Reservas::getTotalPago).reduce(BigDecimal.ZERO, BigDecimal::add);

		BigDecimal ingresosHoy = todasReservas.stream()
				.filter(r -> hoy.equals(r.getFechaReserva()) && !"CANCELADA".equalsIgnoreCase(r.getEstado()))
				.map(Reservas::getTotalPago).reduce(BigDecimal.ZERO, BigDecimal::add);

		return ResponseEntity.ok(new AdminStatsDTO(totalUsuarios, totalCanchas, totalReservas, reservasHoy,
				reservasActivas, reservasCanceladas, ingresosTotales, ingresosHoy));
	}

	// ── GET /api/admin/usuarios ───────────────────────────────────
	@GetMapping("/usuarios")
	public ResponseEntity<List<Usuarios>> getUsuarios() {
		return ResponseEntity.ok(usuariosRepo.findAll());
	}

	// ── GET /api/admin/canchas ────────────────────────────────────
	@GetMapping("/canchas")
	public ResponseEntity<List<Canchas>> getCanchas() {
		return ResponseEntity.ok(canchasRepo.findAll());
	}

	// ── GET /api/admin/reservas ───────────────────────────────────
	@GetMapping("/reservas")
	public ResponseEntity<List<AdminReservaDTO>> getReservas() {
		List<Reservas> reservas = reservasRepo.findAll();
		List<AdminReservaDTO> dtos = reservas.stream()
				.map(r -> new AdminReservaDTO(r.getId(), r.getUsuario().getNombre(), r.getUsuario().getCorreo(),
						r.getCancha().getNombre(), r.getFechaReserva(), r.getHoraInicio(), r.getTotalPago(),
						r.getEstado()))
				.toList();
		return ResponseEntity.ok(dtos);
	}

	// ── PUT /api/admin/reservas/{id}/estado ───────────────────────
	@PutMapping("/reservas/{id}/estado")
	public ResponseEntity<String> cambiarEstadoReserva(@PathVariable Long id, @RequestBody Map<String, String> body) {
		return reservasRepo.findById(id).map(r -> {
			r.setEstado(body.get("estado"));
			reservasRepo.save(r);
			return ResponseEntity.ok("Estado actualizado.");
		}).orElse(ResponseEntity.notFound().build());
	}

	// ── DELETE /api/admin/usuarios/{id} ──────────────────────────
	@DeleteMapping("/usuarios/{id}")
	public ResponseEntity<String> eliminarUsuario(@PathVariable Long id) {
		if (!usuariosRepo.existsById(id)) {
			return ResponseEntity.notFound().build();
		}
		usuariosRepo.deleteById(id);
		return ResponseEntity.ok("Usuario eliminado.");
	}

	// ── PUT /api/admin/canchas/{id}/disponibilidad ────────────────
	@PutMapping("/canchas/{id}/disponibilidad")
	public ResponseEntity<String> toggleDisponibilidad(@PathVariable Long id) {
		return canchasRepo.findById(id).map(c -> {
			c.setDisponibilidad(!c.getDisponibilidad());
			canchasRepo.save(c);
			return ResponseEntity.ok("Disponibilidad actualizada.");
		}).orElse(ResponseEntity.notFound().build());
	}

	@PostMapping("/usuarios/cancha-admin")
	public ResponseEntity<?> crearAdminCancha(@RequestBody Map<String, String> body) {
		try {
			String nombre = body.get("nombre");
			String correo = body.get("correo");
			String password = body.get("password");
			String telefono = body.getOrDefault("telefono", "");

			if (nombre == null || correo == null || password == null) {
				return ResponseEntity.badRequest().body(Map.of("error", "Nombre, correo y password son requeridos"));
			}

			if (usuariosRepo.existsByCorreo(correo)) {
				return ResponseEntity.status(409).body(Map.of("error", "El correo ya está registrado"));
			}

			Rol rolAdmin = rolRepositorio.findByCodigo("CANCHA_ADMIN")
					.orElseThrow(() -> new RuntimeException("Rol CANCHA_ADMIN no encontrado"));

			Usuarios nuevo = new Usuarios(nombre, correo, telefono, passwordEncoder.encode(password), rolAdmin);
			nuevo.setEmailVerified(true);
			usuariosRepo.save(nuevo);

			return ResponseEntity.ok(Map.of("mensaje", "Admin de cancha creado exitosamente"));
		} catch (Exception e) {
			return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
		}
	}
}