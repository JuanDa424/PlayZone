package co.playzone.PlayZoneAPI.config;

import co.playzone.PlayZoneAPI.security.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

	// Nota: Mantenemos las inyecciones para no romper otras partes del código,
	// pero no las usaremos en la cadena de filtros por ahora.
	private final JwtAuthFilter jwtAuthFilter;
	private final AuthenticationProvider authenticationProvider;

	public SecurityConfig(JwtAuthFilter jwtAuthFilter, AuthenticationProvider authenticationProvider) {
		this.jwtAuthFilter = jwtAuthFilter;
		this.authenticationProvider = authenticationProvider;
	}

	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		// Permitimos todos los orígenes para evitar bloqueos en el navegador o emulador
		configuration.setAllowedOrigins(List.of("*"));
		configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
		configuration.setAllowedHeaders(List.of("*"));

		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}

	@Bean
	SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

		http
				// 1. Deshabilitar CSRF (Indispensable para que funcionen los POST desde
				// Flutter)
				.csrf(csrf -> csrf.disable())

				// 2. Aplicar configuración CORS abierta
				.cors(cors -> cors.configurationSource(corsConfigurationSource()))

				// 3. LIBERAR TODAS LAS RUTAS
				.authorizeHttpRequests(auth -> auth
						// Cambiamos todo a permitAll() para que no pida login en nada
						.anyRequest().permitAll())

				// 4. Gestión de sesiones (Aunque permitamos todo, lo dejamos Stateless por
				// buena práctica)
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

				// 5. Proveedor de autenticación (Se mantiene pero no se usará activamente)
				.authenticationProvider(authenticationProvider);

		// IMPORTANTE: Hemos QUITADO la línea '.addFilterBefore(jwtAuthFilter...)'.
		// Al quitarla, Spring Security ya no intentará validar el Token JWT en cada
		// petición.

		return http.build();
	}
}