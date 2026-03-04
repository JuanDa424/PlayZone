package co.playzone.PlayZoneAPI.dto;

import jakarta.validation.constraints.*;

public record CrearTarifaHorariaReq(@NotNull Long canchaId, @NotNull @Min(1) @Max(7) Short diaSemana,
		@NotBlank String horaInicio, // "HH:mm" — la hora fin se calcula sumando 1h
		@NotBlank String precioHora // "75000.00"
) {
}