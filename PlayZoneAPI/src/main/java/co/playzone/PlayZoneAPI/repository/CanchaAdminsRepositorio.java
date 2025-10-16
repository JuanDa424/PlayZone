package co.playzone.PlayZoneAPI.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import co.playzone.PlayZoneAPI.model.CanchaAdmin;
import co.playzone.PlayZoneAPI.model.CanchaAdminId;

public interface CanchaAdminsRepositorio extends JpaRepository<CanchaAdmin, CanchaAdminId> {
	List<CanchaAdmin> findByUsuario_Id(Long usuarioId);

	List<CanchaAdmin> findByCancha_Id(Long canchaId);
}