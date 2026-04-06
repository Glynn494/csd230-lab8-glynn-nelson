package csd230.bookstore.repositories;

import csd230.bookstore.entities.RamEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RamEntityRepository extends JpaRepository<RamEntity, Long> {}