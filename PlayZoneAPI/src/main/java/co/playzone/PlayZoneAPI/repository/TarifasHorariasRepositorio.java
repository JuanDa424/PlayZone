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

	/**
	 * Busca la tarifa aplicable a una cancha específica, un día de la semana, y
	 * cuya franja horaria (horaInicio, horaFin) envuelve la hora de inicio de la
	 * reserva. * Dado que la reserva es por 1 hora, buscamos la tarifa que está
	 * activa en la hora de inicio solicitada. * @param canchaId ID de la cancha que
	 * se desea reservar.
	 * 
	 * @param diaSemana  Día de la semana de la reserva (1=Lunes a 7=Domingo).
	 * @param horaInicio Hora de inicio de la reserva (ej: 18:00).
	 * @return TarifaHorarias o vacío si no hay tarifa definida.
	 */
	@Query("SELECT t FROM TarifasHorarias t " + "WHERE t.cancha.id = :canchaId " + "AND t.diaSemana = :diaSemana "
			+ "AND t.horaInicio <= :horaInicio " + // La tarifa debe iniciar antes o justo en la hora solicitada
			"AND t.horaFin > :horaInicio") // La tarifa debe finalizar después de la hora solicitada (usamos > para
											// evitar solapamiento exacto en el límite)
	Optional<TarifasHorarias> findTarifaApplicable(Long canchaId, Short diaSemana, LocalTime horaInicio);
}
