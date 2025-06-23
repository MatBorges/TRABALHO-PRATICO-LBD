import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlanoAlimentarLogica {
    private final Connection conn;

    public PlanoAlimentarLogica(Connection conn) {
        this.conn = conn;
    }

    public void gerarPlanoAlimentar(int usuarioId) throws SQLException {
        String sql = "select gerar_plano_automatico(?);";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, usuarioId);
            stmt.executeQuery();
        }
    }


    public List<PlanoAlimentar> listarPlanosAlimentares(int usuarioId) throws SQLException {
        List<PlanoAlimentar> planosAlimentares = new ArrayList<>();
        String sql = "SELECT * FROM planos_alimentares WHERE usuario_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    PlanoAlimentar p = new PlanoAlimentar(
                            rs.getInt("id"),
                            rs.getInt("usuario_id"),
                            rs.getDate("data"),
                            rs.getString("objetivo"),
                            rs.getString("observacoes")
                    );
                    planosAlimentares.add(p);
                }
            }
        }
        return planosAlimentares;
    }


}
