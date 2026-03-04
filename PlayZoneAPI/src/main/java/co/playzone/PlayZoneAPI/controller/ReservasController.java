package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.ReservaDTO;
import co.playzone.PlayZoneAPI.dto.ReservaRequestDTO;
import co.playzone.PlayZoneAPI.dto.ReservaResponse;
import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import co.playzone.PlayZoneAPI.service.ReservaServicio;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/reservas")
public class ReservasController {

	private final ReservaServicio reservaService;

	public ReservasController(ReservaServicio servicio, ReservasRepositorio repo) {
		this.reservaService = servicio;
	}

	@GetMapping("/usuario/{usuarioId}")
	public ResponseEntity<List<ReservaResponse>> obtenerReservasUsuario(@PathVariable("usuarioId") Long usuarioId // <---
																													// Agregamos
																													// ("usuarioId")
	) {
		List<ReservaResponse> reservas = reservaService.listarReservasPorUsuario(usuarioId);
		return ResponseEntity.ok(reservas);
	}

	@PostMapping
	public ResponseEntity<?> crearReserva(@RequestBody ReservaRequestDTO reservaDto) {
		try {
			// Pasamos el ID que viene en el cuerpo del JSON
			Reservas nuevaReserva = reservaService.crearReserva(reservaDto);
			return new ResponseEntity<>(nuevaReserva, HttpStatus.CREATED);
		} catch (RuntimeException e) {
			return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
		}
	}

	@PutMapping("/{id}/cancelar")
	public ResponseEntity<String> cancelarReserva(@PathVariable("id") Long id) {
		reservaService.cancelarReserva(id);
		return ResponseEntity.ok("Reserva cancelada exitosamente y horario liberado.");
	}

	// GET reservas de todas las canchas de un propietario
	@GetMapping("/propietario/{propietarioId}")
	public ResponseEntity<List<ReservaResponse>> obtenerReservasPropietario(
			@PathVariable("propietarioId") Long propietarioId) {
		List<ReservaResponse> reservas = reservaService.listarReservasPorPropietario(propietarioId);
		return ResponseEntity.ok(reservas);
	}
}
