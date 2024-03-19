package com.videogame.example.second.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;
import com.videogame.example.second.model.Videogame;

import java.util.*;

@RestController
public class SubscriptionController {
	
	private List<Videogame> videogamesList = new ArrayList<>();

	@GetMapping("/") 
	public ResponseEntity<String> getHome() {
		String welcome = "Welcome to VideoGame Store! Please add videogame to Database to path /add/videogame.\n" +
						 "Otherwise, please delete with /remove/{idProduct} <--- Instead of idProduct, select the id you want to delete.";
					return new ResponseEntity<>(welcome, HttpStatus.OK);
	}
	
	@GetMapping("/health")
	public ResponseEntity<String> checkStatus() {
		return new ResponseEntity<>("Service is up and running", HttpStatus.OK);
	}

	@CrossOrigin(origins = "http://localhost:8080")
	@GetMapping("/videogames") 
	public List<Videogame> getVideogames() {
		return videogamesList;
	}
	
	@PostMapping("/add/videogame")
	public Map<String, Videogame> addVideoGameToList(@Validated @RequestBody Videogame videogame) {
		Map<String, Videogame> mapResponse = new HashMap<>();
		if (videogame.getName() == null || videogame.getType() == null || videogame.getPrice() == 0) {
			mapResponse.put("Videogame not Added, maybe is empty. Try Again.", videogame);
		} else { 
			mapResponse.put("Videogame Successful Added", videogame);
			videogamesList.add(videogame);
		}
		return mapResponse;
	}
	
	@DeleteMapping("/remove/{idProduct}")
	public Map<String, Long> removeVideogameToList(@PathVariable long idProduct) {
		Map<String, Long> mapResponse = new HashMap<>();
		Iterator<Videogame> v = videogamesList.iterator();
		while(v.hasNext()) {
			Videogame v1 = v.next();
			if(v1.getIdProduct() == idProduct) {
				v.remove();
				mapResponse.put("Founded and removed, idProduct ", idProduct);
			}
		}
		if(mapResponse.isEmpty()) {
			mapResponse.put("Not Founded idProduct ", idProduct);
		}
		return mapResponse;
	}
}
