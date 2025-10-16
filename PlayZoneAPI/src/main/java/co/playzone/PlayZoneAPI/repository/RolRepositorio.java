package co.playzone.PlayZoneAPI.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import co.playzone.PlayZoneAPI.model.Rol;

public interface RolRepositorio extends JpaRepository<Rol, Long> {
	Optional<Rol> findByCodigo(String codigo); // "APP_ADMIN", "CANCHA_ADMIN", "CLIENTE"
	
}