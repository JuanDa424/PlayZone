package co.playzone.PlayZoneAPI.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import co.playzone.PlayZoneAPI.model.Usuarios;

public interface UsuariosRepositorio extends JpaRepository<Usuarios, Long> {
	Optional<Usuarios> findByCorreo(String correo);

	boolean existsByCorreo(String correo);

	List<Usuarios> findByRol_Id(Long rolId);
}