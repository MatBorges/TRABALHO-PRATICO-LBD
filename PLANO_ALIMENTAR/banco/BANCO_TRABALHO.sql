

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
    nome varchar(100) not null,
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

CREATE TABLE avaliacoes (
    id serial primary key,
    recomendacao_id int references recomendacoes(id) on delete cascade,
    usuario_id int references usuarios(id),
    nota smallint check (nota BETWEEN 1 AND 5),
    comentario text,
    data_avaliacao timestamp default CURRENT_TIMESTAMP
);


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