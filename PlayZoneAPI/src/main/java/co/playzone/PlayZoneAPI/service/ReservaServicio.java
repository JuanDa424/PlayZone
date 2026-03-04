package co.playzone.PlayZoneAPI.service;

import java.util.List;
import java.util.stream.Collectors;

//ReservaServicio.java
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import co.playzone.PlayZoneAPI.dto.ReservaRequestDTO;
import co.playzone.PlayZoneAPI.dto.ReservaResponse;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.Reservas;
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

	public List<ReservaResponse> listarReservasPorUsuario(Long usuarioId) {
		List<Reservas> reservas = reservasRepo.findByUsuarioIdOrderByFechaReservaAsc(usuarioId);

		return reservas.stream().map(r -> new ReservaResponse(r.getId(), r.getCancha().getNombre(), // Obtenemos el
																									// nombre de la
																									// relación
				r.getFechaReserva(), r.getHoraInicio(), r.getTotalPago(), r.getEstado())).collect(Collectors.toList());
	}

	@Transactional
	public Reservas crearReserva(ReservaRequestDTO dto) {
		// 1. Validar Usuario por ID
		Usuarios usuario = usuariosRepo.findById(dto.getUsuarioId())
				.orElseThrow(() -> new RuntimeException("Usuario no encontrado ID: " + dto.getUsuarioId()));

		// 2. Validar Cancha
		Canchas cancha = canchasRepo.findById(dto.getCanchaId())
				.orElseThrow(() -> new RuntimeException("Cancha no encontrada ID: " + dto.getCanchaId()));

		// 3. Validar Disponibilidad (Busca si ya existe reserva a esa hora)
		if (reservasRepo.findActiveReservaByCanchaAndHora(dto.getCanchaId(), dto.getFecha(), dto.getHoraInicio())
				.isPresent()) {
			throw new RuntimeException("Horario no disponible para esta cancha.");
		}

		// 4. Calcular Tarifa
		Short diaSemana = (short) dto.getFecha().getDayOfWeek().getValue();
		TarifasHorarias tarifa = tarifasRepo.findTarifaApplicable(dto.getCanchaId(), diaSemana, dto.getHoraInicio())
				.orElseThrow(() -> new RuntimeException("No hay tarifa configurada para este horario."));

		// 5. Mapear a la Entidad Real
		Reservas reserva = new Reservas();
		reserva.setUsuario(usuario);
		reserva.setCancha(cancha);
		reserva.setFechaReserva(dto.getFecha());
		reserva.setHoraInicio(dto.getHoraInicio());
		reserva.setEstado("RESERVADO");
		reserva.setTotalPago(tarifa.getPrecioHora()); // Usamos el precio de la tarifa

		return reservasRepo.save(reserva);
	}

	@Transactional
	public void cancelarReserva(Long id) {
		Reservas reserva = reservasRepo.findById(id)
				.orElseThrow(() -> new RuntimeException("La reserva con ID " + id + " no existe."));

		// Simplemente cambiamos el estado.
		// No la borramos para que el usuario la siga viendo en su historial.
		reserva.setEstado("CANCELADA");
		reservasRepo.save(reserva);
	}

	public List<ReservaResponse> listarReservasPorPropietario(Long propietarioId) {
		List<Reservas> reservas = reservasRepo.findByPropietarioId(propietarioId);
		return reservas.stream().map(r -> new ReservaResponse(r.getId(), r.getCancha().getNombre(), r.getFechaReserva(),
				r.getHoraInicio(), r.getTotalPago(), r.getEstado())).collect(Collectors.toList());
	}
}