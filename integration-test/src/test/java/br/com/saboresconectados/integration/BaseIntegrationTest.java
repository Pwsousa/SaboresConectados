package br.com.saboresconectados.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.RestAssured;
import io.restassured.config.ObjectMapperConfig;
import io.restassured.mapper.ObjectMapperType;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@ActiveProfiles("integration")
public abstract class BaseIntegrationTest {

    @LocalServerPort
    protected int port;

    protected static final Network network = Network.newNetwork();

    @Container
    protected static final MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("test_db")
            .withUsername("test")
            .withPassword("test")
            .withNetwork(network)
            .withNetworkAliases("mysql");

    protected ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        RestAssured.port = port;
        RestAssured.baseURI = "http://localhost";
        RestAssured.config = RestAssured.config()
                .objectMapperConfig(ObjectMapperConfig.objectMapperConfig()
                        .defaultObjectMapperType(ObjectMapperType.JACKSON_2));
        RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();
    }

    protected String getBaseUrl() {
        return "http://localhost:" + port;
    }

    protected String getDatabaseUrl() {
        return mysql.getJdbcUrl();
    }

    protected String getDatabaseUsername() {
        return mysql.getUsername();
    }

    protected String getDatabasePassword() {
        return mysql.getPassword();
    }
}
