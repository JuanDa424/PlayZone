package co.playzone.PlayZoneAPI.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import co.playzone.PlayZoneAPI.model.Canchas;
import co.playzone.PlayZoneAPI.repository.CanchasRepositorio;

@Service
public class CanchasServicio {

	@Autowired
	private final CanchasRepositorio repo;

	public CanchasServicio(CanchasRepositorio repo) {
		this.repo = repo;
	}

	public List<Canchas> listarTodas() {
		return repo.findAll();
	}

	public Canchas guardar(Canchas cancha) {
		return repo.save(cancha);
	}

}
