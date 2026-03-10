// co/playzone/PlayZoneAPI/dto/PagoRequestDTO.java
package co.playzone.PlayZoneAPI.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class PagoRequestDTO {
	private Long usuarioId;
	private Long canchaId;
	private LocalDate fecha;
	private LocalTime horaInicio;

	public PagoRequestDTO() {
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