package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/roles")
public class RolesController {
	private final RolRepositorio repo;

	public RolesController(RolRepositorio repo) {
		this.repo = repo;
	}

	@GetMapping
	public List<Rol> listar() {
		return repo.findAll();
	}
}
