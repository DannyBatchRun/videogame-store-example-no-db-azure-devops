package com.videogame.example.third.model;

import java.util.List;
import java.util.ArrayList;

public class Client {
	
	private String name;
	private String surname;
	private String typeSubscription;
    private List<Videogame> videogames = new ArrayList<>();
	
	public Client() {
		
	}

	public Client(String name, String surname, String typeSubscription) {
		this.name = name;
		this.surname = surname;
		this.typeSubscription = typeSubscription;
	}

	public String getName() {
		return name;
	}

	public String getSurname() {
		return surname;
	}
	
	public String getTypeSubscription() {
		return typeSubscription;
	}

    public List<Videogame> getVideogames() {
		return videogames;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setSurname(String surname) {
		this.surname = surname;
	}

	public void setTypeSubscription(String typeSubscription) {
		this.typeSubscription = typeSubscription;
	}

    public void setVideogames(List<Videogame> videogames) {
		this.videogames = videogames;
	}

	@Override
	public String toString() {
		return "Client [name=" + name + ", surname=" + surname + ", typeSubscription=" + typeSubscription + ", videogames=" + videogames + "]";
	}

}