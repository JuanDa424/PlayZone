package co.playzone.PlayZoneAPI.model;

import java.time.LocalDate;
import java.time.LocalTime;

import jakarta.persistence.*;

@Entity
@Table(name = "reservas", uniqueConstraints = {
		@UniqueConstraint(name = "uq_reserva_cancha_fecha_horas", columnNames = { "id_cancha", "fecha_reserva",
				"hora_inicio", "hora_fin" }) })
public class Reservas {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@ManyToOne(optional = false, fetch = FetchType.LAZY)
	@JoinColumn(name = "id_usuario", nullable = false)
	private Usuarios usuario;

	@ManyToOne(optional = false, fetch = FetchType.LAZY)
	@JoinColumn(name = "id_cancha", nullable = false)
	private Canchas cancha;

	@Column(name = "fecha_reserva", nullable = false)
	private LocalDate fechaReserva;

	@Column(name = "hora_inicio", nullable = false)
	private LocalTime horaInicio;

	@Column(name = "hora_fin", nullable = false)
	private LocalTime horaFin;

	@Column(name = "estado", nullable = false)
	private String estado = "pendiente";

	public Reservas() {
	}

	// getters/setters
	public Long getId() {
		return id;
	}

	public Usuarios getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuarios usuario) {
		this.usuario = usuario;
	}

	public Canchas getCancha() {
		return cancha;
	}

	public void setCancha(Canchas cancha) {
		this.cancha = cancha;
	}

	public LocalDate getFechaReserva() {
		return fechaReserva;
	}

	public void setFechaReserva(LocalDate fechaReserva) {
		this.fechaReserva = fechaReserva;
	}

	public LocalTime getHoraInicio() {
		return horaInicio;
	}

	public void setHoraInicio(LocalTime horaInicio) {
		this.horaInicio = horaInicio;
	}

	public LocalTime getHoraFin() {
		return horaFin;
	}

	public void setHoraFin(LocalTime horaFin) {
		this.horaFin = horaFin;
	}

	public String getEstado() {
		return estado;
	}

	public void setEstado(String estado) {
		this.estado = estado;
	}
}
