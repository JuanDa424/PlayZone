package co.playzone.PlayZoneAPI.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import co.playzone.PlayZoneAPI.model.Canchas;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface CanchasRepositorio extends JpaRepository<Canchas, Long> {

	// Busca canchas donde el usuario es admin en cancha_admins
	@Query("""
			    SELECT c FROM Canchas c
			    JOIN CanchaAdmin ca ON ca.cancha.id = c.id
			    WHERE ca.usuario.id = :usuarioId
			""")
	List<Canchas> findByPropietario(@Param("usuarioId") Long usuarioId);

}
