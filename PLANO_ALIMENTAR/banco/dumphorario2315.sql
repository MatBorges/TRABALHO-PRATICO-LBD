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
-- Name: tipo_objetivo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_objetivo AS ENUM (
    'Perder peso',
    'Ganhar massa',
    'Dieta Saudavel'
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
-- Name: fn_refeicoes_objetivo(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_refeicoes_objetivo(usuario_alvo_id integer) RETURNS TABLE(refeicao_id integer, nome_refeicao character varying, tipo_refeicao public.tipo_refeicao, horario_sugerido time without time zone, total_calorias numeric, total_proteinas numeric, total_gorduras numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_objetivo tipo_objetivo;
BEGIN
    
    SELECT objetivo INTO v_objetivo FROM usuarios WHERE id = usuario_alvo_id;

   
    IF v_objetivo = 'Perder peso' THEN
        RETURN QUERY
        WITH info_refeicoes AS (
            SELECT 
                ra.refeicao_id,
                SUM(a.calorias_kcal * (ra.quantidade_gramas / 100.0)) AS calorias,
                SUM(a.proteinas_g * (ra.quantidade_gramas / 100.0)) AS proteinas,
                SUM(a.gorduras_g * (ra.quantidade_gramas / 100.0)) AS gorduras
            FROM refeicao_alimentos ra JOIN alimentos a ON ra.alimento_id = a.id
            GROUP BY ra.refeicao_id
        ),
        refeicoes_elegiveis AS (
            SELECT f.refeicao_id FROM fn_refeicoes_para_diabeticos(usuario_alvo_id) f
            INTERSECT
            SELECT f.refeicao_id FROM fn_refeicoes_sem_lactose_gluten(usuario_alvo_id) f
        )
        SELECT r.id, r.nome, r.tipo, r.horario_sugerido, 
               ROUND(ir.calorias, 2), ROUND(ir.proteinas, 2), ROUND(ir.gorduras, 2)
        FROM refeicoes r
        JOIN info_refeicoes ir ON r.id = ir.refeicao_id
        WHERE r.id IN (SELECT re.refeicao_id FROM refeicoes_elegiveis re)
        ORDER BY ir.calorias ASC;

    ELSIF v_objetivo = 'Ganhar massa' THEN
        RETURN QUERY
        WITH info_refeicoes AS (
            SELECT 
                ra.refeicao_id,
                SUM(a.calorias_kcal * (ra.quantidade_gramas / 100.0)) AS calorias,
                SUM(a.proteinas_g * (ra.quantidade_gramas / 100.0)) AS proteinas,
                SUM(a.gorduras_g * (ra.quantidade_gramas / 100.0)) AS gorduras
            FROM refeicao_alimentos ra JOIN alimentos a ON ra.alimento_id = a.id
            GROUP BY ra.refeicao_id
        ),
        refeicoes_elegiveis AS (
            SELECT f.refeicao_id FROM fn_refeicoes_para_diabeticos(usuario_alvo_id) f
            INTERSECT
            SELECT f.refeicao_id FROM fn_refeicoes_sem_lactose_gluten(usuario_alvo_id) f
        )
        SELECT r.id, r.nome, r.tipo, r.horario_sugerido, 
               ROUND(ir.calorias, 2), ROUND(ir.proteinas, 2), ROUND(ir.gorduras, 2)
        FROM refeicoes r
        JOIN info_refeicoes ir ON r.id = ir.refeicao_id
        WHERE r.id IN (SELECT re.refeicao_id FROM refeicoes_elegiveis re)
        ORDER BY ir.proteinas DESC, ir.calorias DESC;

    ELSE
        RETURN QUERY
        WITH info_refeicoes AS (
            SELECT 
                ra.refeicao_id,
                SUM(a.calorias_kcal * (ra.quantidade_gramas / 100.0)) AS calorias,
                SUM(a.proteinas_g * (ra.quantidade_gramas / 100.0)) AS proteinas,
                SUM(a.gorduras_g * (ra.quantidade_gramas / 100.0)) AS gorduras
            FROM refeicao_alimentos ra JOIN alimentos a ON ra.alimento_id = a.id
            GROUP BY ra.refeicao_id
        ),
        refeicoes_elegiveis AS (
            SELECT f.refeicao_id FROM fn_refeicoes_para_diabeticos(usuario_alvo_id) f
            INTERSECT
            SELECT f.refeicao_id FROM fn_refeicoes_sem_lactose_gluten(usuario_alvo_id) f
        )
        SELECT r.id, r.nome, r.tipo, r.horario_sugerido, 
               ROUND(ir.calorias, 2), ROUND(ir.proteinas, 2), ROUND(ir.gorduras, 2)
        FROM refeicoes r
        JOIN info_refeicoes ir ON r.id = ir.refeicao_id
        WHERE r.id IN (SELECT re.refeicao_id FROM refeicoes_elegiveis re)
        ORDER BY r.horario_sugerido DESC;
    END IF;
END;
$$;


--
-- Name: fn_refeicoes_para_diabeticos(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_refeicoes_para_diabeticos(usuario_alvo integer) RETURNS TABLE(refeicao_id integer, nome text, tipo text, horario time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
      FROM public.usuario_restricoes ur
      JOIN public.restricoes r ON r.id = ur.restricao_id
     WHERE ur.usuario_id = usuario_alvo
       AND r.nome ILIKE '%Diabetes%'
  ) THEN
    RETURN QUERY
      SELECT
        rf.id,
        rf.nome::TEXT,
        rf.tipo::TEXT,
        rf.horario_sugerido
      FROM public.refeicoes rf
     WHERE NOT EXISTS (
        SELECT 1
          FROM public.refeicao_alimentos ra
          JOIN public.alimentos a ON a.id = ra.alimento_id
         WHERE ra.refeicao_id = rf.id
           AND a.indice_glicemico > 55
      )
     ORDER BY rf.horario_sugerido;
  ELSE
    RETURN QUERY
      SELECT
        rf.id,
        rf.nome::TEXT,
        rf.tipo::TEXT,
        rf.horario_sugerido
      FROM public.refeicoes rf
     ORDER BY rf.horario_sugerido;
  END IF;
END;
$$;


--
-- Name: fn_refeicoes_sem_lactose_gluten(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_refeicoes_sem_lactose_gluten(usuario_alvo integer) RETURNS TABLE(refeicao_id integer, nome text, tipo text, horario time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
    SELECT
      rf.id,
      rf.nome::TEXT,
      rf.tipo::TEXT,
      rf.horario_sugerido
    FROM public.refeicoes rf
   WHERE NOT EXISTS (
      SELECT 1
        FROM public.refeicao_alimentos ra
        JOIN public.alimentos a ON a.id = ra.alimento_id
       WHERE ra.refeicao_id = rf.id
         AND (
           (a.lactose = TRUE AND EXISTS (
              SELECT 1 FROM public.usuario_restricoes ur
              JOIN public.restricoes r ON r.id = ur.restricao_id
             WHERE ur.usuario_id = usuario_alvo
               AND r.nome ILIKE '%Lactose%'
           ))
        OR (a.gluten = TRUE AND EXISTS (
              SELECT 1 FROM public.usuario_restricoes ur
              JOIN public.restricoes r ON r.id = ur.restricao_id
             WHERE ur.usuario_id = usuario_alvo
               AND r.nome ILIKE '%Glúten%'
           ))
         )
    )
   ORDER BY rf.horario_sugerido;
END;
$$;


--
-- Name: gerar_plano_automatico(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gerar_plano_automatico(usuario_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  plano_id INT;
  ordem    SMALLINT := 1;
  rec      RECORD;
BEGIN
  INSERT INTO planos_alimentares(usuario_id, objetivo, observacoes)
  VALUES (
    usuario_id,
    (SELECT objetivo FROM usuarios WHERE id = usuario_id),
    'Plano automático'
  )
  RETURNING id INTO plano_id;

  FOR rec IN
    SELECT refeicao_id
      FROM fn_refeicoes_por_objetivo_simples(usuario_id)
     ORDER BY horario_sugerido
  LOOP
    INSERT INTO planos_refeicoes(plano_id, refeicao_id, ordem_refeicao)
    VALUES (plano_id, rec.refeicao_id, ordem);
    ordem := ordem + 1;
  END LOOP;

  RETURN plano_id;
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
    calorias_kcal numeric(6,2),
    proteinas_g numeric(6,2),
    carboidratos_g numeric(6,2),
    gorduras_g numeric(6,2),
    sodio_mg numeric(6,2),
    lactose boolean,
    gluten boolean,
    vegano boolean,
    indice_glicemico smallint,
    grupo_alimentar_id integer,
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
-- Name: grupos_alimentares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grupos_alimentares (
    id integer NOT NULL,
    nome character varying(50) NOT NULL
);


--
-- Name: grupos_alimentares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grupos_alimentares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grupos_alimentares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grupos_alimentares_id_seq OWNED BY public.grupos_alimentares.id;


--
-- Name: metas_nutricionais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.metas_nutricionais (
    usuario_id integer NOT NULL,
    calorias_kcal numeric(6,2),
    proteinas_g numeric(6,2),
    carboidratos_g numeric(6,2),
    gorduras_g numeric(6,2)
);


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
    ativo boolean DEFAULT true,
    objetivo public.tipo_objetivo NOT NULL
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
-- Name: grupos_alimentares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grupos_alimentares ALTER COLUMN id SET DEFAULT nextval('public.grupos_alimentares_id_seq'::regclass);


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

INSERT INTO public.alimentos VALUES (181, 'Alface Crespa', 15.00, 1.40, 2.90, 0.20, 28.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (182, 'Tomate', 18.00, 0.90, 3.90, 0.20, 5.00, false, false, true, 30, 2);
INSERT INTO public.alimentos VALUES (183, 'Cenoura', 41.00, 0.90, 9.60, 0.20, 69.00, false, false, true, 47, 2);
INSERT INTO public.alimentos VALUES (184, 'Brócolis', 34.00, 2.80, 6.60, 0.40, 33.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (185, 'Espinafre', 23.00, 2.90, 3.60, 0.40, 79.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (186, 'Pepino', 15.00, 0.70, 3.60, 0.10, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (187, 'Pimentão Vermelho', 31.00, 1.00, 6.00, 0.30, 3.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (188, 'Abobrinha', 17.00, 1.20, 3.10, 0.30, 8.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (189, 'Couve Flor', 25.00, 1.90, 5.00, 0.30, 30.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (190, 'Berinjela', 25.00, 1.00, 6.00, 0.20, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (191, 'Vagem', 31.00, 1.80, 7.00, 0.20, 6.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (192, 'Aspargos', 20.00, 2.20, 3.90, 0.20, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (193, 'Cogumelo Paris', 22.00, 3.10, 3.30, 0.30, 5.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (194, 'Batata Doce', 86.00, 1.60, 20.00, 0.10, 55.00, false, false, true, 44, 2);
INSERT INTO public.alimentos VALUES (195, 'Cebola', 40.00, 1.10, 9.30, 0.10, 4.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (196, 'Arroz Branco Cozido', 130.00, 2.70, 28.00, 0.30, 1.00, false, false, true, 73, 3);
INSERT INTO public.alimentos VALUES (197, 'Arroz Integral Cozido', 111.00, 2.60, 23.00, 0.90, 5.00, false, false, true, 50, 3);
INSERT INTO public.alimentos VALUES (198, 'Aveia em Flocos', 389.00, 16.90, 66.30, 6.90, 2.00, false, false, true, 55, 3);
INSERT INTO public.alimentos VALUES (199, 'Milho Cozido', 86.00, 3.30, 19.00, 1.20, 15.00, false, false, true, 60, 3);
INSERT INTO public.alimentos VALUES (200, 'Quinoa Cozida', 120.00, 4.40, 21.00, 1.90, 7.00, false, false, true, 53, 3);
INSERT INTO public.alimentos VALUES (201, 'Trigo Sarraceno', 343.00, 13.00, 71.50, 3.40, 1.00, false, false, true, 54, 3);
INSERT INTO public.alimentos VALUES (202, 'Cevada em Grão', 354.00, 12.50, 73.00, 2.30, 12.00, false, false, true, 60, 3);
INSERT INTO public.alimentos VALUES (203, 'Grão de Bico Cozido', 164.00, 8.90, 27.00, 2.60, 7.00, false, false, true, 28, 3);
INSERT INTO public.alimentos VALUES (204, 'Lentilha Cozida', 116.00, 9.00, 20.00, 0.40, 2.00, false, false, true, 32, 3);
INSERT INTO public.alimentos VALUES (205, 'Feijão Carioca Cozido', 132.00, 8.20, 24.00, 0.50, 5.00, false, false, true, 30, 3);
INSERT INTO public.alimentos VALUES (206, 'Cuscuz Marroquino', 112.00, 3.80, 23.00, 0.20, 2.00, false, true, true, 65, 3);
INSERT INTO public.alimentos VALUES (207, 'Amaranto', 371.00, 13.60, 65.20, 7.00, 4.00, false, false, true, 25, 3);
INSERT INTO public.alimentos VALUES (208, 'Painço', 378.00, 11.00, 72.80, 4.20, 2.00, false, false, true, 71, 3);
INSERT INTO public.alimentos VALUES (209, 'Triticale', 338.00, 13.00, 70.00, 2.00, 1.00, false, true, true, 45, 3);
INSERT INTO public.alimentos VALUES (210, 'Centá', 335.00, 10.30, 69.80, 1.60, 1.00, false, true, true, 48, 3);
INSERT INTO public.alimentos VALUES (211, 'Leite Integral', 61.00, 3.20, 4.80, 3.30, 43.00, true, false, false, 31, 4);
INSERT INTO public.alimentos VALUES (212, 'Iogurte Natural Integral', 61.00, 3.50, 4.70, 3.30, 46.00, true, false, false, 35, 4);
INSERT INTO public.alimentos VALUES (213, 'Queijo Minas Frescal', 260.00, 17.00, 2.00, 20.00, 300.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (214, 'Queijo Muçarela', 300.00, 22.00, 2.20, 22.00, 600.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (215, 'Requeijão Cremoso Light', 200.00, 10.00, 5.00, 15.00, 450.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (216, 'Ricota Fresca', 174.00, 11.00, 3.00, 13.00, 200.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (217, 'Leite Desnatado', 34.00, 3.40, 5.00, 0.10, 50.00, true, false, false, 32, 4);
INSERT INTO public.alimentos VALUES (218, 'Iogurte Grego Light', 90.00, 18.00, 8.00, 0.00, 60.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (219, 'Coalhada Seca', 250.00, 18.00, 4.00, 18.00, 400.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (220, 'Manteiga', 717.00, 0.80, 0.10, 81.00, 11.00, true, false, false, 0, 4);
INSERT INTO public.alimentos VALUES (221, 'Peito de Frango Grelhado', 165.00, 31.00, 0.00, 3.60, 74.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (222, 'Bife de Alcatra Grelhado', 250.00, 26.00, 0.00, 15.00, 60.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (223, 'Ovo Cozido', 155.00, 13.00, 1.10, 11.00, 124.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (224, 'Salmão Assado', 208.00, 20.00, 0.00, 13.00, 59.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (225, 'Filé de Tilápia Grelhado', 128.00, 26.00, 0.00, 2.70, 56.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (226, 'Carne Moída Patinho', 170.00, 21.00, 0.00, 9.00, 60.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (227, 'Linguiça de Frango', 250.00, 15.00, 2.00, 20.00, 800.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (228, 'Hambúrguer de Carne', 290.00, 20.00, 0.00, 23.00, 350.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (229, 'Presunto Magro', 145.00, 18.00, 1.00, 7.00, 1000.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (230, 'Atum em Lata (água)', 116.00, 25.00, 0.00, 1.00, 300.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (231, 'Amendoim Torrado', 567.00, 25.80, 16.10, 49.20, 18.00, false, false, true, 14, 6);
INSERT INTO public.alimentos VALUES (232, 'Castanha de Caju', 553.00, 18.20, 30.20, 43.80, 12.00, false, false, true, 25, 6);
INSERT INTO public.alimentos VALUES (233, 'Amêndoa', 575.00, 21.20, 21.70, 49.90, 1.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (234, 'Nozes', 654.00, 15.20, 13.70, 65.20, 2.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (235, 'Grão de Bico Seco', 364.00, 20.50, 61.00, 6.00, 24.00, false, false, true, 28, 6);
INSERT INTO public.alimentos VALUES (236, 'Feijão Preto Seco', 341.00, 21.60, 62.40, 1.40, 5.00, false, false, true, 30, 6);
INSERT INTO public.alimentos VALUES (237, 'Lentilha Seca', 352.00, 24.60, 63.40, 1.10, 2.00, false, false, true, 32, 6);
INSERT INTO public.alimentos VALUES (238, 'Castanha do Pará', 659.00, 14.30, 12.30, 67.00, 3.00, false, false, true, 10, 6);
INSERT INTO public.alimentos VALUES (239, 'Pistache', 562.00, 20.20, 27.50, 45.30, 1.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (240, 'Semente de Abóbora', 446.00, 24.50, 17.50, 19.40, 18.00, false, false, true, 25, 6);
INSERT INTO public.alimentos VALUES (241, 'Semente de Girassol', 584.00, 20.70, 20.00, 51.50, 9.00, false, false, true, 35, 6);
INSERT INTO public.alimentos VALUES (242, 'Semente de Linhaça', 534.00, 18.30, 28.90, 42.20, 30.00, false, false, true, 35, 6);
INSERT INTO public.alimentos VALUES (243, 'Tofu Firme', 76.00, 8.00, 1.90, 4.80, 7.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (244, 'Ervilha Seca', 340.00, 23.00, 60.00, 1.00, 10.00, false, false, true, 22, 6);
INSERT INTO public.alimentos VALUES (245, 'Edamame Cozido', 122.00, 11.90, 9.90, 5.20, 5.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (246, 'Azeite de Oliva Extra Virgem', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (247, 'Óleo de Coco', 862.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (248, 'Abacate', 160.00, 2.00, 8.50, 14.70, 7.00, false, false, true, 15, 7);
INSERT INTO public.alimentos VALUES (249, 'Óleo de Girassol', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (250, 'Margarina Vegetal', 717.00, 0.00, 0.00, 80.00, 800.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (251, 'Açúcar Refinado', 387.00, 0.00, 100.00, 0.00, 1.00, false, false, true, 65, 8);
INSERT INTO public.alimentos VALUES (252, 'Chocolate ao Leite', 535.00, 8.00, 59.00, 30.00, 60.00, true, true, false, 49, 8);
INSERT INTO public.alimentos VALUES (253, 'Mel', 304.00, 0.30, 82.00, 0.00, 4.00, false, false, true, 61, 8);
INSERT INTO public.alimentos VALUES (254, 'Sorvete de Creme', 207.00, 3.50, 24.00, 11.00, 80.00, true, false, false, 60, 8);
INSERT INTO public.alimentos VALUES (255, 'Bala de Goma', 333.00, 0.00, 83.00, 0.00, 10.00, false, false, true, 70, 8);
INSERT INTO public.alimentos VALUES (256, 'Geleia de Morango', 240.00, 0.50, 60.00, 0.00, 10.00, false, false, true, 50, 8);
INSERT INTO public.alimentos VALUES (257, 'Doce de Leite', 315.00, 6.00, 55.00, 7.00, 100.00, true, false, false, 65, 8);
INSERT INTO public.alimentos VALUES (258, 'Pão Francês', 265.00, 8.00, 50.00, 3.00, 500.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (259, 'Pão Integral', 247.00, 13.00, 41.00, 3.50, 400.00, false, true, true, 55, 9);
INSERT INTO public.alimentos VALUES (260, 'Macarrão Cozido', 158.00, 5.80, 31.00, 0.90, 1.00, false, true, true, 49, 9);
INSERT INTO public.alimentos VALUES (261, 'Torrada Tradicional', 407.00, 11.00, 78.00, 5.00, 550.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (262, 'Biscoito Cream Cracker', 420.00, 9.00, 70.00, 10.00, 600.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (263, 'Lasanha (massa)', 130.00, 5.00, 25.00, 1.00, 5.00, false, true, true, 50, 9);
INSERT INTO public.alimentos VALUES (264, 'Pão de Forma Branco', 260.00, 8.00, 49.00, 3.00, 450.00, false, true, true, 75, 9);
INSERT INTO public.alimentos VALUES (265, 'Pão Sírio', 266.00, 9.00, 52.00, 2.00, 400.00, false, true, true, 65, 9);
INSERT INTO public.alimentos VALUES (266, 'Pizza (massa)', 280.00, 10.00, 40.00, 8.00, 600.00, false, true, false, 60, 9);
INSERT INTO public.alimentos VALUES (267, 'Croissant', 400.00, 8.00, 45.00, 20.00, 300.00, true, true, false, 60, 9);
INSERT INTO public.alimentos VALUES (268, 'Sardinha em Lata (óleo)', 208.00, 24.60, 0.00, 12.00, 463.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (269, 'Camarão Cozido', 85.00, 20.00, 0.00, 0.50, 145.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (270, 'Atum Fresco Grelhado', 184.00, 29.00, 0.00, 6.00, 40.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (271, 'Bacalhau Cozido', 105.00, 23.00, 0.00, 1.00, 100.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (272, 'Ostras Cruas', 68.00, 7.00, 4.00, 2.00, 90.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (273, 'Lula Cozida', 92.00, 15.00, 3.00, 1.00, 35.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (274, 'Mexilhões Cozidos', 172.00, 24.00, 7.00, 4.50, 160.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (275, 'Truta Grelhada', 140.00, 22.00, 0.00, 5.00, 50.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (276, 'Polvo Cozido', 82.00, 14.90, 2.20, 1.00, 290.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (277, 'Robalo Assado', 110.00, 20.00, 0.00, 3.00, 50.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (278, 'Couve Refogada', 40.00, 2.50, 5.00, 2.00, 10.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (279, 'Batata Inglesa Cozida', 87.00, 1.90, 20.00, 0.10, 6.00, false, false, true, 78, 2);
INSERT INTO public.alimentos VALUES (280, 'Ervilha Fresca', 81.00, 5.00, 14.00, 0.40, 5.00, false, false, true, 35, 2);
INSERT INTO public.alimentos VALUES (281, 'Pão de Queijo', 330.00, 8.00, 35.00, 18.00, 400.00, true, false, false, 65, 9);
INSERT INTO public.alimentos VALUES (282, 'Bolo de Chocolate', 450.00, 5.00, 60.00, 20.00, 200.00, true, true, false, 70, 8);
INSERT INTO public.alimentos VALUES (283, 'Feijoada Completa', 250.00, 15.00, 20.00, 12.00, 800.00, false, false, false, 40, 5);
INSERT INTO public.alimentos VALUES (284, 'Suco de Laranja Natural', 45.00, 0.70, 10.00, 0.20, 0.00, false, false, true, 50, 1);
INSERT INTO public.alimentos VALUES (285, 'Água de Coco', 19.00, 0.70, 3.70, 0.20, 105.00, false, false, true, 30, 1);
INSERT INTO public.alimentos VALUES (286, 'Café sem Açúcar', 2.00, 0.10, 0.00, 0.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (287, 'Açúcar Mascavo', 380.00, 0.00, 99.00, 0.00, 5.00, false, false, true, 60, 8);
INSERT INTO public.alimentos VALUES (288, 'Farinha de Trigo', 364.00, 10.00, 76.00, 1.00, 2.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (289, 'Arroz Parboilizado', 120.00, 2.50, 25.00, 0.50, 1.00, false, false, true, 65, 3);
INSERT INTO public.alimentos VALUES (290, 'Leite de Amêndoas', 15.00, 0.50, 1.00, 1.00, 100.00, false, false, true, 25, 4);
INSERT INTO public.alimentos VALUES (291, 'Carne Seca Cozida', 250.00, 30.00, 0.00, 15.00, 1200.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (292, 'Castanha do Brasil', 659.00, 14.00, 12.00, 66.00, 3.00, false, false, true, 10, 6);
INSERT INTO public.alimentos VALUES (293, 'Azeite de Dendê', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (294, 'Refrigerante Cola', 42.00, 0.00, 10.60, 0.00, 10.00, false, false, true, 63, 8);
INSERT INTO public.alimentos VALUES (295, 'Pão de Centeio', 259.00, 9.00, 53.00, 2.00, 400.00, false, true, true, 50, 9);
INSERT INTO public.alimentos VALUES (296, 'Peixe Branco Cozido', 100.00, 20.00, 0.00, 2.00, 50.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (297, 'Azeitona Verde', 115.00, 0.80, 6.00, 11.00, 1500.00, false, false, true, 15, 7);
INSERT INTO public.alimentos VALUES (298, 'Milho Verde enlatado', 70.00, 2.50, 15.00, 1.00, 200.00, false, false, true, 60, 2);
INSERT INTO public.alimentos VALUES (299, 'Pão de Forma Integral', 250.00, 10.00, 45.00, 3.00, 400.00, false, true, true, 50, 9);
INSERT INTO public.alimentos VALUES (300, 'Batata Chips', 536.00, 6.00, 50.00, 35.00, 500.00, false, false, true, 80, 7);
INSERT INTO public.alimentos VALUES (301, 'Biscoito Recheado', 480.00, 5.00, 70.00, 20.00, 300.00, true, true, false, 75, 8);
INSERT INTO public.alimentos VALUES (302, 'Feijão Fradinho Cozido', 140.00, 9.00, 25.00, 0.50, 5.00, false, false, true, 35, 3);
INSERT INTO public.alimentos VALUES (303, 'Leite Condensado', 321.00, 7.00, 55.00, 8.00, 100.00, true, false, false, 70, 8);
INSERT INTO public.alimentos VALUES (304, 'Salsicha', 290.00, 11.00, 2.00, 26.00, 900.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (305, 'Tofu Defumado', 120.00, 13.00, 3.00, 7.00, 150.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (306, 'Óleo de Canola', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (307, 'Açúcar Demerara', 387.00, 0.00, 99.00, 0.00, 2.00, false, false, true, 60, 8);
INSERT INTO public.alimentos VALUES (308, 'Pão de Hot Dog', 280.00, 9.00, 50.00, 5.00, 500.00, true, true, false, 70, 9);
INSERT INTO public.alimentos VALUES (309, 'Lagosta Cozida', 89.00, 19.00, 0.00, 0.80, 238.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (310, 'Cenoura Crua', 41.00, 0.90, 9.60, 0.20, 69.00, false, false, true, 35, 2);
INSERT INTO public.alimentos VALUES (311, 'Brócolis Cozido', 35.00, 2.80, 7.00, 0.40, 30.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (312, 'Pimentão Amarelo', 27.00, 0.90, 6.30, 0.20, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (313, 'Leite Fermentado', 70.00, 2.50, 10.00, 2.00, 30.00, true, false, false, 40, 4);
INSERT INTO public.alimentos VALUES (314, 'Queijo Parmesão', 431.00, 38.00, 3.00, 29.00, 1600.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (315, 'Carne de Porco Cozida', 242.00, 27.00, 0.00, 14.00, 60.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (316, 'Amendoim com Casca', 567.00, 25.00, 16.00, 49.00, 18.00, false, false, true, 14, 6);
INSERT INTO public.alimentos VALUES (317, 'Óleo de Palma', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (318, 'Refrigerante Guaraná', 40.00, 0.00, 10.00, 0.00, 5.00, false, false, true, 60, 8);
INSERT INTO public.alimentos VALUES (319, 'Pão de Milho', 270.00, 7.00, 55.00, 3.00, 450.00, false, true, true, 65, 9);
INSERT INTO public.alimentos VALUES (320, 'Atum em Lata (óleo)', 200.00, 23.00, 0.00, 12.00, 350.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (321, 'Chuchu Cozido', 19.00, 0.80, 4.00, 0.10, 2.00, false, false, true, 20, 2);
INSERT INTO public.alimentos VALUES (322, 'Rabanete', 16.00, 0.70, 3.40, 0.10, 10.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (323, 'Pepino em Conserva', 11.00, 0.30, 2.50, 0.10, 1200.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (324, 'Kefir de Leite', 60.00, 3.50, 5.00, 3.00, 40.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (325, 'Sorvete de Fruta (água)', 100.00, 0.50, 25.00, 0.00, 10.00, false, false, true, 50, 8);
INSERT INTO public.alimentos VALUES (1, 'Alface Crespa', 15.00, 1.40, 2.90, 0.20, 28.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (2, 'Tomate', 18.00, 0.90, 3.90, 0.20, 5.00, false, false, true, 30, 2);
INSERT INTO public.alimentos VALUES (3, 'Cenoura', 41.00, 0.90, 9.60, 0.20, 69.00, false, false, true, 47, 2);
INSERT INTO public.alimentos VALUES (4, 'Brócolis', 34.00, 2.80, 6.60, 0.40, 33.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (5, 'Espinafre', 23.00, 2.90, 3.60, 0.40, 79.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (6, 'Pepino', 15.00, 0.70, 3.60, 0.10, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (7, 'Pimentão Vermelho', 31.00, 1.00, 6.00, 0.30, 3.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (8, 'Abobrinha', 17.00, 1.20, 3.10, 0.30, 8.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (9, 'Couve Flor', 25.00, 1.90, 5.00, 0.30, 30.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (10, 'Berinjela', 25.00, 1.00, 6.00, 0.20, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (11, 'Vagem', 31.00, 1.80, 7.00, 0.20, 6.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (12, 'Aspargos', 20.00, 2.20, 3.90, 0.20, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (13, 'Cogumelo Paris', 22.00, 3.10, 3.30, 0.30, 5.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (14, 'Batata Doce', 86.00, 1.60, 20.00, 0.10, 55.00, false, false, true, 44, 2);
INSERT INTO public.alimentos VALUES (15, 'Cebola', 40.00, 1.10, 9.30, 0.10, 4.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (16, 'Arroz Branco Cozido', 130.00, 2.70, 28.00, 0.30, 1.00, false, false, true, 73, 3);
INSERT INTO public.alimentos VALUES (17, 'Arroz Integral Cozido', 111.00, 2.60, 23.00, 0.90, 5.00, false, false, true, 50, 3);
INSERT INTO public.alimentos VALUES (18, 'Aveia em Flocos', 389.00, 16.90, 66.30, 6.90, 2.00, false, false, true, 55, 3);
INSERT INTO public.alimentos VALUES (19, 'Milho Cozido', 86.00, 3.30, 19.00, 1.20, 15.00, false, false, true, 60, 3);
INSERT INTO public.alimentos VALUES (20, 'Quinoa Cozida', 120.00, 4.40, 21.00, 1.90, 7.00, false, false, true, 53, 3);
INSERT INTO public.alimentos VALUES (21, 'Trigo Sarraceno', 343.00, 13.00, 71.50, 3.40, 1.00, false, false, true, 54, 3);
INSERT INTO public.alimentos VALUES (22, 'Cevada em Grão', 354.00, 12.50, 73.00, 2.30, 12.00, false, false, true, 60, 3);
INSERT INTO public.alimentos VALUES (23, 'Grão de Bico Cozido', 164.00, 8.90, 27.00, 2.60, 7.00, false, false, true, 28, 3);
INSERT INTO public.alimentos VALUES (24, 'Lentilha Cozida', 116.00, 9.00, 20.00, 0.40, 2.00, false, false, true, 32, 3);
INSERT INTO public.alimentos VALUES (25, 'Feijão Carioca Cozido', 132.00, 8.20, 24.00, 0.50, 5.00, false, false, true, 30, 3);
INSERT INTO public.alimentos VALUES (26, 'Cuscuz Marroquino', 112.00, 3.80, 23.00, 0.20, 2.00, false, true, true, 65, 3);
INSERT INTO public.alimentos VALUES (27, 'Amaranto', 371.00, 13.60, 65.20, 7.00, 4.00, false, false, true, 25, 3);
INSERT INTO public.alimentos VALUES (28, 'Painço', 378.00, 11.00, 72.80, 4.20, 2.00, false, false, true, 71, 3);
INSERT INTO public.alimentos VALUES (29, 'Triticale', 338.00, 13.00, 70.00, 2.00, 1.00, false, true, true, 45, 3);
INSERT INTO public.alimentos VALUES (30, 'Centá', 335.00, 10.30, 69.80, 1.60, 1.00, false, true, true, 48, 3);
INSERT INTO public.alimentos VALUES (31, 'Leite Integral', 61.00, 3.20, 4.80, 3.30, 43.00, true, false, false, 31, 4);
INSERT INTO public.alimentos VALUES (32, 'Iogurte Natural Integral', 61.00, 3.50, 4.70, 3.30, 46.00, true, false, false, 35, 4);
INSERT INTO public.alimentos VALUES (33, 'Queijo Minas Frescal', 260.00, 17.00, 2.00, 20.00, 300.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (34, 'Queijo Muçarela', 300.00, 22.00, 2.20, 22.00, 600.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (35, 'Requeijão Cremoso Light', 200.00, 10.00, 5.00, 15.00, 450.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (36, 'Ricota Fresca', 174.00, 11.00, 3.00, 13.00, 200.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (37, 'Leite Desnatado', 34.00, 3.40, 5.00, 0.10, 50.00, true, false, false, 32, 4);
INSERT INTO public.alimentos VALUES (38, 'Iogurte Grego Light', 90.00, 18.00, 8.00, 0.00, 60.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (39, 'Coalhada Seca', 250.00, 18.00, 4.00, 18.00, 400.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (40, 'Manteiga', 717.00, 0.80, 0.10, 81.00, 11.00, true, false, false, 0, 4);
INSERT INTO public.alimentos VALUES (41, 'Peito de Frango Grelhado', 165.00, 31.00, 0.00, 3.60, 74.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (42, 'Bife de Alcatra Grelhado', 250.00, 26.00, 0.00, 15.00, 60.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (43, 'Ovo Cozido', 155.00, 13.00, 1.10, 11.00, 124.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (44, 'Salmão Assado', 208.00, 20.00, 0.00, 13.00, 59.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (45, 'Filé de Tilápia Grelhado', 128.00, 26.00, 0.00, 2.70, 56.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (46, 'Carne Moída Patinho', 170.00, 21.00, 0.00, 9.00, 60.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (47, 'Linguiça de Frango', 250.00, 15.00, 2.00, 20.00, 800.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (48, 'Hambúrguer de Carne', 290.00, 20.00, 0.00, 23.00, 350.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (49, 'Presunto Magro', 145.00, 18.00, 1.00, 7.00, 1000.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (50, 'Atum em Lata (água)', 116.00, 25.00, 0.00, 1.00, 300.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (51, 'Amendoim Torrado', 567.00, 25.80, 16.10, 49.20, 18.00, false, false, true, 14, 6);
INSERT INTO public.alimentos VALUES (52, 'Castanha de Caju', 553.00, 18.20, 30.20, 43.80, 12.00, false, false, true, 25, 6);
INSERT INTO public.alimentos VALUES (53, 'Amêndoa', 575.00, 21.20, 21.70, 49.90, 1.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (54, 'Nozes', 654.00, 15.20, 13.70, 65.20, 2.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (55, 'Grão de Bico Seco', 364.00, 20.50, 61.00, 6.00, 24.00, false, false, true, 28, 6);
INSERT INTO public.alimentos VALUES (56, 'Feijão Preto Seco', 341.00, 21.60, 62.40, 1.40, 5.00, false, false, true, 30, 6);
INSERT INTO public.alimentos VALUES (57, 'Lentilha Seca', 352.00, 24.60, 63.40, 1.10, 2.00, false, false, true, 32, 6);
INSERT INTO public.alimentos VALUES (58, 'Castanha do Pará', 659.00, 14.30, 12.30, 67.00, 3.00, false, false, true, 10, 6);
INSERT INTO public.alimentos VALUES (59, 'Pistache', 562.00, 20.20, 27.50, 45.30, 1.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (60, 'Semente de Abóbora', 446.00, 24.50, 17.50, 19.40, 18.00, false, false, true, 25, 6);
INSERT INTO public.alimentos VALUES (61, 'Semente de Girassol', 584.00, 20.70, 20.00, 51.50, 9.00, false, false, true, 35, 6);
INSERT INTO public.alimentos VALUES (62, 'Semente de Linhaça', 534.00, 18.30, 28.90, 42.20, 30.00, false, false, true, 35, 6);
INSERT INTO public.alimentos VALUES (63, 'Tofu Firme', 76.00, 8.00, 1.90, 4.80, 7.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (64, 'Ervilha Seca', 340.00, 23.00, 60.00, 1.00, 10.00, false, false, true, 22, 6);
INSERT INTO public.alimentos VALUES (65, 'Edamame Cozido', 122.00, 11.90, 9.90, 5.20, 5.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (66, 'Azeite de Oliva Extra Virgem', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (67, 'Óleo de Coco', 862.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (68, 'Abacate', 160.00, 2.00, 8.50, 14.70, 7.00, false, false, true, 15, 7);
INSERT INTO public.alimentos VALUES (69, 'Óleo de Girassol', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (70, 'Margarina Vegetal', 717.00, 0.00, 0.00, 80.00, 800.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (71, 'Açúcar Refinado', 387.00, 0.00, 100.00, 0.00, 1.00, false, false, true, 65, 8);
INSERT INTO public.alimentos VALUES (72, 'Chocolate ao Leite', 535.00, 8.00, 59.00, 30.00, 60.00, true, true, false, 49, 8);
INSERT INTO public.alimentos VALUES (73, 'Mel', 304.00, 0.30, 82.00, 0.00, 4.00, false, false, true, 61, 8);
INSERT INTO public.alimentos VALUES (74, 'Sorvete de Creme', 207.00, 3.50, 24.00, 11.00, 80.00, true, false, false, 60, 8);
INSERT INTO public.alimentos VALUES (75, 'Bala de Goma', 333.00, 0.00, 83.00, 0.00, 10.00, false, false, true, 70, 8);
INSERT INTO public.alimentos VALUES (76, 'Geleia de Morango', 240.00, 0.50, 60.00, 0.00, 10.00, false, false, true, 50, 8);
INSERT INTO public.alimentos VALUES (77, 'Doce de Leite', 315.00, 6.00, 55.00, 7.00, 100.00, true, false, false, 65, 8);
INSERT INTO public.alimentos VALUES (78, 'Pão Francês', 265.00, 8.00, 50.00, 3.00, 500.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (79, 'Pão Integral', 247.00, 13.00, 41.00, 3.50, 400.00, false, true, true, 55, 9);
INSERT INTO public.alimentos VALUES (80, 'Macarrão Cozido', 158.00, 5.80, 31.00, 0.90, 1.00, false, true, true, 49, 9);
INSERT INTO public.alimentos VALUES (81, 'Torrada Tradicional', 407.00, 11.00, 78.00, 5.00, 550.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (82, 'Biscoito Cream Cracker', 420.00, 9.00, 70.00, 10.00, 600.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (83, 'Lasanha (massa)', 130.00, 5.00, 25.00, 1.00, 5.00, false, true, true, 50, 9);
INSERT INTO public.alimentos VALUES (84, 'Pão de Forma Branco', 260.00, 8.00, 49.00, 3.00, 450.00, false, true, true, 75, 9);
INSERT INTO public.alimentos VALUES (85, 'Pão Sírio', 266.00, 9.00, 52.00, 2.00, 400.00, false, true, true, 65, 9);
INSERT INTO public.alimentos VALUES (86, 'Pizza (massa)', 280.00, 10.00, 40.00, 8.00, 600.00, false, true, false, 60, 9);
INSERT INTO public.alimentos VALUES (87, 'Croissant', 400.00, 8.00, 45.00, 20.00, 300.00, true, true, false, 60, 9);
INSERT INTO public.alimentos VALUES (88, 'Sardinha em Lata (óleo)', 208.00, 24.60, 0.00, 12.00, 463.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (89, 'Camarão Cozido', 85.00, 20.00, 0.00, 0.50, 145.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (90, 'Atum Fresco Grelhado', 184.00, 29.00, 0.00, 6.00, 40.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (91, 'Bacalhau Cozido', 105.00, 23.00, 0.00, 1.00, 100.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (92, 'Ostras Cruas', 68.00, 7.00, 4.00, 2.00, 90.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (93, 'Lula Cozida', 92.00, 15.00, 3.00, 1.00, 35.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (94, 'Mexilhões Cozidos', 172.00, 24.00, 7.00, 4.50, 160.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (95, 'Truta Grelhada', 140.00, 22.00, 0.00, 5.00, 50.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (96, 'Polvo Cozido', 82.00, 14.90, 2.20, 1.00, 290.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (97, 'Robalo Assado', 110.00, 20.00, 0.00, 3.00, 50.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (98, 'Couve Refogada', 40.00, 2.50, 5.00, 2.00, 10.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (99, 'Batata Inglesa Cozida', 87.00, 1.90, 20.00, 0.10, 6.00, false, false, true, 78, 2);
INSERT INTO public.alimentos VALUES (100, 'Ervilha Fresca', 81.00, 5.00, 14.00, 0.40, 5.00, false, false, true, 35, 2);
INSERT INTO public.alimentos VALUES (101, 'Pão de Queijo', 330.00, 8.00, 35.00, 18.00, 400.00, true, false, false, 65, 9);
INSERT INTO public.alimentos VALUES (102, 'Bolo de Chocolate', 450.00, 5.00, 60.00, 20.00, 200.00, true, true, false, 70, 8);
INSERT INTO public.alimentos VALUES (103, 'Feijoada Completa', 250.00, 15.00, 20.00, 12.00, 800.00, false, false, false, 40, 5);
INSERT INTO public.alimentos VALUES (104, 'Suco de Laranja Natural', 45.00, 0.70, 10.00, 0.20, 0.00, false, false, true, 50, 1);
INSERT INTO public.alimentos VALUES (105, 'Água de Coco', 19.00, 0.70, 3.70, 0.20, 105.00, false, false, true, 30, 1);
INSERT INTO public.alimentos VALUES (106, 'Café sem Açúcar', 2.00, 0.10, 0.00, 0.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (107, 'Açúcar Mascavo', 380.00, 0.00, 99.00, 0.00, 5.00, false, false, true, 60, 8);
INSERT INTO public.alimentos VALUES (108, 'Farinha de Trigo', 364.00, 10.00, 76.00, 1.00, 2.00, false, true, true, 70, 9);
INSERT INTO public.alimentos VALUES (109, 'Arroz Parboilizado', 120.00, 2.50, 25.00, 0.50, 1.00, false, false, true, 65, 3);
INSERT INTO public.alimentos VALUES (110, 'Leite de Amêndoas', 15.00, 0.50, 1.00, 1.00, 100.00, false, false, true, 25, 4);
INSERT INTO public.alimentos VALUES (111, 'Carne Seca Cozida', 250.00, 30.00, 0.00, 15.00, 1200.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (112, 'Castanha do Brasil', 659.00, 14.00, 12.00, 66.00, 3.00, false, false, true, 10, 6);
INSERT INTO public.alimentos VALUES (113, 'Azeite de Dendê', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (114, 'Refrigerante Cola', 42.00, 0.00, 10.60, 0.00, 10.00, false, false, true, 63, 8);
INSERT INTO public.alimentos VALUES (115, 'Pão de Centeio', 259.00, 9.00, 53.00, 2.00, 400.00, false, true, true, 50, 9);
INSERT INTO public.alimentos VALUES (116, 'Peixe Branco Cozido', 100.00, 20.00, 0.00, 2.00, 50.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (117, 'Azeitona Verde', 115.00, 0.80, 6.00, 11.00, 1500.00, false, false, true, 15, 7);
INSERT INTO public.alimentos VALUES (118, 'Milho Verde enlatado', 70.00, 2.50, 15.00, 1.00, 200.00, false, false, true, 60, 2);
INSERT INTO public.alimentos VALUES (119, 'Pão de Forma Integral', 250.00, 10.00, 45.00, 3.00, 400.00, false, true, true, 50, 9);
INSERT INTO public.alimentos VALUES (120, 'Batata Chips', 536.00, 6.00, 50.00, 35.00, 500.00, false, false, true, 80, 7);
INSERT INTO public.alimentos VALUES (121, 'Biscoito Recheado', 480.00, 5.00, 70.00, 20.00, 300.00, true, true, false, 75, 8);
INSERT INTO public.alimentos VALUES (122, 'Feijão Fradinho Cozido', 140.00, 9.00, 25.00, 0.50, 5.00, false, false, true, 35, 3);
INSERT INTO public.alimentos VALUES (123, 'Leite Condensado', 321.00, 7.00, 55.00, 8.00, 100.00, true, false, false, 70, 8);
INSERT INTO public.alimentos VALUES (124, 'Salsicha', 290.00, 11.00, 2.00, 26.00, 900.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (125, 'Tofu Defumado', 120.00, 13.00, 3.00, 7.00, 150.00, false, false, true, 15, 6);
INSERT INTO public.alimentos VALUES (126, 'Óleo de Canola', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (127, 'Açúcar Demerara', 387.00, 0.00, 99.00, 0.00, 2.00, false, false, true, 60, 8);
INSERT INTO public.alimentos VALUES (128, 'Pão de Hot Dog', 280.00, 9.00, 50.00, 5.00, 500.00, true, true, false, 70, 9);
INSERT INTO public.alimentos VALUES (129, 'Lagosta Cozida', 89.00, 19.00, 0.00, 0.80, 238.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (130, 'Cenoura Crua', 41.00, 0.90, 9.60, 0.20, 69.00, false, false, true, 35, 2);
INSERT INTO public.alimentos VALUES (131, 'Brócolis Cozido', 35.00, 2.80, 7.00, 0.40, 30.00, false, false, true, 10, 2);
INSERT INTO public.alimentos VALUES (132, 'Pimentão Amarelo', 27.00, 0.90, 6.30, 0.20, 2.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (133, 'Leite Fermentado', 70.00, 2.50, 10.00, 2.00, 30.00, true, false, false, 40, 4);
INSERT INTO public.alimentos VALUES (134, 'Queijo Parmesão', 431.00, 38.00, 3.00, 29.00, 1600.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (135, 'Carne de Porco Cozida', 242.00, 27.00, 0.00, 14.00, 60.00, false, false, false, 0, 5);
INSERT INTO public.alimentos VALUES (136, 'Amendoim com Casca', 567.00, 25.00, 16.00, 49.00, 18.00, false, false, true, 14, 6);
INSERT INTO public.alimentos VALUES (137, 'Óleo de Palma', 884.00, 0.00, 0.00, 100.00, 0.00, false, false, true, 0, 7);
INSERT INTO public.alimentos VALUES (138, 'Refrigerante Guaraná', 40.00, 0.00, 10.00, 0.00, 5.00, false, false, true, 60, 8);
INSERT INTO public.alimentos VALUES (139, 'Pão de Milho', 270.00, 7.00, 55.00, 3.00, 450.00, false, true, true, 65, 9);
INSERT INTO public.alimentos VALUES (140, 'Atum em Lata (óleo)', 200.00, 23.00, 0.00, 12.00, 350.00, false, false, false, 0, 10);
INSERT INTO public.alimentos VALUES (141, 'Chuchu Cozido', 19.00, 0.80, 4.00, 0.10, 2.00, false, false, true, 20, 2);
INSERT INTO public.alimentos VALUES (142, 'Rabanete', 16.00, 0.70, 3.40, 0.10, 10.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (143, 'Pepino em Conserva', 11.00, 0.30, 2.50, 0.10, 1200.00, false, false, true, 15, 2);
INSERT INTO public.alimentos VALUES (144, 'Kefir de Leite', 60.00, 3.50, 5.00, 3.00, 40.00, true, false, false, 30, 4);
INSERT INTO public.alimentos VALUES (145, 'Sorvete de Fruta (água)', 100.00, 0.50, 25.00, 0.00, 10.00, false, false, true, 50, 8);


--
-- Data for Name: avaliacoes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: grupos_alimentares; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.grupos_alimentares VALUES (1, 'Frutas');
INSERT INTO public.grupos_alimentares VALUES (2, 'Vegetais');
INSERT INTO public.grupos_alimentares VALUES (3, 'Grãos');
INSERT INTO public.grupos_alimentares VALUES (4, 'Laticínios');
INSERT INTO public.grupos_alimentares VALUES (5, 'Carnes e Ovos');
INSERT INTO public.grupos_alimentares VALUES (6, 'Leguminosas e Oleaginosas');
INSERT INTO public.grupos_alimentares VALUES (7, 'Gorduras e Óleos');
INSERT INTO public.grupos_alimentares VALUES (8, 'Açúcares e Doces');
INSERT INTO public.grupos_alimentares VALUES (9, 'Pães e Massas');
INSERT INTO public.grupos_alimentares VALUES (10, 'Peixes e Frutos do Mar');


--
-- Data for Name: metas_nutricionais; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.metas_nutricionais VALUES (1, 1600.00, 100.00, 180.00, 40.00);
INSERT INTO public.metas_nutricionais VALUES (2, 2000.00, 80.00, 210.00, 60.00);
INSERT INTO public.metas_nutricionais VALUES (3, 2800.00, 130.00, 300.00, 80.00);
INSERT INTO public.metas_nutricionais VALUES (4, 1500.00, 90.00, 170.00, 40.00);
INSERT INTO public.metas_nutricionais VALUES (5, 1600.00, 100.00, 180.00, 45.00);
INSERT INTO public.metas_nutricionais VALUES (6, 2700.00, 120.00, 280.00, 75.00);
INSERT INTO public.metas_nutricionais VALUES (7, 2000.00, 80.00, 210.00, 60.00);
INSERT INTO public.metas_nutricionais VALUES (8, 2000.00, 75.00, 200.00, 60.00);
INSERT INTO public.metas_nutricionais VALUES (9, 2600.00, 120.00, 290.00, 75.00);
INSERT INTO public.metas_nutricionais VALUES (10, 1500.00, 85.00, 165.00, 45.00);


--
-- Data for Name: planos_alimentares; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.planos_alimentares VALUES (3, 3, '2025-06-23', 'Ganhar massa', 'Plano automático');
INSERT INTO public.planos_alimentares VALUES (4, 2, '2025-06-23', 'Dieta Saudavel', 'Plano automático');


--
-- Data for Name: planos_refeicoes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.planos_refeicoes VALUES (3, 21, 1);
INSERT INTO public.planos_refeicoes VALUES (3, 11, 2);
INSERT INTO public.planos_refeicoes VALUES (3, 1, 3);
INSERT INTO public.planos_refeicoes VALUES (3, 46, 4);
INSERT INTO public.planos_refeicoes VALUES (3, 26, 5);
INSERT INTO public.planos_refeicoes VALUES (3, 6, 6);
INSERT INTO public.planos_refeicoes VALUES (3, 41, 7);
INSERT INTO public.planos_refeicoes VALUES (3, 16, 8);
INSERT INTO public.planos_refeicoes VALUES (3, 51, 9);
INSERT INTO public.planos_refeicoes VALUES (3, 31, 10);
INSERT INTO public.planos_refeicoes VALUES (3, 36, 11);
INSERT INTO public.planos_refeicoes VALUES (3, 14, 12);
INSERT INTO public.planos_refeicoes VALUES (3, 9, 13);
INSERT INTO public.planos_refeicoes VALUES (3, 29, 14);
INSERT INTO public.planos_refeicoes VALUES (3, 44, 15);
INSERT INTO public.planos_refeicoes VALUES (3, 12, 16);
INSERT INTO public.planos_refeicoes VALUES (3, 42, 17);
INSERT INTO public.planos_refeicoes VALUES (3, 47, 18);
INSERT INTO public.planos_refeicoes VALUES (3, 2, 19);
INSERT INTO public.planos_refeicoes VALUES (3, 27, 20);
INSERT INTO public.planos_refeicoes VALUES (3, 7, 21);
INSERT INTO public.planos_refeicoes VALUES (3, 32, 22);
INSERT INTO public.planos_refeicoes VALUES (3, 17, 23);
INSERT INTO public.planos_refeicoes VALUES (3, 52, 24);
INSERT INTO public.planos_refeicoes VALUES (3, 22, 25);
INSERT INTO public.planos_refeicoes VALUES (3, 37, 26);
INSERT INTO public.planos_refeicoes VALUES (3, 19, 27);
INSERT INTO public.planos_refeicoes VALUES (3, 34, 28);
INSERT INTO public.planos_refeicoes VALUES (3, 49, 29);
INSERT INTO public.planos_refeicoes VALUES (3, 4, 30);
INSERT INTO public.planos_refeicoes VALUES (3, 54, 31);
INSERT INTO public.planos_refeicoes VALUES (3, 39, 32);
INSERT INTO public.planos_refeicoes VALUES (3, 24, 33);
INSERT INTO public.planos_refeicoes VALUES (3, 23, 34);
INSERT INTO public.planos_refeicoes VALUES (3, 13, 35);
INSERT INTO public.planos_refeicoes VALUES (3, 43, 36);
INSERT INTO public.planos_refeicoes VALUES (3, 3, 37);
INSERT INTO public.planos_refeicoes VALUES (3, 48, 38);
INSERT INTO public.planos_refeicoes VALUES (3, 28, 39);
INSERT INTO public.planos_refeicoes VALUES (3, 18, 40);
INSERT INTO public.planos_refeicoes VALUES (3, 53, 41);
INSERT INTO public.planos_refeicoes VALUES (3, 8, 42);
INSERT INTO public.planos_refeicoes VALUES (3, 33, 43);
INSERT INTO public.planos_refeicoes VALUES (3, 25, 44);
INSERT INTO public.planos_refeicoes VALUES (3, 38, 45);
INSERT INTO public.planos_refeicoes VALUES (3, 15, 46);
INSERT INTO public.planos_refeicoes VALUES (3, 45, 47);
INSERT INTO public.planos_refeicoes VALUES (3, 50, 48);
INSERT INTO public.planos_refeicoes VALUES (3, 5, 49);
INSERT INTO public.planos_refeicoes VALUES (3, 30, 50);
INSERT INTO public.planos_refeicoes VALUES (3, 10, 51);
INSERT INTO public.planos_refeicoes VALUES (3, 35, 52);
INSERT INTO public.planos_refeicoes VALUES (3, 20, 53);
INSERT INTO public.planos_refeicoes VALUES (3, 55, 54);
INSERT INTO public.planos_refeicoes VALUES (3, 40, 55);
INSERT INTO public.planos_refeicoes VALUES (4, 11, 1);
INSERT INTO public.planos_refeicoes VALUES (4, 46, 2);
INSERT INTO public.planos_refeicoes VALUES (4, 26, 3);
INSERT INTO public.planos_refeicoes VALUES (4, 16, 4);
INSERT INTO public.planos_refeicoes VALUES (4, 14, 5);
INSERT INTO public.planos_refeicoes VALUES (4, 9, 6);
INSERT INTO public.planos_refeicoes VALUES (4, 29, 7);
INSERT INTO public.planos_refeicoes VALUES (4, 42, 8);
INSERT INTO public.planos_refeicoes VALUES (4, 37, 9);
INSERT INTO public.planos_refeicoes VALUES (4, 19, 10);
INSERT INTO public.planos_refeicoes VALUES (4, 34, 11);
INSERT INTO public.planos_refeicoes VALUES (4, 49, 12);
INSERT INTO public.planos_refeicoes VALUES (4, 4, 13);
INSERT INTO public.planos_refeicoes VALUES (4, 54, 14);
INSERT INTO public.planos_refeicoes VALUES (4, 39, 15);
INSERT INTO public.planos_refeicoes VALUES (4, 24, 16);
INSERT INTO public.planos_refeicoes VALUES (4, 13, 17);
INSERT INTO public.planos_refeicoes VALUES (4, 43, 18);
INSERT INTO public.planos_refeicoes VALUES (4, 48, 19);
INSERT INTO public.planos_refeicoes VALUES (4, 3, 20);
INSERT INTO public.planos_refeicoes VALUES (4, 28, 21);
INSERT INTO public.planos_refeicoes VALUES (4, 25, 22);
INSERT INTO public.planos_refeicoes VALUES (4, 38, 23);
INSERT INTO public.planos_refeicoes VALUES (4, 15, 24);
INSERT INTO public.planos_refeicoes VALUES (4, 45, 25);
INSERT INTO public.planos_refeicoes VALUES (4, 30, 26);
INSERT INTO public.planos_refeicoes VALUES (4, 10, 27);
INSERT INTO public.planos_refeicoes VALUES (4, 35, 28);
INSERT INTO public.planos_refeicoes VALUES (4, 20, 29);
INSERT INTO public.planos_refeicoes VALUES (4, 55, 30);
INSERT INTO public.planos_refeicoes VALUES (4, 40, 31);


--
-- Data for Name: refeicao_alimentos; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refeicao_alimentos VALUES (1, 86, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (1, 58, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (1, 109, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (2, 32, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (2, 56, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (2, 19, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (2, 76, 5.00);
INSERT INTO public.refeicao_alimentos VALUES (3, 59, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (3, 16, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (3, 17, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (4, 1, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (4, 2, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (5, 46, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (5, 80, 10.00);
INSERT INTO public.refeicao_alimentos VALUES (6, 33, 40.00);
INSERT INTO public.refeicao_alimentos VALUES (6, 2, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (6, 46, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (7, 57, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (7, 40, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (7, 31, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (7, 18, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (8, 60, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (8, 29, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (8, 26, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (9, 66, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (9, 67, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (10, 47, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (10, 6, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (11, 89, 40.00);
INSERT INTO public.refeicao_alimentos VALUES (11, 109, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (12, 35, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (12, 38, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (12, 21, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (13, 23, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (13, 18, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (14, 1, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (15, 90, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (16, 7, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (16, 112, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (17, 31, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (17, 40, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (17, 61, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (17, 16, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (17, 17, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (18, 58, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (18, 21, 40.00);
INSERT INTO public.refeicao_alimentos VALUES (18, 30, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (19, 47, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (19, 6, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (20, 9, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (20, 10, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (21, 2, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (21, 33, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (22, 56, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (22, 29, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (22, 19, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (23, 59, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (23, 26, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (24, 68, 25.00);
INSERT INTO public.refeicao_alimentos VALUES (24, 53, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (25, 51, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (25, 6, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (26, 3, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (26, 109, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (27, 31, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (27, 40, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (27, 57, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (27, 16, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (27, 17, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (28, 60, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (28, 76, 5.00);
INSERT INTO public.refeicao_alimentos VALUES (28, 17, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (29, 90, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (30, 46, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (31, 87, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (31, 58, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (31, 48, 40.00);
INSERT INTO public.refeicao_alimentos VALUES (31, 109, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (32, 59, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (32, 32, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (32, 26, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (33, 38, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (33, 35, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (33, 22, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (33, 24, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (34, 105, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (35, 90, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (35, 46, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (36, 107, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (36, 58, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (36, 80, 20.00);
INSERT INTO public.refeicao_alimentos VALUES (37, 106, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (38, 88, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (38, 76, 10.00);
INSERT INTO public.refeicao_alimentos VALUES (38, 17, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (39, 47, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (39, 4, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (40, 8, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (40, 14, 5.00);
INSERT INTO public.refeicao_alimentos VALUES (41, 58, 120.00);
INSERT INTO public.refeicao_alimentos VALUES (41, 87, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (42, 91, 200.00);
INSERT INTO public.refeicao_alimentos VALUES (42, 61, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (43, 16, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (43, 17, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (43, 20, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (43, 18, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (43, 76, 5.00);
INSERT INTO public.refeicao_alimentos VALUES (44, 92, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (44, 82, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (45, 1, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (46, 6, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (46, 11, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (46, 47, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (47, 56, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (47, 31, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (47, 19, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (48, 22, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (48, 24, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (48, 18, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (48, 76, 5.00);
INSERT INTO public.refeicao_alimentos VALUES (49, 1, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (49, 53, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (50, 35, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (50, 39, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (51, 87, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (51, 58, 60.00);
INSERT INTO public.refeicao_alimentos VALUES (51, 46, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (51, 1, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (52, 60, 150.00);
INSERT INTO public.refeicao_alimentos VALUES (52, 31, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (52, 25, 70.00);
INSERT INTO public.refeicao_alimentos VALUES (53, 87, 80.00);
INSERT INTO public.refeicao_alimentos VALUES (53, 48, 50.00);
INSERT INTO public.refeicao_alimentos VALUES (53, 17, 30.00);
INSERT INTO public.refeicao_alimentos VALUES (53, 16, 20.00);
INSERT INTO public.refeicao_alimentos VALUES (54, 68, 20.00);
INSERT INTO public.refeicao_alimentos VALUES (54, 4, 100.00);
INSERT INTO public.refeicao_alimentos VALUES (55, 51, 80.00);


--
-- Data for Name: refeicoes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.refeicoes VALUES (1, 'Café da Manhã Clássico', 'Café da manhã', '07:00:00');
INSERT INTO public.refeicoes VALUES (2, 'Almoço Saudável', 'Almoço', '12:30:00');
INSERT INTO public.refeicoes VALUES (3, 'Jantar Leve', 'Jantar', '19:00:00');
INSERT INTO public.refeicoes VALUES (4, 'Lanche da Tarde de Frutas', 'Lanche', '16:00:00');
INSERT INTO public.refeicoes VALUES (5, 'Ceia Relaxante', 'Ceia', '21:30:00');
INSERT INTO public.refeicoes VALUES (6, 'Café da Manhã Energético', 'Café da manhã', '07:30:00');
INSERT INTO public.refeicoes VALUES (7, 'Almoço Proteico', 'Almoço', '13:00:00');
INSERT INTO public.refeicoes VALUES (8, 'Jantar de Peixe', 'Jantar', '20:00:00');
INSERT INTO public.refeicoes VALUES (9, 'Lanche de Oleaginosas', 'Lanche', '10:00:00');
INSERT INTO public.refeicoes VALUES (10, 'Ceia com Iogurte', 'Ceia', '22:00:00');
INSERT INTO public.refeicoes VALUES (11, 'Café Rápido', 'Café da manhã', '06:45:00');
INSERT INTO public.refeicoes VALUES (12, 'Almoço Vegetariano', 'Almoço', '12:00:00');
INSERT INTO public.refeicoes VALUES (13, 'Jantar de Sopas', 'Jantar', '18:30:00');
INSERT INTO public.refeicoes VALUES (14, 'Lanche da Manhã', 'Lanche', '09:30:00');
INSERT INTO public.refeicoes VALUES (15, 'Ceia de Chá', 'Ceia', '21:00:00');
INSERT INTO public.refeicoes VALUES (16, 'Café da Manhã Tropical', 'Café da manhã', '08:00:00');
INSERT INTO public.refeicoes VALUES (17, 'Almoço Completo', 'Almoço', '13:30:00');
INSERT INTO public.refeicoes VALUES (18, 'Jantar de Omelete', 'Jantar', '19:30:00');
INSERT INTO public.refeicoes VALUES (19, 'Lanche com Iogurte', 'Lanche', '15:00:00');
INSERT INTO public.refeicoes VALUES (20, 'Ceia de Frutas', 'Ceia', '22:30:00');
INSERT INTO public.refeicoes VALUES (21, 'Café Pré-Treino', 'Café da manhã', '06:30:00');
INSERT INTO public.refeicoes VALUES (22, 'Almoço Pós-Treino', 'Almoço', '14:00:00');
INSERT INTO public.refeicoes VALUES (23, 'Jantar Low Carb', 'Jantar', '18:00:00');
INSERT INTO public.refeicoes VALUES (24, 'Lanche Proteico', 'Lanche', '17:00:00');
INSERT INTO public.refeicoes VALUES (25, 'Ceia Nutritiva', 'Ceia', '20:30:00');
INSERT INTO public.refeicoes VALUES (26, 'Café Leve', 'Café da manhã', '07:15:00');
INSERT INTO public.refeicoes VALUES (27, 'Almoço Tradicional', 'Almoço', '12:45:00');
INSERT INTO public.refeicoes VALUES (28, 'Jantar Mediterrâneo', 'Jantar', '19:15:00');
INSERT INTO public.refeicoes VALUES (29, 'Lanche Rápido', 'Lanche', '10:30:00');
INSERT INTO public.refeicoes VALUES (30, 'Ceia Simples', 'Ceia', '21:45:00');
INSERT INTO public.refeicoes VALUES (31, 'Café Reforçado', 'Café da manhã', '08:30:00');
INSERT INTO public.refeicoes VALUES (32, 'Almoço Executivo', 'Almoço', '13:15:00');
INSERT INTO public.refeicoes VALUES (33, 'Jantar Vegano', 'Jantar', '20:15:00');
INSERT INTO public.refeicoes VALUES (34, 'Lanche com Bolo', 'Lanche', '15:30:00');
INSERT INTO public.refeicoes VALUES (35, 'Ceia com Biscoito', 'Ceia', '22:15:00');
INSERT INTO public.refeicoes VALUES (36, 'Café de Fim de Semana', 'Café da manhã', '09:00:00');
INSERT INTO public.refeicoes VALUES (37, 'Almoço de Domingo', 'Almoço', '14:30:00');
INSERT INTO public.refeicoes VALUES (38, 'Jantar de Massas', 'Jantar', '20:45:00');
INSERT INTO public.refeicoes VALUES (39, 'Lanche da Tarde', 'Lanche', '16:30:00');
INSERT INTO public.refeicoes VALUES (40, 'Ceia Leve de Verão', 'Ceia', '23:00:00');
INSERT INTO public.refeicoes VALUES (41, 'Café da Manhã Fitness', 'Café da manhã', '07:45:00');
INSERT INTO public.refeicoes VALUES (42, 'Almoço de Conveniência', 'Almoço', '12:15:00');
INSERT INTO public.refeicoes VALUES (43, 'Jantar de Salada', 'Jantar', '18:45:00');
INSERT INTO public.refeicoes VALUES (44, 'Lanche Escolar', 'Lanche', '11:00:00');
INSERT INTO public.refeicoes VALUES (45, 'Ceia Pós-Jantar', 'Ceia', '21:15:00');
INSERT INTO public.refeicoes VALUES (46, 'Café da Manhã com Frutas', 'Café da manhã', '07:00:00');
INSERT INTO public.refeicoes VALUES (47, 'Almoço com Frango', 'Almoço', '12:30:00');
INSERT INTO public.refeicoes VALUES (48, 'Jantar com Legumes', 'Jantar', '19:00:00');
INSERT INTO public.refeicoes VALUES (49, 'Lanche da Tarde Light', 'Lanche', '16:00:00');
INSERT INTO public.refeicoes VALUES (50, 'Ceia de Grãos', 'Ceia', '21:30:00');
INSERT INTO public.refeicoes VALUES (51, 'Café Completo', 'Café da manhã', '08:15:00');
INSERT INTO public.refeicoes VALUES (52, 'Almoço de Peixe', 'Almoço', '13:45:00');
INSERT INTO public.refeicoes VALUES (53, 'Jantar Rápido', 'Jantar', '19:45:00');
INSERT INTO public.refeicoes VALUES (54, 'Lanche da Tarde Nutritivo', 'Lanche', '16:15:00');
INSERT INTO public.refeicoes VALUES (55, 'Ceia Simples com Queijo', 'Ceia', '22:45:00');


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

INSERT INTO public.usuario_restricoes VALUES (1, 2);
INSERT INTO public.usuario_restricoes VALUES (2, 3);
INSERT INTO public.usuario_restricoes VALUES (2, 4);
INSERT INTO public.usuario_restricoes VALUES (4, 5);
INSERT INTO public.usuario_restricoes VALUES (5, 1);
INSERT INTO public.usuario_restricoes VALUES (6, 3);
INSERT INTO public.usuario_restricoes VALUES (7, 5);
INSERT INTO public.usuario_restricoes VALUES (8, 4);
INSERT INTO public.usuario_restricoes VALUES (10, 2);
INSERT INTO public.usuario_restricoes VALUES (10, 1);


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuarios VALUES (1, 'Carlos Mendes', 'carlos.mendes@email.com', '1995-03-15', 'Masculino', 88.50, 178, true, 'Perder peso');
INSERT INTO public.usuarios VALUES (2, 'Ana Julia Rios', 'ana.rios@email.com', '1988-07-22', 'Feminino', 62.00, 165, true, 'Dieta Saudavel');
INSERT INTO public.usuarios VALUES (3, 'Bruno Teixeira', 'bruno.t@email.com', '2001-01-30', 'Masculino', 75.00, 182, true, 'Ganhar massa');
INSERT INTO public.usuarios VALUES (4, 'Fernanda Costa', 'fernanda.costa@email.com', '1999-11-05', 'Feminino', 58.70, 160, true, 'Perder peso');
INSERT INTO public.usuarios VALUES (5, 'Lucas de Almeida', 'lucas.almeida@email.com', '1992-09-18', 'Masculino', 95.20, 185, true, 'Perder peso');
INSERT INTO public.usuarios VALUES (6, 'Beatriz Martins', 'beatriz.m@email.com', '2003-04-12', 'Feminino', 55.00, 170, true, 'Ganhar massa');
INSERT INTO public.usuarios VALUES (7, 'Gabriel Pereira', 'gabriel.p@email.com', '1985-02-28', 'Masculino', 82.00, 176, true, 'Dieta Saudavel');
INSERT INTO public.usuarios VALUES (8, 'Juliana Lima', 'juliana.lima@email.com', '1998-06-01', 'Feminino', 68.50, 168, true, 'Dieta Saudavel');
INSERT INTO public.usuarios VALUES (9, 'Rafael Souza', 'rafael.souza@email.com', '2000-12-25', 'Masculino', 69.80, 179, true, 'Ganhar massa');
INSERT INTO public.usuarios VALUES (10, 'Larissa Ferreira', 'larissa.f@email.com', '1993-10-08', 'Feminino', 74.00, 172, true, 'Perder peso');


--
-- Name: alimentos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alimentos_id_seq', 145, true);


--
-- Name: avaliacoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.avaliacoes_id_seq', 1, false);


--
-- Name: grupos_alimentares_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.grupos_alimentares_id_seq', 10, true);


--
-- Name: plano_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plano_id_seq', 4, true);


--
-- Name: refeicoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refeicoes_id_seq', 55, true);


--
-- Name: restricoes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.restricoes_id_seq', 1, false);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 10, true);


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
-- Name: grupos_alimentares grupos_alimentares_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grupos_alimentares
    ADD CONSTRAINT grupos_alimentares_nome_key UNIQUE (nome);


--
-- Name: grupos_alimentares grupos_alimentares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grupos_alimentares
    ADD CONSTRAINT grupos_alimentares_pkey PRIMARY KEY (id);


--
-- Name: metas_nutricionais metas_nutricionais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metas_nutricionais
    ADD CONSTRAINT metas_nutricionais_pkey PRIMARY KEY (usuario_id);


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
-- Name: alimentos grupo_alimentar_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alimentos
    ADD CONSTRAINT grupo_alimentar_id_fk FOREIGN KEY (grupo_alimentar_id) REFERENCES public.grupos_alimentares(id) NOT VALID;


--
-- Name: metas_nutricionais metas_nutricionais_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.metas_nutricionais
    ADD CONSTRAINT metas_nutricionais_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


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

