public class PlanoAlimentar {
    private int id;
    private int refeicao_id;
    private int ordem_refeicao;

    public PlanoAlimentar(int id, int ordem_refeicao, int refeicao_id) {
        this.id = id;
        this.ordem_refeicao = ordem_refeicao;
        this.refeicao_id = refeicao_id;
    }

    public int getId() {
        return id;
    }

    public int getRefeicao_id() {
        return refeicao_id;
    }

    public int getOrdem_refeicao() {
        return ordem_refeicao;
    }

    @Override
    public String toString() {
        return String.format("ID: %d | ID Refeição: %d | Ordem Refeição: %d",
                id, refeicao_id, ordem_refeicao);
    }
}
