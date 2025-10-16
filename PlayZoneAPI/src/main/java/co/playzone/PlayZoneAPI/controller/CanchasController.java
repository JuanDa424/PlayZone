package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.CanchasDTO;
import co.playzone.PlayZoneAPI.dto.CrearCanchaReq;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/canchas")
public class CanchasController {

	private final CanchasRepositorio repo;

	public CanchasController(CanchasRepositorio repo) {
		this.repo = repo;
	}

	@PostMapping
	public ResponseEntity<CanchasDTO> crear(@Valid @RequestBody CrearCanchaReq r) {
		Canchas c = new Canchas(null, r.nombre(), r.direccion(), r.ciudad(),
				r.disponibilidad() == null ? Boolean.TRUE : r.disponibilidad());
		c = repo.save(c);
		var dto = new CanchasDTO(c.getId(), c.getNombre(), c.getDireccion(), c.getCiudad(), c.getDisponibilidad());
		return ResponseEntity.created(URI.create("/canchas/" + c.getId())).body(dto);
	}

	@GetMapping
	public List<CanchasDTO> listar() {
		return repo.findAll().stream().map(
				c -> new CanchasDTO(c.getId(), c.getNombre(), c.getDireccion(), c.getCiudad(), c.getDisponibilidad()))
				.toList();
	}

	@GetMapping("/{id}")
	public ResponseEntity<CanchasDTO> obtener(@PathVariable("id") Long id) {
		return repo.findById(id).map(c -> ResponseEntity
				.ok(new CanchasDTO(c.getId(), c.getNombre(), c.getDireccion(), c.getCiudad(), c.getDisponibilidad())))
				.orElse(ResponseEntity.notFound().build());
	}
	/*
	 * @PatchMapping("/{id}/disponibilidad") public ResponseEntity<Void>
	 * cambiarDisponibilidad(@PathVariable("id") Long id,
	 * 
	 * @RequestParam("disponible") boolean disponible) { return repo.findById(id)
	 * .map(c -> { c.setDisponibilidad(disponible); repo.save(c); return
	 * ResponseEntity.<Void>noContent().build(); // <Void> correcto }) .orElseGet(()
	 * -> ResponseEntity.<Void>notFound().build()); // <Void> correcto }
	 */

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> eliminar(@PathVariable Long id) {
		if (!repo.existsById(id))
			return ResponseEntity.notFound().build();
		repo.deleteById(id);
		return ResponseEntity.noContent().build();
	}
}
