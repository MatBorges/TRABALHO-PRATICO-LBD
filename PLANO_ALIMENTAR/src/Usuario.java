public class Usuario {

    private int id;
    private String nome;
    private String email;
    private java.sql.Date dataNascimento;
    private String sexo;
    private double pesoKg;
    private int alturaCm;
    private boolean ativo;

    public Usuario(String nome, String email, java.sql.Date dataNascimento, String sexo, double pesoKg, int alturaCm, boolean ativo) {
        this.nome = nome;
        this.email = email;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.pesoKg = pesoKg;
        this.alturaCm = alturaCm;
        this.ativo = ativo;
    }

    public Usuario(int id, String nome, String email, java.sql.Date dataNascimento, String sexo, double pesoKg, int alturaCm, boolean ativo) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.dataNascimento = dataNascimento;
        this.sexo = sexo;
        this.pesoKg = pesoKg;
        this.alturaCm = alturaCm;
        this.ativo = ativo;
    }

    

    public int getId() {
        return id;
    }



    public String getNome() {
        return nome;
    }



    public String getEmail() {
        return email;
    }



    public java.sql.Date getDataNascimento() {
        return dataNascimento;
    }



    public String getSexo() {
        return sexo;
    }



    public double getPesoKg() {
        return pesoKg;
    }



    public int getAlturaCm() {
        return alturaCm;
    }



    public boolean isAtivo() {
        return ativo;
    }


    

    public void setNome(String nome) {
        this.nome = nome;
    }



    public void setPesoKg(double pesoKg) {
        this.pesoKg = pesoKg;
    }



    public void setAlturaCm(int alturaCm) {
        this.alturaCm = alturaCm;
    }



    public void setAtivo(boolean ativo) {
        this.ativo = ativo;
    }



    @Override
    public String toString() {
        return String.format("ID: %d | Nome: %s | Email: %s | Nascimento: %s | Sexo: %s | Peso: %.2f | Altura: %d | Ativo: %b",
                id, nome, email, dataNascimento, sexo, pesoKg, alturaCm, ativo);
    }
}
