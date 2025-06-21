public class Restricao {
    private int id;
    private String nome;
    private String descricao;


    public Restricao(int id, String nome, String descricao){
        this.id = id;
        this.nome = nome;
        this.descricao = descricao;
    }

    public Restricao(String nome, String descricao){
        this.nome = nome;
        this.descricao = descricao;
    }


    public int getId() {
        return id;
    }


    public String getNome() {
        return nome;
    }


    public String getDescricao() {
        return descricao;
    }


    public void setNome(String nome) {
        this.nome = nome;
    }


    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }


    @Override
    public String toString() {
        return String.format("ID: %d | Nome: %s | Descrição: %s",
                id, nome, descricao);
    }

}
