package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;

@Entity
public class DriveEntity extends ComputerHardwareEntity {

    @Column
    private int storageGB;

    @Column
    private String driveType;

    @Column
    private int readSpeedMBs;

    @Column
    private int writeSpeedMBs;

    public DriveEntity() {}

    public DriveEntity(String name, String manufacturer, int warrantyMonths, Double price,
                       int storageGB, String driveType, int readSpeedMBs, int writeSpeedMBs) {
        super(name, manufacturer, warrantyMonths, price);
        this.storageGB     = storageGB;
        this.driveType     = driveType;
        this.readSpeedMBs  = readSpeedMBs;
        this.writeSpeedMBs = writeSpeedMBs;
    }

    public int    getStorageGB()              { return storageGB; }
    public void   setStorageGB(int gb)        { this.storageGB = gb; }

    public String getDriveType()              { return driveType; }
    public void   setDriveType(String type)   { this.driveType = type; }

    public int    getReadSpeedMBs()           { return readSpeedMBs; }
    public void   setReadSpeedMBs(int speed)  { this.readSpeedMBs = speed; }

    public int    getWriteSpeedMBs()          { return writeSpeedMBs; }
    public void   setWriteSpeedMBs(int speed) { this.writeSpeedMBs = speed; }

    @Override public String getProductType() { return "Drive"; }
    @Override public void   sellItem()       {}
}