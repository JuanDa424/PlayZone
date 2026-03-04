package co.playzone.PlayZoneAPI.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import jakarta.persistence.*;

@Entity
@Table(name = "reservas", uniqueConstraints = {
		// Actualizamos el UniqueConstraint para que no incluya hora_fin
		@UniqueConstraint(name = "uq_reserva_cancha_fecha_hora", columnNames = { "id_cancha", "fecha_reserva",
				"hora_inicio" }) })
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

	@Column(name = "total_pago", nullable = false) // Nueva columna para el precio
	private BigDecimal totalPago;

	@Column(name = "estado", nullable = false)
	private String estado = "pendiente";

	public Reservas() {
	}

	// --- Getters y Setters ---

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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

	public BigDecimal getTotalPago() {
		return totalPago;
	}

	public void setTotalPago(BigDecimal totalPago) {
		this.totalPago = totalPago;
	}

	public String getEstado() {
		return estado;
	}

	public void setEstado(String estado) {
		this.estado = estado;
	}
}