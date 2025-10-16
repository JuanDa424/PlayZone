package co.playzone.PlayZoneAPI.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class ReservaReq {
	private Long usuarioId;
	private Long canchaId;
	private LocalDate fecha; // fecha_reserva
	private LocalTime horaInicio; // exacta (en punto)
	// horaFin se infiere = horaInicio + 1h

	public ReservaReq() {
	}

	public ReservaReq(Long usuarioId, Long canchaId, LocalDate fecha, LocalTime horaInicio) {
		this.usuarioId = usuarioId;
		this.canchaId = canchaId;
		this.fecha = fecha;
		this.horaInicio = horaInicio;
	}

	public Long getUsuarioId() {
		return usuarioId;
	}

	public void setUsuarioId(Long usuarioId) {
		this.usuarioId = usuarioId;
	}

	public Long getCanchaId() {
		return canchaId;
	}

	public void setCanchaId(Long canchaId) {
		this.canchaId = canchaId;
	}

	public LocalDate getFecha() {
		return fecha;
	}

	public void setFecha(LocalDate fecha) {
		this.fecha = fecha;
	}

	public LocalTime getHoraInicio() {
		return horaInicio;
	}

	public void setHoraInicio(LocalTime horaInicio) {
		this.horaInicio = horaInicio;
	}
}
