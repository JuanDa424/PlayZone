package co.playzone.PlayZoneAPI.dto;

public record CrearCanchaReq(String nombre, Double latitud, Double longitud, Boolean disponibilidad,
		Long propietarioId) {
}
