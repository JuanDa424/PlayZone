// co/playzone/PlayZoneAPI/dto/AdminReservaDTO.java
package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class AdminReservaDTO {
	private Long id;
	private String usuarioNombre;
	private String usuarioCorreo;
	private String canchaNombre;
	private LocalDate fechaReserva;
	private LocalTime horaInicio;
	private BigDecimal totalPago;
	private String estado;

	public AdminReservaDTO(Long id, String usuarioNombre, String usuarioCorreo, String canchaNombre,
			LocalDate fechaReserva, LocalTime horaInicio, BigDecimal totalPago, String estado) {
		this.id = id;
		this.usuarioNombre = usuarioNombre;
		this.usuarioCorreo = usuarioCorreo;
		this.canchaNombre = canchaNombre;
		this.fechaReserva = fechaReserva;
		this.horaInicio = horaInicio;
		this.totalPago = totalPago;
		this.estado = estado;
	}

	public Long getId() {
		return id;
	}

	public String getUsuarioNombre() {
		return usuarioNombre;
	}

	public String getUsuarioCorreo() {
		return usuarioCorreo;
	}

	public String getCanchaNombre() {
		return canchaNombre;
	}

	public LocalDate getFechaReserva() {
		return fechaReserva;
	}

	public LocalTime getHoraInicio() {
		return horaInicio;
	}

	public BigDecimal getTotalPago() {
		return totalPago;
	}

	public String getEstado() {
		return estado;
	}
}