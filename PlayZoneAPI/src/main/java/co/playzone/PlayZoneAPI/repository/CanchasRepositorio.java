package co.playzone.PlayZoneAPI.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import co.playzone.PlayZoneAPI.model.Canchas;

import org.springframework.data.jpa.repository.Query;

public interface CanchasRepositorio extends JpaRepository<Canchas, Long> {
	
}
