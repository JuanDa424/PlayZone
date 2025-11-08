package co.playzone.PlayZoneAPI.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class ReservaRequestDTO {
	private Long canchaId;
	private LocalDate fecha;
	private LocalTime horaInicio;
	private LocalTime horaFin;

	public ReservaRequestDTO() {
		// TODO Auto-generated constructor stub
	}

	public ReservaRequestDTO(Long canchaId, LocalDate fecha, LocalTime horaInicio, LocalTime horaFin) {
		super();
		this.canchaId = canchaId;
		this.fecha = fecha;
		this.horaInicio = horaInicio;
		this.horaFin = horaFin;
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

	public LocalTime getHoraFin() {
		return horaFin;
	}

	public void setHoraFin(LocalTime horaFin) {
		this.horaFin = horaFin;
	}

}
