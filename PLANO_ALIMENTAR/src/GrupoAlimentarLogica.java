import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GrupoAlimentarLogica {

    private final Connection conn;

    public GrupoAlimentarLogica(Connection conn) {
        this.conn = conn;
    }
    
    public void adicionarGrupoAlimentar(GrupoAlimentar ga) throws SQLException {
        String sql = "INSERT INTO grupos_alimentares (nome) VALUES (?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, ga.getNome());
            stmt.executeUpdate();
        }
    }

    public List<GrupoAlimentar> listarGruposAlimentares() throws SQLException {
        List<GrupoAlimentar> gruposAlimentares = new ArrayList<>();
        String sql = "SELECT * FROM grupos_alimentares";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                GrupoAlimentar ga = new GrupoAlimentar(
                        rs.getInt("id"),
                        rs.getString("nome")
                );
                gruposAlimentares.add(ga);
            }
        }
        return gruposAlimentares;
    }
}
