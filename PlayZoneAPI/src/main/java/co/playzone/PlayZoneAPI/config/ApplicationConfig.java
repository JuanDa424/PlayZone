package co.playzone.PlayZoneAPI.config;

import co.playzone.PlayZoneAPI.service.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class ApplicationConfig {

	private final CustomUserDetailsService userDetailsService;

	public ApplicationConfig(CustomUserDetailsService userDetailsService) {
		this.userDetailsService = userDetailsService;
	}

	// 1. Define el Codificador de Contraseñas (Password Encoder)

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	// 2. Define el Proveedor de Autenticación (Authentication Provider) // Es el
	// componente que obtiene los detalles del usuario (UserDetailsService) // y
	// verifica la contraseña (PasswordEncoder).

	@Bean
	public AuthenticationProvider authenticationProvider() {
		DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
		authProvider.setUserDetailsService(userDetailsService);
		authProvider.setPasswordEncoder(passwordEncoder());
		return authProvider;
	}

	// 3. Define el Gestor de Autenticación (Authentication Manager) // Es el punto
	// de entrada para realizar la autenticación (login).

	@Bean
	public AuthenticationManager

			authenticationManager(AuthenticationConfiguration config) throws Exception {
		return config.getAuthenticationManager();
	}

}