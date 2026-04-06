package csd230.bookstore.controllers;

import csd230.bookstore.entities.DriveEntity;
import csd230.bookstore.repositories.DriveEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/drives")
public class DriveRestController {

    private final DriveEntityRepository driveRepo;

    public DriveRestController(DriveEntityRepository driveRepo) {
        this.driveRepo = driveRepo;
    }

    @GetMapping
    public List<DriveEntity> getAll() { return driveRepo.findAll(); }

    @GetMapping("/{id}")
    public ResponseEntity<DriveEntity> getById(@PathVariable Long id) {
        return driveRepo.findById(id).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public DriveEntity create(@RequestBody DriveEntity drive) { return driveRepo.save(drive); }

    @PutMapping("/{id}")
    public ResponseEntity<DriveEntity> update(@PathVariable Long id, @RequestBody DriveEntity updated) {
        return driveRepo.findById(id).map(existing -> {
            existing.setName(updated.getName());
            existing.setManufacturer(updated.getManufacturer());
            existing.setWarrantyMonths(updated.getWarrantyMonths());
            existing.setPrice(updated.getPrice());
            existing.setStorageGB(updated.getStorageGB());
            existing.setDriveType(updated.getDriveType());
            existing.setReadSpeedMBs(updated.getReadSpeedMBs());
            existing.setWriteSpeedMBs(updated.getWriteSpeedMBs());
            return ResponseEntity.ok(driveRepo.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!driveRepo.existsById(id)) return ResponseEntity.notFound().build();
        driveRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}