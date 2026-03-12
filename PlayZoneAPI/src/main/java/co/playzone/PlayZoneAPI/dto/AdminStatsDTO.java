// co/playzone/PlayZoneAPI/dto/AdminStatsDTO.java
package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;

public class AdminStatsDTO {
	private long totalUsuarios;
	private long totalCanchas;
	private long totalReservas;
	private long reservasHoy;
	private long reservasActivas;
	private long reservasCanceladas;
	private BigDecimal ingresosTotales;
	private BigDecimal ingresosHoy;

	public AdminStatsDTO(long totalUsuarios, long totalCanchas, long totalReservas, long reservasHoy,
			long reservasActivas, long reservasCanceladas, BigDecimal ingresosTotales, BigDecimal ingresosHoy) {
		this.totalUsuarios = totalUsuarios;
		this.totalCanchas = totalCanchas;
		this.totalReservas = totalReservas;
		this.reservasHoy = reservasHoy;
		this.reservasActivas = reservasActivas;
		this.reservasCanceladas = reservasCanceladas;
		this.ingresosTotales = ingresosTotales;
		this.ingresosHoy = ingresosHoy;
	}

	public long getTotalUsuarios() {
		return totalUsuarios;
	}

	public long getTotalCanchas() {
		return totalCanchas;
	}

	public long getTotalReservas() {
		return totalReservas;
	}

	public long getReservasHoy() {
		return reservasHoy;
	}

	public long getReservasActivas() {
		return reservasActivas;
	}

	public long getReservasCanceladas() {
		return reservasCanceladas;
	}

	public BigDecimal getIngresosTotales() {
		return ingresosTotales;
	}

	public BigDecimal getIngresosHoy() {
		return ingresosHoy;
	}
}