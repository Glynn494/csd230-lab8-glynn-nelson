package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public class GpuEntity extends ComputerHardwareEntity {

    @Column
    private int vramGB;

    public GpuEntity() {}

    public GpuEntity(String name, String manufacturer, int warrantyMonths, Double price, int vramGB) {
        super(name, manufacturer, warrantyMonths, price);
        this.vramGB = vramGB;
    }

    public int  getVramGB()           { return vramGB; }
    public void setVramGB(int vramGB) { this.vramGB = vramGB; }

    @Override public String getProductType() { return "GPU"; }
    @Override public void   sellItem()       {}
}