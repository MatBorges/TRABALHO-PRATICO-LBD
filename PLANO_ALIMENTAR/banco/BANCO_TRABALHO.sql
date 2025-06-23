

CREATE TYPE tipo_sexo AS ENUM ('Masculino', 'Feminino');
CREATE TYPE tipo_objetivo AS ENUM ('Perder Peso', 'Ganho de Massa', 'Dieta Saudavel');

CREATE TABLE usuarios (
    id serial primary key,
    nome varchar(100) not null,
    email varchar(100) unique not null,
    data_nascimento date,
    sexo tipo_sexo,
    peso_kg decimal(5,2),
    altura_cm int,
    objetivo tipo_objetivo, -- ver se mantem ou nõa
    ativo boolean default TRUE
);


CREATE TABLE restricoes (
    id serial primary key,
    nome varchar(100) unique not null,
    descricao text
);


CREATE TABLE usuario_restricoes (
    usuario_id int references usuarios(id) on delete cascade,
    restricao_id int references restricoes(id) on delete cascade,
    primary key (usuario_id, restricao_id)
);



CREATE TABLE grupos_alimentares (
    id serial primary key,
    nome varchar(50) unique not null
);



CREATE TABLE alimentos (
    id serial primary key,
    nome varchar(100) not null unique,
    grupo_alimentar_id integer NOT NULL references grupos_alimentares (id),
    calorias_kcal decimal(6,2) CHECK (calorias_kcal >= 0),
    proteinas_g decimal(6,2) CHECK (proteinas_g >= 0),
    carboidratos_g decimal(6,2) CHECK (carboidratos_g >= 0),
    gorduras_g decimal(6,2) CHECK (gorduras_g >= 0),
    sodio_mg decimal(6,2) CHECK (sodio_mg >= 0),
    indice_glicemico smallint CHECK (indice_glicemico >= 0),
    lactose boolean,
    gluten boolean,
    vegano boolean
);


CREATE TYPE tipo_refeicao AS enum ('Café da manhã', 'Almoço', 'Jantar', 'Lanche', 'Ceia');

CREATE TABLE refeicoes (
    id serial primary key,
    nome varchar(100),
    tipo tipo_refeicao,
    horario_sugerido time
);



CREATE TABLE refeicao_alimentos (
    refeicao_id int references refeicoes(id) on delete cascade,
    alimento_id int references alimentos(id),
    quantidade_gramas decimal(6,2),
    primary key (refeicao_id, alimento_id)
);



CREATE TABLE planos_alimentares (
    id serial primary key,
    usuario_id int references usuarios(id) on delete cascade,
    data date default CURRENT_DATE,
    objetivo tipo_objetivo,
    observacoes text
);


CREATE TABLE plano_refeicoes (
    plano_id int references planos_alimentares(id) on delete cascade,
    refeicao_id int references refeicoes(id),
    ordem_refeicao smallint, 
    primary key (plano_id, refeicao_id)
);

CREATE TABLE avaliacoes (
    id serial primary key,
    plano_id int references planos_alimentares(id) on delete cascade,
    usuario_id int references usuarios(id),
    nota smallint check (nota BETWEEN 1 AND 5),
    comentario text,
    data_avaliacao timestamp default CURRENT_TIMESTAMP
);

INSERT INTO public.restricoes VALUES (1, 'Diabetes', 'Controle de índice glicêmico');
INSERT INTO public.restricoes VALUES (2, 'Hipertensão', 'Controle de ingestão de sódio');
INSERT INTO public.restricoes VALUES (5, 'Vegetariano', 'Evita carne e derivados animais');
INSERT INTO public.restricoes VALUES (3, 'Lactose', 'Evita alimentos com lactose');
INSERT INTO public.restricoes VALUES (4, 'Glúten', 'Evita alimentos com glúten');

INSERT INTO usuarios (nome, email, data_nascimento, sexo, peso_kg, altura_cm, objetivo, ativo) VALUES
('João Silva', 'joao.silva@email.com', '1990-05-15', 'Masculino', 85.50, 180, 'Ganho de Massa', TRUE),
('Maria Souza', 'maria.souza@email.com', '1992-08-22', 'Feminino', 62.10, 165, 'Perder Peso', TRUE),
('Pedro Santos', 'pedro.santos@email.com', '1988-11-30', 'Masculino', 78.00, 175, 'Dieta Saudavel', TRUE),
('Ana Lima', 'ana.lima@email.com', '1995-03-10', 'Feminino', 58.75, 160, 'Perder Peso', TRUE),
('Carlos Oliveira', 'carlos.oliver@email.com', '1985-01-20', 'Masculino', 90.20, 185, 'Ganho de Massa', TRUE),
('Mariana Costa', 'mariana.costa@email.com', '1998-07-01', 'Feminino', 60.00, 170, 'Dieta Saudavel', TRUE),
('Fernando Alves', 'fernando.alves@email.com', '1991-04-05', 'Masculino', 75.30, 178, 'Perder Peso', TRUE),
('Julia Rocha', 'julia.rocha@email.com', '1993-09-12', 'Feminino', 55.90, 162, 'Perder Peso', TRUE),
('Rafael Pereira', 'rafael.pereira@email.com', '1987-06-25', 'Masculino', 88.90, 182, 'Ganho de Massa', TRUE),
('Beatriz Gomes', 'beatriz.gomes@email.com', '1996-02-18', 'Feminino', 68.30, 172, 'Dieta Saudavel', TRUE),
('Lucas Martins', 'lucas.martins@email.com', '1989-10-03', 'Masculino', 72.40, 170, 'Perder Peso', TRUE),
('Amanda Ribeiro', 'amanda.ribeiro@email.com', '1994-12-08', 'Feminino', 59.50, 168, 'Dieta Saudavel', TRUE),
('Thiago Fernandes', 'thiago.fernandes@email.com', '1986-07-14', 'Masculino', 81.60, 179, 'Ganho de Massa', TRUE),
('Priscila Cavalcante', 'priscila.cava@email.com', '1997-01-28', 'Feminino', 63.80, 166, 'Perder Peso', TRUE),
('Daniel Rodrigues', 'daniel.rodri@email.com', '1990-09-01', 'Masculino', 80.10, 176, 'Dieta Saudavel', TRUE),
('Gabriela Nunes', 'gabriela.nunes@email.com', '1991-04-19', 'Feminino', 57.20, 163, 'Perder Peso', TRUE),
('Felipe Barbosa', 'felipe.barbosa@email.com', '1984-08-07', 'Masculino', 93.00, 183, 'Ganho de Massa', TRUE),
('Larissa Freitas', 'larissa.freitas@email.com', '1999-05-23', 'Feminino', 61.50, 171, 'Dieta Saudavel', TRUE),
('Gustavo Dias', 'gustavo.dias@email.com', '1983-03-02', 'Masculino', 76.80, 174, 'Perder Peso', TRUE),
('Isabela Mendes', 'isabela.mendes@email.com', '1990-11-11', 'Feminino', 65.40, 169, 'Ganho de Massa', TRUE);

