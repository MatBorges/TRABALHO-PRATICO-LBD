import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AvaliacaoLogica {
    private final Connection conn;

    public AvaliacaoLogica(Connection conn) {
        this.conn = conn;
    }

    public void adicionarAvaliacao(Avaliacao a) throws SQLException {
        String sql = "INSERT INTO avaliacoes (plano_id, usuario_id, nota, comentario) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, a.getPlanoId());
            stmt.setInt(2, a.getUsuarioId());
            stmt.setInt(3, a.getNota());
            stmt.setString(4, a.getComentário());
            stmt.executeUpdate();
        }
    }


    public List<Avaliacao> listarAvaliacoes() throws SQLException {
        List<Avaliacao> avaliacoes = new ArrayList<>();
        String sql = "SELECT * FROM avaliacoes";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Avaliacao a = new Avaliacao(
                        rs.getInt("id"),
                        rs.getInt("plano_id"),
                        rs.getInt("usuario_id"),
                        rs.getInt("nota"),
                        rs.getString("comentario"),
                        rs.getTimestamp("data_avaliacao")
                );
                avaliacoes.add(a);
            }
        }
        return avaliacoes;
    }
    
}



