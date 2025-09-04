package br.com.saboresconectados.integration;

import io.restassured.http.ContentType;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

public class CardapioIntegrationTest extends BaseIntegrationTest {

    @Test
    void shouldCreateAndRetrieveItem() {
        // Given
        String itemJson = """
            {
                "nome": "Pizza Margherita",
                "descricao": "Pizza com molho de tomate, mussarela e manjericão",
                "preco": 35.90,
                "categoria": "PIZZA",
                "disponivel": true
            }
            """;

        // When & Then - Create item
        String itemId = given()
                .contentType(ContentType.JSON)
                .body(itemJson)
                .when()
                .post("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .body("id", notNullValue())
                .body("nome", equalTo("Pizza Margherita"))
                .body("preco", equalTo(35.90f))
                .body("categoria", equalTo("PIZZA"))
                .body("disponivel", equalTo(true))
                .extract()
                .path("id");

        // When & Then - Retrieve item
        given()
                .when()
                .get("/cardapio/itens/{id}", itemId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("id", equalTo(itemId))
                .body("nome", equalTo("Pizza Margherita"))
                .body("preco", equalTo(35.90f));
    }

    @Test
    void shouldListItemsWithPagination() {
        // Given - Create multiple items
        for (int i = 1; i <= 5; i++) {
            String itemJson = String.format("""
                {
                    "nome": "Item %d",
                    "descricao": "Descrição do item %d",
                    "preco": %.2f,
                    "categoria": "PIZZA",
                    "disponivel": true
                }
                """, i, i, 10.0 + i);

            given()
                    .contentType(ContentType.JSON)
                    .body(itemJson)
                    .when()
                    .post("/cardapio/itens")
                    .then()
                    .statusCode(HttpStatus.CREATED.value());
        }

        // When & Then - List items with pagination
        given()
                .queryParam("page", 0)
                .queryParam("size", 3)
                .when()
                .get("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("content", hasSize(3))
                .body("totalElements", greaterThanOrEqualTo(5))
                .body("totalPages", greaterThanOrEqualTo(2))
                .body("first", equalTo(true))
                .body("last", equalTo(false));
    }

    @Test
    void shouldUpdateItem() {
        // Given - Create item
        String itemJson = """
            {
                "nome": "Pizza Original",
                "descricao": "Pizza original",
                "preco": 30.00,
                "categoria": "PIZZA",
                "disponivel": true
            }
            """;

        String itemId = given()
                .contentType(ContentType.JSON)
                .body(itemJson)
                .when()
                .post("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract()
                .path("id");

        // When - Update item
        String updatedItemJson = """
            {
                "nome": "Pizza Atualizada",
                "descricao": "Pizza com nova descrição",
                "preco": 35.00,
                "categoria": "PIZZA",
                "disponivel": false
            }
            """;

        // Then
        given()
                .contentType(ContentType.JSON)
                .body(updatedItemJson)
                .when()
                .put("/cardapio/itens/{id}", itemId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("id", equalTo(itemId))
                .body("nome", equalTo("Pizza Atualizada"))
                .body("preco", equalTo(35.00f))
                .body("disponivel", equalTo(false));
    }

    @Test
    void shouldDeleteItem() {
        // Given - Create item
        String itemJson = """
            {
                "nome": "Item para Deletar",
                "descricao": "Item que será deletado",
                "preco": 20.00,
                "categoria": "PIZZA",
                "disponivel": true
            }
            """;

        String itemId = given()
                .contentType(ContentType.JSON)
                .body(itemJson)
                .when()
                .post("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract()
                .path("id");

        // When - Delete item
        given()
                .when()
                .delete("/cardapio/itens/{id}", itemId)
                .then()
                .statusCode(HttpStatus.NO_CONTENT.value());

        // Then - Verify item is deleted
        given()
                .when()
                .get("/cardapio/itens/{id}", itemId)
                .then()
                .statusCode(HttpStatus.NOT_FOUND.value());
    }

    @Test
    void shouldReturnNotFoundForInvalidItem() {
        given()
                .when()
                .get("/cardapio/itens/999")
                .then()
                .statusCode(HttpStatus.NOT_FOUND.value());
    }

    @Test
    void shouldValidateRequiredFields() {
        String invalidItemJson = """
            {
                "descricao": "Item sem nome",
                "preco": 20.00,
                "categoria": "PIZZA"
            }
            """;

        given()
                .contentType(ContentType.JSON)
                .body(invalidItemJson)
                .when()
                .post("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.BAD_REQUEST.value());
    }
}
