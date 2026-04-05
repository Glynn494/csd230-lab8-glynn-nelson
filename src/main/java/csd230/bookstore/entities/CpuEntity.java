package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public class CpuEntity extends ComputerHardwareEntity {

    @Column
    private int cores;

    public CpuEntity() {}

    public CpuEntity(int warrantyMonths, int cores) {
        super(warrantyMonths);
        this.cores = cores;
    }

    public int  getCores()          { return cores; }
    public void setCores(int cores) { this.cores = cores; }

    @Override
    public String getProductType() { return "CPU"; }

    @Override
    public void sellItem() {

    }

    @Override
    public Double getPrice() {
        return 0.0;
    }
}