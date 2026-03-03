package co.playzone.PlayZoneAPI.controller;

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

	@GetMapping
	public ResponseEntity<List<Canchas>> obtenerTodas() {
		List<Canchas> lista = canchaServicio.listarTodas();
		return ResponseEntity.ok().header("Content-Type", "application/json").body(lista);
	}

	@PostMapping("/crear")
	public ResponseEntity<Canchas> crear(@RequestBody Canchas cancha) {
		// 1. Verificamos que los datos llegaron al controlador
		System.out.println("DEBUG - Nombre recibido: " + cancha.getNombre());
		System.out.println("DEBUG - Latitud recibida: " + cancha.getLatitud());

		Canchas guardada = canchaServicio.guardar(cancha);

		// 2. Verificamos que se guardó y generó un ID
		if (guardada != null) {
			System.out.println("DEBUG - Guardado exitoso con ID: " + guardada.getId());
			return ResponseEntity.status(201).body(guardada); // 201 es mejor para creación
		} else {
			System.out.println("DEBUG - Falló el guardado, el objeto es null");
			return ResponseEntity.internalServerError().build();
		}
	}

}
