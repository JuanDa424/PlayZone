package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class ReservaDTO {
	private Long id;
	private Long usuarioId;
	private Long canchaId;
	private LocalDate fecha;
	private LocalTime horaInicio;
	private LocalTime horaFin;
	private String estado; // 'pendiente' según tu V1
	private BigDecimal precioHora; // tomado de tarifas_horarias

	public ReservaDTO() {
	}

	public ReservaDTO(Long id, Long usuarioId, Long canchaId, LocalDate fecha, LocalTime horaInicio, LocalTime horaFin,
			String estado, BigDecimal precioHora) {
		this.id = id;
		this.usuarioId = usuarioId;
		this.canchaId = canchaId;
		this.fecha = fecha;
		this.horaInicio = horaInicio;
		this.horaFin = horaFin;
		this.estado = estado;
		this.precioHora = precioHora;
	}

	public Long getId() {
		return id;
	}

	public Long getUsuarioId() {
		return usuarioId;
	}

	public Long getCanchaId() {
		return canchaId;
	}

	public LocalDate getFecha() {
		return fecha;
	}

	public LocalTime getHoraInicio() {
		return horaInicio;
	}

	public LocalTime getHoraFin() {
		return horaFin;
	}

	public String getEstado() {
		return estado;
	}

	public BigDecimal getPrecioHora() {
		return precioHora;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public void setUsuarioId(Long usuarioId) {
		this.usuarioId = usuarioId;
	}

	public void setCanchaId(Long canchaId) {
		this.canchaId = canchaId;
	}

	public void setFecha(LocalDate fecha) {
		this.fecha = fecha;
	}

	public void setHoraInicio(LocalTime horaInicio) {
		this.horaInicio = horaInicio;
	}

	public void setHoraFin(LocalTime horaFin) {
		this.horaFin = horaFin;
	}

	public void setEstado(String estado) {
		this.estado = estado;
	}

	public void setPrecioHora(java.math.BigDecimal precioHora) {
		this.precioHora = precioHora;
	}
}
