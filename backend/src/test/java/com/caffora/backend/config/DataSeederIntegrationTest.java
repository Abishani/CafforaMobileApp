package com.caffora.backend.config;

import com.caffora.backend.model.Product;
import com.caffora.backend.model.Role;
import com.caffora.backend.repo.CafeTableRepo;
import com.caffora.backend.repo.CategoryRepo;
import com.caffora.backend.repo.ProductRepo;
import com.caffora.backend.repo.UserRepo;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assumptions.assumeThat;

/**
 * Runs against a brand-new in-memory database (test profile, create-drop), exactly like a
 * first production start: the seeder must produce a menu whose images actually resolve.
 */
@SpringBootTest
@ActiveProfiles("test")
class DataSeederIntegrationTest {

    private static final Map<String, String> EXPECTED = Map.of(
            "Craft Flat White", "/images/Beverages/Craft-Flat-White.jpg",
            "Cinnamon Swirl Bun", "/images/Snacks/Cinnamon-Swirl-Bun.png",
            "Avocado Sourdough Toast", "/images/Meals/Avocado-Sourdough-Toast.png",
            "Pistachio Raspberry Tart", "/images/Desserts/Pistachio-Raspberry-Tart.png",
            "Sourdough Chocolate Cookie", "/images/Desserts/Sourdough-Chocolate-Cookie.png",
            "Iced Honey Oat Latte", "/images/Beverages/Iced-Honey-Oat-Latte.png",
            "Smoked Turkey Ciabatta", "/images/Meals/Smoked-Turkey-Ciabatta.png",
            "Matcha Jasmine Crepe", "/images/Snacks/Matcha-Jasmine-Crepe.png"
    );

    @Autowired private DataSeeder dataSeeder;
    @Autowired private ProductRepo productRepo;
    @Autowired private CategoryRepo categoryRepo;
    @Autowired private UserRepo userRepo;
    @Autowired private CafeTableRepo cafeTableRepo;

    @Test
    @Transactional(readOnly = true) // product.category is lazy; read it inside a session (rolled back)
    void freshDatabaseGetsEveryProductWithItsImagePath() {
        assertThat(categoryRepo.findAll()).extracting("name")
                .containsExactlyInAnyOrder("Beverages", "Snacks", "Meals", "Desserts");

        List<Product> products = productRepo.findAll();
        Map<String, String> actual = products.stream().collect(Collectors.toMap(Product::getName, Product::getImageUrl));
        assertThat(actual).isEqualTo(EXPECTED);

        for (Product p : products) {
            // folder matches the product's category, format stays /images/<Category>/<file>
            assertThat(p.getImageUrl())
                    .startsWith("/images/" + p.getCategory().getName() + "/")
                    .matches("^/images/(Beverages|Desserts|Meals|Snacks)/[^/]+\\.(jpg|jpeg|png|webp)$");
        }
    }

    @Test
    void everySeededImageFileExistsInTheWebApp() {
        // backend tests run from backend/, so the web app is a sibling directory
        Path webPublic = Path.of("..", "web", "public");
        assumeThat(Files.isDirectory(webPublic)).as("web/public present (full repo checkout)").isTrue();
        for (String url : EXPECTED.values()) {
            assertThat(webPublic.resolve(url.substring(1))).as(url).isRegularFile();
        }
    }

    @Test
    void rerunningTheSeederNeverDuplicatesOrOverwrites() throws Exception {
        long admins = userRepo.findAll().stream().filter(u -> u.getRole() == Role.ADMIN).count();
        long tables = cafeTableRepo.count();

        // Simulate an admin having edited a product in production.
        Product edited = productRepo.findAll().get(0);
        String originalName = edited.getName();
        String originalImage = edited.getImageUrl();
        edited.setImageUrl("/images/Beverages/Classic-Espresso.jpg");
        edited.setName("Renamed By Admin");
        productRepo.save(edited);
        try {
            dataSeeder.run();

            assertThat(productRepo.count()).isEqualTo(EXPECTED.size());
            assertThat(categoryRepo.count()).isEqualTo(4);
            assertThat(userRepo.findAll().stream().filter(u -> u.getRole() == Role.ADMIN).count()).isEqualTo(admins);
            assertThat(cafeTableRepo.count()).isEqualTo(tables);
            Product after = productRepo.findById(edited.getId()).orElseThrow();
            assertThat(after.getName()).isEqualTo("Renamed By Admin");
            assertThat(after.getImageUrl()).isEqualTo("/images/Beverages/Classic-Espresso.jpg");
        } finally {
            // The test database is shared with other test classes; put the product back.
            Product restore = productRepo.findById(edited.getId()).orElseThrow();
            restore.setName(originalName);
            restore.setImageUrl(originalImage);
            productRepo.save(restore);
        }
    }
}
