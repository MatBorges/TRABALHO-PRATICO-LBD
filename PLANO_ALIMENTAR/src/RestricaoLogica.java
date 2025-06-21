import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestricaoLogica {
    private final Connection conn;

    public RestricaoLogica(Connection conn) {
        this.conn = conn;
    }

    public void adicionarRestricao(Restricao r) throws SQLException {
        String sql = "INSERT INTO restricoes (nome, descricao) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, r.getNome());
            stmt.setString(2, r.getDescricao());
            stmt.executeUpdate();
        }
    }

    public List<Restricao> listarRestricoes() throws SQLException {
        List<Restricao> restricoes = new ArrayList<>();
        String sql = "SELECT * FROM restricoes";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Restricao r = new Restricao(
                        rs.getInt("id"),
                        rs.getString("nome"),
                        rs.getString("descricao")
                );
                restricoes.add(r);
            }
        }
        return restricoes;
    }
}