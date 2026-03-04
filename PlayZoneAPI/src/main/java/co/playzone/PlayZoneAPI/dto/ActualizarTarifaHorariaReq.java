package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;

public class ActualizarTarifaHorariaReq {
	private Short diaSemana; // nullable si no cambia
	private String horaInicio; // nullable si no cambia
	private String horaFin; // nullable si no cambia
	private BigDecimal precioHora; // nullable si no cambia

	public ActualizarTarifaHorariaReq() {
	}

	// Getters / Setters
	public Short getDiaSemana() {
		return diaSemana;
	}

	public void setDiaSemana(Short diaSemana) {
		this.diaSemana = diaSemana;
	}

	public String getHoraInicio() {
		return horaInicio;
	}

	public void setHoraInicio(String horaInicio) {
		this.horaInicio = horaInicio;
	}

	public String getHoraFin() {
		return horaFin;
	}

	public void setHoraFin(String horaFin) {
		this.horaFin = horaFin;
	}

	public BigDecimal getPrecioHora() {
		return precioHora;
	}

	public void setPrecioHora(BigDecimal precioHora) {
		this.precioHora = precioHora;
	}
}
