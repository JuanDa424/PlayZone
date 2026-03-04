package co.playzone.PlayZoneAPI.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import co.playzone.PlayZoneAPI.dto.CrearCanchaReq;
import co.playzone.PlayZoneAPI.model.CanchaAdmin;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.CanchaAdminsRepositorio;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;

@Service
public class CanchasServicio {

	@Autowired
	private final CanchasRepositorio repo;

	@Autowired
	private CanchaAdminsRepositorio canchaAdminsRepo;

	@Autowired
	private UsuariosRepositorio usuariosRepo;

	public CanchasServicio(CanchasRepositorio repo) {
		this.repo = repo;
	}

	public List<Canchas> listarTodas() {
		return repo.findAll();
	}

	public Canchas guardar(Canchas cancha) {
		return repo.save(cancha);
	}

	public List<Canchas> listarPorPropietario(Long usuarioId) {
		return repo.findByPropietario(usuarioId);
	}

	// ✅ NUEVO: crea la cancha y la asocia al propietario en cancha_admins
	@Transactional
	public Canchas crearConPropietario(CrearCanchaReq request) {
		// 1. Crear y guardar la cancha
		Canchas cancha = new Canchas();
		cancha.setNombre(request.nombre());
		cancha.setLatitud(request.latitud());
		cancha.setLongitud(request.longitud());
		cancha.setDisponibilidad(request.disponibilidad() != null ? request.disponibilidad() : true);
		cancha = repo.save(cancha);

		// 2. Buscar el usuario propietario
		Usuarios propietario = usuariosRepo.findById(request.propietarioId()).orElseThrow(
				() -> new IllegalArgumentException("Usuario no encontrado con id: " + request.propietarioId()));

		// 3. Crear la relación en cancha_admins
		CanchaAdmin canchaAdmin = new CanchaAdmin(propietario, cancha);
		canchaAdminsRepo.save(canchaAdmin);

		return cancha;
	}
}
