import java.util.Date;

public class Refeicao {
    private int id;
    private String nome;
    private String tipo;
    private Date horarioSugerido;

    public Refeicao(int id, String nome, String tipo, Date horarioSugerido) {
        this.id = id;
        this.nome = nome;
        this.tipo = tipo;
        this.horarioSugerido = horarioSugerido;
    }

    public int getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public String getTipo() {
        return tipo;
    }

    public Date getHorarioSugerido() {
        return horarioSugerido;
    }

    @Override
    public String toString() {        
        return String.format("ID: %d | Nome: %s | Tipo: %s | Horário Sugerido: %s",
                id, nome, tipo, horarioSugerido);
    }
}