INSERT INTO grupos_alimentares (nome) VALUES
('Frutas'),
('Vegetais'),
('Grãos'),
('Laticínios'),
('Carnes e Ovos'),
('Leguminosas e Oleaginosas'),
('Gorduras e Óleos'),
('Açúcares e Doces'),
('Pães e Massas'),
('Peixes e Frutos do Mar');

-- Grupo: Frutas (ID: 1)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Maçã Fuji', 1, 52.00, 0.30, 14.00, 0.20, 1.00, 36, FALSE, FALSE, TRUE),
('Banana Prata', 1, 89.00, 1.10, 23.00, 0.30, 1.00, 51, FALSE, FALSE, TRUE),
('Laranja Pera', 1, 47.00, 0.90, 12.00, 0.10, 0.00, 43, FALSE, FALSE, TRUE),
('Uva Crimson', 1, 69.00, 0.60, 18.00, 0.20, 2.00, 59, FALSE, FALSE, TRUE),
('Manga Tommy', 1, 60.00, 0.80, 15.00, 0.40, 1.00, 51, FALSE, FALSE, TRUE),
('Morango', 1, 32.00, 0.70, 7.70, 0.30, 1.00, 40, FALSE, FALSE, TRUE),
('Abacaxi', 1, 50.00, 0.50, 13.00, 0.10, 1.00, 59, FALSE, FALSE, TRUE),
('Melancia', 1, 30.00, 0.60, 7.60, 0.20, 1.00, 72, FALSE, FALSE, TRUE),
('Pêssego', 1, 39.00, 0.90, 9.50, 0.30, 0.00, 42, FALSE, FALSE, TRUE),
('Pera', 1, 57.00, 0.40, 15.00, 0.10, 1.00, 38, FALSE, FALSE, TRUE),
('Kiwi', 1, 61.00, 1.10, 15.00, 0.50, 3.00, 53, FALSE, FALSE, TRUE),
('Cereja', 1, 50.00, 1.00, 12.00, 0.30, 0.00, 22, FALSE, FALSE, TRUE),
('Mirtilo', 1, 57.00, 0.70, 14.00, 0.30, 1.00, 53, FALSE, FALSE, TRUE),
('Limão Tahiti', 1, 29.00, 1.10, 9.00, 0.30, 2.00, 20, FALSE, FALSE, TRUE),
('Goiaba', 1, 68.00, 2.60, 14.30, 1.00, 2.00, 20, FALSE, FALSE, TRUE);

-- Grupo: Vegetais (ID: 2)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Alface Crespa', 2, 15.00, 1.40, 2.90, 0.20, 28.00, 10, FALSE, FALSE, TRUE),
('Tomate', 2, 18.00, 0.90, 3.90, 0.20, 5.00, 30, FALSE, FALSE, TRUE),
('Cenoura', 2, 41.00, 0.90, 9.60, 0.20, 69.00, 47, FALSE, FALSE, TRUE),
('Brócolis', 2, 34.00, 2.80, 6.60, 0.40, 33.00, 10, FALSE, FALSE, TRUE),
('Espinafre', 2, 23.00, 2.90, 3.60, 0.40, 79.00, 15, FALSE, FALSE, TRUE),
('Pepino', 2, 15.00, 0.70, 3.60, 0.10, 2.00, 15, FALSE, FALSE, TRUE),
('Pimentão Vermelho', 2, 31.00, 1.00, 6.00, 0.30, 3.00, 15, FALSE, FALSE, TRUE),
('Abobrinha', 2, 17.00, 1.20, 3.10, 0.30, 8.00, 15, FALSE, FALSE, TRUE),
('Couve Flor', 2, 25.00, 1.90, 5.00, 0.30, 30.00, 15, FALSE, FALSE, TRUE),
('Berinjela', 2, 25.00, 1.00, 6.00, 0.20, 2.00, 15, FALSE, FALSE, TRUE),
('Vagem', 2, 31.00, 1.80, 7.00, 0.20, 6.00, 15, FALSE, FALSE, TRUE),
('Aspargos', 2, 20.00, 2.20, 3.90, 0.20, 2.00, 15, FALSE, FALSE, TRUE),
('Cogumelo Paris', 2, 22.00, 3.10, 3.30, 0.30, 5.00, 10, FALSE, FALSE, TRUE),
('Batata Doce', 2, 86.00, 1.60, 20.00, 0.10, 55.00, 44, FALSE, FALSE, TRUE),
('Cebola', 2, 40.00, 1.10, 9.30, 0.10, 4.00, 15, FALSE, FALSE, TRUE);

