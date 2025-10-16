package co.playzone.PlayZoneAPI.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalTime;

@Entity
@Table(name = "tarifas_horarias", uniqueConstraints = @UniqueConstraint(name = "uq_tarifa", columnNames = { "id_cancha",
		"dia_semana", "hora_inicio", "hora_fin" }))

@Builder
public class TarifasHorarias {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@NotNull
	@ManyToOne(optional = false, fetch = FetchType.LAZY)
	@JoinColumn(name = "id_cancha", nullable = false)
	private Canchas cancha;

	@NotNull
	@Column(name = "dia_semana", nullable = false)
	private Short diaSemana; // 1=Lunes ... 7=Domingo

	@NotNull
	@Column(name = "hora_inicio", nullable = false)
	private LocalTime horaInicio;

	@NotNull
	@Column(name = "hora_fin", nullable = false)
	private LocalTime horaFin;

	@NotNull
	@Column(name = "precio_hora", nullable = false, precision = 10, scale = 2)
	private BigDecimal precioHora;

	public TarifasHorarias() {
		// TODO Auto-generated constructor stub
	}

	public TarifasHorarias(Long id, @NotNull Canchas cancha, @NotNull Short diaSemana, @NotNull LocalTime horaInicio,
			@NotNull LocalTime horaFin, @NotNull BigDecimal precioHora) {
		super();
		this.id = id;
		this.cancha = cancha;
		this.diaSemana = diaSemana;
		this.horaInicio = horaInicio;
		this.horaFin = horaFin;
		this.precioHora = precioHora;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Canchas getCancha() {
		return cancha;
	}

	public void setCancha(Canchas cancha) {
		this.cancha = cancha;
	}

	public Short getDiaSemana() {
		return diaSemana;
	}

	public void setDiaSemana(Short diaSemana) {
		this.diaSemana = diaSemana;
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

	public BigDecimal getPrecioHora() {
		return precioHora;
	}

	public void setPrecioHora(BigDecimal precioHora) {
		this.precioHora = precioHora;
	}

}
