package br.com.saboresconectados.integration;

import io.restassured.http.ContentType;
import org.awaitility.Awaitility;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import java.time.Duration;
import java.util.Map;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

public class EndToEndIntegrationTest extends BaseIntegrationTest {

    @Test
    void shouldCompleteOrderFlow() {
        // Step 1: Create menu item
        String itemJson = """
            {
                "nome": "Pizza Margherita",
                "descricao": "Pizza com molho de tomate, mussarela e manjericão",
                "preco": 35.90,
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

        // Step 2: Create order
        String orderJson = String.format("""
            {
                "cliente": "João Silva",
                "itens": [
                    {
                        "itemId": %s,
                        "quantidade": 2,
                        "observacoes": "Sem cebola"
                    }
                ]
            }
            """, itemId);

        String orderId = given()
                .contentType(ContentType.JSON)
                .body(orderJson)
                .when()
                .post("/pedidos")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .body("id", notNullValue())
                .body("cliente", equalTo("João Silva"))
                .body("status", equalTo("EM_ANDAMENTO"))
                .body("itens", hasSize(1))
                .extract()
                .path("id");

        // Step 3: Create payment
        String paymentJson = String.format("""
            {
                "pedidoId": %s,
                "valor": 71.80,
                "tipoPagamento": "A_VISTA",
                "status": "PENDENTE"
            }
            """, orderId);

        String paymentId = given()
                .contentType(ContentType.JSON)
                .body(paymentJson)
                .when()
                .post("/pagamentos")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .body("id", notNullValue())
                .body("pedidoId", equalTo(orderId))
                .body("valor", equalTo(71.80f))
                .body("status", equalTo("PENDENTE"))
                .extract()
                .path("id");

        // Step 4: Approve payment
        given()
                .contentType(ContentType.JSON)
                .when()
                .put("/pagamentos/{id}/aprovar", paymentId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("status", equalTo("APROVADO"));

        // Step 5: Verify order status updated
        Awaitility.await()
                .atMost(Duration.ofSeconds(10))
                .untilAsserted(() -> {
                    given()
                            .when()
                            .get("/pedidos/{id}", orderId)
                            .then()
                            .statusCode(HttpStatus.OK.value())
                            .body("status", equalTo("PAGO"));
                });

        // Step 6: Verify payment status
        given()
                .when()
                .get("/pagamentos/{id}", paymentId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("status", equalTo("APROVADO"));
    }

    @Test
    void shouldHandleOrderCancellation() {
        // Step 1: Create menu item
        String itemJson = """
            {
                "nome": "Pizza Pepperoni",
                "descricao": "Pizza com pepperoni e queijo",
                "preco": 40.00,
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

        // Step 2: Create order
        String orderJson = String.format("""
            {
                "cliente": "Maria Santos",
                "itens": [
                    {
                        "itemId": %s,
                        "quantidade": 1
                    }
                ]
            }
            """, itemId);

        String orderId = given()
                .contentType(ContentType.JSON)
                .body(orderJson)
                .when()
                .post("/pedidos")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract()
                .path("id");

        // Step 3: Cancel order
        given()
                .contentType(ContentType.JSON)
                .body(Map.of("status", "CANCELADO"))
                .when()
                .put("/pedidos/{id}/status", orderId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("status", equalTo("CANCELADO"));

        // Step 4: Verify order is cancelled
        given()
                .when()
                .get("/pedidos/{id}", orderId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("status", equalTo("CANCELADO"));
    }

    @Test
    void shouldHandleMultipleItemsInOrder() {
        // Step 1: Create multiple menu items
        String item1Json = """
            {
                "nome": "Pizza Margherita",
                "descricao": "Pizza clássica",
                "preco": 35.90,
                "categoria": "PIZZA",
                "disponivel": true
            }
            """;

        String item2Json = """
            {
                "nome": "Coca-Cola",
                "descricao": "Refrigerante 350ml",
                "preco": 5.50,
                "categoria": "BEBIDA",
                "disponivel": true
            }
            """;

        String item1Id = given()
                .contentType(ContentType.JSON)
                .body(item1Json)
                .when()
                .post("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract()
                .path("id");

        String item2Id = given()
                .contentType(ContentType.JSON)
                .body(item2Json)
                .when()
                .post("/cardapio/itens")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .extract()
                .path("id");

        // Step 2: Create order with multiple items
        String orderJson = String.format("""
            {
                "cliente": "Pedro Costa",
                "itens": [
                    {
                        "itemId": %s,
                        "quantidade": 1
                    },
                    {
                        "itemId": %s,
                        "quantidade": 2
                    }
                ]
            }
            """, item1Id, item2Id);

        String orderId = given()
                .contentType(ContentType.JSON)
                .body(orderJson)
                .when()
                .post("/pedidos")
                .then()
                .statusCode(HttpStatus.CREATED.value())
                .body("itens", hasSize(2))
                .extract()
                .path("id");

        // Step 3: Verify order total calculation
        given()
                .when()
                .get("/pedidos/{id}", orderId)
                .then()
                .statusCode(HttpStatus.OK.value())
                .body("itens", hasSize(2))
                .body("valorTotal", equalTo(46.90f)); // 35.90 + (5.50 * 2)
    }

    @Test
    void shouldValidateBusinessRules() {
        // Test: Cannot create payment for non-existent order
        String paymentJson = """
            {
                "pedidoId": 999,
                "valor": 50.00,
                "tipoPagamento": "A_VISTA",
                "status": "PENDENTE"
            }
            """;

        given()
                .contentType(ContentType.JSON)
                .body(paymentJson)
                .when()
                .post("/pagamentos")
                .then()
                .statusCode(HttpStatus.BAD_REQUEST.value());

        // Test: Cannot approve already approved payment
        // (This would require creating a payment first and then trying to approve it twice)
    }
}