-- Grupo: Grãos (ID: 3)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Arroz Branco Cozido', 3, 130.00, 2.70, 28.00, 0.30, 1.00, 73, FALSE, FALSE, TRUE),
('Arroz Integral Cozido', 3, 111.00, 2.60, 23.00, 0.90, 5.00, 50, FALSE, FALSE, TRUE),
('Aveia em Flocos', 3, 389.00, 16.90, 66.30, 6.90, 2.00, 55, FALSE, FALSE, TRUE),
('Milho Cozido', 3, 86.00, 3.30, 19.00, 1.20, 15.00, 60, FALSE, FALSE, TRUE),
('Quinoa Cozida', 3, 120.00, 4.40, 21.00, 1.90, 7.00, 53, FALSE, FALSE, TRUE),
('Trigo Sarraceno', 3, 343.00, 13.00, 71.50, 3.40, 1.00, 54, FALSE, FALSE, TRUE),
('Cevada em Grão', 3, 354.00, 12.50, 73.00, 2.30, 12.00, 60, FALSE, FALSE, TRUE),
('Grão de Bico Cozido', 3, 164.00, 8.90, 27.00, 2.60, 7.00, 28, FALSE, FALSE, TRUE),
('Lentilha Cozida', 3, 116.00, 9.00, 20.00, 0.40, 2.00, 32, FALSE, FALSE, TRUE),
('Feijão Carioca Cozido', 3, 132.00, 8.20, 24.00, 0.50, 5.00, 30, FALSE, FALSE, TRUE),
('Cuscuz Marroquino', 3, 112.00, 3.80, 23.00, 0.20, 2.00, 65, FALSE, TRUE, TRUE),
('Amaranto', 3, 371.00, 13.60, 65.20, 7.00, 4.00, 25, FALSE, FALSE, TRUE),
('Painço', 3, 378.00, 11.00, 72.80, 4.20, 2.00, 71, FALSE, FALSE, TRUE),
('Triticale', 3, 338.00, 13.00, 70.00, 2.00, 1.00, 45, FALSE, TRUE, TRUE),
('Centá', 3, 335.00, 10.30, 69.80, 1.60, 1.00, 48, FALSE, TRUE, TRUE);

-- Grupo: Laticínios (ID: 4)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Leite Integral', 4, 61.00, 3.20, 4.80, 3.30, 43.00, 31, TRUE, FALSE, FALSE),
('Iogurte Natural Integral', 4, 61.00, 3.50, 4.70, 3.30, 46.00, 35, TRUE, FALSE, FALSE),
('Queijo Minas Frescal', 4, 260.00, 17.00, 2.00, 20.00, 300.00, 30, TRUE, FALSE, FALSE),
('Queijo Muçarela', 4, 300.00, 22.00, 2.20, 22.00, 600.00, 30, TRUE, FALSE, FALSE),
('Requeijão Cremoso Light', 4, 200.00, 10.00, 5.00, 15.00, 450.00, 30, TRUE, FALSE, FALSE),
('Ricota Fresca', 4, 174.00, 11.00, 3.00, 13.00, 200.00, 30, TRUE, FALSE, FALSE),
('Leite Desnatado', 4, 34.00, 3.40, 5.00, 0.10, 50.00, 32, TRUE, FALSE, FALSE),
('Iogurte Grego Light', 4, 90.00, 18.00, 8.00, 0.00, 60.00, 30, TRUE, FALSE, FALSE),
('Coalhada Seca', 4, 250.00, 18.00, 4.00, 18.00, 400.00, 30, TRUE, FALSE, FALSE),
('Manteiga', 4, 717.00, 0.80, 0.10, 81.00, 11.00, 0, TRUE, FALSE, FALSE);

-- Grupo: Carnes e Ovos (ID: 5)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Peito de Frango Grelhado', 5, 165.00, 31.00, 0.00, 3.60, 74.00, 0, FALSE, FALSE, FALSE),
('Bife de Alcatra Grelhado', 5, 250.00, 26.00, 0.00, 15.00, 60.00, 0, FALSE, FALSE, FALSE),
('Ovo Cozido', 5, 155.00, 13.00, 1.10, 11.00, 124.00, 0, FALSE, FALSE, FALSE),
('Salmão Assado', 5, 208.00, 20.00, 0.00, 13.00, 59.00, 0, FALSE, FALSE, FALSE),
('Filé de Tilápia Grelhado', 5, 128.00, 26.00, 0.00, 2.70, 56.00, 0, FALSE, FALSE, FALSE),
('Carne Moída Patinho', 5, 170.00, 21.00, 0.00, 9.00, 60.00, 0, FALSE, FALSE, FALSE),
('Linguiça de Frango', 5, 250.00, 15.00, 2.00, 20.00, 800.00, 0, FALSE, FALSE, FALSE),
('Hambúrguer de Carne', 5, 290.00, 20.00, 0.00, 23.00, 350.00, 0, FALSE, FALSE, FALSE),
('Presunto Magro', 5, 145.00, 18.00, 1.00, 7.00, 1000.00, 0, FALSE, FALSE, FALSE),
('Atum em Lata (água)', 5, 116.00, 25.00, 0.00, 1.00, 300.00, 0, FALSE, FALSE, FALSE);

-- Grupo: Leguminosas e Oleaginosas (ID: 6)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Amendoim Torrado', 6, 567.00, 25.80, 16.10, 49.20, 18.00, 14, FALSE, FALSE, TRUE),
('Castanha de Caju', 6, 553.00, 18.20, 30.20, 43.80, 12.00, 25, FALSE, FALSE, TRUE),
('Amêndoa', 6, 575.00, 21.20, 21.70, 49.90, 1.00, 15, FALSE, FALSE, TRUE),
('Nozes', 6, 654.00, 15.20, 13.70, 65.20, 2.00, 15, FALSE, FALSE, TRUE),
('Grão de Bico Seco', 6, 364.00, 20.50, 61.00, 6.00, 24.00, 28, FALSE, FALSE, TRUE),
('Feijão Preto Seco', 6, 341.00, 21.60, 62.40, 1.40, 5.00, 30, FALSE, FALSE, TRUE),
('Lentilha Seca', 6, 352.00, 24.60, 63.40, 1.10, 2.00, 32, FALSE, FALSE, TRUE),
('Castanha do Pará', 6, 659.00, 14.30, 12.30, 67.00, 3.00, 10, FALSE, FALSE, TRUE),
('Pistache', 6, 562.00, 20.20, 27.50, 45.30, 1.00, 15, FALSE, FALSE, TRUE),
('Semente de Abóbora', 6, 446.00, 24.50, 17.50, 19.40, 18.00, 25, FALSE, FALSE, TRUE),
('Semente de Girassol', 6, 584.00, 20.70, 20.00, 51.50, 9.00, 35, FALSE, FALSE, TRUE),
('Semente de Linhaça', 6, 534.00, 18.30, 28.90, 42.20, 30.00, 35, FALSE, FALSE, TRUE),
('Tofu Firme', 6, 76.00, 8.00, 1.90, 4.80, 7.00, 15, FALSE, FALSE, TRUE),
('Ervilha Seca', 6, 340.00, 23.00, 60.00, 1.00, 10.00, 22, FALSE, FALSE, TRUE),
('Edamame Cozido', 6, 122.00, 11.90, 9.90, 5.20, 5.00, 15, FALSE, FALSE, TRUE);

