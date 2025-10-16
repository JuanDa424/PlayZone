package co.playzone.PlayZoneAPI.service;

import java.util.List;

import org.springframework.stereotype.Service;

import co.playzone.PlayZoneAPI.dto.CanchasDTO;
import co.playzone.PlayZoneAPI.dto.CrearCanchaReq;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;

@Service

public class CanchasServicio {

	private final CanchasRepositorio repo;

	public CanchasServicio(CanchasRepositorio repo) {
		this.repo = repo;
	}

	public List<CanchasDTO> listar() {
		return repo.findAll().stream().map(
				c -> new CanchasDTO(c.getId(), c.getNombre(), c.getDireccion(), c.getCiudad(), c.getDisponibilidad()))
				.toList();
	}

	public CanchasDTO crear(CrearCanchaReq r) {
		// Como el ID es autogenerado en la BD, lo pasamos como null
		Canchas c = new Canchas(null, r.nombre(), r.direccion(), r.ciudad(),
				r.disponibilidad() == null ? Boolean.TRUE : r.disponibilidad());

		c = repo.save(c);

		return new CanchasDTO(c.getId(), c.getNombre(), c.getDireccion(), c.getCiudad(), c.getDisponibilidad());
	}

}
