package com.videogame.example.first.model;

public class Client {
	
	private String name;
	private String surname;
	private String typeSubscription;
	
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

	public void setName(String name) {
		this.name = name;
	}

	public void setSurname(String surname) {
		this.surname = surname;
	}

	public void setTypeSubscription(String typeSubscription) {
		this.typeSubscription = typeSubscription;
	}

	@Override
	public String toString() {
		return "Client [name=" + name + ", surname=" + surname + ", typeSubscription=" + typeSubscription + "]";
	}

}
