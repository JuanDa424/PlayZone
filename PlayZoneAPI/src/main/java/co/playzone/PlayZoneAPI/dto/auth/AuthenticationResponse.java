package co.playzone.PlayZoneAPI.dto.auth;

import lombok.Builder;
import lombok.Data;

@Data
public class AuthenticationResponse {

	private String token;

	public AuthenticationResponse() {
		// TODO Auto-generated constructor stub
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

}