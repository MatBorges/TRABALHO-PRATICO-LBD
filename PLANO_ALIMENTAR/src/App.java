import java.sql.*;
import java.util.InputMismatchException;
import java.util.List;
import java.util.Scanner;

public class App {
    static final String URL = "jdbc:postgresql://localhost:5433/TRABALHO_LBD";
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
            RefeicaoLogica refLog = new RefeicaoLogica(conn);
            AvaliacaoLogica avaLog = new AvaliacaoLogica(conn);
            PlanoAlimentarLogica plaLog = new PlanoAlimentarLogica(conn);

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
                System.out.println("9 - Consultar Refeições");
                System.out.println("10 - Fazer Avaliação");
                System.out.println("11 - Consultar Avaliações");
                System.out.println("12 - Gerar Plano Alimentar");
                System.out.println("0 - Sair");
                System.out.print("Escolha uma opção: ");
                int opcao = scan.nextInt();
                scan.nextLine();

                switch (opcao) {
                    case 1 -> cadastrarUsuario(scan, usuLog, resLog);
                    case 2 -> consultarUsuarios(usuLog);
                    case 3 -> cadastrarRestricao(scan, resLog);
                    case 4 -> consultarRestricoes(resLog);
                    case 5 -> cadastrarGrupoAlimentar(scan, gaLog);
                    case 6 -> consultarGruposAlimentares(gaLog);
                    case 7 -> cadastrarAlimento(scan, aliLog, gaLog);
                    case 8 -> consultarAlimentos(aliLog);
                    case 9 -> consultarRefeicoes(refLog);
                    case 10 -> fazerAvaliacao(scan, avaLog, plaLog);
                    case 11 -> consultarAvaliacoes(avaLog);
                    case 12 -> gerarPlanoAlimentar(scan, plaLog);
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


    private static void cadastrarUsuario(Scanner scan, UsuarioLogica usuLog, RestricaoLogica resLog) {
        try {
            System.out.print("Nome: ");
            String nome = scan.nextLine();

            System.out.print("Email: ");
            String email = scan.nextLine();

            java.sql.Date dataNascimento = null;
            while (dataNascimento == null) {
                System.out.print("Data de nascimento (AAAA-MM-DD): ");
                try {
                    dataNascimento = java.sql.Date.valueOf(scan.nextLine());
                } catch (IllegalArgumentException e) {
                    System.out.println("Formato de data inválido. Por favor, use o formato AAAA-MM-DD.");
                }
            }

            String sexo;
            while (true) {
                System.out.print("Sexo (1 - Masculino ou 2 - Feminino): ");
                
                String opcaoStr = scan.nextLine(); 
                try {
                    int opcao = Integer.parseInt(opcaoStr);
                    if (opcao == 1) {
                        sexo = "Masculino";
                        break;
                    } else if (opcao == 2) {
                        sexo = "Feminino";
                        break;
                    } else {
                        System.out.println("Opção inválida! Por favor, digite 1 para Masculino ou 2 para Feminino.");
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Entrada inválida. Por favor, digite 1 ou 2.");
                }
            }

            double peso = 0;
            while (peso <= 0) {
                System.out.print("Peso (kg): ");
                String pesoStr = scan.nextLine();
                try {
                    peso = Double.parseDouble(pesoStr);
                    if (peso <= 0) {
                        System.out.println("Peso inválido. Por favor, digite um valor maior que zero.");
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Entrada inválida. Por favor, digite um número para o peso.");
                }
            }

            int altura = 0;
            while (altura <= 0) {
                System.out.print("Altura (cm): ");
                String alturaStr = scan.nextLine();
                try {
                    altura = Integer.parseInt(alturaStr);
                    if (altura <= 0) {
                        System.out.println("Altura inválida. Por favor, digite um valor maior que zero.");
                    }
                } catch (NumberFormatException e) {
                    System.out.println("Entrada inválida. Por favor, digite um número inteiro para a altura.");
                }
            }

            String objetivo;
            while (true) {
                System.out.print("Objetivo (1 - Perder Peso, 2 - Ganho de Massa, 3 - Dieta Saudavel): ");
                
                String opcaoStr = scan.nextLine(); 
                try {
                    int opcao = Integer.parseInt(opcaoStr);

                    switch (opcao) {
                        case 1:
                            objetivo = "Perder Peso";
                            break;
                        case 2:
                            objetivo = "Ganho de Massa";
                            break;
                        case 3:
                            objetivo = "Dieta Saudavel";
                            break;
                        default:
                            System.out.println("Opção inválida.");
                            continue;
                    }
                    break;
                } catch (NumberFormatException e) {
                    System.out.println("Entrada inválida. Por favor, digite 1 ou 2.");
                }
            }

            boolean ativo = true;

            Usuario p = new Usuario(nome, email, dataNascimento, sexo, peso, altura, objetivo, ativo);
            int usuarioId = usuLog.adicionarUsuario(p);

            System.out.print("Deseja adicionar restrições? (s/n): ");
            String resp = scan.nextLine().trim().toLowerCase();

            if (resp.equals("s")) {
                System.out.print("Selecione a Restrição:\n");
                List<Restricao> lista = resLog.listarRestricoes();
                for (Restricao r : lista) {
                    System.out.printf("%d - %s\n", r.getId(), r.getNome());
                }

                System.out.print("Digite os IDs das restrições separadas por vírgula (ex: 1,3,5): ");
                String[] ids = scan.nextLine().split(",");

                for (String idStr : ids) {
                    try {
                        int restricaoId = Integer.parseInt(idStr.trim());
                        usuLog.adicionarRestricaoParaUsuario(usuarioId, restricaoId);
                    } catch (NumberFormatException e) {
                        System.out.println("ID de restrição inválido foi ignorado: " + idStr);
                    }
                }
            }

            System.out.println("Usuário cadastrado com sucesso!");

        } catch (Exception e) {
            System.out.println("Ocorreu um erro inesperado durante o cadastro: " + e.getMessage());
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
            System.out.println("Erro ao cadastrar Restrição: " + e.getMessage());
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
            System.out.println("Alimento cadastrado com sucesso!");

        } catch (Exception e) {
            System.out.println("Erro: " + e.getMessage());
            scan.nextLine();
        }
    }


    private static void fazerAvaliacao(Scanner scan, AvaliacaoLogica avaLog, PlanoAlimentarLogica plaLog) {
        try {
            System.out.print("Digite o código do usuário que ira avaliar: ");
            int usuarioId = scan.nextInt();
            int nota;
            
            List<PlanoAlimentar> lista = plaLog.listarPlanosAlimentares(usuarioId);

            if (lista.isEmpty()) {
                System.out.println("Nenhum plano alimentar encontrado!");
            } else {
                for(PlanoAlimentar pa : lista){
                    System.out.println(pa);
                }
                System.out.print("Digite o código do Plano Alimentar que deseja avaliar: ");
                int planoId = scan.nextInt();

                System.out.println("Comentário:");
                String comentario = scan.nextLine();
                while (true) {
                    System.out.println("Nota: (1 a 5)");
                    nota = scan.nextInt();
                    if ((nota < 1) || (nota > 5)) {
                        System.out.println("Valor inválido!");
                    }
                    else{
                        break;
                    }                    
                }
                Avaliacao a = new Avaliacao(planoId, usuarioId, nota, comentario);
                avaLog.adicionarAvaliacao(a);
                System.out.println("Avaliação cadastrada com sucesso, Obrigado!");
            }
        } catch (Exception e){
            System.out.println("Erro ao fazer avaliação: " + e.getMessage());
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


    private static void consultarRefeicoes(RefeicaoLogica refLog) {
        try {
            List<Refeicao> lista = refLog.listarRefeicoes();
            for (Refeicao r : lista) {
                System.out.println(r);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao consultar Refeicoes: " + e.getMessage());
        }
    }


    private static void consultarAvaliacoes(AvaliacaoLogica avaLog) {
        try {
            List<Avaliacao> lista = avaLog.listarAvaliacoes();
            for (Avaliacao a : lista) {
                System.out.println(a);
            }
        } catch (SQLException e) {
            System.out.println("Erro ao consultar Avaliacoes: " + e.getMessage());
        }
    }


    private static void gerarPlanoAlimentar(Scanner scan, PlanoAlimentarLogica plaLog) {
        try {
            System.out.print("Informe o ID do usuário: ");
            int usuarioId = scan.nextInt();
            
            plaLog.gerarPlanoAlimentar(usuarioId);
            System.out.println("Plano Alimentar gerado com sucesso!");


        } catch (Exception e) {
            System.out.println("Erro ao Gerar Plano Alimentar: " + e.getMessage());
            scan.nextLine();
        }
    }
}