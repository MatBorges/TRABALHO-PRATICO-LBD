import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoBD {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5433/TESTE_TRABALHO_LBD";
        String usuario = "postgres";
        String senha = "minhasenha";

        try (Connection conexao = DriverManager.getConnection(url, usuario, senha)) {
            System.out.println("Conexão realizada com sucesso!");
        } catch (SQLException e) {
            System.out.println("Erro ao conectar: " + e.getMessage());
        }
    }
}
