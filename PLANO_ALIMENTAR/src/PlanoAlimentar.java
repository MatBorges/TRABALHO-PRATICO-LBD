import java.util.Date;

public class PlanoAlimentar {
    private int id;
    private int usuario_id;
    private Date data;
    private String objetivo;
    private String observacoes;

    

    public PlanoAlimentar(int id, int usuario_id, Date data, String objetivo, String observacoes) {
        this.id = id;
        this.usuario_id = usuario_id;
        this.data = data;
        this.objetivo = objetivo;
        this.observacoes = observacoes;
    }

    

    public int getId() {
        return id;
    }



    public int getUsuario_id() {
        return usuario_id;
    }



    public Date getData() {
        return data;
    }



    public String getObjetivo() {
        return objetivo;
    }



    public String getObservacoes() {
        return observacoes;
    }



    @Override
    public String toString() {
        return String.format("ID: %d | ID Usuário: %d | Data: %s | Objetivo: %s | Observações: %s",
                id, usuario_id, data, objetivo, observacoes);
    }
}
