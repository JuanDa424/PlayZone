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
				// 1. Deshabilitar CSRF
				.csrf(csrf -> csrf.disable())

				// 2. AÑADIR CONFIGURACIÓN CORS
				.cors(cors -> cors.configurationSource(corsConfigurationSource()))

				// 3. ASEGURAR RUTAS Y DEFINIR PERMISOS
				.authorizeHttpRequests(auth -> auth
						// Rutas públicas (ej: Login, Registro) - Estas NO requieren token
						.requestMatchers("/api/auth/**").permitAll()

						// Rutas de Reservas - REQUIEREN TOKEN JWT
						.requestMatchers("/api/reservas/**").authenticated() // Aseguramos todas las operaciones en
																				// /api/reservas

						// Aseguramos el resto de peticiones que no sean las de arriba
						.anyRequest().authenticated())

				// 4. Habilitar la Gestión de Sesiones como STATELESS (Necesario para JWT)
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

				// 5. Agregar el Proveedor de Autenticación
				.authenticationProvider(authenticationProvider)

				// 6. Agregar el Filtro JWT (Antes del filtro de Usuario/Contraseña de Spring)
				.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

		return http.build();
	}
}