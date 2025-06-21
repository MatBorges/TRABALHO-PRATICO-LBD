import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AlimentoLogica {

    private final Connection conn;

    public AlimentoLogica(Connection conn) {
        this.conn = conn;
    }

    public void adicionarAlimento(Alimento a) throws SQLException {
        String sql = "INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, a.getNome());
            stmt.setInt(2, a.getGrupo_alimentar_id());
            stmt.setDouble(3, a.getCalorias_kcal());
            stmt.setDouble(4, a.getProteinas_g());
            stmt.setDouble(5, a.getCarboidratos_g());
            stmt.setDouble(6, a.getGorduras_g());
            stmt.setDouble(7, a.getSodio_mg());
            stmt.setInt(8, a.getIndice_glicemico());
            stmt.setBoolean(9, a.isLactose());
            stmt.setBoolean(10, a.isGluten());
            stmt.setBoolean(11, a.isVegano());
            stmt.executeUpdate();
        }
    }


    public List<Alimento> listarAlimentos() throws SQLException {
        List<Alimento> alimentos = new ArrayList<>();
        String sql = "SELECT * FROM alimentos";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Alimento a = new Alimento(
                        rs.getInt("id"),
                        rs.getString("nome"),
                        rs.getInt("grupo_alimentar_id"),
                        rs.getDouble("calorias_kcal"),
                        rs.getDouble("proteinas_g"),
                        rs.getDouble("carboidratos_g"),
                        rs.getDouble("gorduras_g"),
                        rs.getDouble("sodio_mg"),
                        rs.getInt("indice_glicemico"),
                        rs.getBoolean("lactose"),
                        rs.getBoolean("gluten"), 
                        rs.getBoolean("vegano")
                );
                alimentos.add(a);
            }
        }
        return alimentos;
    }
}
