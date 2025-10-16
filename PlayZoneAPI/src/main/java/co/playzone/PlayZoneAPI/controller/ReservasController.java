package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.ReservaDTO;
import co.playzone.PlayZoneAPI.dto.ReservaReq;
import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import co.playzone.PlayZoneAPI.service.ReservaServicio;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/reservas")
public class ReservasController {

	private final ReservaServicio servicio;
	private final ReservasRepositorio repo;

	public ReservasController(ReservaServicio servicio, ReservasRepositorio repo) {
		this.servicio = servicio;
		this.repo = repo;
	}

	@PostMapping
	public ResponseEntity<ReservaDTO> reservar(@RequestBody ReservaReq req) {
		return ResponseEntity.ok(servicio.reservarUnaHora(req));
	}

	@GetMapping("/usuario/{usuarioId}")
	public List<Reservas> listarPorUsuario(@PathVariable("usuarioId") Long usuarioId) {
		// Puedes crear un método repo:
		// findByUsuario_IdOrderByFechaReservaDescHoraInicioAsc
		return repo.findAll().stream().filter(r -> r.getUsuario().getId().equals(usuarioId)).toList();
	}

	@GetMapping("/cancha/{canchaId}")
	public List<Reservas> listarPorCanchaYFecha(@PathVariable("canchaId") Long canchaId,
			@RequestParam(name = "fecha", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
		if (fecha == null) {
			return repo.findAll().stream().filter(r -> r.getCancha().getId().equals(canchaId)).toList();
		}
		// Ideal: crear repo method findByCancha_IdAndFechaReservaOrderByHoraInicioAsc
		return repo.findAll().stream()
				.filter(r -> r.getCancha().getId().equals(canchaId) && r.getFechaReserva().equals(fecha)).toList();
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> cancelar(@PathVariable Long id) {
		if (!repo.existsById(id))
			return ResponseEntity.notFound().build();
		repo.deleteById(id);
		return ResponseEntity.noContent().build();
	}
}
