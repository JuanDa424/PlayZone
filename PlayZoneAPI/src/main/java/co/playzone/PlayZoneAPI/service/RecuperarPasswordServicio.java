// co/playzone/PlayZoneAPI/service/RecuperarPasswordServicio.java
package co.playzone.PlayZoneAPI.service;

import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class RecuperarPasswordServicio {

	private final UsuariosRepositorio usuariosRepo;
	private final EmailService emailService;
	private final PasswordEncoder passwordEncoder;

	// Almacén temporal en memoria: correo → {código, expiración}
	private final Map<String, CodigoReset> codigos = new ConcurrentHashMap<>();

	public RecuperarPasswordServicio(UsuariosRepositorio usuariosRepo, EmailService emailService,
			PasswordEncoder passwordEncoder) {
		this.usuariosRepo = usuariosRepo;
		this.emailService = emailService;
		this.passwordEncoder = passwordEncoder;
	}

	// ── 1. Solicitar código ───────────────────────────────────────
	@Transactional
	public void solicitarCodigo(String correo) {
		Usuarios usuario = usuariosRepo.findByCorreo(correo)
				.orElseThrow(() -> new RuntimeException("No existe una cuenta con ese correo."));

		String codigo = String.format("%06d", new Random().nextInt(999999));
		LocalDateTime expiracion = LocalDateTime.now().plusMinutes(10);

		codigos.put(correo.toLowerCase(), new CodigoReset(codigo, expiracion));
		emailService.sendPasswordResetEmail(correo, codigo);
	}

	// ── 2. Verificar código ───────────────────────────────────────
	public boolean verificarCodigo(String correo, String codigo) {
		CodigoReset reset = codigos.get(correo.toLowerCase());
		if (reset == null)
			return false;
		if (LocalDateTime.now().isAfter(reset.expiracion())) {
			codigos.remove(correo.toLowerCase());
			return false;
		}
		return reset.codigo().equals(codigo);
	}

	// ── 3. Cambiar contraseña ─────────────────────────────────────
	@Transactional
	public void cambiarPassword(String correo, String codigo, String nuevaPassword) {
		if (!verificarCodigo(correo, codigo)) {
			throw new RuntimeException("Código inválido o expirado.");
		}
		if (nuevaPassword == null || nuevaPassword.length() < 6) {
			throw new RuntimeException("La contraseña debe tener al menos 6 caracteres.");
		}

		Usuarios usuario = usuariosRepo.findByCorreo(correo)
				.orElseThrow(() -> new RuntimeException("Usuario no encontrado."));

		usuario.setPassword(passwordEncoder.encode(nuevaPassword));
		usuariosRepo.save(usuario);
		codigos.remove(correo.toLowerCase());
	}

	// ── Record interno ────────────────────────────────────────────
	private record CodigoReset(String codigo, LocalDateTime expiracion) {
	}
}