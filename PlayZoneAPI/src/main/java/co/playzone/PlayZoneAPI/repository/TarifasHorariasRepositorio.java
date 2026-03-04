package co.playzone.PlayZoneAPI.repository;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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
			""")
	Optional<TarifasHorarias> encontrarTarifaContenedora(Long canchaId, short diaSemana, LocalTime horaInicio,
			LocalTime horaFin);

	@Query("SELECT t FROM TarifasHorarias t WHERE t.cancha.id = :canchaId "
			+ "AND t.diaSemana = :diaSemana AND t.horaInicio = :horaInicio")
	Optional<TarifasHorarias> findTarifaApplicable(@Param("canchaId") Long canchaId,
			@Param("diaSemana") Short diaSemana, @Param("horaInicio") LocalTime horaInicio);

}
