import java.sql.*;

public class TESTESConexaoBD {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5433/TESTE_TRABALHO_LBD";
        String usuario = "postgres";
        String senha = "minhasenha";

        try (Connection conexao = DriverManager.getConnection(url, usuario, senha)) {
            System.out.println("Conexão realizada com sucesso!");


            Statement stmt = conexao.createStatement();

            String criarTabela = """

                CREATE TYPE tipo_sexo AS ENUM ('Masculino', 'Feminino');

                CREATE TABLE usuarios (
                    id serial primary key,
                    nome varchar(100) not null,
                    email varchar(100) unique not null,
                    data_nascimento date,
                    sexo tipo_sexo,
                    peso_kg decimal(5,2),
                    altura_cm int,
                    objetivo varchar(50),
                    ativo boolean default TRUE
                );

                """;


            stmt.executeUpdate(criarTabela);

            System.out.println("SQL executado!!!!");

            

        } catch (SQLException e) {
            System.out.println("Erro ao conectar: " + e.getMessage());
        }
    }
}
