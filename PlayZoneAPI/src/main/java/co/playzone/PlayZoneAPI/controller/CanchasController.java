package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.CanchasDTO;
import co.playzone.PlayZoneAPI.dto.CrearCanchaReq;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.service.CanchasServicio;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/canchas")
@CrossOrigin(origins = "*")
public class CanchasController {

	private final CanchasServicio canchaServicio;

	public CanchasController(CanchasServicio canchaServicio) {
		this.canchaServicio = canchaServicio;
	}

	// GET todas las canchas
	@GetMapping
	public ResponseEntity<List<CanchasDTO>> obtenerTodas() {
		List<CanchasDTO> lista = canchaServicio.listarTodas().stream().map(this::toDTO).toList();
		return ResponseEntity.ok(lista);
	}

	// ✅ NUEVO: canchas de un propietario específico
	@GetMapping("/propietario/{usuarioId}")
	public ResponseEntity<List<CanchasDTO>> obtenerPorPropietario(@PathVariable Long usuarioId) {
		List<CanchasDTO> lista = canchaServicio.listarPorPropietario(usuarioId).stream().map(this::toDTO).toList();
		return ResponseEntity.ok(lista);
	}

	@PostMapping
	public ResponseEntity<CanchasDTO> crear(@RequestBody CrearCanchaReq request) {
		System.out.println("DEBUG - Nombre: " + request.nombre());
		System.out.println("DEBUG - PropietarioId: " + request.propietarioId());

		Canchas guardada = canchaServicio.crearConPropietario(request);
		if (guardada != null) {
			return ResponseEntity.status(201).body(toDTO(guardada));
		}
		return ResponseEntity.internalServerError().build();
	}

	// Método privado para convertir entidad → DTO
	private CanchasDTO toDTO(Canchas c) {
		return new CanchasDTO(c.getId(), c.getNombre(), c.getLatitud(), c.getLongitud(), c.getDisponibilidad());
	}
}
