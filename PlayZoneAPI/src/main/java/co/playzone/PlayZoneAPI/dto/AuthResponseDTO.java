package co.playzone.PlayZoneAPI.dto;

public class AuthResponseDTO {
	// Datos del Usuario
	private Long id;
	private String nombre;
	private String correo;
	private String role; // El rol del usuario

	// El Token JWT
	private String jwtToken;

	public AuthResponseDTO() {
		// TODO Auto-generated constructor stub
	}

	public AuthResponseDTO(Long id, String nombre, String correo, String role, String jwtToken) {
		super();
		this.id = id;
		this.nombre = nombre;
		this.correo = correo;
		this.role = role;
		this.jwtToken = jwtToken;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

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

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public String getJwtToken() {
		return jwtToken;
	}

	public void setJwtToken(String jwtToken) {
		this.jwtToken = jwtToken;
	}

}