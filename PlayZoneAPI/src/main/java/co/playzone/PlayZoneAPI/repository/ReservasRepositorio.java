package co.playzone.PlayZoneAPI.repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import co.playzone.PlayZoneAPI.model.Reservas;

public interface ReservasRepositorio extends JpaRepository<Reservas, Long> {

	// ¿Hay traslape en la misma cancha/fecha?
	// overlap si (start1 < end2) AND (start2 < end1)
	@Query("""
			    SELECT COUNT(r) > 0 FROM Reservas r
			     WHERE r.cancha.id = :canchaId
			       AND r.fechaReserva = :fecha
			       AND r.horaInicio < :horaFin
			       AND :horaInicio < r.horaFin
			""")
	boolean existeTraslape(Long canchaId, LocalDate fecha, LocalTime horaInicio, LocalTime horaFin);

	boolean existsByCancha_IdAndFechaReservaAndHoraInicioAndHoraFin(Long canchaId, LocalDate fecha, LocalTime hi,
			LocalTime hf);

	List<Reservas> findByUsuario_IdOrderByFechaReservaDescHoraInicioAsc(Long usuarioId);

	List<Reservas> findByCancha_IdOrderByFechaReservaDescHoraInicioAsc(Long canchaId);

	List<Reservas> findByCancha_IdAndFechaReservaOrderByHoraInicioAsc(Long canchaId, LocalDate fecha);

	/**
	 * Verifica si ya existe una reserva ACTIVA (no cancelada/finalizada) para una
	 * cancha y hora específicas. Dado que las reservas son de 1 hora (horaInicio =
	 * horaFin), solo necesitamos buscar una coincidencia exacta de horaInicio y
	 * fecha.
	 */
	@Query("SELECT r FROM Reservas r " + "WHERE r.cancha.id = :canchaId " + "AND r.fechaReserva = :fechaReserva "
			+ "AND r.horaInicio = :horaInicio " + "AND r.estado IN ('PENDIENTE', 'CONFIRMADA')") // Solo reservamos si
																									// el estado es
																									// activo
	Optional<Reservas> findActiveReservaByCanchaAndHora(Long canchaId, LocalDate fechaReserva, LocalTime horaInicio);

	/**
	 * Encuentra todas las reservas realizadas por un usuario, buscando por su
	 * email. Spring Data JPA automáticamente genera la consulta gracias al nombre
	 * del método.
	 */
	List<Reservas> findByUsuarioCorreo(String email);
}
