package co.playzone.PlayZoneAPI.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.security.web.util.matcher.RequestMatcher;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

	private final RequestMatcher PUBLIC_URLS = new AntPathRequestMatcher("/api/auth/**");

	private final JwtService jwtService;
	private final UserDetailsService userDetailsService;

	public JwtAuthFilter(JwtService jwtService, UserDetailsService userDetailsService) {
		this.jwtService = jwtService;
		this.userDetailsService = userDetailsService;
	}

	@Override
	protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
		// Retorna TRUE si el filtro NO DEBE ejecutarse para esta petición.
		// Ignoramos el filtro si la URL comienza con /api/auth/
		return PUBLIC_URLS.matches(request);
	}

	@Override
	protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
			@NonNull FilterChain filterChain) throws ServletException, IOException {

		// 1. VERIFICACIÓN DE RUTAS PÚBLICAS (¡CLAVE!)
		// Si la ruta es el registro, login, o cualquier ruta pública, salta la lógica
		// JWT.
		if (request.getServletPath().startsWith("/api/auth/") || request.getServletPath().startsWith("/v3/api-docs")
				|| request.getServletPath().startsWith("/swagger-ui")) {

			filterChain.doFilter(request, response);
			return; // Detiene el procesamiento aquí para rutas públicas
		}

		// 2. Lógica normal de extracción de Token y validación...
		final String authHeader = request.getHeader("Authorization");
		// ... el resto de tu lógica de token ...
	}
}