-- Grupo: Gorduras e Óleos (ID: 7)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Azeite de Oliva Extra Virgem', 7, 884.00, 0.00, 0.00, 100.00, 0.00, 0, FALSE, FALSE, TRUE),
('Óleo de Coco', 7, 862.00, 0.00, 0.00, 100.00, 0.00, 0, FALSE, FALSE, TRUE),
('Abacate', 7, 160.00, 2.00, 8.50, 14.70, 7.00, 15, FALSE, FALSE, TRUE),
('Óleo de Girassol', 7, 884.00, 0.00, 0.00, 100.00, 0.00, 0, FALSE, FALSE, TRUE),
('Margarina Vegetal', 7, 717.00, 0.00, 0.00, 80.00, 800.00, 0, FALSE, FALSE, TRUE);

-- Grupo: Açúcares e Doces (ID: 8)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Açúcar Refinado', 8, 387.00, 0.00, 100.00, 0.00, 1.00, 65, FALSE, FALSE, TRUE),
('Chocolate ao Leite', 8, 535.00, 8.00, 59.00, 30.00, 60.00, 49, TRUE, TRUE, FALSE),
('Mel', 8, 304.00, 0.30, 82.00, 0.00, 4.00, 61, FALSE, FALSE, TRUE),
('Sorvete de Creme', 8, 207.00, 3.50, 24.00, 11.00, 80.00, 60, TRUE, FALSE, FALSE),
('Bala de Goma', 8, 333.00, 0.00, 83.00, 0.00, 10.00, 70, FALSE, FALSE, TRUE),
('Geleia de Morango', 8, 240.00, 0.50, 60.00, 0.00, 10.00, 50, FALSE, FALSE, TRUE),
('Doce de Leite', 8, 315.00, 6.00, 55.00, 7.00, 100.00, 65, TRUE, FALSE, FALSE);

-- Grupo: Pães e Massas (ID: 9)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Pão Francês', 9, 265.00, 8.00, 50.00, 3.00, 500.00, 70, FALSE, TRUE, TRUE),
('Pão Integral', 9, 247.00, 13.00, 41.00, 3.50, 400.00, 55, FALSE, TRUE, TRUE),
('Macarrão Cozido', 9, 158.00, 5.80, 31.00, 0.90, 1.00, 49, FALSE, TRUE, TRUE),
('Torrada Tradicional', 9, 407.00, 11.00, 78.00, 5.00, 550.00, 70, FALSE, TRUE, TRUE),
('Biscoito Cream Cracker', 9, 420.00, 9.00, 70.00, 10.00, 600.00, 70, FALSE, TRUE, TRUE),
('Lasanha (massa)', 9, 130.00, 5.00, 25.00, 1.00, 5.00, 50, FALSE, TRUE, TRUE),
('Pão de Forma Branco', 9, 260.00, 8.00, 49.00, 3.00, 450.00, 75, FALSE, TRUE, TRUE),
('Pão Sírio', 9, 266.00, 9.00, 52.00, 2.00, 400.00, 65, FALSE, TRUE, TRUE),
('Pizza (massa)', 9, 280.00, 10.00, 40.00, 8.00, 600.00, 60, FALSE, TRUE, FALSE),
('Croissant', 9, 400.00, 8.00, 45.00, 20.00, 300.00, 60, TRUE, TRUE, FALSE);

-- Grupo: Peixes e Frutos do Mar (ID: 10)
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Sardinha em Lata (óleo)', 10, 208.00, 24.60, 0.00, 12.00, 463.00, 0, FALSE, FALSE, FALSE),
('Camarão Cozido', 10, 85.00, 20.00, 0.00, 0.50, 145.00, 0, FALSE, FALSE, FALSE),
('Atum Fresco Grelhado', 10, 184.00, 29.00, 0.00, 6.00, 40.00, 0, FALSE, FALSE, FALSE),
('Bacalhau Cozido', 10, 105.00, 23.00, 0.00, 1.00, 100.00, 0, FALSE, FALSE, FALSE),
('Ostras Cruas', 10, 68.00, 7.00, 4.00, 2.00, 90.00, 0, FALSE, FALSE, FALSE),
('Lula Cozida', 10, 92.00, 15.00, 3.00, 1.00, 35.00, 0, FALSE, FALSE, FALSE),
('Mexilhões Cozidos', 10, 172.00, 24.00, 7.00, 4.50, 160.00, 0, FALSE, FALSE, FALSE),
('Truta Grelhada', 10, 140.00, 22.00, 0.00, 5.00, 50.00, 0, FALSE, FALSE, FALSE),
('Polvo Cozido', 10, 82.00, 14.90, 2.20, 1.00, 290.00, 0, FALSE, FALSE, FALSE),
('Robalo Assado', 10, 110.00, 20.00, 0.00, 3.00, 50.00, 0, FALSE, FALSE, FALSE);

