package co.playzone.PlayZoneAPI.service;

import co.playzone.PlayZoneAPI.model.Usuarios;
import co.playzone.PlayZoneAPI.repository.UsuariosRepositorio; // Asumo este nombre
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

	private final UsuariosRepositorio usuariosRepositorio;

	public CustomUserDetailsService(UsuariosRepositorio usuariosRepositorio) {
		this.usuariosRepositorio = usuariosRepositorio;
	}

	@Override
	public UserDetails loadUserByUsername(String correo) throws UsernameNotFoundException {

		// 1. Busca la entidad 'Usuarios' por correo
		// Nota: El método findByCorreo debe devolver un Optional<Usuarios>
		Usuarios usuario = usuariosRepositorio.findByCorreo(correo)
				.orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado con correo: " + correo));

		// 2. Devuelve la entidad directamente, ya que implementa UserDetails
		return usuario;
	}
}