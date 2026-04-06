package csd230.bookstore;

import com.github.javafaker.Faker;
import csd230.bookstore.entities.*;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import jakarta.transaction.Transactional;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.time.LocalDateTime;

@SpringBootApplication
public class Application implements CommandLineRunner {
    private final ProductEntityRepository productRepository;
    private final CartEntityRepository    cartRepository;
    private final UserEntityRepository    userRepository;
    private final PasswordEncoder         passwordEncoder;

    public Application(ProductEntityRepository productRepository,
                       CartEntityRepository cartRepository,
                       UserEntityRepository userRepository,
                       PasswordEncoder passwordEncoder) {
        this.productRepository = productRepository;
        this.cartRepository    = cartRepository;
        this.userRepository    = userRepository;
        this.passwordEncoder   = passwordEncoder;
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        Faker faker = new Faker();

        // ── Books ────────────────────────────────────────────────────
        for (int i = 0; i < 10; i++) {
            String title  = faker.book().title();
            String author = faker.book().author();
            double price  = Double.parseDouble(faker.commerce().price());
            productRepository.save(new BookEntity(title, price, 10, author));
            System.out.println("Saved Book " + (i + 1) + ": " + title + " by " + author);
        }

        // ── Magazines ────────────────────────────────────────────────
        productRepository.save(new MagazineEntity("National Geographic",  9.99,  50, 12, LocalDateTime.of(2025, 3,  1, 0, 0)));
        productRepository.save(new MagazineEntity("PC Gamer",            12.99,  40, 12, LocalDateTime.of(2025, 3, 15, 0, 0)));
        productRepository.save(new MagazineEntity("Popular Science",      8.99,  35, 12, LocalDateTime.of(2025, 2,  1, 0, 0)));
        productRepository.save(new MagazineEntity("Wired",               10.99,  45, 12, LocalDateTime.of(2025, 3,  1, 0, 0)));
        productRepository.save(new MagazineEntity("New Scientist",       11.99,  30, 12, LocalDateTime.of(2025, 2, 15, 0, 0)));
        productRepository.save(new MagazineEntity("Time",                 7.99,  60, 52, LocalDateTime.of(2025, 3, 10, 0, 0)));
        System.out.println("Magazines seeded.");

        // ── CPUs  (name, manufacturer, warrantyMonths, price, cores) ─
        productRepository.save(new CpuEntity("Ryzen 5 7600X",  "AMD",   36, 229.99,  6));
        productRepository.save(new CpuEntity("Core i5-13600K", "Intel", 36, 279.99,  8));
        productRepository.save(new CpuEntity("Ryzen 9 5900X",  "AMD",   36, 269.99, 12));
        productRepository.save(new CpuEntity("Core i7-13700K", "Intel", 36, 349.99, 16));
        productRepository.save(new CpuEntity("Ryzen 9 7950X",  "AMD",   36, 549.99, 16));
        productRepository.save(new CpuEntity("Core i9-14900K", "Intel", 36, 549.99, 24));
        System.out.println("CPUs seeded.");

        // ── GPUs  (name, manufacturer, warrantyMonths, price, vramGB) ─
        productRepository.save(new GpuEntity("RTX 4060 Ti",    "NVIDIA", 36,  399.99,  8));
        productRepository.save(new GpuEntity("RX 7600",        "AMD",    36,  269.99,  8));
        productRepository.save(new GpuEntity("RX 7700 XT",     "AMD",    36,  349.99, 12));
        productRepository.save(new GpuEntity("RTX 4080 Super", "NVIDIA", 36,  999.99, 16));
        productRepository.save(new GpuEntity("RX 7900 XTX",    "AMD",    36,  949.99, 24));
        productRepository.save(new GpuEntity("RTX 4090",       "NVIDIA", 36, 1599.99, 24));
        System.out.println("GPUs seeded.");

        // ── RAM  (name, manufacturer, warrantyMonths, price, capacityGB, generation, speedMHz) ─
        productRepository.save(new RamEntity("Vengeance DDR5",  "Corsair",  36,  89.99, 32, "DDR5", 6000));
        productRepository.save(new RamEntity("Trident Z5 RGB",  "G.Skill",  36, 109.99, 32, "DDR5", 6400));
        productRepository.save(new RamEntity("Fury Beast DDR5", "Kingston", 36,  54.99, 16, "DDR5", 5200));
        productRepository.save(new RamEntity("Ripjaws V",       "G.Skill",  36,  64.99, 32, "DDR4", 3600));
        productRepository.save(new RamEntity("Vengeance LPX",   "Corsair",  36,  39.99, 16, "DDR4", 3200));
        productRepository.save(new RamEntity("Fury Beast DDR4", "Kingston", 36, 109.99, 64, "DDR4", 3200));
        System.out.println("RAM seeded.");

        // ── Drives  (name, manufacturer, warrantyMonths, price, storageGB, type, readMBs, writeMBs) ─
        productRepository.save(new DriveEntity("970 EVO Plus",  "Samsung", 36,  89.99, 1000, "SSD", 3500, 3300));
        productRepository.save(new DriveEntity("SN850X",        "WD",      36, 109.99, 1000, "SSD", 7300, 6600));
        productRepository.save(new DriveEntity("MP600 Pro XT",  "Corsair", 36, 179.99, 2000, "SSD", 7100, 6500));
        productRepository.save(new DriveEntity("FireCuda 530",  "Seagate", 36, 189.99, 2000, "SSD", 7300, 6900));
        productRepository.save(new DriveEntity("BarraCuda HDD", "Seagate", 24,  49.99, 4000, "HDD",  190,  190));
        productRepository.save(new DriveEntity("WD Blue HDD",   "WD",      24,  44.99, 2000, "HDD",  180,  180));
        System.out.println("Drives seeded.");

        // ── Users ────────────────────────────────────────────────────
        userRepository.save(new UserEntity("admin", passwordEncoder.encode("admin"), "ADMIN"));
        userRepository.save(new UserEntity("user",  passwordEncoder.encode("user"),  "USER"));
        System.out.println("Default users created: admin/admin and user/user");

        // ── Cart ─────────────────────────────────────────────────────
        if (cartRepository.count() == 0) {
            CartEntity defaultCart = new CartEntity();
            cartRepository.save(defaultCart);
            System.out.println("Default Cart created with ID: " + defaultCart.getId());
        }
    }

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**").allowedOrigins("*");
            }
        };
    }
}