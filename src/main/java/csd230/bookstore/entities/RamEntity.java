package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public class RamEntity extends ComputerHardwareEntity {

    @Column
    private int capacityGB;

    @Column
    private String generation;

    @Column
    private int speedMHz;

    public RamEntity() {}

    public RamEntity(String name, String manufacturer, int warrantyMonths, Double price,
                     int capacityGB, String generation, int speedMHz) {
        super(name, manufacturer, warrantyMonths, price);
        this.capacityGB = capacityGB;
        this.generation = generation;
        this.speedMHz   = speedMHz;
    }

    public int    getCapacityGB()           { return capacityGB; }
    public void   setCapacityGB(int gb)     { this.capacityGB = gb; }

    public String getGeneration()           { return generation; }
    public void   setGeneration(String gen) { this.generation = gen; }

    public int    getSpeedMHz()             { return speedMHz; }
    public void   setSpeedMHz(int speed)    { this.speedMHz = speed; }

    @Override public String getProductType() { return "RAM"; }
    @Override public void   sellItem()       {}
}