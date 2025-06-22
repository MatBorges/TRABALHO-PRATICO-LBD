import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioLogica {
    private final Connection conn;

    public UsuarioLogica(Connection conn) {
        this.conn = conn;
    }

    public int adicionarUsuario(Usuario u) throws SQLException {
        String sql = "INSERT INTO usuarios (nome, email, data_nascimento, sexo, peso_kg, altura_cm, ativo) VALUES (?, ?, ?, ?::tipo_sexo, ?, ?, ?) RETURNING id";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, u.getNome());
            stmt.setString(2, u.getEmail());
            stmt.setDate(3, u.getDataNascimento());
            stmt.setString(4, u.getSexo());
            stmt.setDouble(5, u.getPesoKg());
            stmt.setInt(6, u.getAlturaCm());
            stmt.setBoolean(7, u.isAtivo());

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
            stmt.executeUpdate();
        }

        throw new SQLException("Erro ao obter ID do usuário.");
    }

    public List<Usuario> listarUsuarios() throws SQLException {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Usuario p = new Usuario(
                        rs.getInt("id"),
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


    public void adicionarRestricaoParaUsuario(int usuarioId, int restricaoId) throws SQLException {
        String sql = "INSERT INTO usuario_restricoes (usuario_id, restricao_id) VALUES (?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, usuarioId);
            stmt.setInt(2, restricaoId);
            stmt.executeUpdate();
        }
    }
}