--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tipo_grupo_alimentar; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_grupo_alimentar AS ENUM (
    'Frutas',
    'Verduras',
    'Cereais',
    'Laticínios',
    'Carnes',
    'Doces'
);


--
-- Name: tipo_refeicao; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_refeicao AS ENUM (
    'Café da manhã',
    'Almoço',
    'Jantar',
    'Lanche',
    'Ceia'
);


--
-- Name: tipo_sexo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_sexo AS ENUM (
    'Masculino',
    'Feminino'
);


--
-- Name: fn_refeicoes_para_diabeticos(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_refeicoes_para_diabeticos(usuario_alvo integer) RETURNS TABLE(refeicao_id integer, nome text, tipo text, horario time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM usuario_restricoes ur
        JOIN restricoes r ON r.id = ur.restricao_id
        WHERE ur.usuario_id = usuario_alvo AND r.nome ILIKE '%Diabetes%'
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


--
-- Name: fn_refeicoes_sem_lactose_ou_gluten(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_refeicoes_sem_lactose_ou_gluten(usuario_alvo integer) RETURNS TABLE(refeicao_id integer, nome text, tipo text, horario time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT rf.id, rf.nome::TEXT, rf.tipo::TEXT, rf.horario_sugerido
    FROM refeicoes rf
    WHERE NOT EXISTS (
        SELECT 1
        FROM refeicao_alimentos ra
        JOIN alimentos a ON a.id = ra.alimento_id
        WHERE ra.refeicao_id = rf.id
        AND (
            (a.lactose = TRUE AND EXISTS (
                SELECT 1 FROM usuario_restricoes ur
                JOIN restricoes r ON r.id = ur.restricao_id
                WHERE ur.usuario_id = usuario_alvo
                  AND r.nome ILIKE '%Lactose%'
            )) OR
            (a.gluten = TRUE AND EXISTS (
                SELECT 1 FROM usuario_restricoes ur
                JOIN restricoes r ON r.id = ur.restricao_id
                WHERE ur.usuario_id = usuario_alvo
                  AND r.nome ILIKE '%Glúten%'
            ))
        )
    );
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alimentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alimentos (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    grupo_alimentar public.tipo_grupo_alimentar,
    calorias_kcal numeric(6,2),
    proteinas_g numeric(6,2),
    carboidratos_g numeric(6,2),
    gorduras_g numeric(6,2),
    sodio_mg numeric(6,2),
    lactose boolean,
    gluten boolean,
    vegano boolean,
    indice_glicemico smallint,
    CONSTRAINT alimentos_calorias_kcal_check CHECK ((calorias_kcal >= (0)::numeric)),
    CONSTRAINT alimentos_carboidratos_g_check CHECK ((carboidratos_g >= (0)::numeric)),
    CONSTRAINT alimentos_gorduras_g_check CHECK ((gorduras_g >= (0)::numeric)),
    CONSTRAINT alimentos_indice_glicemico_check CHECK (((indice_glicemico >= 0) AND (indice_glicemico <= 100))),
    CONSTRAINT alimentos_proteinas_g_check CHECK ((proteinas_g >= (0)::numeric)),
    CONSTRAINT alimentos_sodio_mg_check CHECK ((sodio_mg >= (0)::numeric))
);


--
-- Name: alimentos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alimentos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alimentos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alimentos_id_seq OWNED BY public.alimentos.id;


--
-- Name: avaliacoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avaliacoes (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    plano_id integer NOT NULL,
    nota smallint,
    comentario text,
    CONSTRAINT avaliacoes_nota_check CHECK (((nota >= 1) AND (nota <= 5)))
);


--
-- Name: avaliacoes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.avaliacoes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: avaliacoes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.avaliacoes_id_seq OWNED BY public.avaliacoes.id;


--
-- Name: planos_alimentares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planos_alimentares (
    id integer NOT NULL,
    usuario_id integer,
    data date DEFAULT CURRENT_DATE,
    objetivo text,
    observacoes text
);


--
-- Name: plano_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plano_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plano_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plano_id_seq OWNED BY public.planos_alimentares.id;


--
-- Name: planos_refeicoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planos_refeicoes (
    plano_id integer NOT NULL,
    refeicao_id integer NOT NULL,
    ordem_refeicao smallint
);


--
-- Name: refeicao_alimentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refeicao_alimentos (
    refeicao_id integer NOT NULL,
    alimento_id integer NOT NULL,
    quantidade_gramas numeric(6,2)
);


--
-- Name: refeicoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refeicoes (
    id integer NOT NULL,
    nome character varying(100),
    tipo public.tipo_refeicao,
    horario_sugerido time without time zone
);


--
-- Name: refeicoes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refeicoes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refeicoes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refeicoes_id_seq OWNED BY public.refeicoes.id;


--
-- Name: restricoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restricoes (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    descricao text
);


--
-- Name: restricoes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restricoes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: restricoes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restricoes_id_seq OWNED BY public.restricoes.id;


--
-- Name: usuario_restricoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_restricoes (
    usuario_id integer NOT NULL,
    restricao_id integer NOT NULL
);


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    data_nascimento date,
    sexo public.tipo_sexo,
    peso_kg numeric(5,2),
    altura_cm integer,
    objetivo character varying(50),
    ativo boolean DEFAULT true
);


--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: vw_refeicoes_para_diabeticos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_refeicoes_para_diabeticos AS
 SELECT rd.refeicao_id,
    rd.nome,
    rd.tipo,
    rd.horario,
    a.nome AS alimento
   FROM ((public.fn_refeicoes_para_diabeticos(5) rd(refeicao_id, nome, tipo, horario)
     LEFT JOIN public.refeicao_alimentos ra ON ((ra.refeicao_id = rd.refeicao_id)))
     LEFT JOIN public.alimentos a ON ((a.id = ra.alimento_id)));


--
-- Name: alimentos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alimentos ALTER COLUMN id SET DEFAULT nextval('public.alimentos_id_seq'::regclass);


--
-- Name: avaliacoes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avaliacoes ALTER COLUMN id SET DEFAULT nextval('public.avaliacoes_id_seq'::regclass);


--
-- Name: planos_alimentares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planos_alimentares ALTER COLUMN id SET DEFAULT nextval('public.plano_id_seq'::regclass);


--
-- Name: refeicoes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refeicoes ALTER COLUMN id SET DEFAULT nextval('public.refeicoes_id_seq'::regclass);


--
-- Name: restricoes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restricoes ALTER COLUMN id SET DEFAULT nextval('public.restricoes_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Data for Name: alimentos; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.alimentos VALUES (11, 'Arroz branco cozido', 'Cereais', 130.00, 2.50, 28.00, 0.30, 1.00, false, false, true, 70);
INSERT INTO public.alimentos VALUES (12, 'Feijão carioca cozido', 'Cereais', 76.00, 4.80, 13.60, 0.50, 1.00, false, false, true, 38);
INSERT INTO public.alimentos VALUES (13, 'Carne bovina grelhada', 'Carnes', 250.00, 26.00, 0.00, 15.00, 65.00, false, false, false, 0);
INSERT INTO public.alimentos VALUES (14, 'Peito de frango grelhado', 'Carnes', 165.00, 31.00, 0.00, 3.60, 70.00, false, false, false, 0);
INSERT INTO public.alimentos VALUES (15, 'Brócolis cozido', 'Verduras', 55.00, 3.70, 11.20, 0.60, 33.00, false, false, true, 15);
INSERT INTO public.alimentos VALUES (16, 'Banana prata', 'Frutas', 89.00, 1.00, 23.00, 0.30, 1.00, false, false, true, 52);
INSERT INTO public.alimentos VALUES (17, 'Leite integral', 'Laticínios', 61.00, 3.20, 4.80, 3.40, 44.00, true, false, false, 47);
INSERT INTO public.alimentos VALUES (18, 'Pão francês', 'Cereais', 270.00, 8.00, 50.00, 1.50, 330.00, false, true, true, 70);
INSERT INTO public.alimentos VALUES (19, 'Maçã', 'Frutas', 52.00, 0.30, 14.00, 0.20, 1.00, false, false, true, 39);
INSERT INTO public.alimentos VALUES (20, 'Iogurte natural integral', 'Laticínios', 61.00, 3.50, 4.70, 3.30, 50.00, true, false, false, 36);


--
-- Data for Name: avaliacoes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: planos_alimentares; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: planos_refeicoes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: refeicao_alimentos; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refeicao_alimentos VALUES (1, 11, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (1, 12, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (1, 13, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (2, 14, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (2, 15, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (3, 18, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (3, 17, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (4, 16, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (4, 19, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (5, 20, 150.00);


--
-- Data for Name: refeicoes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refeicoes VALUES (1, 'Almoço tradicional', 'Almoço', '12:00:00');
INSERT INTO public.refeicoes VALUES (2, 'Jantar leve', 'Jantar', '19:00:00');
INSERT INTO public.refeicoes VALUES (3, 'Café da manhã', 'Café da manhã', '07:30:00');
INSERT INTO public.refeicoes VALUES (4, 'Lanche da tarde', 'Lanche', '15:30:00');
INSERT INTO public.refeicoes VALUES (5, 'Ceia', 'Ceia', '22:00:00');


--
-- Data for Name: restricoes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.restricoes VALUES (1, 'Diabetes', 'Controle de índice glicêmico');
INSERT INTO public.restricoes VALUES (2, 'Hipertensão', 'Controle de ingestão de sódio');
INSERT INTO public.restricoes VALUES (5, 'Vegetariano', 'Evita carne e derivados animais');
INSERT INTO public.restricoes VALUES (3, 'Lactose', 'Evita alimentos com lactose');
INSERT INTO public.restricoes VALUES (4, 'Glúten', 'Evita alimentos com glúten');


--
-- Data for Name: usuario_restricoes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuario_restricoes VALUES (1, 1);
INSERT INTO public.usuario_restricoes VALUES (1, 3);
INSERT INTO public.usuario_restricoes VALUES (5, 1);


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuarios VALUES (1, 'Maria Alice Monteiro', 'felipeduarte@ig.com.br', '1987-03-13', 'Masculino', 56.00, 167, 'Perder peso', true);
INSERT INTO public.usuarios VALUES (2, 'Ana Clara Silveira', 'henrique16@da.org', '1994-01-06', 'Masculino', 60.58, 156, 'Ganhar massa', true);
INSERT INTO public.usuarios VALUES (3, 'Maria Julia Moraes', 'vpires@yahoo.com.br', '1981-05-14', 'Masculino', 78.62, 152, 'Perder peso', true);
INSERT INTO public.usuarios VALUES (4, 'Fernando da Rosa', 'lsales@melo.com', '1970-04-15', 'Masculino', 63.75, 182, 'Ganhar massa', true);
INSERT INTO public.usuarios VALUES (5, 'Bruna da Cunha', 'emanuelly38@ig.com.br', '1994-03-12', 'Masculino', 77.45, 184, 'Manter peso', true);
INSERT INTO public.usuarios VALUES (6, 'Nathan da Rosa', 'luiz-henriquegoncalves@yahoo.com.br', '2003-05-27', 'Masculino', 72.97, 167, 'Perder peso', true);
INSERT INTO public.usuarios VALUES (7, 'Agatha Cavalcanti', 'maria-fernandamoreira@ig.com.br', '1987-12-21', 'Masculino', 82.93, 171, 'Manter peso', true);
INSERT INTO public.usuarios VALUES (8, 'Bruna Rezende', 'camposdiego@da.com', '2003-01-26', 'Masculino', 63.61, 171, 'Perder peso', true);
INSERT INTO public.usuarios VALUES (9, 'Pedro Almeida', 'raquelfreitas@hotmail.com', '1976-05-02', 'Masculino', 70.20, 172, 'Manter peso', true);
INSERT INTO public.usuarios VALUES (10, 'Sr. Vitor Novaes', 'castromaite@lopes.br', '2006-03-01', 'Feminino', 87.29, 179, 'Ganhar massa', true);


--
-- Name: alimentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alimentos_id_seq', 1, false);


--
-- Name: avaliacoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.avaliacoes_id_seq', 1, false);


--
-- Name: plano_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plano_id_seq', 1, false);


--
-- Name: refeicoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refeicoes_id_seq', 1, false);


--
-- Name: restricoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.restricoes_id_seq', 1, false);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 1, false);


--
-- Name: alimentos alimentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alimentos
    ADD CONSTRAINT alimentos_pkey PRIMARY KEY (id);


--
-- Name: avaliacoes avaliacoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avaliacoes
    ADD CONSTRAINT avaliacoes_pkey PRIMARY KEY (id);


--
-- Name: planos_refeicoes recomendacao_refeicoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planos_refeicoes
    ADD CONSTRAINT recomendacao_refeicoes_pkey PRIMARY KEY (plano_id, refeicao_id);


--
-- Name: planos_alimentares recomendacoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planos_alimentares
    ADD CONSTRAINT recomendacoes_pkey PRIMARY KEY (id);


--
-- Name: refeicao_alimentos refeicao_alimentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refeicao_alimentos
    ADD CONSTRAINT refeicao_alimentos_pkey PRIMARY KEY (refeicao_id, alimento_id);


--
-- Name: refeicoes refeicoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refeicoes
    ADD CONSTRAINT refeicoes_pkey PRIMARY KEY (id);


--
-- Name: restricoes restricoes_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restricoes
    ADD CONSTRAINT restricoes_nome_key UNIQUE (nome);


--
-- Name: restricoes restricoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restricoes
    ADD CONSTRAINT restricoes_pkey PRIMARY KEY (id);


--
-- Name: usuario_restricoes usuario_restricoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_restricoes
    ADD CONSTRAINT usuario_restricoes_pkey PRIMARY KEY (usuario_id, restricao_id);


--
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: avaliacoes avaliacoes_planosalimentares_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avaliacoes
    ADD CONSTRAINT avaliacoes_planosalimentares_id_fkey FOREIGN KEY (plano_id) REFERENCES public.planos_alimentares(id) ON DELETE CASCADE;


--
-- Name: avaliacoes avaliacoes_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avaliacoes
    ADD CONSTRAINT avaliacoes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: planos_refeicoes recomendacao_refeicoes_recomendacao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planos_refeicoes
    ADD CONSTRAINT recomendacao_refeicoes_recomendacao_id_fkey FOREIGN KEY (plano_id) REFERENCES public.planos_alimentares(id) ON DELETE CASCADE;


--
-- Name: planos_refeicoes recomendacao_refeicoes_refeicao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planos_refeicoes
    ADD CONSTRAINT recomendacao_refeicoes_refeicao_id_fkey FOREIGN KEY (refeicao_id) REFERENCES public.refeicoes(id);


--
-- Name: planos_alimentares recomendacoes_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planos_alimentares
    ADD CONSTRAINT recomendacoes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: refeicao_alimentos refeicao_alimentos_alimento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refeicao_alimentos
    ADD CONSTRAINT refeicao_alimentos_alimento_id_fkey FOREIGN KEY (alimento_id) REFERENCES public.alimentos(id);


--
-- Name: refeicao_alimentos refeicao_alimentos_refeicao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refeicao_alimentos
    ADD CONSTRAINT refeicao_alimentos_refeicao_id_fkey FOREIGN KEY (refeicao_id) REFERENCES public.refeicoes(id) ON DELETE CASCADE;


--
-- Name: usuario_restricoes usuario_restricoes_restricao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_restricoes
    ADD CONSTRAINT usuario_restricoes_restricao_id_fkey FOREIGN KEY (restricao_id) REFERENCES public.restricoes(id) ON DELETE CASCADE;


--
-- Name: usuario_restricoes usuario_restricoes_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_restricoes
    ADD CONSTRAINT usuario_restricoes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

