public class GrupoAlimentar {
    private int id;
    private String nome;

    public GrupoAlimentar(int id, String nome) {
        this.id = id;
        this.nome = nome;
    }
    
    public GrupoAlimentar(String nome) {
        this.nome = nome;
    }

    public int getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    @Override
    public String toString() {
        return String.format("ID: %d | Nome: %s", id, nome);
    }
    
}
