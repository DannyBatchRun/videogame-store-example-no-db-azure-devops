package com.videogame.example.third.controller;

import java.util.*;

import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;

import com.videogame.example.third.model.*;

@RestController
public class VideogameController {
    
    private List<Client> clients = new ArrayList<>();
    private List<Videogame> videogames = new ArrayList<>();

    @GetMapping("/") 
    public String getHome() {
        return "Welcome to Videogame Store! Please use /syncronize for syncronize all databases\nAnd then, you can add a videogame to cart's client with /add/cart.\nIf you want to check total price, please use /allcarts endpoint.";
    }

    @GetMapping("/health")
    public String getHealth() {
        return "Service is up and running";
    }

    @GetMapping("/videogames")
    public List<Videogame> getVideogamesSynched() {
        return videogames;
    }

    @GetMapping("/buyers")
    public List<Client> getBuyersWithItsCart() {
        return clients;
    }

    @PostMapping("/synchronize")
    public String synchronizeAll(@Validated @RequestBody Map<String, String> endpoints) {
        RestTemplate restTemplate = new RestTemplate();
        String fullSubscription = endpoints.get("subscriptionEndpoint") + "/registered";
        String fullVideogame = endpoints.get("videogameEndpoint") + "/videogames";
        Videogame[] videogameArray = restTemplate.getForObject(fullVideogame, Videogame[].class);
        Client[] clientArray = restTemplate.getForObject(fullSubscription, Client[].class);
        if (videogameArray != null) {
            for (Videogame newVideogame : videogameArray) {
                boolean exists = false;
                for (Videogame existingVideogame : videogames) {
                    if (existingVideogame.getIdProduct() == newVideogame.getIdProduct()) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    videogames.add(newVideogame);
                }
            }
        }   
        if (clientArray != null) {
            for (Client newClient : clientArray) {
                boolean exists = false;
                for (Client existingClient : clients) {
                    if (existingClient.getName().equals(newClient.getName()) && existingClient.getSurname().equals(newClient.getSurname())) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    clients.add(newClient);
                }
            }
        }
        return "Data synchronized successfully!";
    }
    
    

    @PostMapping("/add/cart")
    public Map<String, Client> addVideogameToCart(@Validated @RequestBody Map<String, String> requestBody) {
        String videogameName = requestBody.get("videogameName");
        String clientName = requestBody.get("clientName");
        String clientSurname = requestBody.get("clientSurname");
        Map<String, Client> responseMap = new HashMap<>();
        for (Videogame videogame : videogames) {
            if (videogame.getName().equals(videogameName)) {
                for (Client client : clients) {
                    if (client.getName().equals(clientName) && client.getSurname().equals(clientSurname)) {
                        client.getVideogames().add(videogame);
                        responseMap.put("Success", client);
                        return responseMap;
                    }
                }
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Client not found");
            }
        }
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Videogame not found");
    }

    @GetMapping("/allcarts")
    public Map<String, Double> getTotalPricePerClient() {
        Map<String, Double> totalPricePerClient = new HashMap<>();
        for (Client client : clients) {
            double total = 0;
            for (Videogame videogame : client.getVideogames()) {
                total += videogame.getPrice();
            }
            totalPricePerClient.put(client.getName() + " " + client.getSurname(), total);
        }
        return totalPricePerClient;
    }
}
