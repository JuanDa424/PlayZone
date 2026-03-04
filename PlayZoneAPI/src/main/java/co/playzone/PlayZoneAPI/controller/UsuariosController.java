package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.UsuariosDTO;
import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio;
import co.playzone.PlayZoneAPI.service.UsuarioServicio;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/usuarios")
public class UsuariosController {

	private final UsuarioServicio servicio;
	private final UsuariosRepositorio usuariosRepo;
	private final RolRepositorio rolRepo;

	public UsuariosController(UsuarioServicio servicio, UsuariosRepositorio usuariosRepo, RolRepositorio rolRepo) {
		this.servicio = servicio;
		this.usuariosRepo = usuariosRepo;
		this.rolRepo = rolRepo;
	}

	@GetMapping
	public List<UsuariosDTO> listar(@RequestParam(name = "rolCodigo", required = false) String rolCodigo) {
		if (rolCodigo == null) {
			return usuariosRepo.findAll().stream().map(u -> new UsuariosDTO(u.getId(), u.getNombre(), u.getCorreo(),
					u.getTelefono(), u.getRol().getId(), u.getRol().getCodigo())).toList();
		}
		Rol rol = rolRepo.findByCodigo(rolCodigo.toUpperCase())
				.orElseThrow(() -> new IllegalArgumentException("Rol inválido"));
		return usuariosRepo.findByRol_Id(rol.getId()).stream().map(u -> new UsuariosDTO(u.getId(), u.getNombre(),
				u.getCorreo(), u.getTelefono(), u.getRol().getId(), u.getRol().getCodigo())).toList();
	}

	@PostMapping("/{id}/canchas/{canchaId}")
	public ResponseEntity<Void> asignarAdminACancha(@PathVariable("id") Long id,
			@PathVariable("canchaId") Long canchaId) {
		servicio.asignarAdminACancha(id, canchaId);
		return ResponseEntity.noContent().build();
	}
}
