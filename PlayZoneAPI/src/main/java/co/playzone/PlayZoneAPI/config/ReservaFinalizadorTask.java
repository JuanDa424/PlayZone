package co.playzone.PlayZoneAPI.config;

import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Component
public class ReservaFinalizadorTask {

	@Autowired
	private ReservasRepositorio reservasRepositorio;

	// Corre cada 15 minutos
	@Scheduled(fixedRate = 900000)
	@Transactional
	public void finalizarReservasPasadas() {
		LocalDate hoy = LocalDate.now();
		LocalTime ahora = LocalTime.now();

		List<Reservas> reservas = reservasRepositorio.findAll();
		for (Reservas r : reservas) {
			if (!"RESERVADO".equalsIgnoreCase(r.getEstado()))
				continue;

			boolean esPasada = r.getFechaReserva().isBefore(hoy)
					|| (r.getFechaReserva().isEqual(hoy) && r.getHoraInicio().isBefore(ahora));

			if (esPasada) {
				r.setEstado("FINALIZADA");
				reservasRepositorio.save(r);
				System.out.println("Reserva #" + r.getId() + " finalizada automaticamente.");
			}
		}
	}
}