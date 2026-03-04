package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public class ReservaResponse {

	private Long id;
	private String canchaNombre;
	private LocalDate fecha;
	private LocalTime horaInicio;
	private BigDecimal totalPago;
	private String estado;

	public ReservaResponse() {
		// TODO Auto-generated constructor stub
	}

	public ReservaResponse(Long id, String canchaNombre, LocalDate fecha, LocalTime horaInicio, BigDecimal totalPago,
			String estado) {
		super();
		this.id = id;
		this.canchaNombre = canchaNombre;
		this.fecha = fecha;
		this.horaInicio = horaInicio;
		this.totalPago = totalPago;
		this.estado = estado;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getCanchaNombre() {
		return canchaNombre;
	}

	public void setCanchaNombre(String canchaNombre) {
		this.canchaNombre = canchaNombre;
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

	public BigDecimal getTotalPago() {
		return totalPago;
	}

	public void setTotalPago(BigDecimal totalPago) {
		this.totalPago = totalPago;
	}

	public String getEstado() {
		return estado;
	}

	public void setEstado(String estado) {
		this.estado = estado;
	}

}
