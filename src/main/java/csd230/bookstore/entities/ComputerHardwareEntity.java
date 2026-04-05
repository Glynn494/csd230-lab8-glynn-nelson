package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public abstract class ComputerHardwareEntity extends ProductEntity {

    @Column
    private int warrantyMonths;

    public ComputerHardwareEntity() {}

    public ComputerHardwareEntity(int warrantyMonths) {
        this.warrantyMonths = warrantyMonths;
    }

    public int  getWarrantyMonths()                   { return warrantyMonths; }
    public void setWarrantyMonths(int warrantyMonths) { this.warrantyMonths = warrantyMonths; }

    @Override
    public String getProductType() { return "Hardware"; }
}