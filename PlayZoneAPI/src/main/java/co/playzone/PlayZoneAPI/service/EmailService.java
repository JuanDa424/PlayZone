package co.playzone.PlayZoneAPI.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
public class EmailService {

	@Value("${RESEND_API_KEY:}")
	private String apiKey;

	@Value("${RESEND_FROM_EMAIL:no-reply@controlsas.com.co}")
	private String fromEmail;

	private final HttpClient httpClient = HttpClient.newHttpClient();

	private void sendEmail(String toEmail, String subject, String textContent) {

		// 🔥 protección clave: si no hay API KEY, no rompe la app
		if (apiKey == null || apiKey.isBlank()) {
			System.out.println("⚠️ Resend API Key no configurada. Email no enviado.");
			return;
		}

		String body = String.format("""
				{
				  "from": "PlayZone <%s>",
				  "to": ["%s"],
				  "subject": "%s",
				  "text": "%s"
				}
				""", fromEmail, toEmail, subject, textContent.replace("\n", "\\n").replace("\"", "\\\""));

		HttpRequest request = HttpRequest.newBuilder().uri(URI.create("https://api.resend.com/emails"))
				.header("Authorization", "Bearer " + apiKey).header("Content-Type", "application/json")
				.POST(HttpRequest.BodyPublishers.ofString(body)).build();

		try {
			HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

			if (response.statusCode() != 200) {
				System.out.println("❌ Error enviando email: " + response.body());
			} else {
				System.out.println("✅ Email enviado correctamente a " + toEmail);
			}

		} catch (Exception e) {
			System.out.println("❌ Fallo al enviar email: " + e.getMessage());
		}
	}

	public void sendVerificationEmail(String toEmail, String code) {
		String subject = "Código de verificación PlayZone";
		String text = "Hola!\n\nGracias por registrarte en PlayZone.\nTu código es: " + code
				+ "\n\nExpira en 10 minutos.\n\n- PlayZone";
		sendEmail(toEmail, subject, text);
	}

	public void sendPasswordResetEmail(String toEmail, String code) {
		String subject = "Recuperación de contraseña PlayZone";
		String text = "Hola!\n\nTu código de recuperación es: " + code + "\n\nExpira en 10 minutos.\n\n- PlayZone";
		sendEmail(toEmail, subject, text);
	}
}