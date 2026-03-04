package co.playzone.PlayZoneAPI.repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import co.playzone.PlayZoneAPI.model.Reservas;

@Repository
public interface ReservasRepositorio extends JpaRepository<Reservas, Long> {

	// Obtener historial por ID de usuario
	List<Reservas> findByUsuarioIdOrderByFechaReservaAsc(Long usuarioId);

	// Obtener historial por Email
	List<Reservas> findByUsuarioCorreo(String email);

	/**
	 * Verifica si el horario está ocupado. Si una reserva existe pero está
	 * 'CANCELADA', el COUNT será 0 y liberará el cupo.
	 */
	@Query("""
			 SELECT COUNT(r) > 0 FROM Reservas r
			  WHERE r.cancha.id = :canchaId
			    AND r.fechaReserva = :fecha
			    AND r.horaInicio = :horaInicio
			    AND r.estado <> 'CANCELADA'
			""")
	boolean existeReservaActiva(@Param("canchaId") Long canchaId, @Param("fecha") LocalDate fecha,
			@Param("horaInicio") LocalTime horaInicio);

	@Query("SELECT r FROM Reservas r " + "WHERE r.cancha.id = :canchaId " + "AND r.fechaReserva = :fechaReserva "
			+ "AND r.horaInicio = :horaInicio " + "AND r.estado NOT IN ('CANCELADA', 'FINALIZADA')")
	Optional<Reservas> findActiveReservaByCanchaAndHora(@Param("canchaId") Long canchaId,
			@Param("fechaReserva") LocalDate fechaReserva, @Param("horaInicio") LocalTime horaInicio);

	// Obtener todas las reservas de las canchas de un propietario
	@Query("""
			    SELECT r FROM Reservas r
			    JOIN CanchaAdmin ca ON ca.cancha.id = r.cancha.id
			    WHERE ca.usuario.id = :propietarioId
			    ORDER BY r.fechaReserva DESC, r.horaInicio ASC
			""")
	List<Reservas> findByPropietarioId(@Param("propietarioId") Long propietarioId);
}