-- Mais alguns alimentos diversos para atingir 100+ registros e variedade
INSERT INTO alimentos (nome, grupo_alimentar_id, calorias_kcal, proteinas_g, carboidratos_g, gorduras_g, sodio_mg, indice_glicemico, lactose, gluten, vegano) VALUES
('Couve Refogada', 2, 40.00, 2.50, 5.00, 2.00, 10.00, 15, FALSE, FALSE, TRUE),
('Batata Inglesa Cozida', 2, 87.00, 1.90, 20.00, 0.10, 6.00, 78, FALSE, FALSE, TRUE),
('Ervilha Fresca', 2, 81.00, 5.00, 14.00, 0.40, 5.00, 35, FALSE, FALSE, TRUE),
('Pão de Queijo', 9, 330.00, 8.00, 35.00, 18.00, 400.00, 65, TRUE, FALSE, FALSE),
('Bolo de Chocolate', 8, 450.00, 5.00, 60.00, 20.00, 200.00, 70, TRUE, TRUE, FALSE),
('Feijoada Completa', 5, 250.00, 15.00, 20.00, 12.00, 800.00, 40, FALSE, FALSE, FALSE), -- Exemplo de prato misto
('Suco de Laranja Natural', 1, 45.00, 0.70, 10.00, 0.20, 0.00, 50, FALSE, FALSE, TRUE),
('Água de Coco', 1, 19.00, 0.70, 3.70, 0.20, 105.00, 30, FALSE, FALSE, TRUE),
('Café sem Açúcar', 7, 2.00, 0.10, 0.00, 0.00, 0.00, 0, FALSE, FALSE, TRUE),
('Açúcar Mascavo', 8, 380.00, 0.00, 99.00, 0.00, 5.00, 60, FALSE, FALSE, TRUE),
('Farinha de Trigo', 9, 364.00, 10.00, 76.00, 1.00, 2.00, 70, FALSE, TRUE, TRUE),
('Arroz Parboilizado', 3, 120.00, 2.50, 25.00, 0.50, 1.00, 65, FALSE, FALSE, TRUE),
('Leite de Amêndoas', 4, 15.00, 0.50, 1.00, 1.00, 100.00, 25, FALSE, FALSE, TRUE),
('Carne Seca Cozida', 5, 250.00, 30.00, 0.00, 15.00, 1200.00, 0, FALSE, FALSE, FALSE),
('Castanha do Brasil', 6, 659.00, 14.00, 12.00, 66.00, 3.00, 10, FALSE, FALSE, TRUE),
('Azeite de Dendê', 7, 884.00, 0.00, 0.00, 100.00, 0.00, 0, FALSE, FALSE, TRUE),
('Refrigerante Cola', 8, 42.00, 0.00, 10.60, 0.00, 10.00, 63, FALSE, FALSE, TRUE),
('Pão de Centeio', 9, 259.00, 9.00, 53.00, 2.00, 400.00, 50, FALSE, TRUE, TRUE),
('Peixe Branco Cozido', 10, 100.00, 20.00, 0.00, 2.00, 50.00, 0, FALSE, FALSE, FALSE),
('Azeitona Verde', 7, 115.00, 0.80, 6.00, 11.00, 1500.00, 15, FALSE, FALSE, TRUE),
('Milho Verde enlatado', 2, 70.00, 2.50, 15.00, 1.00, 200.00, 60, FALSE, FALSE, TRUE),
('Pão de Forma Integral', 9, 250.00, 10.00, 45.00, 3.00, 400.00, 50, FALSE, TRUE, TRUE),
('Batata Chips', 7, 536.00, 6.00, 50.00, 35.00, 500.00, 80, FALSE, FALSE, TRUE), -- Alto em gordura e sódio
('Biscoito Recheado', 8, 480.00, 5.00, 70.00, 20.00, 300.00, 75, TRUE, TRUE, FALSE),
('Feijão Fradinho Cozido', 3, 140.00, 9.00, 25.00, 0.50, 5.00, 35, FALSE, FALSE, TRUE),
('Leite Condensado', 8, 321.00, 7.00, 55.00, 8.00, 100.00, 70, TRUE, FALSE, FALSE),
('Salsicha', 5, 290.00, 11.00, 2.00, 26.00, 900.00, 0, FALSE, FALSE, FALSE),
('Tofu Defumado', 6, 120.00, 13.00, 3.00, 7.00, 150.00, 15, FALSE, FALSE, TRUE),
('Óleo de Canola', 7, 884.00, 0.00, 0.00, 100.00, 0.00, 0, FALSE, FALSE, TRUE),
('Açúcar Demerara', 8, 387.00, 0.00, 99.00, 0.00, 2.00, 60, FALSE, FALSE, TRUE),
('Pão de Hot Dog', 9, 280.00, 9.00, 50.00, 5.00, 500.00, 70, TRUE, TRUE, FALSE),
('Lagosta Cozida', 10, 89.00, 19.00, 0.00, 0.80, 238.00, 0, FALSE, FALSE, FALSE),
('Cenoura Crua', 2, 41.00, 0.90, 9.60, 0.20, 69.00, 35, FALSE, FALSE, TRUE),
('Brócolis Cozido', 2, 35.00, 2.80, 7.00, 0.40, 30.00, 10, FALSE, FALSE, TRUE),
('Pimentão Amarelo', 2, 27.00, 0.90, 6.30, 0.20, 2.00, 15, FALSE, FALSE, TRUE),
('Leite Fermentado', 4, 70.00, 2.50, 10.00, 2.00, 30.00, 40, TRUE, FALSE, FALSE),
('Queijo Parmesão', 4, 431.00, 38.00, 3.00, 29.00, 1600.00, 30, TRUE, FALSE, FALSE),
('Carne de Porco Cozida', 5, 242.00, 27.00, 0.00, 14.00, 60.00, 0, FALSE, FALSE, FALSE),
('Amendoim com Casca', 6, 567.00, 25.00, 16.00, 49.00, 18.00, 14, FALSE, FALSE, TRUE),
('Óleo de Palma', 7, 884.00, 0.00, 0.00, 100.00, 0.00, 0, FALSE, FALSE, TRUE),
('Refrigerante Guaraná', 8, 40.00, 0.00, 10.00, 0.00, 5.00, 60, FALSE, FALSE, TRUE),
('Pão de Milho', 9, 270.00, 7.00, 55.00, 3.00, 450.00, 65, FALSE, TRUE, TRUE),
('Atum em Lata (óleo)', 10, 200.00, 23.00, 0.00, 12.00, 350.00, 0, FALSE, FALSE, FALSE),
('Chuchu Cozido', 2, 19.00, 0.80, 4.00, 0.10, 2.00, 20, FALSE, FALSE, TRUE),
('Rabanete', 2, 16.00, 0.70, 3.40, 0.10, 10.00, 15, FALSE, FALSE, TRUE),
('Pepino em Conserva', 2, 11.00, 0.30, 2.50, 0.10, 1200.00, 15, FALSE, FALSE, TRUE),
('Kefir de Leite', 4, 60.00, 3.50, 5.00, 3.00, 40.00, 30, TRUE, FALSE, FALSE),
('Sorvete de Fruta (água)', 8, 100.00, 0.50, 25.00, 0.00, 10.00, 50, FALSE, FALSE, TRUE);




