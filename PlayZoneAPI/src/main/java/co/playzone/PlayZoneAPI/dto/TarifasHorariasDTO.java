package co.playzone.PlayZoneAPI.dto;

public record TarifasHorariasDTO(Long id, Long canchaId, Short diaSemana, String horaInicio,
		java.math.BigDecimal precioHora) {
}
