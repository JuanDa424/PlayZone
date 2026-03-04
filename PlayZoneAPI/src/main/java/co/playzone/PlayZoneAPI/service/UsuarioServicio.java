package co.playzone.PlayZoneAPI.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import co.playzone.PlayZoneAPI.model.CanchaAdmin;
import co.playzone.PlayZoneAPI.model.CanchaAdminId;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.CanchaAdminsRepositorio;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;

@Service
public class UsuarioServicio {

	private final UsuariosRepositorio usuarios;
	private final RolRepositorio roles;
	private final CanchasRepositorio canchas;
	private final CanchaAdminsRepositorio canchaAdmins;

	public UsuarioServicio(UsuariosRepositorio usuarios, RolRepositorio roles, CanchasRepositorio canchas,
			CanchaAdminsRepositorio canchaAdmins, PasswordEncoder passwordEncoder) {
		this.usuarios = usuarios;
		this.roles = roles;
		this.canchas = canchas;
		this.canchaAdmins = canchaAdmins;
	}

	@Transactional
	public void asignarAdminACancha(Long usuarioId, Long canchaId) {
		Usuarios u = usuarios.findById(usuarioId)
				.orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

		if (!"CANCHA_ADMIN".equalsIgnoreCase(u.getRol().getCodigo())) {
			throw new IllegalStateException("El usuario no tiene rol CANCHA_ADMIN");
		}

		Canchas cancha = canchas.findById(canchaId)
				.orElseThrow(() -> new IllegalArgumentException("Cancha no encontrada"));

		CanchaAdminId relId = new CanchaAdminId(usuarioId, canchaId);
		if (!canchaAdmins.existsById(relId)) {
			canchaAdmins.save(new CanchaAdmin(u, cancha));
		}
	}

	@Transactional
	public void cambiarRol(Long usuarioId, String nuevoCodigoRol) {
		Usuarios u = usuarios.findById(usuarioId)
				.orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

		String codigo = nuevoCodigoRol.trim().toUpperCase();
		Rol rol = roles.findByCodigo(codigo).orElseThrow(() -> new IllegalArgumentException("Rol inválido: " + codigo));

		u.setRol(rol);
	}

	@Transactional(readOnly = true)
	public boolean correoDisponible(String correo) {
		return !usuarios.existsByCorreo(correo.trim().toLowerCase());
	}
}
