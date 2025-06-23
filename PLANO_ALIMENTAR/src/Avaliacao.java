
import java.sql.Timestamp;

public class Avaliacao {
    private int id;
    private int planoId;
    private int usuarioId;
    private int nota;
    private String comentário;
    private Timestamp datavaliação;

    public Avaliacao(int id, int planoId, int usuarioId, int nota, String comentário, Timestamp datavaliação) {
        this.id = id;
        this.planoId = planoId;
        this.usuarioId = usuarioId;
        this.nota = nota;
        this.comentário = comentário;
        this.datavaliação = datavaliação;
    }

    public Avaliacao(int planoId, int usuarioId, int nota, String comentário) {
        this.planoId = planoId;
        this.usuarioId = usuarioId;
        this.nota = nota;
        this.comentário = comentário;
    }

    public int getId() {
        return id;
    }

    public int getPlanoId() {
        return planoId;
    }

    public int getUsuarioId() {
        return usuarioId;
    }

    public int getNota() {
        return nota;
    }

    public String getComentário() {
        return comentário;
    }

    public Timestamp getDatavaliação() {
        return datavaliação;
    }


    @Override
    public String toString() {
        return String.format("ID Avaliação: %d | ID Plano: %d | ID Usuário: %d | Nota: %d | Comentário: \"%s\" | Data Avaliação: %s",
                id, planoId, usuarioId, nota, comentário, datavaliação);
    }
}
