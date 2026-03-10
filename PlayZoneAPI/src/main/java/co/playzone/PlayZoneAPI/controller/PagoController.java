// co/playzone/PlayZoneAPI/controller/PagoController.java
package co.playzone.PlayZoneAPI.controller;

import co.playzone.PlayZoneAPI.dto.PagoRequestDTO;
import co.playzone.PlayZoneAPI.dto.PagoResponseDTO;
import co.playzone.PlayZoneAPI.service.PagoServicio;
import com.mercadopago.client.payment.PaymentClient;
import com.mercadopago.resources.payment.Payment;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/pagos")
public class PagoController {

	private final PagoServicio pagoServicio;

	public PagoController(PagoServicio pagoServicio) {
		this.pagoServicio = pagoServicio;
	}

	// ── 1. Crear preferencia de pago ─────────────────────────────
	@PostMapping("/crear")
	public ResponseEntity<?> crearPago(@RequestBody PagoRequestDTO dto) {
		try {
			PagoResponseDTO response = pagoServicio.crearPreferencia(dto);
			return ResponseEntity.ok(response);
		} catch (RuntimeException e) {
			e.printStackTrace();
			return ResponseEntity.badRequest().body(e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.internalServerError().body("Error al crear preferencia de pago: " + e.getMessage());
		}
	}

	// ── 2. Webhook — Mercado Pago notifica el resultado ───────────
	@PostMapping("/webhook")
	public ResponseEntity<Void> webhook(@RequestParam(value = "type", required = false) String type,
			@RequestParam(value = "topic", required = false) String topic,
			@RequestBody(required = false) Map<String, Object> body) {

		System.out.println("=== WEBHOOK RECIBIDO ===");
		System.out.println("Type: " + type);
		System.out.println("Topic: " + topic);
		System.out.println("Body: " + body);

		try {
			// Manejo de merchant_order
			if ("merchant_order".equals(topic) && body != null) {
				String resource = body.get("resource").toString();
				// Extraer el ID del merchant_order de la URL
				String orderId = resource.substring(resource.lastIndexOf("/") + 1);
				System.out.println("Order ID: " + orderId);

				// Consultar el merchant_order
				com.mercadopago.client.merchantorder.MerchantOrderClient orderClient = new com.mercadopago.client.merchantorder.MerchantOrderClient();
				var order = orderClient.get(Long.parseLong(orderId));

				System.out.println("Order status: " + order.getOrderStatus());
				System.out.println("External ref: " + order.getExternalReference());

				if ("paid".equals(order.getOrderStatus())) {
					Long reservaId = Long.parseLong(order.getExternalReference());
					pagoServicio.confirmarPago(reservaId);
					System.out.println("Reserva " + reservaId + " confirmada!");
				}
			}
		} catch (Exception e) {
			System.err.println("Error webhook: " + e.getMessage());
			e.printStackTrace();
		}
		return ResponseEntity.ok().build();
	}

	// ── 3. Redirect de vuelta desde la página de pago ────────────
	// MP redirige al usuario aquí después de pagar
	@GetMapping("/resultado")
	public ResponseEntity<String> resultado(@RequestParam("estado") String estado,
			@RequestParam("reservaId") Long reservaId,
			@RequestParam(value = "payment_id", required = false) String paymentId,
			@RequestParam(value = "status", required = false) String status) {

		// El webhook ya confirmó el pago — esto es solo para redirigir al usuario
		// En producción aquí redirigirías a tu app con un deeplink
		return switch (estado) {
		case "success" -> ResponseEntity.ok("Pago exitoso. Reserva #" + reservaId + " confirmada.");
		case "failure" -> ResponseEntity.ok("Pago rechazado. Reserva #" + reservaId + " cancelada.");
		default -> ResponseEntity.ok("Pago pendiente. Reserva #" + reservaId + " en proceso.");
		};
	}
}