package co.playzone.PlayZoneAPI.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StatusController {

	private static final Logger logger = LoggerFactory.getLogger(StatusController.class); // <-- Logger para esta clase

	@GetMapping("/api/public/status")
	public ResponseEntity<String> getPublicStatus() {
		logger.info("ENTRA AL METODO PRUEBA - LOGBACK");
		System.out.println("SI ENTRAAAAAAAA");
		return ResponseEntity.ok("Servicio Activo. Ruta sin token.");
	}
}