-- Inserindo dados na tabela refeicoes
INSERT INTO refeicoes (nome, tipo, horario_sugerido) VALUES
('Café da Manhã Clássico', 'Café da manhã', '07:00:00'),
('Almoço Saudável', 'Almoço', '12:30:00'),
('Jantar Leve', 'Jantar', '19:00:00'),
('Lanche da Tarde de Frutas', 'Lanche', '16:00:00'),
('Ceia Relaxante', 'Ceia', '21:30:00'),
('Café da Manhã Energético', 'Café da manhã', '07:30:00'),
('Almoço Proteico', 'Almoço', '13:00:00'),
('Jantar de Peixe', 'Jantar', '20:00:00'),
('Lanche de Oleaginosas', 'Lanche', '10:00:00'),
('Ceia com Iogurte', 'Ceia', '22:00:00'),
('Café Rápido', 'Café da manhã', '06:45:00'),
('Almoço Vegetariano', 'Almoço', '12:00:00'),
('Jantar de Sopas', 'Jantar', '18:30:00'),
('Lanche da Manhã', 'Lanche', '09:30:00'),
('Ceia de Chá', 'Ceia', '21:00:00'),
('Café da Manhã Tropical', 'Café da manhã', '08:00:00'),
('Almoço Completo', 'Almoço', '13:30:00'),
('Jantar de Omelete', 'Jantar', '19:30:00'),
('Lanche com Iogurte', 'Lanche', '15:00:00'),
('Ceia de Frutas', 'Ceia', '22:30:00'),
('Café Pré-Treino', 'Café da manhã', '06:30:00'),
('Almoço Pós-Treino', 'Almoço', '14:00:00'),
('Jantar Low Carb', 'Jantar', '18:00:00'),
('Lanche Proteico', 'Lanche', '17:00:00'),
('Ceia Nutritiva', 'Ceia', '20:30:00'),
('Café Leve', 'Café da manhã', '07:15:00'),
('Almoço Tradicional', 'Almoço', '12:45:00'),
('Jantar Mediterrâneo', 'Jantar', '19:15:00'),
('Lanche Rápido', 'Lanche', '10:30:00'),
('Ceia Simples', 'Ceia', '21:45:00'),
('Café Reforçado', 'Café da manhã', '08:30:00'),
('Almoço Executivo', 'Almoço', '13:15:00'),
('Jantar Vegano', 'Jantar', '20:15:00'),
('Lanche com Bolo', 'Lanche', '15:30:00'),
('Ceia com Biscoito', 'Ceia', '22:15:00'),
('Café de Fim de Semana', 'Café da manhã', '09:00:00'),
('Almoço de Domingo', 'Almoço', '14:30:00'),
('Jantar de Massas', 'Jantar', '20:45:00'),
('Lanche da Tarde', 'Lanche', '16:30:00'),
('Ceia Leve de Verão', 'Ceia', '23:00:00'),
('Café da Manhã Fitness', 'Café da manhã', '07:45:00'),
('Almoço de Conveniência', 'Almoço', '12:15:00'),
('Jantar de Salada', 'Jantar', '18:45:00'),
('Lanche Escolar', 'Lanche', '11:00:00'),
('Ceia Pós-Jantar', 'Ceia', '21:15:00'),
('Café da Manhã com Frutas', 'Café da manhã', '07:00:00'),
('Almoço com Frango', 'Almoço', '12:30:00'),
('Jantar com Legumes', 'Jantar', '19:00:00'),
('Lanche da Tarde Light', 'Lanche', '16:00:00'),
('Ceia de Grãos', 'Ceia', '21:30:00');


-- Refeição 1: Café da Manhã Clássico (Pão, Ovo, Café)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(1, 86, 50.00), -- Pão Francês
(1, 58, 60.00), -- Ovo Cozido
(1, 109, 200.00); -- Café sem Açúcar

-- Refeição 2: Almoço Saudável (Arroz Integral, Frango, Brócolis, Azeite)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(2, 32, 100.00), -- Arroz Integral Cozido
(2, 56, 120.00), -- Peito de Frango Grelhado
(2, 19, 80.00),  -- Brócolis
(2, 76, 5.00);   -- Azeite de Oliva Extra Virgem

-- Refeição 3: Jantar Leve (Salmão, Alface, Tomate)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(3, 59, 150.00), -- Salmão Assado
(3, 16, 50.00),  -- Alface Crespa
(3, 17, 50.00);  -- Tomate

-- Refeição 4: Lanche da Tarde de Frutas (Maçã, Banana)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(4, 1, 100.00),  -- Maçã Fuji
(4, 2, 80.00);   -- Banana Prata

-- Refeição 5: Ceia Relaxante (Leite, Mel)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(5, 46, 200.00), -- Leite Integral
(5, 80, 10.00);  -- Mel

-- Refeição 6: Café da Manhã Energético (Aveia, Banana, Leite)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(6, 33, 40.00),  -- Aveia em Flocos
(6, 2, 80.00),   -- Banana Prata
(6, 46, 150.00); -- Leite Integral

-- Refeição 7: Almoço Proteico (Bife, Feijão, Arroz Branco, Cenoura)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(7, 57, 150.00), -- Bife de Alcatra Grelhado
(7, 40, 80.00),  -- Feijão Carioca Cozido
(7, 31, 100.00), -- Arroz Branco Cozido
(7, 18, 50.00);  -- Cenoura

-- Refeição 8: Jantar de Peixe (Tilápia, Batata Doce, Aspargos)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(8, 60, 150.00), -- Filé de Tilápia Grelhado
(8, 29, 100.00), -- Batata Doce
(8, 26, 70.00);  -- Aspargos

-- Refeição 9: Lanche de Oleaginosas (Amendoim, Castanha de Caju)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(9, 66, 30.00),  -- Amendoim Torrado
(9, 67, 30.00);  -- Castanha de Caju

-- Refeição 10: Ceia com Iogurte (Iogurte, Morango)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(10, 47, 150.00), -- Iogurte Natural Integral
(10, 6, 50.00);   -- Morango

