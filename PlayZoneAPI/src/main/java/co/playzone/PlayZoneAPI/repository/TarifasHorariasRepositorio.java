package co.playzone.PlayZoneAPI.repository;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import co.playzone.PlayZoneAPI.model.TarifasHorarias;

public interface TarifasHorariasRepositorio extends JpaRepository<TarifasHorarias, Long> {

	// Lista por cancha y día, ordenado por horaInicio asc
	List<TarifasHorarias> findByCancha_IdAndDiaSemanaOrderByHoraInicioAsc(Long canchaId, Short diaSemana);

	// (opcional) todas las tarifas de una cancha, ordenadas
	List<TarifasHorarias> findByCancha_IdOrderByDiaSemanaAscHoraInicioAsc(Long canchaId);

	// Contenga completamente el rango solicitado (1 hora)
	@Query("""
			   SELECT th FROM TarifasHorarias th
			    WHERE th.cancha.id = :canchaId
			      AND th.diaSemana = :diaSemana
			      AND th.horaInicio <= :horaInicio
			      AND th.horaFin >= :horaFin
			""")
	Optional<TarifasHorarias> encontrarTarifaContenedora(Long canchaId, short diaSemana, LocalTime horaInicio,
			LocalTime horaFin);
}
