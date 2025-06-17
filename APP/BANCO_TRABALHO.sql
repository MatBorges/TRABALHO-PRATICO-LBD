

CREATE TYPE tipo_sexo AS ENUM ('Masculino', 'Feminino');

CREATE TABLE usuarios (
    id serial primary key,
    nome varchar(100) not null,
    email varchar(100) unique not null,
    data_nascimento date,
    sexo tipo_sexo,
    peso_kg decimal(5,2),
    altura_cm int,
    objetivo varchar(50), -- ver se mantem ou nõa
    ativo boolean default TRUE
);


CREATE TABLE restricoes (
    id serial primary key,
    nome varchar(100) not null unique,
    descricao text
);


CREATE TABLE usuario_restricoes (
    usuario_id int references usuarios(id) on delete cascade,
    restricao_id int references restricoes(id) on delete cascade,
    primary key (usuario_id, restricao_id)
);


CREATE TYPE tipo_grupo_alimentar AS enum ('Frutas', 'Verduras', 'Cereais', 'Laticínios', 'Carnes', 'Doces');

CREATE TABLE alimentos (
    id serial primary key,
    nome varchar(100) not null,
    grupo_alimentar tipo_grupo_alimentar,
    calorias_kcal decimal(6,2) CHECK (calorias_kcal >= 0),
    proteinas_g decimal(6,2) CHECK (proteinas_g >= 0),
    carboidratos_g decimal(6,2) CHECK (carboidratos_g >= 0),
    gorduras_g decimal(6,2) CHECK (gorduras_g >= 0),
    sodio_mg decimal(6,2) CHECK (sodio_mg >= 0),
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



CREATE TABLE recomendacoes (
    id serial primary key,
    usuario_id int references usuarios(id) on delete cascade,
    data date default CURRENT_DATE,
    objetivo text,
    observacoes text
);


CREATE TABLE recomendacao_refeicoes (
    recomendacao_id int references recomendacoes(id) on delete cascade,
    refeicao_id int references refeicoes(id),
    ordem_refeicao smallint, 
    primary key (recomendacao_id, refeicao_id)
);