-- Refeição 11: Café Rápido (Torrada, Café)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(11, 89, 40.00),  -- Torrada Tradicional
(11, 109, 200.00); -- Café sem Açúcar

-- Refeição 12: Almoço Vegetariano (Quinoa, Grão de Bico, Pimentão)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(12, 35, 80.00),  -- Quinoa Cozida
(12, 38, 100.00), -- Grão de Bico Cozido
(12, 21, 50.00);  -- Pimentão Vermelho

-- Refeição 13: Jantar de Sopas (Couve Flor, Cenoura)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(13, 23, 100.00), -- Couve Flor
(13, 18, 50.00);  -- Cenoura

-- Refeição 14: Lanche da Manhã (Maçã)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(14, 1, 150.00); -- Maçã Fuji

-- Refeição 15: Ceia de Chá (Chá - não temos, mas podemos usar água para simplificar, e Biscoito)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(15, 90, 30.00); -- Biscoito Cream Cracker

-- Refeição 16: Café da Manhã Tropical (Abacaxi, Coco - não temos coco puro, então usamos abacaxi e leite de amêndoas)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(16, 7, 120.00),   -- Abacaxi
(16, 112, 150.00); -- Leite de Amêndoas

-- Refeição 17: Almoço Completo (Arroz, Feijão, Carne Moída, Salada)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(17, 31, 100.00), -- Arroz Branco Cozido
(17, 40, 80.00),  -- Feijão Carioca Cozido
(17, 61, 100.00), -- Carne Moída Patinho
(17, 16, 50.00),  -- Alface Crespa
(17, 17, 50.00);  -- Tomate

-- Refeição 18: Jantar de Omelete (Ovo, Pimentão, Cebola)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(18, 58, 120.00), -- Ovo Cozido (2 ovos)
(18, 21, 40.00),  -- Pimentão Vermelho
(18, 30, 30.00);  -- Cebola

-- Refeição 19: Lanche com Iogurte (Iogurte, Morango)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(19, 47, 150.00), -- Iogurte Natural Integral
(19, 6, 50.00);   -- Morango

-- Refeição 20: Ceia de Frutas (Pêssego, Pera)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(20, 9, 80.00),   -- Pêssego
(20, 10, 80.00);  -- Pera

-- Refeição 21: Café Pré-Treino (Banana, Aveia)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(21, 2, 100.00),  -- Banana Prata
(21, 33, 30.00);  -- Aveia em Flocos

-- Refeição 22: Almoço Pós-Treino (Frango, Batata Doce, Brócolis)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(22, 56, 150.00), -- Peito de Frango Grelhado
(22, 29, 120.00), -- Batata Doce
(22, 19, 100.00); -- Brócolis

-- Refeição 23: Jantar Low Carb (Salmão, Aspargos)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(23, 59, 150.00), -- Salmão Assado
(23, 26, 100.00); -- Aspargos

-- Refeição 24: Lanche Proteico (Amêndoa, Iogurte Grego)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(24, 68, 25.00),  -- Amêndoa
(24, 53, 100.00); -- Iogurte Grego Light

-- Refeição 25: Ceia Nutritiva (Ricota, Morango)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(25, 51, 80.00),  -- Ricota Fresca
(25, 6, 50.00);   -- Morango

-- Refeição 26: Café Leve (Laranja, Café)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(26, 3, 150.00),  -- Laranja Pera
(26, 109, 200.00); -- Café sem Açúcar

-- Refeição 27: Almoço Tradicional (Arroz, Feijão, Bife, Salada)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(27, 31, 100.00), -- Arroz Branco Cozido
(27, 40, 80.00),  -- Feijão Carioca Cozido
(27, 57, 120.00), -- Bife de Alcatra Grelhado
(27, 16, 50.00),  -- Alface Crespa
(27, 17, 50.00);  -- Tomate

-- Refeição 28: Jantar Mediterrâneo (Tilápia, Azeite, Tomate)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(28, 60, 120.00), -- Filé de Tilápia Grelhado
(28, 76, 5.00),   -- Azeite de Oliva Extra Virgem
(28, 17, 80.00);  -- Tomate

-- Refeição 29: Lanche Rápido (Biscoito Cream Cracker)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(29, 90, 30.00); -- Biscoito Cream Cracker

-- Refeição 30: Ceia Simples (Leite Integral)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(30, 46, 200.00); -- Leite Integral

-- Refeição 31: Café Reforçado (Pão Integral, Ovo, Queijo Minas, Café)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(31, 87, 60.00),  -- Pão Integral
(31, 58, 60.00),  -- Ovo Cozido
(31, 48, 40.00),  -- Queijo Minas Frescal
(31, 109, 200.00); -- Café sem Açúcar

-- Refeição 32: Almoço Executivo (Salmão, Arroz Integral, Aspargos)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(32, 59, 150.00), -- Salmão Assado
(32, 32, 100.00), -- Arroz Integral Cozido
(32, 26, 80.00);  -- Aspargos

-- Refeição 33: Jantar Vegano (Grão de Bico, Quinoa, Abobrinha, Berinjela)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(33, 38, 120.00), -- Grão de Bico Cozido
(33, 35, 80.00),  -- Quinoa Cozida
(33, 22, 70.00),  -- Abobrinha
(33, 24, 70.00);  -- Berinjela

-- Refeição 34: Lanche com Bolo (Bolo de Chocolate)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(34, 105, 80.00); -- Bolo de Chocolate

-- Refeição 35: Ceia com Biscoito (Biscoito, Leite)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(35, 90, 30.00),  -- Biscoito Cream Cracker
(35, 46, 150.00); -- Leite Integral

-- Refeição 36: Café de Fim de Semana (Panqueca - não temos panqueca, mas podemos usar farinha de trigo e ovo como base)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(36, 107, 50.00), -- Farinha de Trigo
(36, 58, 60.00),  -- Ovo Cozido
(36, 80, 20.00);  -- Mel

-- Refeição 37: Almoço de Domingo (Feijoada - usar os ingredientes da feijoada separeiamente)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(37, 106, 200.00); -- Feijoada Completa (usando o alimento 'Feijoada Completa')

