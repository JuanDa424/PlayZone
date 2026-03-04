package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;

public class HoraDisponibleDTO {
	private String hora;
	private BigDecimal precio;
	private boolean disponible;

	public HoraDisponibleDTO(String hora, BigDecimal precio, boolean disponible) {
		this.hora = hora;
		this.precio = precio;
		this.disponible = disponible;
	}

	public String getHora() {
		return hora;
	}

	public BigDecimal getPrecio() {
		return precio;
	}

	public boolean isDisponible() {
		return disponible;
	}
}