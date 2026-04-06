package csd230.bookstore.repositories;

import csd230.bookstore.entities.DriveEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DriveEntityRepository extends JpaRepository<DriveEntity, Long> {}