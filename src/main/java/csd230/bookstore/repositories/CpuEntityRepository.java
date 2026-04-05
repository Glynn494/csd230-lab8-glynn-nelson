package csd230.bookstore.repositories;

import csd230.bookstore.entities.CpuEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CpuEntityRepository extends JpaRepository<CpuEntity, Long> {}