import java.sql.*;
import java.util.InputMismatchException;
import java.util.List;
import java.util.Scanner;

public class App {
    static final String URL = "jdbc:postgresql://localhost:5433/TESTE_TRABALHO_LBD";
    static final String USER = "postgres";
    static final String SENHA = "minhasenha";

    public static void main(String[] args) {
        try (Connection conn = DriverManager.getConnection(URL, USER, SENHA);
             Scanner scan = new Scanner(System.in)) {


            // Objetos entidades
            UsuarioLogica usuLog = new UsuarioLogica(conn);
            RestricaoLogica resLog = new RestricaoLogica(conn);
            GrupoAlimentarLogica gaLog = new GrupoAlimentarLogica(conn);
            AlimentoLogica aliLog = new AlimentoLogica(conn);

            while (true) {
                System.out.println("\nMenu PLANO ALIMENTAR:");
                System.out.println("1 - Cadastrar Usuario");
                System.out.println("2 - Consultar Usuarios");
                System.out.println("3 - Cadastrar Restrição");
                System.out.println("4 - Consultar Restrições");
                System.out.println("5 - Cadastrar Grupo Alimentar");
                System.out.println("6 - Consultar Grupo Alimentar");
                System.out.println("7 - Cadastrar Alimento");
                System.out.println("8 - Consultar Alimentos");
                System.out.println("0 - Sair");
                System.out.print("Escolha uma opção: ");
                int opcao = scan.nextInt();
                scan.nextLine();

                switch (opcao) {
                    case 1 -> cadastrarUsuario(scan, usuLog);
                    case 2 -> consultarUsuarios(usuLog);
                    case 3 -> cadastrarRestricao(scan, resLog);
                    case 4 -> consultarRestricoes(resLog);
                    case 5 -> cadastrarGrupoAlimentar(scan, gaLog);
                    case 6 -> consultarGruposAlimentares(gaLog);
                    case 7 -> cadastrarAlimento(scan, aliLog, gaLog);
                    case 8 -> consultarAlimentos(aliLog);
                    case 0 -> {
                        System.out.println("Encerrando programa.");
                        return;
                    }
                    default -> System.out.println("Opção inválida.");
                }
            }
        } catch (SQLException e) {
            System.out.println("Erro de conexão: " + e.getMessage());
        }
    }

    private static void cadastrarUsuario(Scanner scan, UsuarioLogica usuLog) {
        try {
            System.out.print("Nome: ");
            String nome = scan.nextLine();

            System.out.print("Email: ");
            String email = scan.nextLine();
            
            System.out.print("Data de nascimento (AAAA-MM-DD): ");
            java.sql.Date dataNascimento = java.sql.Date.valueOf(scan.nextLine());
            
            String sexo;
            
            while (true) {
                System.out.print("Sexo (1 - Masculino ou 2 - Feminino): ");
                int opcao = scan.nextInt();
                if ((opcao != 1) && (opcao != 2)) {
                    System.out.println("Opção inválida!");
                }
                else{
                    if (opcao == 1) {
                        sexo = "Masculino";
                    }
                    else{
                        sexo = "Feminino";
                    }
                    break;
                }                
            }

            System.out.print("Peso (kg): ");
            double peso = scan.nextDouble();

            System.out.print("Altura (cm): ");
            int altura = scan.nextInt();

            boolean ativo = true;

            Usuario p = new Usuario(nome, email, dataNascimento, sexo, peso, altura, ativo);
            usuLog.adicionarUsuario(p);
            System.out.println("Usuario cadastrada com sucesso!");

        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
            scan.nextLine();
        }
    }


    private static void cadastrarRestricao(Scanner scan, RestricaoLogica resLog) {
        try {
            System.out.print("Nome: ");
            String nome = scan.nextLine().toUpperCase();

            System.out.print("Descrição: ");
            String descricao = scan.nextLine();            

            Restricao r = new Restricao(nome, descricao);
            resLog.adicionarRestricao(r);
            System.out.println("Restrição cadastrada com sucesso!");

        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
            scan.nextLine();
        }
    }


    private static void cadastrarGrupoAlimentar(Scanner scan, GrupoAlimentarLogica gaLog) {
        try {
            System.out.print("Nome: ");
            String nome = scan.nextLine().toUpperCase();          

            GrupoAlimentar ga = new GrupoAlimentar(nome);
            gaLog.adicionarGrupoAlimentar(ga);
            System.out.println("Grupo Alimentar cadastrado com sucesso!");

        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
            scan.nextLine();
        }
    }


