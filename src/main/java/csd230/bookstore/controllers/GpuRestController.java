package csd230.bookstore.controllers;

import csd230.bookstore.entities.GpuEntity;
import csd230.bookstore.repositories.GpuEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/gpus")
public class GpuRestController {

    private final GpuEntityRepository gpuRepo;

    public GpuRestController(GpuEntityRepository gpuRepo) {
        this.gpuRepo = gpuRepo;
    }

    @GetMapping
    public List<GpuEntity> getAll() {
        return gpuRepo.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<GpuEntity> getById(@PathVariable Long id) {
        return gpuRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public GpuEntity create(@RequestBody GpuEntity gpu) {
        return gpuRepo.save(gpu);
    }

    @PutMapping("/{id}")
    public ResponseEntity<GpuEntity> update(@PathVariable Long id,
                                            @RequestBody GpuEntity updated) {
        return gpuRepo.findById(id).map(existing -> {
            existing.setWarrantyMonths(updated.getWarrantyMonths());
            existing.setVramGB(updated.getVramGB());
            return ResponseEntity.ok(gpuRepo.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!gpuRepo.existsById(id)) return ResponseEntity.notFound().build();
        gpuRepo.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}