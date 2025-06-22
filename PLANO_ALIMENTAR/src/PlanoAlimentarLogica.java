import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlanoAlimentarLogica {
    private final Connection conn;

    public PlanoAlimentarLogica(Connection conn) {
        this.conn = conn;
    }

    public List<PlanoAlimentar> listarPlanosAlimentares() throws SQLException {
        List<PlanoAlimentar> planosAlimentares = new ArrayList<>();
        String sql = "SELECT * FROM planos_alimentares";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                PlanoAlimentar p = new PlanoAlimentar(
                        rs.getInt("id"),
                        rs.getInt("refeicao_id"),
                        rs.getInt("ordem_refeicao")
                );
                planosAlimentares.add(p);
            }
        }
        return planosAlimentares;
    }
}
