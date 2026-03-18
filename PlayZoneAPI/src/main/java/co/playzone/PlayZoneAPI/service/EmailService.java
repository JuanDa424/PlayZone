package co.playzone.PlayZoneAPI.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
public class EmailService {

    @Value("${brevo.api.key}")
    private String apiKey;

    private final HttpClient httpClient = HttpClient.newHttpClient();

    private void sendEmail(String toEmail, String subject, String textContent) {
        String body = String.format("""
                {
                  "sender": { "name": "PlayZone", "email": "a55b2a001@smtp-brevo.com" },
                  "to": [{ "email": "%s" }],
                  "subject": "%s",
                  "textContent": "%s"
                }
                """, toEmail, subject, textContent.replace("\n", "\\n").replace("\"", "\\\""));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.brevo.com/v3/smtp/email"))
                .header("accept", "application/json")
                .header("api-key", apiKey)
                .header("content-type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 201) {
                throw new RuntimeException("Error enviando email: " + response.body());
            }
        } catch (Exception e) {
            throw new RuntimeException("Fallo al enviar email a " + toEmail, e);
        }
    }

    public void sendVerificationEmail(String toEmail, String code) {
        String subject = "Codigo de verificacion PlayZone";
        String text = "Hola!\n\nGracias por registrarte en PlayZone.\nTu codigo de verificacion es: "
                + code + "\n\nEste codigo expira en 10 minutos.\n\nSi no fuiste tu, ignora este mensaje.\n\n- El equipo de PlayZone";
        sendEmail(toEmail, subject, text);
    }

    public void sendPasswordResetEmail(String toEmail, String code) {
        String subject = "Recuperacion de contrasena PlayZone";
        String text = "Hola!\n\nRecibimos una solicitud para restablecer tu contrasena en PlayZone.\nTu codigo de recuperacion es: "
                + code + "\n\nEste codigo expira en 10 minutos.\n\nSi no fuiste tu, ignora este mensaje.\n\n- El equipo de PlayZone";
        sendEmail(toEmail, subject, text);
    }
}