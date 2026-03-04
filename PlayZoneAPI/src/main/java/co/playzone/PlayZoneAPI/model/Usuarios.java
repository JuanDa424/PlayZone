package co.playzone.PlayZoneAPI.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
// ELIMINAR TODAS las importaciones de LOMBOK
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

@Entity
@Table(name = "usuarios", uniqueConstraints = {
		@UniqueConstraint(name = "uk_usuarios_correo", columnNames = { "correo" }) })
public class Usuarios implements UserDetails {

	// CAMPOS
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false, length = 100)
	private String nombre;

	@Column(nullable = false, length = 150)
	private String correo;

	@Column(length = 20)
	private String telefono;

	@Column(nullable = false, length = 200)
	private String password;

	@ManyToOne(fetch = FetchType.EAGER, optional = false)
	@JoinColumn(name = "rol_id", nullable = false, foreignKey = @ForeignKey(name = "fk_usuarios_roles"))
	private Rol rol;

	@Column(name = "fecha_registro", nullable = false)
	private LocalDateTime fechaRegistro = LocalDateTime.now();

	// ------------------- CONSTRUCTORES MANUALES -------------------

	// 1. Constructor vacío (Requerido por JPA)
	public Usuarios() {
		this.fechaRegistro = LocalDateTime.now();
	}

	// 2. Constructor completo (Si lo usas para crear objetos)
	public Usuarios(Long id, String nombre, String correo, String telefono, String password, Rol rol,
			LocalDateTime fechaRegistro) {
		this.id = id;
		this.nombre = nombre;
		this.correo = correo;
		this.telefono = telefono;
		this.password = password;
		this.rol = rol;
		this.fechaRegistro = fechaRegistro;
	}

	// 3. Constructor para el registro (Común para crear un nuevo usuario)
	public Usuarios(String nombre, String correo, String telefono, String password, Rol rol) {
		this.nombre = nombre;
		this.correo = correo;
		this.telefono = telefono;
		this.password = password;
		this.rol = rol;
		this.fechaRegistro = LocalDateTime.now();
	}

	// ------------------- MÉTODOS DE USERDETAILS -------------------

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		// Asegúrate de que el rol sea el string correcto
		return List.of(new SimpleGrantedAuthority("ROLE_" + rol.getNombre()));
	}

	@Override
	public String getUsername() {
		return correo; // Usamos correo como username
	}

	@Override
	public String getPassword() {
		return this.password; // Devuelve el hash de la DB
	}

	// Los métodos booleanos se quedan en 'true'
	@Override
	public boolean isAccountNonExpired() {
		return true;
	}

	@Override
	public boolean isAccountNonLocked() {
		return true;
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}

	@Override
	public boolean isEnabled() {
		return true;
	}

	// ------------------- GETTERS Y SETTERS MANUALES -------------------

	// Debes mantener TODOS los getters y setters de todos tus campos manualmente.

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

	public String getTelefono() {
		return telefono;
	}

	public void setTelefono(String telefono) {
		this.telefono = telefono;
	}

	public Rol getRol() {
		return rol;
	}

	public void setRol(Rol rol) {
		this.rol = rol;
	}

	public LocalDateTime getFechaRegistro() {
		return fechaRegistro;
	}

	public void setFechaRegistro(LocalDateTime fechaRegistro) {
		this.fechaRegistro = fechaRegistro;
	}

	public void setPassword(String password) {
		this.password = password;
	}

}