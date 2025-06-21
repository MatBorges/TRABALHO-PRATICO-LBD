public class Alimento {
    private int id;
    private String nome;
    private int grupo_alimentar_id;
    private double calorias_kcal;
    private double proteinas_g;
    private double carboidratos_g;
    private double gorduras_g;
    private double sodio_mg;
    private int indice_glicemico;
    private boolean lactose;
    private boolean gluten;
    private boolean vegano;

    public Alimento(String nome, int grupo_alimentar_id, double calorias_kcal, double proteinas_g, double carboidratos_g, double gorduras_g, double sodio_mg, int indice_glicemico, boolean lactose, boolean gluten, boolean vegano) {
        this.nome = nome;
        this.grupo_alimentar_id = grupo_alimentar_id;
        this.calorias_kcal = calorias_kcal;
        this.proteinas_g = proteinas_g;
        this.carboidratos_g = carboidratos_g;
        this.gorduras_g = gorduras_g;
        this.sodio_mg = sodio_mg;
        this.indice_glicemico = indice_glicemico;
        this.lactose = lactose;
        this.gluten = gluten;
        this.vegano = vegano;
    }

    public Alimento(int id, String nome, int grupo_alimentar_id, double calorias_kcal, double proteinas_g, double carboidratos_g, double gorduras_g, double sodio_mg, int indice_glicemico, boolean lactose, boolean gluten, boolean vegano) {
        this.id = id;
        this.nome = nome;
        this.grupo_alimentar_id = grupo_alimentar_id;
        this.calorias_kcal = calorias_kcal;
        this.proteinas_g = proteinas_g;
        this.carboidratos_g = carboidratos_g;
        this.gorduras_g = gorduras_g;
        this.sodio_mg = sodio_mg;
        this.indice_glicemico = indice_glicemico;
        this.lactose = lactose;
        this.gluten = gluten;
        this.vegano = vegano;
    }

    public int getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public int getGrupo_alimentar_id() {
        return grupo_alimentar_id;
    }

    public double getCalorias_kcal() {
        return calorias_kcal;
    }

    public double getProteinas_g() {
        return proteinas_g;
    }

    public double getCarboidratos_g() {
        return carboidratos_g;
    }

    public double getGorduras_g() {
        return gorduras_g;
    }

    public double getSodio_mg() {
        return sodio_mg;
    }

    public int getIndice_glicemico() {
        return indice_glicemico;
    }

    public boolean isLactose() {
        return lactose;
    }

    public boolean isGluten() {
        return gluten;
    }

    public boolean isVegano() {
        return vegano;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public void setGrupo_alimentar_id(int grupo_alimentar_id) {
        this.grupo_alimentar_id = grupo_alimentar_id;
    }

    public void setCalorias_kcal(double calorias_kcal) {
        this.calorias_kcal = calorias_kcal;
    }

    public void setProteinas_g(double proteinas_g) {
        this.proteinas_g = proteinas_g;
    }

    public void setCarboidratos_g(double carboidratos_g) {
        this.carboidratos_g = carboidratos_g;
    }

    public void setGorduras_g(double gorduras_g) {
        this.gorduras_g = gorduras_g;
    }

    public void setSodio_mg(double sodio_mg) {
        this.sodio_mg = sodio_mg;
    }

    public void setIndice_glicemico(int indice_glicemico) {
        this.indice_glicemico = indice_glicemico;
    }

    public void setLactose(boolean lactose) {
        this.lactose = lactose;
    }

    public void setGluten(boolean gluten) {
        this.gluten = gluten;
    }

    public void setVegano(boolean vegano) {
        this.vegano = vegano;
    }

    @Override
    public String toString() {
        return String.format("ID: %d | Nome: %s | Grupo Alimentar: %d | Calorias: %.2f kcal | Proteínas: %.2f g | Carboidratos: %.2f g | Gorduras: %.2f g | Sodio: %.2f mg | Indice Glicemico: %d | Lactose: %b | Gluten %b | Vegano %b",
                id, nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano);
    }

    

}