-- Refeição 38: Jantar de Massas (Macarrão, Azeite, Tomate)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(38, 88, 150.00), -- Macarrão Cozido
(38, 76, 10.00),  -- Azeite de Oliva Extra Virgem
(38, 17, 80.00);  -- Tomate

-- Refeição 39: Lanche da Tarde (Iogurte, Uva)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(39, 47, 150.00), -- Iogurte Natural Integral
(39, 4, 80.00);   -- Uva Crimson

-- Refeição 40: Ceia Leve de Verão (Melancia, Limão)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(40, 8, 200.00),  -- Melancia
(40, 14, 5.00);   -- Limão Tahiti

-- Refeição 41: Café da Manhã Fitness (Ovo, Pão Integral)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(41, 58, 120.00), -- Ovo Cozido (2 ovos)
(41, 87, 50.00);  -- Pão Integral

-- Refeição 42: Almoço de Conveniência (Lasanha - massa, e um complemento)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(42, 91, 200.00), -- Lasanha (massa)
(42, 61, 80.00);  -- Carne Moída Patinho (como complemento)

-- Refeição 43: Jantar de Salada (Alface, Tomate, Pepino, Cenoura, Azeite)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(43, 16, 80.00),  -- Alface Crespa
(43, 17, 60.00),  -- Tomate
(43, 20, 50.00),  -- Pepino
(43, 18, 50.00),  -- Cenoura
(43, 76, 5.00);   -- Azeite de Oliva Extra Virgem

-- Refeição 44: Lanche Escolar (Pão de Forma Branco, Geleia)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(44, 92, 50.00),  -- Pão de Forma Branco
(44, 82, 30.00);  -- Geleia de Morango

-- Refeição 45: Ceia Pós-Jantar (Chá e fruta, ou apenas fruta)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(45, 1, 100.00); -- Maçã Fuji

-- Refeição 46: Café da Manhã com Frutas (Morango, Kiwi, Iogurte)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(46, 6, 70.00),   -- Morango
(46, 11, 70.00),  -- Kiwi
(46, 47, 100.00); -- Iogurte Natural Integral

-- Refeição 47: Almoço com Frango (Frango, Arroz, Brócolis)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(47, 56, 150.00), -- Peito de Frango Grelhado
(47, 31, 100.00), -- Arroz Branco Cozido
(47, 19, 80.00);  -- Brócolis

-- Refeição 48: Jantar com Legumes (Abobrinha, Berinjela, Cenoura, Azeite)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(48, 22, 80.00),  -- Abobrinha
(48, 24, 80.00),  -- Berinjela
(48, 18, 60.00),  -- Cenoura
(48, 76, 5.00);   -- Azeite de Oliva Extra Virgem

-- Refeição 49: Lanche da Tarde Light (Maçã, Iogurte Grego)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(49, 1, 100.00),  -- Maçã Fuji
(49, 53, 100.00); -- Iogurte Grego Light

-- Refeição 50: Ceia de Grãos (Quinoa, Lentilha)
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(50, 35, 70.00),  -- Quinoa Cozida
(50, 39, 70.00);  -- Lentilha Cozida

-- Mais algumas refeições para garantir que tenhamos mais de 50
-- Refeição 51: Café Completo (Pão Integral, Ovo, Leite, Fruta)
INSERT INTO refeicoes (nome, tipo, horario_sugerido) VALUES ('Café Completo', 'Café da manhã', '08:15:00');
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(51, 87, 60.00), -- Pão Integral
(51, 58, 60.00), -- Ovo Cozido
(51, 46, 150.00), -- Leite Integral
(51, 1, 80.00);  -- Maçã Fuji

-- Refeição 52: Almoço de Peixe (Tilápia, Arroz Branco, Vagem)
INSERT INTO refeicoes (nome, tipo, horario_sugerido) VALUES ('Almoço de Peixe', 'Almoço', '13:45:00');
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(52, 60, 150.00), -- Filé de Tilápia Grelhado
(52, 31, 100.00), -- Arroz Branco Cozido
(52, 25, 70.00);  -- Vagem

-- Refeição 53: Jantar Rápido (Sanduíche Natural - Pão integral, Queijo Minas, Tomate, Alface)
INSERT INTO refeicoes (nome, tipo, horario_sugerido) VALUES ('Jantar Rápido', 'Jantar', '19:45:00');
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(53, 87, 80.00),  -- Pão Integral
(53, 48, 50.00),  -- Queijo Minas Frescal
(53, 17, 30.00),  -- Tomate
(53, 16, 20.00);  -- Alface Crespa

-- Refeição 54: Lanche da Tarde Nutritivo (Amêndoa, Uva)
INSERT INTO refeicoes (nome, tipo, horario_sugerido) VALUES ('Lanche da Tarde Nutritivo', 'Lanche', '16:15:00');
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(54, 68, 20.00),  -- Amêndoa
(54, 4, 100.00);  -- Uva Crimson

-- Refeição 55: Ceia Simples com Queijo (Ricota)
INSERT INTO refeicoes (nome, tipo, horario_sugerido) VALUES ('Ceia Simples com Queijo', 'Ceia', '22:45:00');
INSERT INTO refeicao_alimentos (refeicao_id, alimento_id, quantidade_gramas) VALUES
(55, 51, 80.00);  -- Ricota Fresca




CREATE FUNCTION public.fn_refeicoes_para_diabeticos(usuario_alvo integer) RETURNS TABLE(refeicao_id integer, nome text, tipo text, horario time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM usuario_restricoes ur
        JOIN restricoes r ON r.id = ur.restricao_id
        WHERE ur.usuario_id = usuario_alvo AND r.nome ILIKE '%DIABETES%'
    ) THEN
        RETURN QUERY
        SELECT rf.id, rf.nome::TEXT, rf.tipo::TEXT, rf.horario_sugerido
        FROM refeicoes rf
        WHERE NOT EXISTS (
            SELECT 1
            FROM refeicao_alimentos ra
            JOIN alimentos a ON a.id = ra.alimento_id
            WHERE ra.refeicao_id = rf.id AND a.indice_glicemico > 55
        );
    ELSE
        RETURN QUERY SELECT id, nome::TEXT, tipo::TEXT, horario_sugerido FROM refeicoes;
    END IF;
END;
$$;