// co/playzone/PlayZoneAPI/service/EmailService.java
package co.playzone.PlayZoneAPI.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

	@Autowired
	private JavaMailSender mailSender;

	public void sendVerificationEmail(String toEmail, String code) {
		SimpleMailMessage message = new SimpleMailMessage();
		message.setTo(toEmail);
		message.setSubject("Código de verificación PlayZone");
		message.setText("¡Hola!\n\n" + "Gracias por registrarte en PlayZone.\n" + "Tu código de verificación es: "
				+ code + "\n\n" + "Este código expira en 10 minutos.\n\n" + "Si no fuiste tú, ignora este mensaje.\n\n"
				+ "– El equipo de PlayZone");
		mailSender.send(message);
	}

	public void sendPasswordResetEmail(String toEmail, String code) {
		SimpleMailMessage message = new SimpleMailMessage();
		message.setTo(toEmail);
		message.setSubject("Recuperación de contraseña PlayZone");
		message.setText("¡Hola!\n\n" + "Recibimos una solicitud para restablecer tu contraseña en PlayZone.\n"
				+ "Tu código de recuperación es: " + code + "\n\n" + "Este código expira en 10 minutos.\n\n"
				+ "Si no fuiste tú, ignora este mensaje.\n\n" + "– El equipo de PlayZone");
		mailSender.send(message);
	}
}