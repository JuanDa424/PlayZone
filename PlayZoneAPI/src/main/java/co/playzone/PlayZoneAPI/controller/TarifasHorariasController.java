package co.playzone.PlayZoneAPI.controller;

import java.math.BigDecimal;
import java.net.URI;
import java.time.LocalTime;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import co.playzone.PlayZoneAPI.dto.CrearTarifaHorariaReq;
import co.playzone.PlayZoneAPI.dto.TarifasHorariasDTO;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.TarifasHorarias;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.TarifasHorariasRepositorio;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/tarifas")
public class TarifasHorariasController {

	private final TarifasHorariasRepositorio repo;
	private final CanchasRepositorio canchas;

	public TarifasHorariasController(TarifasHorariasRepositorio repo, CanchasRepositorio canchas) {
		this.repo = repo;
		this.canchas = canchas;
	}

	@PostMapping
	public ResponseEntity<TarifasHorariasDTO> crear(@Valid @RequestBody CrearTarifaHorariaReq r) {
		Canchas c = canchas.findById(r.canchaId())
				.orElseThrow(() -> new IllegalArgumentException("Cancha no encontrada"));
		TarifasHorarias t = new TarifasHorarias();
		t.setCancha(c);
		t.setDiaSemana(r.diaSemana());
		t.setHoraInicio(LocalTime.parse(r.horaInicio()));
		t.setHoraFin(LocalTime.parse(r.horaFin()));
		t.setPrecioHora(new BigDecimal(r.precioHora()));
		t = repo.save(t);
		var dto = new TarifasHorariasDTO(t.getId(), c.getId(), t.getDiaSemana(), t.getHoraInicio().toString(),
				t.getHoraFin().toString(), t.getPrecioHora());

		return ResponseEntity.created(URI.create("/tarifas/" + t.getId())).body(dto);
	}

	@GetMapping("/cancha/{canchaId}")
	public List<TarifasHorariasDTO> listarPorCancha(@PathVariable("canchaId") Long canchaId,
			@RequestParam(name = "dia", required = false) Short dia) {
		if (dia == null) {
			return repo.findAll().stream().filter(t -> t.getCancha().getId().equals(canchaId))
					.map(t -> new TarifasHorariasDTO(t.getId(), canchaId, t.getDiaSemana(),
							t.getHoraInicio().toString(), t.getHoraFin().toString(), t.getPrecioHora()))
					.toList();
		}
		return repo.findByCancha_IdAndDiaSemanaOrderByHoraInicioAsc(canchaId, dia).stream()
				.map(t -> new TarifasHorariasDTO(t.getId(), canchaId, t.getDiaSemana(), t.getHoraInicio().toString(),
						t.getHoraFin().toString(), t.getPrecioHora()))
				.toList();
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> eliminar(@PathVariable Long id) {
		if (!repo.existsById(id))
			return ResponseEntity.notFound().build();
		repo.deleteById(id);
		return ResponseEntity.noContent().build();
	}
}
