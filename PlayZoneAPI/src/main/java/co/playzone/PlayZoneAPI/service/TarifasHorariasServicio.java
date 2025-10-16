package co.playzone.PlayZoneAPI.service;

import co.playzone.PlayZoneAPI.dto.CrearTarifaHorariaReq;
import co.playzone.PlayZoneAPI.dto.TarifasHorariasDTO;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.TarifasHorarias;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.TarifasHorariasRepositorio;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class TarifasHorariasServicio {

	private final TarifasHorariasRepositorio repo;
	private final CanchasRepositorio canchasRepo;

	// Constructor manual para inyección
	public TarifasHorariasServicio(TarifasHorariasRepositorio repo, CanchasRepositorio canchasRepo) {
		this.repo = repo;
		this.canchasRepo = canchasRepo;
	}

	public List<TarifasHorariasDTO> listarPorCanchaYDia(Long canchaId, Short diaSemana) {
		return repo.findByCancha_IdAndDiaSemanaOrderByHoraInicioAsc(canchaId, diaSemana).stream()
				.map(t -> new TarifasHorariasDTO(t.getId(), t.getCancha().getId(), t.getDiaSemana(),
						t.getHoraInicio().toString(), t.getHoraFin().toString(), t.getPrecioHora()))
				.collect(Collectors.toList());
	}

	@Transactional
	public TarifasHorariasDTO crear(CrearTarifaHorariaReq r) {
		// Validaciones básicas (además de las de @NotNull/@NotBlank del record)
		if (r.diaSemana() == null || r.diaSemana() < 1 || r.diaSemana() > 7) {
			throw new IllegalArgumentException("El día de la semana debe estar entre 1 (Lunes) y 7 (Domingo).");
		}
		if (r.horaInicio() == null || r.horaFin() == null) {
			throw new IllegalArgumentException("Debe especificar horaInicio y horaFin en formato HH:mm:ss.");
		}

		// Buscar cancha
		var cancha = canchasRepo.findById(r.canchaId())
				.orElseThrow(() -> new IllegalArgumentException("La cancha indicada no existe."));

		// Parseo de horas
		var hi = java.time.LocalTime.parse(r.horaInicio());
		var hf = java.time.LocalTime.parse(r.horaFin());
		if (!hi.isBefore(hf)) {
			throw new IllegalArgumentException("La horaInicio debe ser anterior a la horaFin.");
		}

		// Parseo de precio
		java.math.BigDecimal precio;
		try {
			precio = new java.math.BigDecimal(r.precioHora());
			if (precio.signum() < 0)
				throw new IllegalArgumentException("El precioHora no puede ser negativo.");
		} catch (NumberFormatException e) {
			throw new IllegalArgumentException("precioHora inválido. Use formato numérico, ej: 75000.00");
		}

		// Crear y guardar
		var t = new TarifasHorarias();
		t.setCancha(cancha);
		t.setDiaSemana(r.diaSemana());
		t.setHoraInicio(hi);
		t.setHoraFin(hf);
		t.setPrecioHora(precio);

		t = repo.save(t);

		return new TarifasHorariasDTO(t.getId(), cancha.getId(), t.getDiaSemana(), t.getHoraInicio().toString(),
				t.getHoraFin().toString(), t.getPrecioHora());
	}

	@Transactional
	public void eliminar(Long idTarifa) {
		if (!repo.existsById(idTarifa)) {
			throw new IllegalArgumentException("La tarifa horaria no existe.");
		}
		repo.deleteById(idTarifa);
	}
}
