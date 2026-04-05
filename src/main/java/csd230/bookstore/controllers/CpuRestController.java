package csd230.bookstore.controllers;

import csd230.bookstore.entities.CpuEntity;
import csd230.bookstore.repositories.CpuEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/cpus")
public class CpuRestController {

    private final CpuEntityRepository cpuRepo;

    public CpuRestController(CpuEntityRepository cpuRepo) {
        this.cpuRepo = cpuRepo;
    }

    @GetMapping
    public List<CpuEntity> getAll() {
        return cpuRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<CpuEntity> getById(@PathVariable Long id) {
        return cpuRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public CpuEntity create(@RequestBody CpuEntity cpu) {
        return cpuRepo.save(cpu);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CpuEntity> update(@PathVariable Long id,
                                            @RequestBody CpuEntity updated) {
        return cpuRepo.findById(id).map(existing -> {
            existing.setWarrantyMonths(updated.getWarrantyMonths());
            existing.setCores(updated.getCores());
            return ResponseEntity.ok(cpuRepo.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!cpuRepo.existsById(id)) return ResponseEntity.notFound().build();
        cpuRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}