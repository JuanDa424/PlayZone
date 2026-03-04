package co.playzone.PlayZoneAPI.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

public class RegisterRequest {

	@NotBlank
	private String nombre;

	@Email
	@NotBlank
	private String correo;

	@NotBlank
	private String password;

	@NotBlank
	private String telefono;

	@NotBlank(message = "El nombre del rol es obligatorio")
	private String rolNombre; // Aquí se enviará "CANCHA_ADMIN" o "APP_ADMIN"

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
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

	public String getRolNombre() {
		return rolNombre;
	}

	public void setRolNombre(String rolNombre) {
		this.rolNombre = rolNombre;
	}

	public String getTelefono() {
		return telefono;
	}

	public void setTelefono(String telefono) {
		this.telefono = telefono;
	}

}