import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RefeicaoLogica {
    private final Connection conn;

    public RefeicaoLogica(Connection conn) {
        this.conn = conn;
    }

    public List<Refeicao> listarRefeicoes() throws SQLException {
        List<Refeicao> refeicoes = new ArrayList<>();
        String sql = "SELECT * FROM refeicoes";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Refeicao r = new Refeicao(
                        rs.getInt("id"),
                        rs.getString("nome"),
                        rs.getString("tipo"),
                        rs.getDate("horario_sugerido")
                );
                refeicoes.add(r);
            }
        }
        return refeicoes;
    }
}
