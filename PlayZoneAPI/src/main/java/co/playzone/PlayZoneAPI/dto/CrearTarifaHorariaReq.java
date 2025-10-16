package co.playzone.PlayZoneAPI.dto;

import jakarta.validation.constraints.*;

public record CrearTarifaHorariaReq(@NotNull Long canchaId, @NotNull @Min(1) @Max(7) Short diaSemana,
		@NotBlank String horaInicio, // "HH:mm:ss"
		@NotBlank String horaFin, // "HH:mm:ss"
		@NotBlank String precioHora // "75000.00"
) {
}