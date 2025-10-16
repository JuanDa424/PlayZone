package co.playzone.PlayZoneAPI.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.Objects;

@Embeddable
public class CanchaAdminId implements Serializable {
	@Column(name = "usuario_id")
	private Long usuarioId;

	@Column(name = "cancha_id")
	private Long canchaId;

	public CanchaAdminId() {
	}

	public CanchaAdminId(Long usuarioId, Long canchaId) {
		this.usuarioId = usuarioId;
		this.canchaId = canchaId;
	}

	public Long getUsuarioId() {
		return usuarioId;
	}

	public void setUsuarioId(Long usuarioId) {
		this.usuarioId = usuarioId;
	}

	public Long getCanchaId() {
		return canchaId;
	}

	public void setCanchaId(Long canchaId) {
		this.canchaId = canchaId;
	}

	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (!(o instanceof CanchaAdminId that))
			return false;
		return Objects.equals(usuarioId, that.usuarioId) && Objects.equals(canchaId, that.canchaId);
	}

	@Override
	public int hashCode() {
		return Objects.hash(usuarioId, canchaId);
	}
}
