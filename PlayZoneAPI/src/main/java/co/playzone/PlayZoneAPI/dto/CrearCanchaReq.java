package co.playzone.PlayZoneAPI.dto;

public record CrearCanchaReq(Long id, String nombre, Double latitud, Double longitud, Boolean disponibilidad) {
}
