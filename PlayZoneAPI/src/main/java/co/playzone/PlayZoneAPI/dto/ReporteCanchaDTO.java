package co.playzone.PlayZoneAPI.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class ReporteCanchaDTO {

    // --- Resumen general ---
    private int totalReservas;
    private int reservasConfirmadas;
    private int reservasPendientes;
    private int reservasCanceladas;
    private BigDecimal gananciaTotal;

    // --- Por mes: {"2025-01": {reservas: 10, ganancias: 500000}} ---
    private Map<String, ResumenPeriodo> porMes;

    // --- Por día del mes actual ---
    private Map<String, ResumenPeriodo> porDia;

    // --- Top usuarios ---
    private List<UsuarioReservaDTO> topUsuarios;

    // --- Hora más reservada ---
    private Map<String, Integer> reservasPorHora;

    // --- Mes y año del reporte ---
    private int mes;
    private int anio;
    private String nombreCancha;

    public ReporteCanchaDTO() {}

    // Getters y Setters
    public int getTotalReservas() { return totalReservas; }
    public void setTotalReservas(int totalReservas) { this.totalReservas = totalReservas; }

    public int getReservasConfirmadas() { return reservasConfirmadas; }
    public void setReservasConfirmadas(int reservasConfirmadas) { this.reservasConfirmadas = reservasConfirmadas; }

    public int getReservasPendientes() { return reservasPendientes; }
    public void setReservasPendientes(int reservasPendientes) { this.reservasPendientes = reservasPendientes; }

    public int getReservasCanceladas() { return reservasCanceladas; }
    public void setReservasCanceladas(int reservasCanceladas) { this.reservasCanceladas = reservasCanceladas; }

    public BigDecimal getGananciaTotal() { return gananciaTotal; }
    public void setGananciaTotal(BigDecimal gananciaTotal) { this.gananciaTotal = gananciaTotal; }

    public Map<String, ResumenPeriodo> getPorMes() { return porMes; }
    public void setPorMes(Map<String, ResumenPeriodo> porMes) { this.porMes = porMes; }

    public Map<String, ResumenPeriodo> getPorDia() { return porDia; }
    public void setPorDia(Map<String, ResumenPeriodo> porDia) { this.porDia = porDia; }

    public List<UsuarioReservaDTO> getTopUsuarios() { return topUsuarios; }
    public void setTopUsuarios(List<UsuarioReservaDTO> topUsuarios) { this.topUsuarios = topUsuarios; }

    public Map<String, Integer> getReservasPorHora() { return reservasPorHora; }
    public void setReservasPorHora(Map<String, Integer> reservasPorHora) { this.reservasPorHora = reservasPorHora; }

    public int getMes() { return mes; }
    public void setMes(int mes) { this.mes = mes; }

    public int getAnio() { return anio; }
    public void setAnio(int anio) { this.anio = anio; }

    public String getNombreCancha() { return nombreCancha; }
    public void setNombreCancha(String nombreCancha) { this.nombreCancha = nombreCancha; }

    // --- Clases internas ---
    public static class ResumenPeriodo {
        private int reservas;
        private BigDecimal ganancias;

        public ResumenPeriodo(int reservas, BigDecimal ganancias) {
            this.reservas = reservas;
            this.ganancias = ganancias;
        }

        public int getReservas() { return reservas; }
        public void setReservas(int reservas) { this.reservas = reservas; }
        public BigDecimal getGanancias() { return ganancias; }
        public void setGanancias(BigDecimal ganancias) { this.ganancias = ganancias; }
    }

    public static class UsuarioReservaDTO {
        private String nombre;
        private String correo;
        private int totalReservas;
        private BigDecimal totalGastado;

        public UsuarioReservaDTO(String nombre, String correo, int totalReservas, BigDecimal totalGastado) {
            this.nombre = nombre;
            this.correo = correo;
            this.totalReservas = totalReservas;
            this.totalGastado = totalGastado;
        }

        public String getNombre() { return nombre; }
        public void setNombre(String nombre) { this.nombre = nombre; }
        public String getCorreo() { return correo; }
        public void setCorreo(String correo) { this.correo = correo; }
        public int getTotalReservas() { return totalReservas; }
        public void setTotalReservas(int totalReservas) { this.totalReservas = totalReservas; }
        public BigDecimal getTotalGastado() { return totalGastado; }
        public void setTotalGastado(BigDecimal totalGastado) { this.totalGastado = totalGastado; }
    }
}