package com.videogame.example.first.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;
import com.videogame.example.first.model.Client;

import java.util.*;

@RestController
public class SubscriptionController {
	
	private List<Client> clients = new ArrayList<>();

	@GetMapping("/")
	public ResponseEntity<String> getHome() {
		String welcome = "Welcome to VideoGame Store!\nSubmit your request adding path /add/monthlysubscription or /add/annualsubscription\nWith name and surname of the new subscriber.";
		return new ResponseEntity<>(welcome, HttpStatus.OK);
	}

	@CrossOrigin(origins = "http://localhost:8080")
	@GetMapping("/registered") 
	public List<Client> getClients() {
		return clients;
	}

	@GetMapping("/health")
	public ResponseEntity<String> checkStatus() {
		return new ResponseEntity<>("Service is up and running", HttpStatus.OK);
	}
	
	@PostMapping("/add/monthlysubscription")
	public Map<String, Client> addMontlyClientSubscription(@Validated @RequestBody Client client) {
		Map<String, Client> mapResponse = new HashMap<>();
		client.setTypeSubscription("Monthly");
		if (client.getName() == null || client.getSurname() == null) {
			mapResponse.put("Client not Added, maybe is empty. Try Again.\n", client);
		} else { 
			mapResponse.put("Client Successful Added", client);
			clients.add(client);
		}
		return mapResponse;
	}
	
	@PostMapping("/add/annualsubscription")
	public Map<String, Client> addAnnualClientSubscription(@Validated @RequestBody Client client) {
		Map<String, Client> mapResponse = new HashMap<>();
		client.setTypeSubscription("Annual");
		if (client.getName() == null || client.getSurname() == null) {
			mapResponse.put("Client not Added, maybe is empty. Try Again.\n", client);
		} else { 
			mapResponse.put("Client Successful Added", client);
			clients.add(client);
		}
		return mapResponse;
	}
	
}
