package co.playzone.PlayZoneAPI.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import co.playzone.PlayZoneAPI.model.Canchas;

import org.springframework.data.jpa.repository.Query;

public interface CanchasRepositorio extends JpaRepository<Canchas, Long> {
	// findById(Long) y existsById(Long) ya vienen heredados

	// Conveniencia: lanzar excepción si no existe
	default Canchas getRequired(Long id) {
		return findById(id).orElseThrow(() -> new IllegalArgumentException("Cancha no encontrada"));
	}

	// Ejemplo de búsqueda por nombre (opcional)
	@Query("select c from Canchas c where lower(c.nombre) like lower(concat('%', :q, '%'))")
	java.util.List<Canchas> searchByNombre(String q);
}
