package com.videogame.example.second.model;

public class Videogame {
	
	private long idProduct;
	private String name;
	private String type;
	private double price;
	
	public Videogame() {
		
	}

	public Videogame(long idProduct, String name, String type, double price) {
		this.idProduct = idProduct;
		this.name = name;
		this.type = type;
		this.price = price;
	}
	
	public long getIdProduct() {
		return idProduct;
	}

	public String getName() {
		return name;
	}

	public String getType() {
		return type;
	}

	public double getPrice() {
		return price;
	}
	
	public void setIdProduct(long idProduct) {
		this.idProduct = idProduct;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setType(String type) {
		this.type = type;
	}

	public void setPrice(double price) {
		this.price = price;
	}

	@Override
	public String toString() {
		return "Videogame [idProduct=" + idProduct + ", name=" + name + ", type=" + type + ", price=" + price + "]";
	}

}
