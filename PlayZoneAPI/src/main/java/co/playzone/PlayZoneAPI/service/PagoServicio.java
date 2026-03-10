// co/playzone/PlayZoneAPI/service/PagoServicio.java
package co.playzone.PlayZoneAPI.service;

import com.mercadopago.client.preference.PreferenceBackUrlsRequest;
import com.mercadopago.client.preference.PreferenceClient;
import com.mercadopago.client.preference.PreferenceItemRequest;
import com.mercadopago.client.preference.PreferenceRequest;
import com.mercadopago.resources.preference.Preference;

import co.playzone.PlayZoneAPI.dto.PagoRequestDTO;
import co.playzone.PlayZoneAPI.dto.PagoResponseDTO;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.model.TarifasHorarias;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import co.playzone.PlayZoneAPI.repository.TarifasHorariasRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class PagoServicio {

	private final UsuariosRepositorio usuariosRepo;
	private final CanchasRepositorio canchasRepo;
	private final TarifasHorariasRepositorio tarifasRepo;
	private final ReservasRepositorio reservasRepo;

	@Value("${app.base-url}")
	private String baseUrl;

	public PagoServicio(UsuariosRepositorio usuariosRepo, CanchasRepositorio canchasRepo,
			TarifasHorariasRepositorio tarifasRepo, ReservasRepositorio reservasRepo) {
		this.usuariosRepo = usuariosRepo;
		this.canchasRepo = canchasRepo;
		this.tarifasRepo = tarifasRepo;
		this.reservasRepo = reservasRepo;
	}

	@Transactional
	public PagoResponseDTO crearPreferencia(PagoRequestDTO dto) throws Exception {

		// 1. Validar usuario
		Usuarios usuario = usuariosRepo.findById(dto.getUsuarioId())
				.orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

		// 2. Validar cancha
		Canchas cancha = canchasRepo.findById(dto.getCanchaId())
				.orElseThrow(() -> new RuntimeException("Cancha no encontrada"));

		// 3. Validar disponibilidad
		if (reservasRepo.findActiveReservaByCanchaAndHora(dto.getCanchaId(), dto.getFecha(), dto.getHoraInicio())
				.isPresent()) {
			throw new RuntimeException("Horario no disponible para esta cancha.");
		}

		// 4. Obtener tarifa
		Short diaSemana = (short) dto.getFecha().getDayOfWeek().getValue();
		TarifasHorarias tarifa = tarifasRepo.findTarifaApplicable(dto.getCanchaId(), diaSemana, dto.getHoraInicio())
				.orElseThrow(() -> new RuntimeException("No hay tarifa configurada para este horario."));

		BigDecimal precio = tarifa.getPrecioHora();

		// 5. Crear reserva en estado PENDIENTE_PAGO
		Reservas reserva = new Reservas();
		reserva.setUsuario(usuario);
		reserva.setCancha(cancha);
		reserva.setFechaReserva(dto.getFecha());
		reserva.setHoraInicio(dto.getHoraInicio());
		reserva.setTotalPago(precio);
		reserva.setEstado("PENDIENTE_PAGO");
		reserva = reservasRepo.save(reserva);

		Long reservaId = reserva.getId();

		// 6. Crear preferencia en Mercado Pago
		PreferenceItemRequest item = PreferenceItemRequest.builder().title("Reserva cancha " + cancha.getNombre())
				.description("Fecha: " + dto.getFecha() + " Hora: " + dto.getHoraInicio()).quantity(1).unitPrice(precio)
				.currencyId("COP").build();

		PreferenceBackUrlsRequest backUrls = PreferenceBackUrlsRequest.builder()
				.success(baseUrl + "/api/pagos/resultado?estado=success&reservaId=" + reservaId)
				.failure(baseUrl + "/api/pagos/resultado?estado=failure&reservaId=" + reservaId)
				.pending(baseUrl + "/api/pagos/resultado?estado=pending&reservaId=" + reservaId).build();

		PreferenceRequest preferenceRequest = PreferenceRequest.builder().items(List.of(item)).backUrls(backUrls)
				// .autoReturn("approved")
				.externalReference(reservaId.toString()).notificationUrl(baseUrl + "/api/pagos/webhook").build();

		PreferenceClient client = new PreferenceClient();
		Preference preference;
		try {
			preference = client.create(preferenceRequest);
			System.out.println("=== BASE URL: " + baseUrl);
		} catch (com.mercadopago.exceptions.MPApiException e) {
			System.err.println("=== MP API Error ===");
			System.err.println("Status: " + e.getStatusCode());
			System.err.println("Response: " + e.getApiResponse().getContent());
			throw new RuntimeException("Error MP: " + e.getApiResponse().getContent());
		}
		return new PagoResponseDTO(reservaId, preference.getInitPoint(), preference.getSandboxInitPoint());
	}

	@Transactional
	public void confirmarPago(Long reservaId) {
		Reservas reserva = reservasRepo.findById(reservaId)
				.orElseThrow(() -> new RuntimeException("Reserva no encontrada"));
		reserva.setEstado("RESERVADO");
		reservasRepo.save(reserva);
	}

	@Transactional
	public void rechazarPago(Long reservaId) {
		Reservas reserva = reservasRepo.findById(reservaId)
				.orElseThrow(() -> new RuntimeException("Reserva no encontrada"));
		reserva.setEstado("CANCELADA");
		reservasRepo.save(reserva);
	}
}