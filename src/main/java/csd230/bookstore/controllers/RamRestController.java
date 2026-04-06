package csd230.bookstore.controllers;

import csd230.bookstore.entities.RamEntity;
import csd230.bookstore.repositories.RamEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/ram")
public class RamRestController {

    private final RamEntityRepository ramRepo;

    public RamRestController(RamEntityRepository ramRepo) {
        this.ramRepo = ramRepo;
    }

    @GetMapping
    public List<RamEntity> getAll() { return ramRepo.findAll(); }

    @GetMapping("/{id}")
    public ResponseEntity<RamEntity> getById(@PathVariable Long id) {
        return ramRepo.findById(id).map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public RamEntity create(@RequestBody RamEntity ram) { return ramRepo.save(ram); }

    @PutMapping("/{id}")
    public ResponseEntity<RamEntity> update(@PathVariable Long id, @RequestBody RamEntity updated) {
        return ramRepo.findById(id).map(existing -> {
            existing.setName(updated.getName());
            existing.setManufacturer(updated.getManufacturer());
            existing.setWarrantyMonths(updated.getWarrantyMonths());
            existing.setPrice(updated.getPrice());
            existing.setCapacityGB(updated.getCapacityGB());
            existing.setGeneration(updated.getGeneration());
            existing.setSpeedMHz(updated.getSpeedMHz());
            return ResponseEntity.ok(ramRepo.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!ramRepo.existsById(id)) return ResponseEntity.notFound().build();
        ramRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}