    private static void cadastrarAlimento(Scanner scan, AlimentoLogica aliLog, GrupoAlimentarLogica gaLog) {
        try {
            System.out.print("Nome: ");
            String nome = scan.nextLine().toUpperCase();
            // Mostra uma lista dos grupos alimentares cadastrados
            int grupo_alimentar_id;
            while (true) {
                System.out.print("Selecione o Grupo Alimentar:\n");
                List<GrupoAlimentar> lista = gaLog.listarGruposAlimentares();
                for (GrupoAlimentar ga : lista) {
                    System.out.printf("%d - %s\n", ga.getId(), ga.getNome());
                }
                grupo_alimentar_id = scan.nextInt();
                if ((grupo_alimentar_id < 1) || (grupo_alimentar_id > lista.size())){
                    System.out.println("Opção inválida!");
                }
                else{
                    break;
                }
            }
            System.out.print("Calorias (kcal): ");
            Double calorias_kcal = scan.nextDouble();
            System.out.print("Proteínas (g): ");
            Double proteinas_g = scan.nextDouble();
            System.out.print("Carboidratos (g): ");
            Double carboidratos_g = scan.nextDouble();
            System.out.print("Gorduras (g): ");
            Double gorduras_g = scan.nextDouble();
            System.out.print("Sódio (mg): ");
            Double sodio_mg = scan.nextDouble();
            System.out.print("Índice Glicemico: ");
            int indice_glicemico = scan.nextInt();

            boolean lactose = false;
            boolean gluten = false;
            boolean vegano = false;

            while (true) {
                try {
                    System.out.print("Tem Lactose? (true/false): ");
                    lactose = scan.nextBoolean();
                    scan.nextLine();
                    break;
                } catch (InputMismatchException e) {
                    System.out.println("Entrada inválida. Digite true ou false.");
                    scan.nextLine();
                }                
            }
            while (true) {
                try {
                    System.out.print("Tem Gluten? (true/false): ");
                    gluten = scan.nextBoolean();
                    scan.nextLine();
                    break;
                } catch (InputMismatchException e) {
                    System.out.println("Entrada inválida. Digite true ou false.");
                    scan.nextLine();
                }                
            }
            while (true) {
                try {                    
                    System.out.print("É Vegano? (true/false): ");
                    vegano = scan.nextBoolean();
                    scan.nextLine();
                    break;
                } catch (Exception e) {
                    System.out.println("Entrada inválida. Digite true ou false.");
                    scan.nextLine();
                }                
            }
            Alimento a = new Alimento(
                nome,
                grupo_alimentar_id,
                calorias_kcal,
                proteinas_g,
                carboidratos_g,
                gorduras_g,
                sodio_mg,
                indice_glicemico,
                lactose,
                gluten,
                vegano);
            aliLog.adicionarAlimento(a);
            System.out.println("Grupo Alimentar cadastrado com sucesso!");

        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
            scan.nextLine();
        }
    }


    private static void consultarUsuarios(UsuarioLogica usuLog) {
        try {
            List<Usuario> lista = usuLog.listarUsuarios();
            for (Usuario p : lista) {
                System.out.println(p);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao consultar usuários: " + e.getMessage());
        }
    }


    private static void consultarRestricoes(RestricaoLogica resLog) {
        try {
            List<Restricao> lista = resLog.listarRestricoes();
            for (Restricao r : lista) {
                System.out.println(r);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao consultar restrições: " + e.getMessage());
        }
    }
    
    
    private static void consultarGruposAlimentares(GrupoAlimentarLogica gaLog) {
        try {
            List<GrupoAlimentar> lista = gaLog.listarGruposAlimentares();
            for (GrupoAlimentar ga : lista) {
                System.out.println(ga);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao consultar Grupos Alimentares: " + e.getMessage());
        }
    }
    
    
    private static void consultarAlimentos(AlimentoLogica aliLog) {
        try {
            List<Alimento> lista = aliLog.listarAlimentos();
            for (Alimento a : lista) {
                System.out.println(a);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao consultar Alimentos: " + e.getMessage());
        }
    }
}