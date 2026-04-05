package csd230.bookstore;


import com.github.javafaker.Commerce;
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

import java.time.LocalDate;
import java.time.LocalDateTime;


@SpringBootApplication
public class Application implements CommandLineRunner {
    private final ProductEntityRepository productRepository;
    private final CartEntityRepository cartRepository;
    private final UserEntityRepository userRepository;
    private final PasswordEncoder passwordEncoder;


    public Application(ProductEntityRepository productRepository,
                       CartEntityRepository cartRepository,
                       UserEntityRepository userRepository,
                       PasswordEncoder passwordEncoder
    ) {
        this.productRepository = productRepository;
        this.cartRepository = cartRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }


    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }


    @Override
    @Transactional
    public void run(String... args) throws Exception {
        Faker faker = new Faker();
        Commerce cm = faker.commerce();
        com.github.javafaker.Number number = faker.number();
        com.github.javafaker.Book fakeBook = faker.book();
        String name = cm.productName();
        String description = cm.material();

        for (int i = 0; i < 10; i++) {
            // We call the faker methods inside the loop so each book gets unique data
            String title = faker.book().title();
            String author = faker.book().author();
            String priceString = faker.commerce().price();

            // Create the book entity with the random data
            BookEntity book = new BookEntity(
                    title,
                    Double.parseDouble(priceString),
                    10,      // Defaulting to 10 copies each
                    author
            );

            // Save to database
            productRepository.save(book);

            System.out.println("Saved Book " + (i + 1) + ": " + title + " by " + author);
        }

        // ── Seed CPUs ────────────────────────────────────────────────
            productRepository.save(new CpuEntity(36,  6));  // AMD Ryzen 5 7600X
            productRepository.save(new CpuEntity(36,  8));  // Intel Core i5-13600K
            productRepository.save(new CpuEntity(36, 12));  // AMD Ryzen 9 5900X
            productRepository.save(new CpuEntity(36, 14));  // Intel Core i7-13700K
            productRepository.save(new CpuEntity(36, 16));  // AMD Ryzen 9 7950X
            productRepository.save(new CpuEntity(36, 24));  // Intel Core i9-14900K
            System.out.println("Default CPUs seeded.");


        // ── Seed GPUs ────────────────────────────────────────────────
            productRepository.save(new GpuEntity(36,  8));  // NVIDIA RTX 4060 Ti
            productRepository.save(new GpuEntity(36,  8));  // AMD RX 7600
            productRepository.save(new GpuEntity(36, 12));  // AMD RX 7700 XT
            productRepository.save(new GpuEntity(36, 16));  // NVIDIA RTX 4080 Super
            productRepository.save(new GpuEntity(36, 24));  // AMD RX 7900 XTX
            productRepository.save(new GpuEntity(36, 24));  // NVIDIA RTX 4090
            System.out.println("Default GPUs seeded.");

            productRepository.save(new MagazineEntity("test",  10, 15, 10, LocalDateTime.now()));




        // ------------------------------------
        // CREATE USERS (Lecture 2.6)
        // ------------------------------------


        // Admin User (Can Add/Edit/Delete)
        UserEntity admin = new UserEntity("admin", passwordEncoder.encode("admin"), "ADMIN");
        userRepository.save(admin);


        // Regular User (Can only View/Buy)
        UserEntity user = new UserEntity("user", passwordEncoder.encode("user"), "USER");
        userRepository.save(user);


        System.out.println("Default users created: admin/admin and user/user");

        // Check if a cart exists, if not, create one
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
                // Allow access to all /api endpoints from any origin
                registry.addMapping("/api/**").allowedOrigins("*");
            }
        };
    }



}

