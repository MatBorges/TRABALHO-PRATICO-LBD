import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioLogica {
    private final Connection conn;

    public UsuarioLogica(Connection conn) {
        this.conn = conn;
    }

    public void adicionarUsuario(Usuario u) throws SQLException {
        String sql = "INSERT INTO usuarios (nome, email, data_nascimento, sexo, peso_kg, altura_cm, ativo) VALUES (?, ?, ?, ?::tipo_sexo, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, u.getNome());
            stmt.setString(2, u.getEmail());
            stmt.setDate(3, u.getDataNascimento());
            stmt.setString(4, u.getSexo());
            stmt.setDouble(5, u.getPesoKg());
            stmt.setInt(6, u.getAlturaCm());
            stmt.setBoolean(7, u.isAtivo());
            stmt.executeUpdate();
        }
    }

    public List<Usuario> listarUsuarios() throws SQLException {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Usuario p = new Usuario(
                        rs.getString("nome"),
                        rs.getString("email"),
                        rs.getDate("data_nascimento"),
                        rs.getString("sexo"),
                        rs.getDouble("peso_kg"),
                        rs.getInt("altura_cm"),
                        rs.getBoolean("ativo")
                );
                usuarios.add(p);
            }
        }
        return usuarios;
    }
}