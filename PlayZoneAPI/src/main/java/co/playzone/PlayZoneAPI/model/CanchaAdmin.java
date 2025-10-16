package co.playzone.PlayZoneAPI.model;

import jakarta.persistence.*;

@Entity
@Table(name = "cancha_admins")
public class CanchaAdmin {

	@EmbeddedId
	private CanchaAdminId id = new CanchaAdminId();

	@ManyToOne(fetch = FetchType.LAZY)
	@MapsId("usuarioId")
	@JoinColumn(name = "usuario_id", nullable = false, foreignKey = @ForeignKey(name = "cancha_admins_usuario_fk"))
	private Usuarios usuario;

	@ManyToOne(fetch = FetchType.LAZY)
	@MapsId("canchaId")
	@JoinColumn(name = "cancha_id", nullable = false, foreignKey = @ForeignKey(name = "cancha_admins_cancha_fk"))
	private Canchas cancha; // tu entidad existente

	public CanchaAdmin() {
	}

	public CanchaAdmin(Usuarios usuario, Canchas cancha) {
		this.usuario = usuario;
		this.cancha = cancha;
		this.id = new CanchaAdminId(usuario.getId(), cancha.getId());
	}

	// Getters/Setters
	public CanchaAdminId getId() {
		return id;
	}

	public void setId(CanchaAdminId id) {
		this.id = id;
	}

	public Usuarios getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuarios usuario) {
		this.usuario = usuario;
		if (usuario != null) {
			if (this.id == null)
				this.id = new CanchaAdminId();
			this.id.setUsuarioId(usuario.getId());
		}
	}

	public Canchas getCancha() {
		return cancha;
	}

	public void setCancha(Canchas cancha) {
		this.cancha = cancha;
		if (cancha != null) {
			if (this.id == null)
				this.id = new CanchaAdminId();
			this.id.setCanchaId(cancha.getId());
		}
	}
}
