package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public abstract class ComputerHardwareEntity extends ProductEntity {

    @Column
    private String name;

    @Column
    private String manufacturer;

    @Column
    private int warrantyMonths;

    @Column(name = "hw_price")
    private Double price;

    public ComputerHardwareEntity() {}

    public ComputerHardwareEntity(String name, String manufacturer, int warrantyMonths, Double price) {
        this.name           = name;
        this.manufacturer   = manufacturer;
        this.warrantyMonths = warrantyMonths;
        this.price          = price;
    }

    public String getName()                          { return name; }
    public void   setName(String name)               { this.name = name; }

    public String getManufacturer()                  { return manufacturer; }
    public void   setManufacturer(String m)          { this.manufacturer = m; }

    public int    getWarrantyMonths()                { return warrantyMonths; }
    public void   setWarrantyMonths(int w)           { this.warrantyMonths = w; }

    @Override
    public Double getPrice()                         { return price != null ? price : 0.0; }
    public void   setPrice(Double price)             { this.price = price; }

    @Override
    public String getProductType() { return "Hardware"; }
}