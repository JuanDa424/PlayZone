package co.playzone.PlayZoneAPI.config;

import co.playzone.PlayZoneAPI.security.JwtAuthFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
// --- IMPORTACIONES NECESARIAS PARA CORS ---
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

	private final JwtAuthFilter jwtAuthFilter;
	private final AuthenticationProvider authenticationProvider;

	// Inyección por Constructor
	public SecurityConfig(JwtAuthFilter jwtAuthFilter, AuthenticationProvider authenticationProvider) {
		this.jwtAuthFilter = jwtAuthFilter;
		this.authenticationProvider = authenticationProvider;
	}

	// ==========================================================
	// NUEVO BEAN: CONFIGURACIÓN CORS
	// ==========================================================
	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		// Permitimos CORS desde cualquier origen (ajustar en producción con dominios
		// específicos)
		configuration.setAllowedOrigins(List.of("*"));
		// Permitimos los métodos HTTP que usaremos
		configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
		// Permitimos todos los headers, incluyendo el Authorization para el JWT
		configuration.setAllowedHeaders(List.of("*"));

		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		// Aplicamos esta configuración a todas las rutas ("/**")
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}

	@Bean
	SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

		http
				// 1. Deshabilitar CSRF (Esto se mantiene para APIs REST)
				.csrf(csrf -> csrf.disable())

				// 2. AÑADIR CONFIGURACIÓN CORS (Esto se mantiene)
				.cors(cors -> cors.configurationSource(corsConfigurationSource()))

				// ==========================================================
				// !!! CLAVE PARA DESACTIVAR LA SEGURIDAD TEMPORALMENTE !!!
				// Permitir acceso sin autenticación a CUALQUIER petición
				.authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
		// ==========================================================

		// 3. COMENTAR (o eliminar) TODA la configuración de JWT y Sesiones:
		// ***************************************************************
		/*
		 * // Desactivación de Sesiones y Filtros JWT .sessionManagement(session ->
		 * session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
		 * 
		 * // Comentar la adición del Proveedor de autenticación
		 * .authenticationProvider(authenticationProvider)
		 * 
		 * // Comentar el filtro JWT .addFilterBefore(jwtAuthFilter,
		 * UsernamePasswordAuthenticationFilter.class);
		 */

		return http.build();
	}
}