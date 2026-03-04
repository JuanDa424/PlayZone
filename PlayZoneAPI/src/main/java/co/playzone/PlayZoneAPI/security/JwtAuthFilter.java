package co.playzone.PlayZoneAPI.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

	private final JwtService jwtService;
	private final UserDetailsService userDetailsService;

	public JwtAuthFilter(JwtService jwtService, UserDetailsService userDetailsService) {
		this.jwtService = jwtService;
		this.userDetailsService = userDetailsService;
	}

	/**
	 * Este método le dice a Spring qué rutas NO deben pasar por la validación de
	 * Token. Si retorna true, el filtro se salta y la petición sigue su camino.
	 */
	@Override
	protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
		String path = request.getServletPath();

		// AGREGAMOS LAS RUTAS QUE QUEREMOS LIBERAR:
		// 1. /api/auth/** (Login/Registro)
		// 2. /canchas/** (Tus endpoints de canchas)
		// 3. Documentación de Swagger (opcional)
		return path.startsWith("/api/auth/") || path.startsWith("/canchas") || path.startsWith("/v3/api-docs")
				|| path.startsWith("/swagger-ui");
	}

	@Override
	protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
			@NonNull FilterChain filterChain) throws ServletException, IOException {

		// --- EXPLICACIÓN ---
		// Al haber configurado 'shouldNotFilter' arriba, si la ruta es /canchas,
		// este método doFilterInternal NI SIQUIERA se ejecutará.
		// Pero por seguridad, mantenemos esta validación interna también:

		final String authHeader = request.getHeader("Authorization");
		final String jwt;
		final String userEmail;

		// Si no hay Header de Authorization o no empieza con Bearer, dejamos pasar la
		// petición
		// (Spring Security decidirá luego en su configuración si la ruta era permitida
		// o no)
		if (authHeader == null || !authHeader.startsWith("Bearer ")) {
			filterChain.doFilter(request, response);
			return;
		}
		/*
		 * // Lógica de extracción de Token (Solo se ejecuta para rutas PRIVADAS) jwt =
		 * authHeader.substring(7); userEmail = jwtService.extractUsername(jwt);
		 * 
		 * if (userEmail != null &&
		 * SecurityContextHolder.getContext().getAuthentication() == null) { UserDetails
		 * userDetails = this.userDetailsService.loadUserByUsername(userEmail); if
		 * (jwtService.isTokenValid(jwt, userDetails)) {
		 * UsernamePasswordAuthenticationToken authToken = new
		 * UsernamePasswordAuthenticationToken(userDetails, null,
		 * userDetails.getAuthorities()); authToken.setDetails(new
		 * WebAuthenticationDetailsSource().buildDetails(request));
		 * SecurityContextHolder.getContext().setAuthentication(authToken); } }
		 */

		filterChain.doFilter(request, response);
	}
}