// co/playzone/PlayZoneAPI/dto/PagoResponseDTO.java
package co.playzone.PlayZoneAPI.dto;

public class PagoResponseDTO {
    private Long reservaId;
    private String initPoint;     // URL de pago producción
    private String sandboxInitPoint; // URL de pago sandbox/pruebas

    public PagoResponseDTO() {}

    public PagoResponseDTO(Long reservaId, String initPoint, String sandboxInitPoint) {
        this.reservaId = reservaId;
        this.initPoint = initPoint;
        this.sandboxInitPoint = sandboxInitPoint;
    }

    public Long getReservaId() { return reservaId; }
    public void setReservaId(Long reservaId) { this.reservaId = reservaId; }

    public String getInitPoint() { return initPoint; }
    public void setInitPoint(String initPoint) { this.initPoint = initPoint; }

    public String getSandboxInitPoint() { return sandboxInitPoint; }
    public void setSandboxInitPoint(String sandboxInitPoint) { this.sandboxInitPoint = sandboxInitPoint; }
}