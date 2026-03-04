package co.playzone.PlayZoneAPI;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PlayZoneApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(PlayZoneApiApplication.class, args);
	}
	/*
	 * @Bean public org.springframework.boot.CommandLineRunner
	 * demo(CanchasRepositorio canchasRepo, TarifasHorariasRepositorio tarifasRepo,
	 * UsuarioServicio usuarioSrv, RolRepositorio rolRepo) { return args -> {
	 * 
	 * ============================ /* // 1) Crear y guardar una cancha Canchas c =
	 * new Canchas(); c.setNombre("La Futbolera");
	 * c.setDireccion("Calle 170 #00-00"); c.setCiudad("Bogotá");
	 * c.setDisponibilidad(Boolean.TRUE); c = canchasRepo.save(c);
	 * System.out.println("⚽ Cancha creada: id=" + c.getId());
	 * 
	 * // 2) Crear y guardar una tarifa horaria para la cancha TarifasHorarias t =
	 * new TarifasHorarias(); t.setCancha(c); t.setDiaSemana((short) 5); //
	 * 5=Viernes t.setHoraInicio(LocalTime.parse("18:00:00"));
	 * t.setHoraFin(LocalTime.parse("20:00:00")); t.setPrecioHora(new
	 * BigDecimal("75000")); t = tarifasRepo.save(t);
	 * System.out.println("💵 Tarifa creada: id=" + t.getId());
	 * 
	 * // 3) Listar tarifas por cancha y día
	 * System.out.println("🔎 Tarifas de la cancha " + c.getId() +
	 * " para viernes:");
	 * tarifasRepo.findByCanchaIdAndDiaSemanaOrderByHoraInicioAsc(c.getId(), (short)
	 * 5) .forEach(tt -> System.out.println(" - Tarifa " + tt.getId() + " | " +
	 * tt.getHoraInicio() + "-" + tt.getHoraFin() + " | $" + tt.getPrecioHora()));
	 * 
	 * // 4) Verificar existencia boolean existeTarifa =
	 * tarifasRepo.existsById(t.getId()); System.out.println("❓ existsById(" +
	 * t.getId() + ") = " + existeTarifa);
	 * 
	 * // 5) Eliminar la tarifa //tarifasRepo.deleteById(t.getId()); //boolean
	 * sigueExistiendo = tarifasRepo.existsById(t.getId());
	 * //System.out.println("🗑️ deleteById -> existsById ahora = " +
	 * sigueExistiendo);
	 * 
	 * // (Opcional) Eliminar la cancha creada para dejar limpio
	 * //canchasRepo.deleteById(c.getId());
	 * 
	 * 
	 * // 0) Asegurar que existan los roles base rolRepo.findByCodigo("APP_ADMIN")
	 * .orElseGet(() -> rolRepo.save(new Rol(null, "APP_ADMIN",
	 * "Administrador de la aplicación"))); rolRepo.findByCodigo("CANCHA_ADMIN")
	 * .orElseGet(() -> rolRepo.save(new Rol(null, "CANCHA_ADMIN",
	 * "Administrador de canchas"))); rolRepo.findByCodigo("CLIENTE").orElseGet(()
	 * -> rolRepo.save(new Rol(null, "CLIENTE", "Cliente/Usuario")));
	 * 
	 * // 1) Crear una cancha para asociar al CANCHA_ADMIN (si no quieres crearla,
	 * pasa // un ID existente) Canchas canchaParaAdmin = new Canchas();
	 * canchaParaAdmin.setNombre("Cancha Admin");
	 * canchaParaAdmin.setDireccion("Av. Demo 123");
	 * canchaParaAdmin.setCiudad("Bogotá");
	 * canchaParaAdmin.setDisponibilidad(Boolean.TRUE); canchaParaAdmin =
	 * canchasRepo.save(canchaParaAdmin);
	 * System.out.println("⚽ (seed) Cancha para admin creada: id=" +
	 * canchaParaAdmin.getId());
	 * 
	 * // 2) Crear usuarios de ejemplo (uno por cada rol) var adminAppId =
	 * usuarioSrv.crearUsuario( new CrearUsuarioReq("Admin App", "admin@app.com",
	 * "3000000000", "Admin.123", "APP_ADMIN", null // no // requiere // cancha
	 * )).id(); System.out.println("👑 APP_ADMIN creado: id=" + adminAppId +
	 * " | admin@app.com / Admin.123");
	 * 
	 * var adminCancha = usuarioSrv.crearUsuario(new CrearUsuarioReq("Admin Cancha",
	 * "admin.cancha@app.com", "3000000001", "AdminC.123", "CANCHA_ADMIN",
	 * canchaParaAdmin.getId() // asocia a la cancha creada // arriba ));
	 * System.out.println("🏟️ CANCHA_ADMIN creado: id=" + adminCancha.id() +
	 * " | admin.cancha@app.com / AdminC.123 | canchaId=" +
	 * canchaParaAdmin.getId());
	 * 
	 * var cliente = usuarioSrv.crearUsuario(new CrearUsuarioReq("Cliente Demo",
	 * "cliente@app.com", "3000000002", "Cliente.123", "CLIENTE", null));
	 * System.out.println("🧑 CLIENTE creado: id=" + cliente.id() +
	 * " | cliente@app.com / Cliente.123"); }; }
	 */
}
