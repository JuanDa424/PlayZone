package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.ReservaDTO;
import co.playzone.PlayZoneAPI.dto.ReservaRequestDTO;
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
	private final ReservasRepositorio reservaRepo;

	public ReservasController(ReservaServicio servicio, ReservasRepositorio repo) {
		this.reservaService = servicio;
		this.reservaRepo = repo;
	}
	/*
	 * @PostMapping public ResponseEntity<ReservaDTO> reservar(@RequestBody
	 * ReservaRequestDTO req) { return
	 * ResponseEntity.ok(servicio.reservarUnaHora(req)); }
	 * 
	 * @GetMapping("/usuario/{usuarioId}") public List<Reservas>
	 * listarPorUsuario(@PathVariable("usuarioId") Long usuarioId) { // Puedes crear
	 * un método repo: // findByUsuario_IdOrderByFechaReservaDescHoraInicioAsc
	 * return repo.findAll().stream().filter(r ->
	 * r.getUsuario().getId().equals(usuarioId)).toList(); }
	 * 
	 * @GetMapping("/cancha/{canchaId}") public List<Reservas>
	 * listarPorCanchaYFecha(@PathVariable("canchaId") Long canchaId,
	 * 
	 * @RequestParam(name = "fecha", required = false) @DateTimeFormat(iso =
	 * DateTimeFormat.ISO.DATE) LocalDate fecha) { if (fecha == null) { return
	 * repo.findAll().stream().filter(r ->
	 * r.getCancha().getId().equals(canchaId)).toList(); } // Ideal: crear repo
	 * method findByCancha_IdAndFechaReservaOrderByHoraInicioAsc return
	 * repo.findAll().stream() .filter(r -> r.getCancha().getId().equals(canchaId)
	 * && r.getFechaReserva().equals(fecha)).toList(); }
	 * 
	 * @DeleteMapping("/{id}") public ResponseEntity<Void> cancelar(@PathVariable
	 * Long id) { if (!repo.existsById(id)) return
	 * ResponseEntity.notFound().build(); repo.deleteById(id); return
	 * ResponseEntity.noContent().build(); }
	 */

	// Endpoint para LISTAR las reservas del usuario autenticado
	@GetMapping
	public ResponseEntity<List<Reservas>> listarReservasUsuario(Principal principal) {

		// 1. Obtener la identidad del usuario a través del token
		String username = principal.getName();

		// 2. Llamar al servicio
		List<Reservas> reservas = reservaService.listarReservasPorUsuario(username);

		// 3. Retornar la lista
		return ResponseEntity.ok(reservas);
	}

	/**
	 * Endpoint para CREAR una nueva reserva. Requiere un Token JWT válido en el
	 * encabezado Authorization. * @param reservaDto Los datos de la reserva
	 * enviados por el cliente.
	 * 
	 * @param principal Objeto de Spring Security que contiene la identidad (email)
	 *                  del usuario autenticado.
	 * @return 201 Created con la Reserva creada, o 400 Bad Request si falla la
	 *         validación.
	 */
	@PostMapping
	public ResponseEntity<?> crearReserva(@RequestBody ReservaRequestDTO reservaDto, Principal principal) {

		// 1. Autorización: Obtenemos el nombre de usuario (email) del token JWT.
		String username = principal.getName();

		try {
			// 2. Ejecutar lógica de negocio (validación, cálculo de precio y persistencia).
			Reservas nuevaReserva = reservaService.crearReserva(reservaDto, username);

			// 3. Respuesta exitosa.
			return new ResponseEntity<>(nuevaReserva, HttpStatus.CREATED);

		} catch (RuntimeException e) {
			// 4. Manejo de excepciones (e.g., Cancha no encontrada, Horario no disponible,
			// Tarifa no definida).
			return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
		}
	}
}
