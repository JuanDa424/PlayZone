package co.playzone.PlayZoneAPI.service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import co.playzone.PlayZoneAPI.dto.CrearCanchaReq;
import co.playzone.PlayZoneAPI.dto.HoraDisponibleDTO;
import co.playzone.PlayZoneAPI.model.CanchaAdmin;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.TarifasHorarias;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.CanchaAdminsRepositorio;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import co.playzone.PlayZoneAPI.repository.TarifasHorariasRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;

@Service
public class CanchasServicio {

	@Autowired
	private final CanchasRepositorio repo;

	@Autowired
	private CanchaAdminsRepositorio canchaAdminsRepo;

	@Autowired
	private UsuariosRepositorio usuariosRepo;

	@Autowired
	private TarifasHorariasRepositorio tarifasRepo;

	@Autowired
	private ReservasRepositorio reservasRepo;

	public CanchasServicio(CanchasRepositorio repo, CanchaAdminsRepositorio canchaAdminsRepo,
			UsuariosRepositorio usuariosRepo, ReservasRepositorio reservasRepo) {
		this.repo = repo;
		this.canchaAdminsRepo = canchaAdminsRepo;
		this.usuariosRepo = usuariosRepo;
		this.reservasRepo = reservasRepo;
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

	public List<HoraDisponibleDTO> getDisponibilidad(Long canchaId, LocalDate fecha) {
		// 1. Obtener día de la semana (1=Lunes...7=Domingo)
		Short diaSemana = (short) fecha.getDayOfWeek().getValue();

		// 2. Obtener tarifas configuradas para ese día
		List<TarifasHorarias> tarifas = tarifasRepo.findByCancha_IdAndDiaSemanaOrderByHoraInicioAsc(canchaId,
				diaSemana);

		// 3. Para cada tarifa, verificar si ya está reservada
		return tarifas.stream().map(t -> {
			boolean ocupada = reservasRepo.existeReservaActiva(canchaId, fecha, t.getHoraInicio());
			String hora = t.getHoraInicio().toString().substring(0, 5);
			return new HoraDisponibleDTO(hora, t.getPrecioHora(), !ocupada);
		}).collect(Collectors.toList());
	}
}
