package co.playzone.PlayZoneAPI.service;
//ReservaServicio.java
import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import co.playzone.PlayZoneAPI.dto.ReservaDTO;
import co.playzone.PlayZoneAPI.dto.ReservaReq;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.model.TarifasHorarias;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import co.playzone.PlayZoneAPI.repository.TarifasHorariasRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;

@Service
public class ReservaServicio {

	private final UsuariosRepositorio usuariosRepo;
	private final CanchasRepositorio canchasRepo;
	private final TarifasHorariasRepositorio tarifasRepo;
	private final ReservasRepositorio reservasRepo;

	public ReservaServicio(UsuariosRepositorio usuariosRepo, CanchasRepositorio canchasRepo,
			TarifasHorariasRepositorio tarifasRepo, ReservasRepositorio reservasRepo) {
		this.usuariosRepo = usuariosRepo;
		this.canchasRepo = canchasRepo;
		this.tarifasRepo = tarifasRepo;
		this.reservasRepo = reservasRepo;
	}

	@Transactional
	public ReservaDTO reservarUnaHora(ReservaReq req) {
		// 1) Validar usuario y rol CLIENTE
		Usuarios u = usuariosRepo.findById(req.getUsuarioId())
				.orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
		Rol rol = u.getRol();
		if (rol == null || !"CLIENTE".equalsIgnoreCase(rol.getCodigo())) {
			throw new IllegalStateException("Solo usuarios con rol CLIENTE pueden reservar");
		}

		// 2) Validar cancha
		Canchas cancha = canchasRepo.findById(req.getCanchaId())
				.orElseThrow(() -> new IllegalArgumentException("Cancha no encontrada"));

		// 3) Validar duración exacta de 1 hora (alineada al reloj)
		LocalTime horaInicio = req.getHoraInicio();
		if (horaInicio == null)
			throw new IllegalArgumentException("horaInicio es obligatoria");
		LocalTime horaFin = horaInicio.plusHours(1);

		// 4) Encontrar tarifa que contenga el rango (día de la semana)
		short diaSemana = (short) mapDayOfWeekJavaToSmallint(req.getFecha().getDayOfWeek()); // 1..7
		TarifasHorarias tarifa = tarifasRepo.encontrarTarifaContenedora(cancha.getId(), diaSemana, horaInicio, horaFin)
				.orElseThrow(() -> new IllegalArgumentException("No hay tarifa definida para ese horario/día"));

		BigDecimal precioHora = tarifa.getPrecioHora(); // ya definido en BD

		// 5) Chequear disponibilidad (no traslape)
		boolean ocupado = reservasRepo.existeTraslape(cancha.getId(), req.getFecha(), horaInicio, horaFin);
		if (ocupado) {
			throw new IllegalStateException("Horario no disponible");
		}

		// 6) Crear la reserva (estado 'pendiente' por defecto)
		Reservas r = new Reservas();
		r.setUsuario(u);
		r.setCancha(cancha);
		r.setFechaReserva(req.getFecha());
		r.setHoraInicio(horaInicio);
		r.setHoraFin(horaFin);
		r.setEstado("pendiente");
		r = reservasRepo.save(r);

		return new ReservaDTO(r.getId(), u.getId(), cancha.getId(), r.getFechaReserva(), r.getHoraInicio(),
				r.getHoraFin(), r.getEstado(), precioHora // devuelvo el precio vigente por hora
		);
	}

	// Java DayOfWeek: MONDAY=1..SUNDAY=7 -> tu smallint 1..7
	private int mapDayOfWeekJavaToSmallint(DayOfWeek d) {
		return d.getValue(); // Lunes=1 ... Domingo=7 (coincide con tu CHECK)
	}
}
