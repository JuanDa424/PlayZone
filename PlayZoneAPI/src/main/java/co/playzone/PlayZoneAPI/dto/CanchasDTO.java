package co.playzone.PlayZoneAPI.dto;

//Canchas (listado / detalle)
public record CanchasDTO(Long id, String nombre, Double latitud, Double longitud, Boolean disponibilidad) {
}