package co.playzone.PlayZoneAPI.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

@Data
public class LoginRequest {

	@Email(message = "El correo debe ser válido")
	@NotBlank(message = "El correo es obligatorio")
	private String correo;

	@NotBlank(message = "La contraseña es obligatoria")
	private String password;

	public LoginRequest() {
		// TODO Auto-generated constructor stub
	}

	public LoginRequest(
			@Email(message = "El correo debe ser válido") @NotBlank(message = "El correo es obligatorio") String correo,
			@NotBlank(message = "La contraseña es obligatoria") String password) {
		super();
		this.correo = correo;
		this.password = password;
	}

	public String getCorreo() {
		return correo;
	}

	public void setCorreo(String correo) {
		this.correo = correo;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

}