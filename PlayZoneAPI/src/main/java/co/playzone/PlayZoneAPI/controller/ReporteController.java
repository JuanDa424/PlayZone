package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.ReporteCanchaDTO;
import co.playzone.PlayZoneAPI.model.Reservas;
import co.playzone.PlayZoneAPI.repository.ReservasRepositorio;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reportes")
@CrossOrigin(origins = "*")
public class ReporteController {

	@Autowired
	private ReservasRepositorio reservasRepositorio;

	private boolean esPagado(String estado) {
		return estado != null && estado.equalsIgnoreCase("RESERVADO");
	}

	private boolean esPendiente(String estado) {
		return estado != null && estado.equalsIgnoreCase("PENDIENTE_PAGO");
	}

	private boolean esCancelado(String estado) {
		return estado != null && estado.equalsIgnoreCase("CANCELADO")
				|| estado != null && estado.equalsIgnoreCase("CANCELADA");
	}

	@GetMapping("/cancha/{canchaId}")
	public ResponseEntity<ReporteCanchaDTO> getReporteCancha(@PathVariable Long canchaId,
			@RequestParam(defaultValue = "0") int mes, @RequestParam(defaultValue = "0") int anio) {

		if (mes == 0)
			mes = LocalDate.now().getMonthValue();
		if (anio == 0)
			anio = LocalDate.now().getYear();

		List<Reservas> todas = reservasRepositorio.findByCancha_Id(canchaId);

		final int mesFinal = mes;
		final int anioFinal = anio;
		List<Reservas> delMes = todas.stream().filter(
				r -> r.getFechaReserva().getMonthValue() == mesFinal && r.getFechaReserva().getYear() == anioFinal)
				.collect(Collectors.toList());

		ReporteCanchaDTO dto = new ReporteCanchaDTO();
		dto.setMes(mes);
		dto.setAnio(anio);

		if (!todas.isEmpty()) {
			dto.setNombreCancha(todas.get(0).getCancha().getNombre());
		}

		dto.setTotalReservas(delMes.size());
		dto.setReservasConfirmadas((int) delMes.stream().filter(r -> esPagado(r.getEstado())).count());
		dto.setReservasPendientes((int) delMes.stream().filter(r -> esPendiente(r.getEstado())).count());
		dto.setReservasCanceladas((int) delMes.stream().filter(r -> esCancelado(r.getEstado())).count());
		dto.setGananciaTotal(delMes.stream().filter(r -> esPagado(r.getEstado())).map(Reservas::getTotalPago)
				.reduce(BigDecimal.ZERO, BigDecimal::add));

		// Por mes (últimos 12 meses)
		Map<String, ReporteCanchaDTO.ResumenPeriodo> porMes = new TreeMap<>();
		for (int i = 11; i >= 0; i--) {
			LocalDate fecha = LocalDate.of(anio, mes, 1).minusMonths(i);
			int m = fecha.getMonthValue();
			int a = fecha.getYear();
			String key = String.format("%d-%02d", a, m);
			List<Reservas> delPeriodo = todas.stream()
					.filter(r -> r.getFechaReserva().getMonthValue() == m && r.getFechaReserva().getYear() == a)
					.collect(Collectors.toList());
			BigDecimal ganancias = delPeriodo.stream().filter(r -> esPagado(r.getEstado())).map(Reservas::getTotalPago)
					.reduce(BigDecimal.ZERO, BigDecimal::add);
			porMes.put(key, new ReporteCanchaDTO.ResumenPeriodo(delPeriodo.size(), ganancias));
		}
		dto.setPorMes(porMes);

		// Por día del mes seleccionado
		Map<String, ReporteCanchaDTO.ResumenPeriodo> porDia = new TreeMap<>();
		for (Reservas r : delMes) {
			String key = r.getFechaReserva().toString();
			BigDecimal ganancia = esPagado(r.getEstado()) ? r.getTotalPago() : BigDecimal.ZERO;
			porDia.merge(key, new ReporteCanchaDTO.ResumenPeriodo(1, ganancia),
					(a, b) -> new ReporteCanchaDTO.ResumenPeriodo(a.getReservas() + b.getReservas(),
							a.getGanancias().add(b.getGanancias())));
		}
		dto.setPorDia(porDia);

		// Top usuarios
		Map<String, List<Reservas>> porUsuario = delMes.stream()
				.collect(Collectors.groupingBy(r -> r.getUsuario().getCorreo()));
		List<ReporteCanchaDTO.UsuarioReservaDTO> topUsuarios = porUsuario.entrySet().stream().map(e -> {
			String nombre = e.getValue().get(0).getUsuario().getNombre();
			String correo = e.getKey();
			int total = e.getValue().size();
			BigDecimal gastado = e.getValue().stream().filter(r -> esPagado(r.getEstado())).map(Reservas::getTotalPago)
					.reduce(BigDecimal.ZERO, BigDecimal::add);
			return new ReporteCanchaDTO.UsuarioReservaDTO(nombre, correo, total, gastado);
		}).sorted((a, b) -> b.getTotalReservas() - a.getTotalReservas()).limit(5).collect(Collectors.toList());
		dto.setTopUsuarios(topUsuarios);

		// Reservas por hora
		Map<String, Integer> porHora = new TreeMap<>();
		for (Reservas r : delMes) {
			String hora = String.format("%02d:00", r.getHoraInicio().getHour());
			porHora.merge(hora, 1, Integer::sum);
		}
		dto.setReservasPorHora(porHora);

		return ResponseEntity.ok(dto);
	}
}