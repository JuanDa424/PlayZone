package co.playzone.PlayZoneAPI.model;

import jakarta.persistence.*;

@Entity
@Table(name = "roles", uniqueConstraints = { @UniqueConstraint(name = "uk_roles_codigo", columnNames = { "codigo" }) })
public class Rol {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, length = 50)
	private String codigo; // "APP_ADMIN", "CANCHA_ADMIN", "CLIENTE"

	@Column(length = 100)
	private String nombre; // "Administrador de la aplicación", etc.

	public Rol() {
	}

	public Rol(Long id, String codigo, String nombre) {
		this.id = id;
		this.codigo = codigo;
		this.nombre = nombre;
	}

	// Getters/Setters
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getCodigo() {
		return codigo;
	}

	public void setCodigo(String codigo) {
		this.codigo = codigo;
	}

	public String getNombre() {
		return nombre;
	}

	public void setNombre(String nombre) {
		this.nombre = nombre;
	}
}
