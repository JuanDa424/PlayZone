package co.playzone.PlayZoneAPI.config;

import co.playzone.PlayZoneAPI.model.Rol;
import co.playzone.PlayZoneAPI.repository.RolRepositorio;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
public class DataInitializer implements ApplicationRunner {

	@Autowired
	private RolRepositorio rolRepositorio;

	@Override
	public void run(ApplicationArguments args) {
		List<String> roles = List.of("CLIENTE", "CANCHA_ADMIN", "APP_ADMIN");

		for (String codigo : roles) {
			if (rolRepositorio.findByCodigo(codigo).isEmpty()) {
				Rol rol = new Rol();
				rol.setCodigo(codigo);
				rolRepositorio.save(rol);
			}
		}
	}
}