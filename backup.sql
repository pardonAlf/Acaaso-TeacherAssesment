--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alumnos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alumnos (
    id integer NOT NULL,
    dni character varying(20) NOT NULL,
    nombre character varying(100),
    apellido character varying(100),
    correo character varying(150),
    fcreacion timestamp without time zone,
    fmodificacion timestamp without time zone,
    usuario character varying(20),
    estado character(1),
    cempre integer
);


ALTER TABLE public.alumnos OWNER TO postgres;

--
-- Name: alumnos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alumnos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alumnos_id_seq OWNER TO postgres;

--
-- Name: alumnos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alumnos_id_seq OWNED BY public.alumnos.id;


--
-- Name: empresa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empresa (
    cempre integer NOT NULL,
    dempre character varying(100),
    fcreacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    licencia boolean DEFAULT true,
    estado boolean DEFAULT true
);


ALTER TABLE public.empresa OWNER TO postgres;

--
-- Name: empresa_cempre_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.empresa_cempre_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.empresa_cempre_seq OWNER TO postgres;

--
-- Name: empresa_cempre_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.empresa_cempre_seq OWNED BY public.empresa.cempre;


--
-- Name: intentos_quiz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.intentos_quiz (
    id integer NOT NULL,
    alumno_id integer NOT NULL,
    quiz_id integer NOT NULL,
    intento_numero integer NOT NULL,
    fecha_inicio timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fecha_fin timestamp without time zone,
    nota_final numeric(5,2)
);


ALTER TABLE public.intentos_quiz OWNER TO postgres;

--
-- Name: intentos_quiz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.intentos_quiz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.intentos_quiz_id_seq OWNER TO postgres;

--
-- Name: intentos_quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.intentos_quiz_id_seq OWNED BY public.intentos_quiz.id;


--
-- Name: mejoras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mejoras (
    id integer NOT NULL,
    descripcion text NOT NULL,
    usuario character varying(100),
    fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado character varying(20) DEFAULT 'nuevo'::character varying,
    version character varying(20),
    tipo character(1) DEFAULT 'M'::bpchar
);


ALTER TABLE public.mejoras OWNER TO postgres;

--
-- Name: mejoras_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mejoras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mejoras_id_seq OWNER TO postgres;

--
-- Name: mejoras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mejoras_id_seq OWNED BY public.mejoras.id;


--
-- Name: opciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opciones (
    id integer NOT NULL,
    pregunta_id integer,
    texto text,
    es_correcta boolean
);


ALTER TABLE public.opciones OWNER TO postgres;

--
-- Name: opciones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opciones_id_seq OWNER TO postgres;

--
-- Name: opciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opciones_id_seq OWNED BY public.opciones.id;


--
-- Name: planes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planes (
    id integer NOT NULL,
    tipo character varying(20),
    nombre character varying(50),
    precio numeric,
    admins integer,
    profesores integer,
    alumnos integer,
    quizzes integer,
    activo boolean DEFAULT true,
    orden integer DEFAULT 0
);


ALTER TABLE public.planes OWNER TO postgres;

--
-- Name: planes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.planes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.planes_id_seq OWNER TO postgres;

--
-- Name: planes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.planes_id_seq OWNED BY public.planes.id;


--
-- Name: preguntas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preguntas (
    id integer NOT NULL,
    quiz_id integer,
    texto text,
    tipo character varying(20),
    explicacion text,
    norden integer
);


ALTER TABLE public.preguntas OWNER TO postgres;

--
-- Name: preguntas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preguntas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.preguntas_id_seq OWNER TO postgres;

--
-- Name: preguntas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preguntas_id_seq OWNED BY public.preguntas.id;


--
-- Name: quiz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz (
    id integer NOT NULL,
    titulo character varying(100),
    codigo character varying(50),
    fcreacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    fmodificacion timestamp without time zone,
    usuario character varying(50),
    estado character(1) DEFAULT 'A'::bpchar,
    multiple_intentos boolean DEFAULT true,
    enviar_solucionario boolean DEFAULT false,
    cempre integer,
    usuario_id integer
);


ALTER TABLE public.quiz OWNER TO postgres;

--
-- Name: quiz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.quiz_id_seq OWNER TO postgres;

--
-- Name: quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_id_seq OWNED BY public.quiz.id;


--
-- Name: respuestas_alumno; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.respuestas_alumno (
    id integer NOT NULL,
    alumno_id integer,
    pregunta_id integer,
    opcion_id integer,
    salon_quiz_id integer,
    quiz_id integer,
    intento_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.respuestas_alumno OWNER TO postgres;

--
-- Name: respuestas_alumno_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.respuestas_alumno_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.respuestas_alumno_id_seq OWNER TO postgres;

--
-- Name: respuestas_alumno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.respuestas_alumno_id_seq OWNED BY public.respuestas_alumno.id;


--
-- Name: salon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salon (
    id integer NOT NULL,
    codigo character varying(30) NOT NULL,
    descripcion character varying(60),
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    usuario character varying(50),
    estado character(1) DEFAULT 'A'::bpchar,
    cempre integer NOT NULL,
    usuario_id integer NOT NULL
);


ALTER TABLE public.salon OWNER TO postgres;

--
-- Name: salon_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.salon_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salon_id_seq OWNER TO postgres;

--
-- Name: salon_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.salon_id_seq OWNED BY public.salon.id;


--
-- Name: salon_quiz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salon_quiz (
    id integer NOT NULL,
    salon_id integer,
    quiz_id integer,
    codigo character varying(20),
    fecha_asignacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado character(1) DEFAULT 'A'::bpchar,
    cempre integer
);


ALTER TABLE public.salon_quiz OWNER TO postgres;

--
-- Name: salon_quiz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.salon_quiz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salon_quiz_id_seq OWNER TO postgres;

--
-- Name: salon_quiz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.salon_quiz_id_seq OWNED BY public.salon_quiz.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    usuario character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    rol character varying(20) DEFAULT 'admin'::character varying NOT NULL,
    dni character varying(20),
    nombre character varying(100),
    apellido character varying(100),
    correo character varying(150),
    cempre integer NOT NULL,
    fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: alumnos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alumnos ALTER COLUMN id SET DEFAULT nextval('public.alumnos_id_seq'::regclass);


--
-- Name: empresa cempre; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresa ALTER COLUMN cempre SET DEFAULT nextval('public.empresa_cempre_seq'::regclass);


--
-- Name: intentos_quiz id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intentos_quiz ALTER COLUMN id SET DEFAULT nextval('public.intentos_quiz_id_seq'::regclass);


--
-- Name: mejoras id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mejoras ALTER COLUMN id SET DEFAULT nextval('public.mejoras_id_seq'::regclass);


--
-- Name: opciones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones ALTER COLUMN id SET DEFAULT nextval('public.opciones_id_seq'::regclass);


--
-- Name: planes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes ALTER COLUMN id SET DEFAULT nextval('public.planes_id_seq'::regclass);


--
-- Name: preguntas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preguntas ALTER COLUMN id SET DEFAULT nextval('public.preguntas_id_seq'::regclass);


--
-- Name: quiz id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz ALTER COLUMN id SET DEFAULT nextval('public.quiz_id_seq'::regclass);


--
-- Name: respuestas_alumno id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuestas_alumno ALTER COLUMN id SET DEFAULT nextval('public.respuestas_alumno_id_seq'::regclass);


--
-- Name: salon id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon ALTER COLUMN id SET DEFAULT nextval('public.salon_id_seq'::regclass);


--
-- Name: salon_quiz id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz ALTER COLUMN id SET DEFAULT nextval('public.salon_quiz_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Data for Name: alumnos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alumnos (id, dni, nombre, apellido, correo, fcreacion, fmodificacion, usuario, estado, cempre) FROM stdin;
159	06783672	Luis Enrique	Pardon	kpardon@hotmail.com	\N	\N	\N	\N	\N
15	73154585	Darien	Villalobos	dariengaelvillalobos@gmail.com	\N	\N	\N	\N	1
73	63284329	David 	Salas Albarado	davidsalasalbarado@gmail.com	\N	\N	\N	\N	1
4	10101010	Luis	Tests	\N	\N	\N	\N	\N	1
8	72052966	Adriano	Bueno	\N	\N	\N	\N	\N	1
9	76609413	Elías	Montes	\N	\N	\N	\N	\N	1
18	61264321	Christopher 	Calderón 	\N	\N	\N	\N	\N	1
19	77740711	luis	enrique	lenrique@gmail.com	\N	\N	\N	\N	1
20	60760794	Nicolas Adrian	Cconislla Ocharan	60760794@mail.isil.pe	\N	\N	\N	\N	1
21	72269777	jose	ricse	josemricse@gmail.com	\N	\N	\N	\N	1
3	61851706	Jeanluca	Pardon Dominguez	pardojea@gmail.com	\N	\N	\N	\N	1
2	77740710	Francesco	Pardon Dominguez	pardofra@gmail.com	\N	\N	\N	\N	1
22	70593812	Giuliana	Vega Ausejo	giulianavega37@gmail.com	\N	\N	\N	\N	1
23	75949244 	JUAN	RIVEROS	juanrafaelriveros123777@gmail.com	\N	\N	\N	\N	1
86	73085520	Guillermo	Mamani Talledo	73085520@mail.isil.pe	\N	\N	\N	\N	1
24	70953053	Lucero	Torres Leiva	lucerotorresleivalol@gmail.com	\N	\N	\N	\N	1
25	75000004	Piero Andre	Llosa	piero_5_lt@hotmail.com	\N	\N	\N	\N	1
26	72827629	Xavi Nahuel	Toribio Rueda	xavitoribio.1smdla@gmail.com	\N	\N	\N	\N	1
13	76314621	Zoila Paloma	Peralta Yucra	76314621@mail.isil.pe	\N	\N	\N	\N	1
12	007335673	Carlos	Salazar	salazarxvb@gmail.com	\N	\N	\N	\N	1
27	11100222	Pablo	Prueba	pprueba@gmail.com	\N	\N	\N	\N	1
28	55566677	luis	Perez	luisoerez@gmail.com	\N	\N	\N	\N	1
29	74693112	Danovic	Lucas	74693112@mail.isil.pe	\N	\N	\N	\N	1
30	125478822	pepe	le pu	ana@gmail	\N	\N	\N	\N	1
31	72028764	Luciana	Gamberini	lucianagamberinie@gmail.com	\N	\N	\N	\N	1
32	007295380	Jesús 	Marcano	jisaschrist01@gmail.com	\N	\N	\N	\N	1
11	08226948	Jose	Guerrero 	jguerrerom17@gmail.com	\N	\N	\N	\N	1
33	70556858	Josel Aaron	Buleje Reyna	josel.aron@gmail.com	\N	\N	\N	\N	1
7	70986495	Jesus	Diaz	jada20152005@gmail.com	\N	\N	\N	\N	1
34	73887867	Favio	Vicuña 	favioernes@gmail.com	\N	\N	\N	\N	1
35	72511292	Gabriel 	Carmen rojas 	adanltcarmen@hotmail.com	\N	\N	\N	\N	1
36	74849843	Samuel	Llacoarimay	ll.canales.samuel@gmail.com	\N	\N	\N	\N	1
37	72215289	Luis Eduardo 	Geng	luisgeng557@gmail.com	\N	\N	\N	\N	1
38	75329999	Jean Pier	Rojas Salvador	rojassalvadorjean@gmail.com	\N	\N	\N	\N	1
39	72963987	Aldahir José 	Gonzales Obando 	gonzalesaldahir25@gmail.com	\N	\N	\N	\N	1
40	71404788	Edgard 	Antezana 	antezanaedgard@gmail.com	\N	\N	\N	\N	1
41	71844792	Josue 	Godos	josuegodos14@gmail.com	\N	\N	\N	\N	1
42	72331818	Ivan Eduardo 	Cajachagua 	ivancajachagua39@gmail.com	\N	\N	\N	\N	1
43	72822068	Renzo	Cabrera	cabrerarenzo072@gmail.com	\N	\N	\N	\N	1
44	77915103	Emanuel Patrick	Palomino Medina	patrickpalomino2410@gmail.com	\N	\N	\N	\N	1
45	77600663 	Jahir 	Rivera Yancce 	jahirangeloriverayancce@gmail.com	\N	\N	\N	\N	1
46	74550802	Alberth	Grajeda Aguilar	alberthmaxgrajedaaguilar@gmail.com	\N	\N	\N	\N	1
47	48401186	Geraldine Ana Paola	Gomez Atanacio 	anapaolago5@gmail.com	\N	\N	\N	\N	1
48	60240276	Jose Snaider 	Huaman Tuñoque 	60240276@mail.isil.pe	\N	\N	\N	\N	1
49	74567032	Angel Gabriel 	Inca Prado	angel927417136@gmail.com	\N	\N	\N	\N	1
50	79402034	Anibal	Bodero 	frankbodero1@gmail.com	\N	\N	\N	\N	1
51	60795733	Cris	Zavala	alexispr688@gmail.com	\N	\N	\N	\N	1
52	76146776	Juan	Torres	juanditor2005@gmail.com	\N	\N	\N	\N	1
53	60870051	Isabel 	Apeña	apenaisabel13@gmail.com	\N	\N	\N	\N	1
54	76000418	Juan Aaron 	Quispe Cristóbal 	76000418@mail	\N	\N	\N	\N	1
55	60492450	Carlos	Medina	eduardohuamanyauri059@gmail.com	\N	\N	\N	\N	1
56	73495091	Piero	Castro	73495091@mail.isil.pe	\N	\N	\N	\N	1
57	71890134	José Manuel 	Yenque Bernal	71890134@mail.isil.pe	\N	\N	\N	\N	1
58	71305190	Angelina 	Ahuanari	angelinaahuanari2012@gmail.com	\N	\N	\N	\N	1
59	61742542	Carlos	Capcha	61742542@mail.isil.pe	\N	\N	\N	\N	1
60	72729761	Josue william	Saavedra garcia	72729761@mail.isil.pe	\N	\N	\N	\N	1
61	75467740	Jean carlos	Salvatierra	75467740@mail.isil.pe	\N	\N	\N	\N	1
62	08226947	Jose 	Guerrero	jguerrerom17@gmail.com	\N	\N	\N	\N	1
63	48471494	Kendy yerson	Capcha ataucusi 	yerson_2324@hotmail.com	\N	\N	\N	\N	1
64	72355817	Abrahan	Montoya	Abrahanmontoya7@gmail.com	\N	\N	\N	\N	1
65	73178937	Pablo Antonio 	De la Torre Rumaldo	73178937@mail.isil.pe	\N	\N	\N	\N	1
5	76050439	Alexis	Hermitaño	alexismoralesgonzales@hotmail.com	\N	\N	\N	\N	1
66	74540474 	crhistofer	sotelo	Crhistofersotelo71@gmail.com	\N	\N	\N	\N	1
1	06775568	Luis Alfredo	Pardon La Rosa	pardoalf@gmail.com	\N	\N	\N	\N	1
6	74540474	crhistofer	sotelo	Crhistofersotelo71@gmail.com	\N	\N	\N	\N	1
67	47613111	Fharit	Nuñez Fallaque	47613111@mail.isil.pe	\N	\N	\N	\N	1
68	70601669	Fiorella	Bejar	fiorella_bejar@hotmail.com	\N	\N	\N	\N	1
69	72329888	Max Anthony 	Cuya armas 	maxing1516@gmail.com	\N	\N	\N	\N	1
70	44912362	GEAN CARLOS	CAPUÑAY AGAMA	44912362@mail.isil.pe	\N	\N	\N	\N	1
71	60855824	Valery	Chavarria 	chavarriavalery2006@gmail.com	\N	\N	\N	\N	1
72	44445555	Pruena	Pruena	trst@lima	\N	\N	\N	\N	1
74	78969298	Jefferson 	Manco 	jreyds2@gmail.com	\N	\N	\N	\N	1
75	75272015	Densy 	Layme puchuri 	75272015@mail.isil.pe	\N	\N	\N	\N	1
76	75949244	Juan 	Riveros	75949244@isil.net.pe	\N	\N	\N	\N	1
16	70538903	FABIAN 	Castillo flores	classfabiancastillo@gmail.com	\N	\N	\N	\N	1
17	61313419	Sebastian 	Palacios	sebastianpalacios10022008@gmail.com	\N	\N	\N	\N	1
77	60959985	Fabian Alonso	Yactayo pacsi 	Fabian.yactayo.pacsi@gmail.com	\N	\N	\N	\N	1
78	75615884	Luana	Camacho Romero	camachobruno115@gmail.com	\N	\N	\N	\N	1
79	72045324	Alan	Grandez	AGM_20@outlook.com	\N	\N	\N	\N	1
80	46995351	Felipe	Saravia	46995351@mail.isil.pe	\N	\N	\N	\N	1
81	72474313	Robert	Parra	parrarobert1278@gmail.com	\N	\N	\N	\N	1
82	77205184	Renzo	Llanos	77205184@mail.isil.pe	\N	\N	\N	\N	1
83	61201848	Sergio 	Da Silva Chiang 	61201848@mail.isil.pe	\N	\N	\N	\N	1
84	71818748	Agustin	Fernandez	71818748@mail.isil.pe	\N	\N	\N	\N	1
85	C0039164	Julian	Naranjo	c0039164@mail.isil.pe	\N	\N	\N	\N	1
10	61093085	Jean	Zuñiga	francozm44@gmail.com	\N	\N	\N	\N	1
87	002631526	Eduardo 	Mejías	eduard.mejias.a@gmail.com	\N	\N	\N	\N	1
88	45734429	Jose	Ruiz	45734429@mail.isil.pe	\N	\N	\N	\N	1
89	40974657	julio elieser	vásquez ordinola	jevotrainer@gmail.com	\N	\N	\N	\N	1
90	63229003 	Brander	Huaman Escudero	63229003@mail.isil.pe	\N	\N	\N	\N	1
91	70269701	Gustavo	Lucero	70269701@mail.isil.pe	\N	\N	\N	\N	1
92	72385966	Aldo	Barrientos	72385966@mail.isil.pe	\N	\N	\N	\N	1
93	76350085	Renzo	Trillo	trillorenzo8@gmail.com	\N	\N	\N	\N	1
94	47403098	Roger	Valencia	roger252573@gmail.com	\N	\N	\N	\N	1
95	73216671	Fabrizio	Martinez Lizarraga	mormon.3002@gmail.com	\N	\N	\N	\N	1
96	75695114	Erick Alexander 	Villacorta Medina 	genialsanos12345@hotmail.com	\N	\N	\N	\N	1
97	70728395	rodrigo 	Almeyda Sanchez	70728395@mail.isil.pe	\N	\N	\N	\N	1
98	73993575	Jim 	Queirolo	jimdn17@gmail.com	\N	\N	\N	\N	1
99	48315047	Hernando 	Suarez	hernando55g@gmail.com	\N	\N	\N	\N	1
100	71062357	Jeremy Kovac	Huamani	71062357@mail.isil.pe	\N	\N	\N	\N	1
101	72410359	Ghazdaly	Neyra	ghazdalyneyraluyo@gmail.com	\N	\N	\N	\N	1
102	61300459	Aldrin Camilo 	Jara Chuquilin 	camilo4khd@gmail.com	\N	\N	\N	\N	1
103	62019339	Fernando 	Aguilar	Fernandoaguilar281m@gmail.com	\N	\N	\N	\N	1
104	73857813	Manuel Alexander	Condori Céspedes	alexandercondori.2326@gmail.com	\N	\N	\N	\N	1
105	70699688	Henrich 	Flores 	floreshenrich7@gmail.com	\N	\N	\N	\N	1
106	61462174	Fernando	Seminario	61462174@mail.isil.pe	\N	\N	\N	\N	1
107	70700595	Joel	López 	ejoelopez14@gmail.com	\N	\N	\N	\N	1
108	77063785	Fabricio Alexander	Ortega Dominguez 	xanderortega2023@gmail.com	\N	\N	\N	\N	1
109	77165469	Elliot	Loyola 	elliotloyola25@gmail.com	\N	\N	\N	\N	1
110	75645697	Alexis Leonel	Díaz Nolasco 	alexisleoneldiaznolasco@gmail.com	\N	\N	\N	\N	1
111	61180593	Camila	Chavez	camilachavezbernal@gmail.com	\N	\N	\N	\N	1
112	61334380	Guillermo 	Euribe	61334380@mail.isil.pe	\N	\N	\N	\N	1
113	61294950	Fabrizio	Vega Guillen	fabrixgv1502@gmail.com	\N	\N	\N	\N	1
114	61177601	Pablo	Santos	psantosricse@gmail.com	\N	\N	\N	\N	1
115	71358204	Dylan Joaquin	Cabrera Avalos	dynavalosa@gmail.com	\N	\N	\N	\N	1
116	71193178	Valentino	Ramos	71193178@mail.isil.pe	\N	\N	\N	\N	1
117	74262497 	Mathias Daniel 	Esquivel Barranzuela 	74262497@mail.isil.pe	\N	\N	\N	\N	1
118	74323240	Ivan Angel 	Cortez Torres 	74323240@mail.isil.pe	\N	\N	\N	\N	1
119	72052960	Jeremias	Oscco	jeremiasoscco@gmail.com	\N	\N	\N	\N	1
14	70906450	Adriana 	Angues 	70906450@mail.com.pe	\N	\N	\N	\N	1
120	007295390	Jesús 	Marcano	jisaschrist01@gmail.com	\N	\N	\N	\N	1
121	77361851	Sarai Ariana	Espejo Taype	arianaespejo727@gmail.com	\N	\N	\N	\N	1
122	72618150	Isaac	Sotelo Guimet	72618150@mail.isil.pe	\N	\N	\N	\N	1
123	74923481	Camila	Biamon	franciscabiamon@gmail.com	\N	\N	\N	\N	1
124	61122977	Tamara	Pando	61122977@mail.isil.pe	\N	\N	\N	\N	1
125	75494148	Adriana	Leon	75494148@mail.isil.pe	\N	\N	\N	\N	1
126	73098965	Juan Francisco 	Barzola	gabriel919110@gmail.com	\N	\N	\N	\N	1
127	77600663	Jahir 	Rivera Yancce 	jahirangeloriverayancce@gmail.com	\N	\N	\N	\N	1
128	77788899	armando	puertas	apuertas@isil.pe	\N	\N	\N	\N	1
131	99988877	carlos 	razuri	crazuri@gmail.com	\N	\N	\N	\N	1
132	77758781	Claudia 	Rovegno	crovegno@gmail.com	\N	\N	\N	\N	1
133	77758782	test	test2	test@gmail.com	\N	\N	\N	\N	1
134	98989898	test3	test3	test3@test2.com	\N	\N	\N	\N	1
135	99966633	test5	test5	test5@gmail.com	\N	\N	\N	\N	1
136	985236542	test6	test6	test6@gmail.com	\N	\N	\N	\N	1
137	10000001	test11	test11	test11@gmail.com	\N	\N	\N	\N	1
138	10000002	test12	test12	test12@gmail.com	\N	\N	\N	\N	1
139	1000310005	test13	test13	test13@gmail.com	\N	\N	\N	\N	1
140	10041004	test14	test14	test14@gmail.com	\N	\N	\N	\N	1
141	10051005	test15	twst15	test15@gmail.com	\N	\N	\N	\N	1
142	10071007	test17	test17	pardoalf@gmail.com	\N	\N	\N	\N	1
143	10008108	test18	test18	pardoalf@hotmail.com	\N	\N	\N	\N	1
144	10081008	test8	test8	pardoalf@hotmail.com	\N	\N	\N	\N	1
145	88888888	test8	test8	pardoalf@hotmail.com	\N	\N	\N	\N	1
146	10111011	test11	test11	pardoalf@hotmail.com	\N	\N	\N	\N	1
147	20202020	test20	test20	pardoalf@hotmail.com	\N	\N	\N	\N	1
148	46182495	JOSE CALEB	ROSALES BALCAZAR	46182495@mail.isil.pe	\N	\N	\N	\N	1
149	74727087	Oscar Jahir 	Izquierdo montesinos	oscarizquierdomontesinos@gmail.com	\N	\N	\N	\N	1
150	73154585 	Darien	Villalobos	dariengaelvillalobos@gmail.com	\N	\N	\N	\N	1
151	72735685	Moises	Siancas 	72735685@mail.isil.pe	\N	\N	\N	\N	1
152	03436297	Julian	Naranjo	c0039164@mail.isil.pe	\N	\N	\N	\N	1
153	72479379	Alexander 	Palacios 	alex13.pa.ac@gmail.com	\N	\N	\N	\N	1
154	7 4 7 2 7 0 8 7	Oscar Jahir 	Izquierdo montesinos	oscarizquierdomontesinos@gmail.com	\N	\N	\N	\N	1
155	7238596	Aldo	Barrientos	72385966@mail.isil.pe	\N	\N	\N	\N	1
156	7321667	Fabrizio	Martinez Lizarraga	mormon.3002@gmail.com	\N	\N	\N	\N	1
157	46995251	Luis	Saravia	fsaraviamunayco@gmail.com	\N	\N	\N	\N	1
158	10102020	Carlos 	Ampuero	campuero@gmail.co	\N	\N	\N	\N	1
\.


--
-- Data for Name: empresa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empresa (cempre, dempre, fcreacion, licencia, estado) FROM stdin;
1	TEST	2026-05-02 00:14:51.999506	t	t
\.


--
-- Data for Name: intentos_quiz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.intentos_quiz (id, alumno_id, quiz_id, intento_numero, fecha_inicio, fecha_fin, nota_final) FROM stdin;
1	1	47	1	2026-05-16 16:37:52.860646	\N	\N
2	1	48	1	2026-05-16 16:37:52.860646	\N	\N
3	1	54	1	2026-05-16 16:37:52.860646	\N	\N
4	1	54	2	2026-05-16 16:37:52.860646	\N	\N
5	2	5	1	2026-05-16 16:37:52.860646	\N	\N
6	2	7	1	2026-05-16 16:37:52.860646	\N	\N
7	2	23	1	2026-05-16 16:37:52.860646	\N	\N
8	5	4	1	2026-05-16 16:37:52.860646	\N	\N
9	5	7	1	2026-05-16 16:37:52.860646	\N	\N
10	5	22	1	2026-05-16 16:37:52.860646	\N	\N
11	5	26	1	2026-05-16 16:37:52.860646	\N	\N
12	6	4	1	2026-05-16 16:37:52.860646	\N	\N
13	6	7	1	2026-05-16 16:37:52.860646	\N	\N
14	6	22	1	2026-05-16 16:37:52.860646	\N	\N
15	6	26	1	2026-05-16 16:37:52.860646	\N	\N
16	7	14	1	2026-05-16 16:37:52.860646	\N	\N
17	10	18	1	2026-05-16 16:37:52.860646	\N	\N
18	11	14	1	2026-05-16 16:37:52.860646	\N	\N
19	11	18	1	2026-05-16 16:37:52.860646	\N	\N
20	11	25	1	2026-05-16 16:37:52.860646	\N	\N
21	12	18	1	2026-05-16 16:37:52.860646	\N	\N
22	13	18	1	2026-05-16 16:37:52.860646	\N	\N
23	13	25	1	2026-05-16 16:37:52.860646	\N	\N
24	14	18	1	2026-05-16 16:37:52.860646	\N	\N
25	15	17	1	2026-05-16 16:37:52.860646	\N	\N
26	15	24	1	2026-05-16 16:37:52.860646	\N	\N
27	16	17	1	2026-05-16 16:37:52.860646	\N	\N
28	16	24	1	2026-05-16 16:37:52.860646	\N	\N
29	17	17	1	2026-05-16 16:37:52.860646	\N	\N
30	17	24	1	2026-05-16 16:37:52.860646	\N	\N
31	20	17	1	2026-05-16 16:37:52.860646	\N	\N
32	21	17	1	2026-05-16 16:37:52.860646	\N	\N
33	21	24	1	2026-05-16 16:37:52.860646	\N	\N
34	21	25	1	2026-05-16 16:37:52.860646	\N	\N
35	22	17	1	2026-05-16 16:37:52.860646	\N	\N
36	23	17	1	2026-05-16 16:37:52.860646	\N	\N
37	24	17	1	2026-05-16 16:37:52.860646	\N	\N
38	26	15	1	2026-05-16 16:37:52.860646	\N	\N
39	26	18	1	2026-05-16 16:37:52.860646	\N	\N
40	29	25	1	2026-05-16 16:37:52.860646	\N	\N
41	31	14	1	2026-05-16 16:37:52.860646	\N	\N
42	31	25	1	2026-05-16 16:37:52.860646	\N	\N
43	32	14	1	2026-05-16 16:37:52.860646	\N	\N
44	33	14	1	2026-05-16 16:37:52.860646	\N	\N
45	34	21	1	2026-05-16 16:37:52.860646	\N	\N
46	34	25	1	2026-05-16 16:37:52.860646	\N	\N
47	35	21	1	2026-05-16 16:37:52.860646	\N	\N
48	36	21	1	2026-05-16 16:37:52.860646	\N	\N
49	36	25	1	2026-05-16 16:37:52.860646	\N	\N
50	37	21	1	2026-05-16 16:37:52.860646	\N	\N
51	37	25	1	2026-05-16 16:37:52.860646	\N	\N
52	38	21	1	2026-05-16 16:37:52.860646	\N	\N
53	38	25	1	2026-05-16 16:37:52.860646	\N	\N
54	39	21	1	2026-05-16 16:37:52.860646	\N	\N
55	39	25	1	2026-05-16 16:37:52.860646	\N	\N
56	40	21	1	2026-05-16 16:37:52.860646	\N	\N
57	40	25	1	2026-05-16 16:37:52.860646	\N	\N
58	41	21	1	2026-05-16 16:37:52.860646	\N	\N
59	42	21	1	2026-05-16 16:37:52.860646	\N	\N
60	42	25	1	2026-05-16 16:37:52.860646	\N	\N
61	43	21	1	2026-05-16 16:37:52.860646	\N	\N
62	43	25	1	2026-05-16 16:37:52.860646	\N	\N
63	44	21	1	2026-05-16 16:37:52.860646	\N	\N
64	44	25	1	2026-05-16 16:37:52.860646	\N	\N
65	45	21	1	2026-05-16 16:37:52.860646	\N	\N
66	46	21	1	2026-05-16 16:37:52.860646	\N	\N
67	47	21	1	2026-05-16 16:37:52.860646	\N	\N
68	47	25	1	2026-05-16 16:37:52.860646	\N	\N
69	48	21	1	2026-05-16 16:37:52.860646	\N	\N
70	48	25	1	2026-05-16 16:37:52.860646	\N	\N
71	49	21	1	2026-05-16 16:37:52.860646	\N	\N
72	50	21	1	2026-05-16 16:37:52.860646	\N	\N
73	50	25	1	2026-05-16 16:37:52.860646	\N	\N
74	51	21	1	2026-05-16 16:37:52.860646	\N	\N
75	52	21	1	2026-05-16 16:37:52.860646	\N	\N
76	52	25	1	2026-05-16 16:37:52.860646	\N	\N
77	53	21	1	2026-05-16 16:37:52.860646	\N	\N
78	54	21	1	2026-05-16 16:37:52.860646	\N	\N
79	55	21	1	2026-05-16 16:37:52.860646	\N	\N
80	55	25	1	2026-05-16 16:37:52.860646	\N	\N
81	56	21	1	2026-05-16 16:37:52.860646	\N	\N
82	56	25	1	2026-05-16 16:37:52.860646	\N	\N
83	59	18	1	2026-05-16 16:37:52.860646	\N	\N
84	60	14	1	2026-05-16 16:37:52.860646	\N	\N
85	60	25	1	2026-05-16 16:37:52.860646	\N	\N
86	61	14	1	2026-05-16 16:37:52.860646	\N	\N
87	61	17	1	2026-05-16 16:37:52.860646	\N	\N
88	61	24	1	2026-05-16 16:37:52.860646	\N	\N
89	61	25	1	2026-05-16 16:37:52.860646	\N	\N
90	63	18	1	2026-05-16 16:37:52.860646	\N	\N
91	63	25	1	2026-05-16 16:37:52.860646	\N	\N
92	64	14	1	2026-05-16 16:37:52.860646	\N	\N
93	65	18	1	2026-05-16 16:37:52.860646	\N	\N
94	67	18	1	2026-05-16 16:37:52.860646	\N	\N
95	68	15	1	2026-05-16 16:37:52.860646	\N	\N
96	69	14	1	2026-05-16 16:37:52.860646	\N	\N
97	70	25	1	2026-05-16 16:37:52.860646	\N	\N
98	71	24	1	2026-05-16 16:37:52.860646	\N	\N
99	73	24	1	2026-05-16 16:37:52.860646	\N	\N
100	74	24	1	2026-05-16 16:37:52.860646	\N	\N
101	75	24	1	2026-05-16 16:37:52.860646	\N	\N
102	76	24	1	2026-05-16 16:37:52.860646	\N	\N
103	77	24	1	2026-05-16 16:37:52.860646	\N	\N
104	78	24	1	2026-05-16 16:37:52.860646	\N	\N
105	79	24	1	2026-05-16 16:37:52.860646	\N	\N
106	100	18	1	2026-05-16 16:37:52.860646	\N	\N
107	101	18	1	2026-05-16 16:37:52.860646	\N	\N
108	102	25	1	2026-05-16 16:37:52.860646	\N	\N
109	103	25	1	2026-05-16 16:37:52.860646	\N	\N
110	104	25	1	2026-05-16 16:37:52.860646	\N	\N
111	105	25	1	2026-05-16 16:37:52.860646	\N	\N
112	106	25	1	2026-05-16 16:37:52.860646	\N	\N
113	107	25	1	2026-05-16 16:37:52.860646	\N	\N
114	108	25	1	2026-05-16 16:37:52.860646	\N	\N
115	109	25	1	2026-05-16 16:37:52.860646	\N	\N
116	110	25	1	2026-05-16 16:37:52.860646	\N	\N
117	111	18	1	2026-05-16 16:37:52.860646	\N	\N
118	112	25	1	2026-05-16 16:37:52.860646	\N	\N
119	113	25	1	2026-05-16 16:37:52.860646	\N	\N
120	114	25	1	2026-05-16 16:37:52.860646	\N	\N
121	115	25	1	2026-05-16 16:37:52.860646	\N	\N
122	116	25	1	2026-05-16 16:37:52.860646	\N	\N
123	117	25	1	2026-05-16 16:37:52.860646	\N	\N
124	118	25	1	2026-05-16 16:37:52.860646	\N	\N
125	119	18	1	2026-05-16 16:37:52.860646	\N	\N
126	120	25	1	2026-05-16 16:37:52.860646	\N	\N
127	121	18	1	2026-05-16 16:37:52.860646	\N	\N
128	122	18	1	2026-05-16 16:37:52.860646	\N	\N
129	123	18	1	2026-05-16 16:37:52.860646	\N	\N
130	124	18	1	2026-05-16 16:37:52.860646	\N	\N
131	125	18	1	2026-05-16 16:37:52.860646	\N	\N
132	127	25	1	2026-05-16 16:37:52.860646	\N	\N
133	131	1	1	2026-05-16 16:37:52.860646	\N	\N
134	132	23	1	2026-05-16 16:37:52.860646	\N	\N
135	139	1	1	2026-05-16 16:37:52.860646	\N	\N
136	158	47	1	2026-05-16 16:37:52.860646	\N	\N
142	159	56	1	2026-05-24 13:27:22.051886	\N	\N
\.


--
-- Data for Name: mejoras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mejoras (id, descripcion, usuario, fecha, estado, version, tipo) FROM stdin;
34	<p>wdwcqecqcqcq</p><p>c AAAAAAAAAAAAAAAAAAAAAA</p><p>qc</p><p>qc</p><p>qe</p><p>cqe</p><p>cqc</p>	pardoalf	2026-05-31 20:53:56.073964	nuevo	\N	E
35	<p>wdwcqecqcqcq</p><p>c AAAAAAAAAAAAAAAAAAAAAA</p><p>qcBBBBBBBBBBBBB</p><p>qc</p><p>qe</p><p>cqe</p><p>cqc</p>	pardoalf	2026-05-31 20:54:05.680382	nuevo	\N	E
36	<p>wdwcqecqcqcq</p><p>c AAAAAAAAAAAAAAAAAAAAAA</p><p>qcACCCCCCCCCCC</p><p>qc</p><p>qe</p><p>cqe</p><p>cqc</p>	pardoalf	2026-05-31 20:56:31.613777	nuevo	\N	E
37	<p>wdwcqecqcqcq</p><p>c AAAAAAAAAAAAAAAAAAAAAA</p><p>qcCCCCCCCCCCCCCCCCCCC</p><p>qc</p><p>qe</p><p>cqe</p><p>cqc</p>	pardoalf	2026-05-31 20:56:47.40142	nuevo	\N	E
1	Implmentar quiz de ingles, aun no sabemos el enfoque pero la idea seria 2 partes, una para completar y otra que sea de opcion múltiple	pardoalf	2026-05-26 23:43:23.225334	revisado	v2.3	M
3	Probar crear quiz con quiz ya creatdo	pardoalf	2026-05-27 00:17:09.654031	realizado		M
2	Pensar en una idea de UX para el alumno	pardoalf	2026-05-27 00:15:03.573991	revisado		M
5	En la pantralla test hay un error	pardoalf	2026-05-30 23:02:19.629085	nuevo	\N	E
6	problems de graciobacion	pardoalf	2026-05-30 23:17:58.971132	nuevo	\N	M
7	estaba listo pero parece que no	pardoalf	2026-05-30 23:18:17.353309	nuevo	\N	E
8	prueba numero 4	pardoalf	2026-05-30 23:21:39.647047	nuevo	\N	E
9	error en la pagina 1, podriamos mejorarlo	pardoalf	2026-05-30 23:22:11.558905	nuevo	\N	M
10	prueba 34	pardoalf	2026-05-30 23:26:31.824477	nuevo	\N	M
12	debes cambiar de estilo	pardoalf	2026-05-30 23:30:18.906753	nuevo	\N	M
13	tremiendo error	pardoalf	2026-05-30 23:30:40.772027	nuevo	\N	E
14	prueba 34	pardoalf	2026-05-30 23:32:46.434076	nuevo	\N	M
15	otra prueba	pardoalf	2026-05-30 23:33:06.549834	nuevo	\N	M
18	perfecto	pardoalf	2026-05-31 01:02:09.412613	enviado		E
17	prueba	pardoalf	2026-05-31 00:59:32.554495	enviado		M
16	prueba	pardoalf	2026-05-31 00:51:01.313544	enviado		M
11	test34	pardoalf	2026-05-30 23:27:26.819889	enviado		E
20		pardoalf	2026-05-31 20:08:29.384085	nuevo	\N	M
21	<p><strong style="color: rgb(230, 0, 0);">dwdwedwdwd</strong></p><p><u>dwdwdwdw</u></p>	pardoalf	2026-05-31 20:10:09.438933	nuevo	\N	M
22	<p>wwwxwxwxwxwxw</p><p>xwxwwxwx</p><ol><li>xwxwxwxw</li><li>xwxwx</li><li>wxwxw</li></ol>	pardoalf	2026-05-31 20:18:51.646547	nuevo	\N	E
24	<p><strong style="color: rgb(230, 0, 0);">dwdwedwdwd</strong></p><p><u>dwdwdwdw</u></p><p><u style="color: rgb(255, 194, 102); background-color: rgb(255, 255, 0);">dwmcqekncqencq</u></p>	pardoalf	2026-05-31 20:38:25.810102	nuevo	\N	M
25	<p><strong style="color: rgb(230, 0, 0);">dwdwedwdwd</strong></p><p><u>dwdwdwdw</u></p><p><u>dwdwdw</u></p>	pardoalf	2026-05-31 20:38:38.311756	nuevo	\N	M
26	<p><strong style="color: rgb(230, 0, 0);">dwdwedwdwd</strong></p><p><u>dwdwdwdw</u></p><p><u style="color: rgb(102, 185, 102); background-color: rgb(255, 255, 0);">sdwdwdwdwdw</u></p>	pardoalf	2026-05-31 20:42:14.128116	nuevo	\N	M
27	<p><strong style="color: rgb(230, 0, 0);">dwdwedwdwd</strong></p><p><u>dwdwdwdw</u></p><p><u>dwdwdw</u></p><ul><li><u>43r1rff3f3f3</u></li><li><u>f32f23f23f23f</u></li><li><u>f32f2f2f2</u></li></ul>	pardoalf	2026-05-31 20:45:50.113168	nuevo	\N	M
32	<p>wdwcqecqcqcq</p><p>cAAAAAAAAAAA</p><p>qc</p><p>qc</p><p>qe</p><p>cqe</p><p>cqc</p>	pardoalf	2026-05-31 20:51:59.380817	nuevo	\N	E
33	<p>wdwcqecqcqcq</p><p>cAAAAAAAAAAAAAAa</p><p>qc</p><p>qc</p><p>qe</p><p>cqe</p><p>cqc</p>	pardoalf	2026-05-31 20:52:08.608629	nuevo	\N	E
53	<p>mejora...este ticket deberia ser hecho antes del 1 fr agosto</p><p>por que tenia pque pasasr si?</p><p>deebriamo ver esta secsion</p><p>AKFREDO</p>	pardoalf	2026-05-31 21:46:25.848674	enviado		M
54	<p>prureba</p>	pardoalf	2026-06-01 16:37:17.101062	nuevo	\N	M
23	<p>que paso no edita el contrenido</p>	pardoalf	2026-05-31 20:22:22.338498	nuevo		M
55	<p>prueba error</p>	pardoalf	2026-06-01 16:37:29.249003	nuevo	\N	M
\.


--
-- Data for Name: opciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opciones (id, pregunta_id, texto, es_correcta) FROM stdin;
369	122	Verdadero	t
370	122	Falso	f
371	123	Verdadero	f
372	123	Falso	t
373	124	Verdadero	t
374	124	Falso	f
7	5	Verdadero	t
8	5	Falso	f
9	6	Verdadero	t
10	6	Falso	f
375	125	Verdadero	t
376	125	Falso	f
377	126	Verdadero	f
378	126	Falso	t
379	127	Verdadero	t
380	127	Falso	f
381	128	Verdadero	t
382	128	Falso	f
383	129	Verdadero	f
384	129	Falso	t
385	130	Verdadero	f
386	130	Falso	t
387	131	Verdadero	t
388	131	Falso	f
1354	392	Solo programas de internet	f
1355	392	Parte física del computador	f
1356	392	Conjunto de programas y datos	t
1357	392	Solo el sistema operativo	f
1358	392	Solo aplicaciones móviles	f
1359	393	Básico y avanzado	f
1360	393	Libre y privativo	t
1361	393	Público y privado	f
1362	393	Local y remoto	f
1363	393	Antiguo y moderno	f
1364	394	Solo usar el programa	f
1365	394	Usarlo y venderlo sin restricciones	f
1366	394	Usar, copiar, estudiar, modificar y redistribuir	t
1367	394	Solo modificarlo	f
1368	394	Solo copiarlo	f
1369	395	Bill Gates	f
1370	395	Steve Jobs	f
1371	395	Linus Torvalds	f
1372	395	Richard Stallman	t
1373	395	Mark Zuckerberg	f
616	199	Verdadero	t
617	199	Falso	f
618	200	Verdadero	f
619	200	Falso	t
620	201	Verdadero	t
621	201	Falso	f
622	202	Verdadero	t
623	202	Falso	f
624	203	Verdadero	t
625	203	Falso	f
626	204	Verdadero	f
627	204	Falso	t
628	205	Verdadero	t
629	205	Falso	f
630	206	Verdadero	t
631	206	Falso	f
632	207	Verdadero	t
633	207	Falso	f
634	208	Verdadero	f
635	208	Falso	t
636	209	Verdadero	t
637	209	Falso	f
638	210	Verdadero	t
639	210	Falso	f
640	211	Verdadero	t
641	211	Falso	f
642	212	Verdadero	t
643	212	Falso	f
644	213	Verdadero	f
645	213	Falso	t
646	214	Verdadero	t
647	214	Falso	f
648	215	Verdadero	t
649	215	Falso	f
650	216	Verdadero	f
651	216	Falso	t
652	217	Verdadero	t
653	217	Falso	f
654	218	Verdadero	t
655	218	Falso	f
1374	396	Un programa de juegos	f
1375	396	Software que administra el hardware	t
1376	396	Solo una interfaz gráfica	f
1377	396	Un antivirus	f
1378	396	Un navegador web	f
1379	397	Es pago	f
1380	397	No tiene código	f
1381	397	Respeta las cuatro libertades	t
1382	397	Solo funciona en servidores	f
1383	397	No se puede modificar	f
1384	398	Interfaz bonita	f
1385	398	Código oculto	f
1386	398	Acceso al código fuente	t
1387	398	Uso gratuito	f
1388	398	Fácil instalación	f
1389	399	Alto costo	f
1390	399	Baja seguridad	f
1391	399	Personalización total	t
1392	399	Dependencia de empresas	f
1393	399	Uso limitado	f
1394	400	Gratis	f
1395	400	Seguridad alta	f
1396	400	Curva de aprendizaje	t
1397	400	Código abierto	f
2836	752	A. Tanjiro Kamado	t
2837	752	B. Zenitsu Agatsuma	f
2838	752	C. Inosuke Hashibira	f
2839	752	D. Kyojuro Rengoku	f
2840	752	E. Muzan Kibutsuji	f
2841	753	A. Cazador de Demonios	f
2842	753	B. Humano	f
2843	753	C. Demonio	t
2844	753	D. Espiritual	f
2845	753	E. Angel	f
2846	754	A. Respiración de Agua	t
2847	754	B. Respiración de Rayo	f
2848	754	C. Respiración de Llama	f
2849	754	D. Respiración de Viento	f
2850	754	E. Respiración de Piedra	f
2851	755	A. Giyu Tomioka	f
2852	755	B. Kyojuro Rengoku	f
2853	755	C. Shinobu Kocho	f
2854	755	D. Sanemi Shinazugawa	f
2855	755	E. No hay un solo líder	t
2856	756	A. Agua bendita	f
2857	756	B. Luz de sol	t
131	47	Verdadero	t
132	47	Falso	f
2858	756	C. Fuego mágico	f
134	47	Falso	f
2859	756	D. Flechas encantadas	f
2860	756	E. Agua normal	f
2981	787	Verdadero	t
2982	787	Falso	f
2983	788	A) Boleta de venta	f
153	48	Verdadero	t
154	48	Falso	f
155	49	Verdadero	t
156	49	Falso	f
157	50	Verdadero	f
158	50	Falso	t
159	51	Verdadero	t
160	51	Falso	f
161	52	Verdadero	t
162	52	Falso	f
163	53	Verdadero	t
164	53	Falso	f
165	54	Verdadero	f
166	54	Falso	t
167	55	Verdadero	t
168	55	Falso	f
169	56	Verdadero	t
170	56	Falso	f
171	57	Verdadero	t
172	57	Falso	f
589	187	Verdadero	t
590	187	Falso	f
591	188	Verdadero	t
592	188	Falso	f
593	189	Verdadero	t
594	189	Falso	f
595	190	Verdadero	f
596	190	Falso	t
597	191	Verdadero	f
598	191	Falso	t
599	192	Verdadero	f
600	192	Falso	t
601	193	Verdadero	t
602	193	Falso	f
603	194	Verdadero	t
604	194	Falso	f
605	195	Verdadero	f
606	195	Falso	t
607	196	Verdadero	t
608	196	Falso	f
1398	400	Comunidad activa	f
1657	492	var	t
1658	492	variable	f
1659	492	letvar	f
197	68	Zenitsu Agatsuma	f
198	68	Tanjiro Kamado	t
199	68	Inosuke Hashibira	f
200	68	Giyu Tomioka	f
201	69	Se mudan	f
202	69	Son atacados por demonios	t
203	69	Desaparecen	f
204	69	Son arrestados	f
205	70	Mitsuri	f
206	70	Shinobu	f
207	70	Nezuko Kamado	t
208	70	Kanao	f
209	71	Respiración del Trueno	f
210	71	Respiración del Agua	t
211	71	Respiración del Viento	f
212	71	Respiración de la Piedra	f
213	72	Akaza	f
214	72	Muzan Kibutsuji	t
215	72	Rui	f
216	72	Kokushibo	f
217	73	Puede volar	f
218	73	No necesita sangre humana constantemente y resiste el sol parcialmente	t
219	73	Es invisible	f
220	73	Puede controlar otros demonios	f
221	74	Guardia Nocturna	f
222	74	Cazadores de Sombras	f
223	74	Cuerpo de Exterminio de Demonios	t
224	74	Orden del Sol	f
225	75	Espadas normales	f
226	75	Espadas Nichirin	t
227	75	Lanzas	f
228	75	Arcos	f
229	76	Mitsuri Kanroji	f
230	76	Shinobu Kocho	t
231	76	Kyojuro Rengoku	f
232	76	Tengen Uzui	f
233	77	Respiración del Agua	f
234	77	Respiración del Trueno	t
235	77	Respiración de la Niebla	f
236	77	Respiración del Amor	f
237	78	gerado pajares	f
238	78	Luis Gerardo	f
239	78	Gerardo Nieto	f
240	78	Luis pajares	f
241	79	Verdadero	t
242	79	Falso	f
243	80	Verdadero	t
244	80	Falso	f
245	81	Carls Ampuero	t
246	81	Felipe de stilals	f
247	81	Francosc Pozarro	f
248	81	Hernando de Luque	f
249	82	Verdadero	f
250	82	Falso	t
251	83	Verdadero	t
252	83	Falso	f
253	84	Verdadero	f
254	84	Falso	t
255	85	Verdadero	f
256	85	Falso	t
257	86	Verdadero	t
258	86	Falso	f
259	87	Verdadero	f
260	87	Falso	t
261	88	Verdadero	t
262	88	Falso	f
263	89	Verdadero	f
264	89	Falso	t
265	90	Verdadero	t
266	90	Falso	f
267	91	Verdadero	t
268	91	Falso	f
269	92	Verdadero	f
270	92	Falso	t
271	93	Verdadero	t
272	93	Falso	f
273	94	Verdadero	f
274	94	Falso	t
275	95	Verdadero	t
276	95	Falso	f
277	96	Verdadero	t
278	96	Falso	f
279	97	Verdadero	f
280	97	Falso	t
281	98	Verdadero	f
282	98	Falso	t
283	99	Verdadero	t
284	99	Falso	f
285	100	Verdadero	f
286	100	Falso	t
287	101	Verdadero	t
288	101	Falso	f
289	102	Bill Gates	f
290	102	Richard Stallman	t
291	102	Linus Torvalds	f
292	102	Steve Jobs	f
293	103	Programa	f
294	103	Núcleo del sistema	t
295	103	App	f
296	103	Navegador	f
297	104	Navegador	f
298	104	Lenguaje	f
299	104	Kernel	t
300	104	Base de datos	f
301	105	MIT	f
302	105	BSD	f
303	105	GPL	t
304	105	Apache	f
305	106	Vender código	f
306	106	Soporte	t
307	106	Juegos	f
308	106	Hardware	f
309	107	Ética	f
310	107	Negocio	f
311	107	Código	t
312	107	Diseño	f
313	108	Precio bajo	f
314	108	Libertades	t
315	108	Seguridad	f
316	108	Velocidad	f
317	109	Free Software Foundation	t
318	109	Fast System File	f
319	109	Free System Format	f
320	109	File System Free	f
1660	492	int	f
321	110	1983	t
322	110	1991	f
323	110	2000	f
324	110	1970	f
325	111	1991	t
326	111	2000	f
327	111	1980	f
328	111	1995	f
329	112	Google	f
330	112	Microsoft	f
331	112	IBM	t
332	112	Amazon	f
333	113	Restrictiva	f
334	113	Permisiva	t
335	113	Comercial	f
336	113	Cerrada	f
337	114	Vende software	f
338	114	Ofrece soporte	t
339	114	Fabrica hardware	f
340	114	Diseña juegos	f
341	115	Navegador	f
342	115	Plataforma en la nube	t
343	115	Sistema operativo	f
344	115	Antivirus	f
345	116	Base de datos	f
346	116	Automatización	t
347	116	Navegador	f
348	116	Editor	f
349	117	Lenguaje	f
350	117	Licencia libre	t
351	117	Sistema operativo	f
352	117	App	f
353	118	Copiar libre	f
354	118	Mantener libertad	t
355	118	Código cerrado	f
356	118	Licencia privada	f
357	119	Precio	f
358	119	Libertad	t
359	119	Publicidad	f
360	119	Diseño	f
361	120	Colaboración	t
362	120	Privacidad	f
363	120	Venta	f
364	120	Control	f
365	121	Software gratis	f
366	121	Que open source es rentable	t
367	121	Que Linux es malo	f
368	121	Que no sirve	f
609	197	Verdadero	t
610	197	Falso	f
611	198	Sasuke	t
612	198	Kakashi	f
613	198	Itachi	f
614	198	Gaara	f
615	198	Madara	f
1399	401	Windows	f
1400	401	macOS	f
1401	401	GNU/Linux	t
1402	401	DOS	f
1403	401	Android	f
1404	402	Un antivirus	f
1405	402	Un sistema UNIX-like	t
1406	402	Un navegador	f
1407	402	Un lenguaje	f
1408	402	Un virus	f
1409	403	Un editor de texto	f
1410	403	Sistema compatible con Windows	t
1411	403	Un antivirus	f
1412	403	Una app móvil	f
1413	403	Un servidor web	f
1414	404	Un virus	f
1415	404	Una variante de Linux con herramientas	t
1416	404	Un hardware	f
1417	404	Un navegador	f
1418	404	Un archivo	f
1419	405	Arch Linux	f
1420	405	Ubuntu	t
1421	405	FreeBSD	f
1422	405	Fedora Server	f
1423	405	Kali Linux	f
1424	406	Ubuntu	f
1425	406	Debian	f
1426	406	Arch Linux	t
1427	406	Mint	f
1428	406	Fedora	f
1429	407	Solo en casas	f
1430	407	Solo en colegios	f
1431	407	Educación, gobierno y empresas	t
1432	407	Solo en celulares	f
1433	407	Solo en videojuegos	f
1434	408	iOS	f
1435	408	Windows Phone	f
1436	408	Android	t
1437	408	Symbian	f
1438	408	BlackBerry	f
1439	409	Photoshop	f
1440	409	LibreOffice	t
1441	409	Chrome	f
1661	492	constante	f
1662	493	let	t
1663	493	var	f
1664	493	const	f
1665	493	int	f
1666	493	static	f
1667	494	const	t
1668	494	let	f
1669	494	var	f
1670	494	constant	f
1671	494	fixed	f
1672	495	Verdadero	t
1673	495	Falso	f
1674	496	Verdadero	t
1675	496	Falso	f
1676	497	No da error y la segunda declaración sobrescribe la primera	t
1677	497	Da error de sintaxis	f
1678	497	Se crea una segunda variable distinta	f
1679	497	El navegador se cierra	f
1680	497	La variable se convierte en constante	f
1681	498	undefined	t
1682	498	null	f
1683	498	0	f
1684	498	'' (cadena vacía)	f
1685	498	NaN	f
1686	499	Verdadero	f
1687	499	Falso	t
1688	500	_miVariable	f
1689	500	2variable	t
1690	500	$valor	f
1691	500	variableUno	f
1692	500	var1	f
1693	501	el ámbito (scope)	t
1694	501	el tipo de dato que almacenan	f
1695	501	var es para objetos y let para primitivos	f
1696	501	let es más rápido	f
1697	501	var permite declarar funciones	f
1698	502	Verdadero	t
1699	502	Falso	f
1700	503	Verdadero	t
1701	503	Falso	f
1702	504	let edad = 30;	t
1703	504	var edad := 30;	f
1704	504	const edad = '30';	f
1705	504	edad = 30 let;	f
1706	504	var 30 = edad;	f
1707	505	int nombre;	t
1708	505	let _nombre;	f
1442	409	Windows	f
1443	409	Notepad	f
1444	410	Es más difícil	f
1445	410	Limita el aprendizaje	f
1446	410	Fomenta pensamiento crítico	t
1447	410	Solo sirve para expertos	f
1448	410	Es obligatorio	f
1449	411	Netflix	f
1450	411	NASA	t
1709	505	let nombre;	f
1710	505	var nombre;	f
1711	505	const nombre;	f
1712	506	Verdadero	t
1713	506	Falso	f
1714	507	const	t
1715	507	let	f
1716	507	var	f
1717	507	final	f
1718	507	static	f
1719	508	Verdadero	t
1720	508	Falso	f
1721	509	Sólo dentro del bloque if	t
1722	509	Global	f
1723	509	Dentro de todo el archivo	f
1724	509	Dentro de la función contenedora	f
1725	509	No tiene ámbito	f
1726	510	Se puede usar porque var no está limitado al bloque	t
1727	510	No se puede usar, da error	f
1728	510	La variable se destruye al salir del bloque	f
1729	510	Se convierte en constante	f
1730	510	El valor pasa a null	f
1731	511	number	t
1732	511	string	f
1733	511	undefined	f
1734	511	object	f
1735	511	boolean	f
1896	552	Verdadero	t
1897	552	Falso	f
3560	930	Convierte texto a decimal	f
3561	930	Convierte texto a entero	t
3562	930	Muestra texto	f
3563	930	Suma números	f
3564	930	Convierte a string	f
3565	931	String	t
3566	931	Boolean	f
3567	931	Entero	f
3568	931	Array	f
3569	931	Objeto	f
3570	932	Suma	f
3571	932	Resta	f
3572	932	Multiplicación	f
3573	932	División	t
3574	932	Potencia	f
3575	933	Convierte a texto	f
3576	933	Obtiene parte decimal	f
3577	933	Obtiene parte entera	t
3578	933	Redondea hacia arriba	f
3579	933	Multiplica	f
3580	934	division + entero	f
3581	934	division * entero	f
2984	788	B) Factura	t
2985	788	C) Recibo por honorarios	f
2986	788	D) Guía de remisión	f
2987	788	E) Declaración jurada	f
2988	789	A) Recaudar impuestos y administrar aduanas	t
2989	789	B) Establecer políticas económicas	f
2990	789	C) Gestionar el sistema de salud pública	f
2991	789	D) Dirigir la educación nacional	f
2992	789	E) Regular el mercado laboral	f
2993	790	A) Impuesto a la Renta	f
2994	790	B) Impuesto General a las Ventas (IGV)	f
2995	790	C) Impuesto Predial	t
2996	790	D) Impuesto Selectivo al Consumo	f
2997	790	E) Impuesto a la Importación	f
2998	791	Verdadero	t
2999	791	Falso	f
3582	934	division - entero	t
3583	934	division / entero	f
3584	934	entero - division	f
3585	935	Convierte a número	f
3586	935	Convierte a texto	t
3587	935	Elimina decimales	f
3588	935	Suma valores	f
3589	935	Duplica valor	f
3229	853	Verdadero	t
3230	853	Falso	f
3231	854	Opción 1	t
3232	854	Opción 2	f
3233	854	Opción 3	f
3234	854	Opción 4	f
3235	854	Opción 5	f
3236	855	esta es la respuesta	t
3237	855	esta no es	f
3238	855	esta tampoco	f
3239	855	esta menos	f
3240	855	no hablar	f
3241	856	Esta podria ser la respuesta	f
3242	856	Esta trambien	f
3243	856	Esta si podria	f
3244	856	Esta creo que si	f
3245	856	Esta es la respuesta final	t
3252	860	A. Naruto Uzumaki	t
3253	860	B. Sasuke Uchiha	f
3254	860	C. Sakura Haruno	f
3255	860	D. Kakashi Hatake	f
3256	860	E. Gaara	f
3257	861	A. Aldea Oculta de la Hoja	t
3258	861	B. Aldea Oculta de la Arena	f
3259	861	C. Aldea Oculta de la Nube	f
3260	861	D. Aldea Oculta del Sonido	f
3261	861	E. Aldea Oculta de la Lluvia	f
3262	862	A. Rasengan	t
3263	862	B. Chidori	f
3264	862	C. Amaterasu	f
3265	862	D. Byakugan	f
3266	862	E. Susanoo	f
3267	863	Verdadero	t
3268	863	Falso	f
3269	864	A. Sasuke Uchiha	t
3270	864	B. Shikamaru Nara	f
3271	864	C. Neji Hyuga	f
3272	864	D. Rock Lee	f
3273	864	E. Kakashi Hatake	f
3274	865	A. Hokage	t
3275	865	B. Jonin	f
3276	865	C. Chunin	f
3277	865	D. Genin	f
3278	865	E. Anbu	f
1451	411	TikTok	f
1452	411	Instagram	f
1453	411	Spotify	f
1898	553	Verdadero	t
1899	553	Falso	f
1900	554	Verdadero	t
1901	554	Falso	f
1902	555	Verdadero	t
1903	555	Falso	f
1904	556	Verdadero	t
1905	556	Falso	f
1906	557	Verdadero	t
1907	557	Falso	f
1908	558	Verdadero	f
1909	558	Falso	t
1910	559	Verdadero	t
1911	559	Falso	f
1912	560	Verdadero	f
1913	560	Falso	t
1914	561	Verdadero	f
1915	561	Falso	t
1637	482	Verdadero	t
1638	482	Falso	f
1639	483	Verdadero	t
1640	483	Falso	f
2883	762	A. 1939	t
2884	762	B. 1914	f
2885	762	C. 1945	f
2886	762	D. 1929	f
2887	762	E. 1950	f
2888	763	A. Alemania	f
1094	337	Structured Query Language	f
1095	337	Simple Query Language	f
1096	337	Sequential Query Language	f
1097	337	Standard Question Language	f
1098	337	Sorted Query Language	f
1099	338	SELECT	f
1100	338	RUN	f
1101	338	PRINT	f
1102	338	COPY	f
1103	338	DELETE FILE	f
1104	339	VARCHAR	f
1105	339	INT	f
1106	339	FLOAT	f
1107	339	DATE	f
1108	339	BOOLEAN	f
1109	340	Identificar filas de forma única	f
1110	340	Almacenar datos duplicados	f
1111	340	Organizar columnas	f
1112	340	Definir el tamaño de la tabla	f
1113	340	Garantizar que los datos son obligatorios	f
1114	341	INSERT INTO	f
1115	341	ADD DATA	f
1116	341	CREATE	f
1117	341	UPDATE	f
1118	341	REMOVE	f
1119	342	UPDATE	f
1120	342	MODIFY	f
1121	342	CHANGE	f
1122	342	ALTER	f
1123	342	EDIT	f
1124	343	Filtrar registros	f
1125	343	Ordenar registros	f
1126	343	Agrupar registros	f
1127	343	Seleccionar columnas	f
1128	343	Crear tablas	f
1129	344	Una colección de filas y columnas	f
1130	344	Un tipo de dato especial	f
1131	344	Una instrucción SQL	f
1132	344	Un tipo de índice	f
1133	344	Un servidor de base de datos	f
1134	345	Relacionar tablas	f
1135	345	Clave única para una tabla	f
1136	345	Almacenar grandes datos	f
1137	345	Garantizar valores numéricos	f
1138	345	Aumentar velocidad de búsqueda	f
1139	346	Valor desconocido o vacío	f
1140	346	Número cero	f
1141	346	Cadena vacía	f
1142	346	Valor verdadero	f
1143	346	Valor falso	f
1144	347	Verdadero	t
1145	347	Falso	f
1146	348	Verdadero	f
1147	348	Falso	t
1148	349	Verdadero	t
1149	349	Falso	f
1150	350	Verdadero	f
1151	350	Falso	t
1152	351	Verdadero	f
1153	351	Falso	t
1454	412	A) Un lenguaje de base de datos	f
1455	412	B) Un lenguaje de programación para páginas web	t
1456	412	C) Un sistema operativo	f
1457	412	D) Un navegador web	f
1458	412	E) Un compilador	f
1459	413	A) variable x = 5;	t
1460	413	B) v x = 5;	f
1461	413	C) let x = 5;	f
1462	413	D) int x = 5;	f
1463	413	E) dim x = 5;	f
1464	414	number	t
1465	414	texto	f
1466	414	decimal fijo	f
1467	414	carácter largo	f
1468	414	binario extendido	f
1469	415	A) <!-- -->	f
1470	415	B) ##	f
1471	415	C) //	t
1472	415	D) **	f
1473	415	E) %%	f
1474	416	print()	f
1475	416	console.log()	t
1476	416	echo()	f
1477	416	write()	f
1478	416	show()	f
1479	417	A) =	f
1480	417	B) ==	f
1481	417	C) ===	t
1482	417	D)<>	f
1483	417	E)!=	f
1484	418	A) for	f
1485	418	B) While	f
1486	418	C)if	t
1487	418	D) function	f
1488	418	E) switch-case obligatorio	f
1489	419	A) def miFuncion()	f
1490	419	B) function miFuncion()	t
1491	419	C) func miFuncion()	f
1492	419	D) create miFuncion()	f
1493	419	E) method miFuncion()	f
1494	420	A) var	f
1495	420	B) let	f
1496	420	C) const	t
1497	420	D) static	f
1498	420	E) final	f
1499	421	A) "int"	f
1500	421	B) "number"	t
1501	421	C) "float"	f
1502	421	D) "numeric"	f
1503	421	E) "double"	f
1535	431	Verdadero	t
1536	431	Falso	f
1537	432	Verdadero	t
1538	432	Falso	f
1539	433	Verdadero	f
1540	433	Falso	t
1541	434	Verdadero	t
1542	434	Falso	f
1543	435	Verdadero	t
1544	435	Falso	f
1545	436	Verdadero	f
1546	436	Falso	t
1547	437	Verdadero	t
1548	437	Falso	f
1549	438	Verdadero	t
1550	438	Falso	f
1551	439	Verdadero	t
1552	439	Falso	f
1553	440	Verdadero	t
1554	440	Falso	f
1555	441	Verdadero	t
1556	441	Falso	f
1557	442	Verdadero	f
1558	442	Falso	t
1559	443	Verdadero	t
1560	443	Falso	f
1561	444	Verdadero	t
1562	444	Falso	f
1563	445	Verdadero	t
1564	445	Falso	f
1565	446	Verdadero	f
1566	446	Falso	t
1567	447	Verdadero	t
1568	447	Falso	f
1569	448	Verdadero	t
1570	448	Falso	f
1571	449	Verdadero	t
1572	449	Falso	f
1504	422	a) Me parece perfecto	t
1505	422	b)No realmente	f
1506	422	c)Puede ser mejor	f
1507	422	d)Nada	f
1508	423	me parece perfecto	t
1509	424	ien	f
1510	424	mal	f
1511	424	otro	f
1512	424	sala	f
1513	424	yo	t
1514	425	a	f
1515	425	b	f
1516	425	c	f
1517	425	d	f
1518	425	e	t
1519	426	se	f
1520	426	sa	f
1521	426	te	f
1522	426	ta	f
1523	426	ce	t
1524	427	Verdadero	t
1525	427	Falso	f
1526	428	da	f
2889	763	B. Unión Soviética	t
2890	763	C. Japón	f
2891	763	D. Italia	f
2892	763	E. Francia	f
2893	764	A. Batalla de Midway	f
2894	764	B. Invasión de Normandía	f
2895	764	C. Lanzamiento de las bombas atómicas en Hiroshima y Nagasaki	t
2896	764	D. Conferencia de Yalta	f
2897	764	E. Tratado de Versalles	f
2898	765	A. Winston Churchill	f
2899	765	B. Benito Mussolini	f
2900	765	C. Harry Truman	f
2901	765	D. Adolf Hitler	t
2902	765	E. Joseph Stalin	f
2903	766	Verdadero	t
2904	766	Falso	f
3000	792	Verdadero	t
3001	792	Falso	f
3002	793	Verdadero	f
3003	793	Falso	t
3004	794	Verdadero	t
3005	794	Falso	f
3006	795	Verdadero	f
3007	795	Falso	t
3008	796	Verdadero	t
3009	796	Falso	f
3177	839	Resultqdos de mistrerio	t
3178	839	Resultqdos de mistrerio	t
3179	839	Resultqdos de mistrerio	t
3180	839	Resultqdos de mistrerio	t
3181	839	Resultqdos de mistrerio	t
3182	840	Verdadero	f
3183	840	Falso	t
3590	936	Cuenta caracteres	t
3591	936	Suma números	f
3592	936	Convierte texto	f
3593	936	Divide valores	f
3594	936	Elimina espacios	f
3595	937	Para sumar	f
3596	937	Para eliminar 2 caracteres	t
3597	937	Para dividir	f
3598	937	Para convertir	f
3279	866	Verdadero	f
3280	866	Falso	t
3281	867	A. Equipo 7	t
3282	867	B. Equipo 10	f
3283	867	C. Equipo 8	f
3284	867	D. Equipo 6	f
3285	867	E. Equipo 9	f
3286	868	A. Minato Namikaze	t
3287	868	B. Jiraiya	f
3288	868	C. Orochimaru	f
3289	868	D. Hiruzen Sarutobi	f
3290	868	E. Tobirama Senju	f
3291	869	Verdadero	f
3292	869	Falso	t
3358	889	D. Sasuke Uchiha	f
3359	889	E. Shisui Uchiha	f
3599	937	Para multiplicar	f
3600	938	Divide	f
3601	938	Suma	f
3602	938	Eleva 10 a una potencia	t
3603	938	Convierte a string	f
3604	938	Resta	f
3605	939	Divide	f
3606	939	Convierte decimal a entero	t
3607	939	Suma	f
3608	939	Resta	f
3609	939	Imprime	f
3610	940	Lee datos	f
3611	940	Muestra en pantalla	t
3612	940	Borra datos	f
3613	940	Convierte texto	f
3614	940	Hace cálculos	f
3615	941	2	f
1527	428	ds	f
1528	428	de	f
1529	428	do	f
1530	428	du	t
1531	429	Verdadero	t
1532	429	Falso	f
1573	450	Verdadero	t
1574	450	Falso	f
1575	451	Verdadero	t
1576	451	Falso	f
1617	472	Verdadero	t
1618	472	Falso	f
1619	473	Verdadero	t
1620	473	Falso	f
1621	474	Verdadero	f
1622	474	Falso	t
1623	475	Verdadero	t
1624	475	Falso	f
1625	476	Verdadero	t
1626	476	Falso	f
1627	477	Verdadero	f
1628	477	Falso	t
1629	478	Verdadero	t
1630	478	Falso	f
1631	479	Verdadero	f
1632	479	Falso	t
1633	480	Verdadero	t
1634	480	Falso	f
1635	481	Verdadero	f
1636	481	Falso	t
3616	941	4	f
3617	941	5	f
3618	941	10	f
1641	484	Verdadero	t
1642	484	Falso	f
1643	485	Verdadero	f
1644	485	Falso	t
1645	486	Verdadero	t
1646	486	Falso	f
1647	487	Verdadero	f
1648	487	Falso	t
1649	488	Verdadero	t
1650	488	Falso	f
1651	489	Verdadero	t
1652	489	Falso	f
1653	490	Verdadero	f
1654	490	Falso	t
1655	491	Verdadero	t
1656	491	Falso	f
1816	532	Es gratuito	f
1817	532	Permite estudiar, modificar y distribuir el código	t
1818	532	Solo funciona en Linux	f
1819	532	Es propiedad de empresas	f
1820	533	Menor velocidad	f
1821	533	Mayor costo	f
1822	533	Auditoría del código	t
1823	533	Uso limitado	f
1824	534	Restricción de acceso	f
1825	534	Innovación colaborativa	t
1826	534	Dependencia tecnológica	f
1827	534	Uso individual	f
1828	535	Bajo rendimiento siempre	f
1829	535	Fragmentación del ecosistema	t
1830	535	Falta de usuarios	f
1831	535	Alto costo obligatorio	f
1832	536	Tener un solo sistema	f
1833	536	Muchas distribuciones diferentes	t
1834	536	Falta de internet	f
1835	536	Software cerrado	f
1836	537	Mejora el soporte	f
1837	537	Facilita la interoperabilidad	f
1838	537	Dificulta la estandarización	t
1839	537	Reduce opciones	f
1840	538	Un sistema operativo gratuito sin soporte	f
1841	538	Una empresa que vende hardware	f
1842	538	Una empresa que ofrece soluciones de software libre con soporte	t
1843	538	Un lenguaje de programación	f
1844	539	Venta de licencias	f
1845	539	Suscripciones y soporte	t
1846	539	Publicidad	f
1847	539	Donaciones únicamente	f
1848	540	Solo software	f
1849	540	Juegos	f
1850	540	Soporte técnico y actualizaciones	t
1851	540	Hardware	f
1852	541	Por moda	f
1853	541	Para reducir costos e independencia tecnológica	t
1854	541	Por falta de software propietario	f
1855	541	Por seguridad baja	f
1856	542	Un lenguaje	f
1857	542	Un sistema operativo propietario	f
1858	542	Proyecto de migración a Linux en Múnich	t
1859	542	Una empresa	f
1860	543	Más dependencia	f
1861	543	Mayor costo	f
1862	543	Ahorro y control tecnológico	t
1863	543	Menos seguridad	f
1864	544	Prohibió Linux	f
1865	544	Adoptó software libre en educación	t
1866	544	Solo usó Windows	f
1867	544	Cerró escuelas	f
1868	545	Menos aprendizaje	f
1869	545	Mejora de competencias digitales	t
1870	545	Aumento de costos	f
1871	545	Menor acceso	f
1872	546	Exceso de dinero	f
1873	546	Dependencia de pocos desarrolladores	t
1874	546	Demasiados usuarios	f
1875	546	Falta de internet	f
1876	547	Menos usuarios	f
1877	547	Financiamiento y comunidad	t
1878	547	Cerrar el código	f
1879	547	Reducir colaboración	f
1880	548	Mayor compatibilidad	f
1881	548	Mejor comunicación	f
1882	548	Dificultan el intercambio de documentos	t
1883	548	Reducen costos	f
1884	549	Software propietario	f
1885	549	Estándares abiertos (ODF)	t
1886	549	Menos usuarios	f
1887	549	Más restricciones	f
1888	550	Excel	f
1889	550	GitHub	t
1890	550	Word	f
1891	550	Paint	f
1892	551	Clean Code	f
1893	551	The Cathedral and the Bazaar	t
1894	551	Windows Guide	f
1895	551	Linux Manual	f
3619	941	20	t
3620	942	Funciona normal	f
3621	942	Error o infinito	f
3622	942	Devuelve 0	t
3623	942	Devuelve 1	f
3624	942	Se detiene el programa	f
3625	943	Suma	f
3626	943	Muestra alert si num2=0	t
3627	943	Convierte texto	f
3628	943	Multiplica	f
3629	943	No hace nada	f
3630	944	Asignación	f
3631	944	Comparación	t
3632	944	Suma	f
3633	944	División	f
3634	944	Potencia	f
3635	945	Minúsculas	f
3636	945	Mayúsculas	t
3637	945	Números	f
3638	945	Borra texto	f
3639	945	Invierte texto	f
3640	946	Mayúsculas	f
3641	946	Minúsculas	t
3642	946	Elimina texto	f
3643	946	Duplica texto	f
3644	946	Divide texto	f
3645	947	Suma	f
3646	947	Compara si valor es mayor que 10	t
3647	947	Divide	f
3648	947	Convierte	f
3649	947	Imprime	f
3650	948	for	f
3651	948	while	f
3652	948	if	t
3653	948	var	f
3654	948	function	f
3655	949	Ejecuta código	f
3656	949	Declara variables	t
3657	949	Imprime	f
3658	949	Compara	f
3659	949	Convierte	f
3762	971	A) 1879	t
3763	971	B) 1885	f
3764	971	C) 1865	f
3765	971	D) 1890	f
3766	971	E) 1900	f
3660	950	Verdadero	t
3661	950	Falso	f
3767	972	A) Guano y salitre	t
3768	972	B) Oro y plata	f
3769	972	C) Petróleo	f
3770	972	D) Trigo	f
3771	972	E) Algodón	f
3772	973	A) Bolivia	t
3773	973	B) Perú	f
3774	973	C) Argentina	f
3775	973	D) Ecuador	f
3776	973	E) Brasil	f
3777	974	A) Batalla de Arica	t
3778	974	B) Batalla de Ayacucho	f
3779	974	C) Batalla de Trafalgar	f
3780	974	D) Batalla de Junín	f
3781	974	E) Batalla de Waterloo	f
3782	975	A) Tratado de Ancón	t
3783	975	B) Tratado de Tordesillas	f
3784	975	C) Tratado de Versalles	f
3785	975	D) Tratado de París	f
3786	975	E) Tratado de Guadalupe Hidalgo	f
3980	1031	Limpiar la casa	f
3981	1032	Johnny Lawrence	t
3982	1032	Tommy	f
3983	1032	Bobby	f
3984	1032	Daniel LaRusso	f
3985	1032	Chozen	f
3986	1033	Su hermana	f
3987	1033	Su novia	t
3988	1033	Su enemiga	f
3989	1033	Su entrenadora	f
3990	1033	No tiene relación	f
3991	1034	Pierde en la final	f
3992	1034	Gana con un movimiento sorpresa	t
3993	1034	Empata	f
3994	1034	Es descalificado	f
3995	1034	Gana por decisión unánime	f
3996	1035	Un amuleto	f
3997	1035	Un cinturón negro	f
3998	1035	Ningún objeto especial	t
3999	1035	Un casco	f
4000	1035	Guantes de karate	f
2416	662	Verdadero	t
2417	662	Falso	f
2418	663	Verdadero	t
2419	663	Falso	f
2420	664	Verdadero	f
2421	664	Falso	t
2422	665	Verdadero	t
2423	665	Falso	f
2424	666	Verdadero	t
2425	666	Falso	f
2426	667	Verdadero	f
2427	667	Falso	t
2428	668	Verdadero	t
2429	668	Falso	f
2430	669	Verdadero	t
2431	669	Falso	f
2432	670	Verdadero	f
2433	670	Falso	t
2434	671	Verdadero	f
2435	671	Falso	t
2436	672	variable x = 5	f
2437	672	var x = 5	t
2438	672	int x = 5	f
2439	672	declare x = 5	f
2440	672	v x = 5	f
2441	673	var	f
2442	673	const	f
2443	673	let	t
2444	673	static	f
2445	673	define	f
2446	674	let nombre = "Juan"	f
2447	674	var edad = 20	f
2448	674	const PI = 3.14	f
2449	674	int numero = 10	t
2450	674	let x	f
2451	675	Se puede modificar libremente	f
2452	675	No necesita valor inicial	f
2453	675	No puede cambiar su valor	f
2454	675	Se convierte en global	t
2455	675	Es temporal	f
2456	676	null	f
2457	676	undefined	t
2458	676	string	f
2459	676	number	f
2460	676	boolean	f
2461	677	let	f
2462	677	const	t
2463	677	var	f
2464	677	static	f
2465	677	private	f
2466	678	1variable	f
2467	678	var	f
2468	678	_nombre	f
2469	678	nombre-variable	t
2470	678	nombre variable	f
2471	679	Solo números	f
2472	679	Solo texto	f
2473	679	Tipado estático	f
2474	679	Tipado dinámico	t
2475	679	Tipado fijo	f
2476	680	let PI = 3.14	f
2477	680	const PI = 3.14	t
2478	680	var PI	f
2479	680	constant PI = 3.14	f
2480	680	define PI = 3.14	f
2481	681	Funciona normal	f
2482	681	Se ignora	f
2483	681	Error	f
2484	681	Se sobreescribe	t
2485	681	Se vuelve global	f
2486	682	Facilitar el proceso Scrum y eliminar impedimentos	f
2487	682	Gestionar el backlog del producto	f
2488	682	Dirigir a los desarrolladores	f
2489	682	Tomar decisiones del proyecto	f
2490	682	Realizar pruebas de calidad	f
2491	683	Sprint Backlog	f
2492	683	Product Backlog	f
2493	683	Incremento	f
2494	683	Definition of Done	f
2495	683	Burn-down Chart	f
2496	684	Cada 2 a 4 semanas	f
2497	684	Cada 6 meses	f
2498	684	Cada día	f
2499	684	Cada año	f
2500	684	Cada 3 a 5 días	f
2501	685	Product Owner	f
2502	685	Scrum Master	f
2503	685	Equipo de desarrollo	f
2504	685	Project Manager	f
2505	685	Stakeholders	f
2506	686	Sprint Review	f
2507	686	Sprint Planning	f
2508	686	Daily Scrum	f
2509	686	Sprint Retrospective	f
2510	686	Backlog Grooming	f
2511	687	15 minutos	f
2512	687	1 hora	f
2513	687	30 minutos	f
2514	687	45 minutos	f
2515	687	10 minutos	f
2516	688	Incremento	f
2517	688	Product Backlog	f
2518	688	Sprint Backlog	f
2519	688	Definition of Ready	f
2520	688	Epic	f
2521	689	Mejorar el proceso y la forma de trabajar del equipo	f
2522	689	Revisar el producto entregado	f
2523	689	Planificar el siguiente sprint	f
2524	689	Actualizar el Product Backlog	f
2525	689	Presentar el trabajo a los stakeholders	f
2526	690	Equipo Scrum completo (Product Owner, Scrum Master, Desarrolladores)	f
2527	690	Solo el Scrum Master	f
2528	690	Solo el Product Owner	f
2529	690	Stakeholders	f
2530	690	Equipo de desarrollo y stakeholders	f
2531	691	Multidisciplinario y autoorganizado	f
2532	691	Jerárquico y supervisado	f
2533	691	Solo desarrolladores	f
2534	691	Externamente gestionado	f
2535	691	Temporario y rotativo	f
2536	692	Tiene una duración fija que no se debe extender	f
2537	692	Puede alargarse según el trabajo requerido	f
2538	692	No tiene límite de tiempo	f
2539	692	Solo dura un día	f
2540	692	Se repite hasta concluir el trabajo	f
2541	693	Conjunto de criterios que debe cumplir el trabajo para considerarse completado	f
2542	693	Lista de tareas pendientes	f
2543	693	Protocolo para iniciar un sprint	f
2544	693	Plan de proyecto	f
2545	693	Documento de requisitos	f
2546	694	Durante la Sprint Planning	f
2547	694	Al inicio del proyecto	f
2548	694	Al final del Sprint	f
2549	694	Durante la Sprint Review	f
2550	694	Cuando termina el proyecto	f
2551	695	Daily Scrum	f
2552	695	Sprint Review	f
2553	695	Sprint Planning	f
2554	695	Sprint Retrospective	f
2555	695	Product Backlog Refinement	f
2556	696	Escribir código del software	f
2557	696	Gestionar el Product Backlog	f
2558	696	Priorizar las historias de usuario	f
2559	696	Comunicar con stakeholders	f
2560	696	Maximizar el valor del producto	f
2561	697	Basado en la experiencia y la observación continua	f
2562	697	Basado exclusivamente en la planificación inicial	f
2563	697	Que requiere documentación extensa antes de empezar	f
2564	697	Que no necesita adaptaciones	f
2565	697	Que sigue un proceso secuencial rígido	f
2566	698	Clarificar, descomponer y priorizar elementos del backlog	f
2567	698	Realizar la entrega final del producto	f
2568	698	Evaluar el desempeño del equipo	f
2569	698	Detallar el plan de marketing	f
2570	698	Cambiar la duración del sprint	f
2571	699	Revisar el incremento de producto y obtener retroalimentación	f
2572	699	Planificar tareas diarias	f
2573	699	Medir la velocidad del equipo	f
2574	699	Actualizar el Definition of Done	f
2575	699	Evaluar la satisfacción del cliente	f
2576	700	Equipo de Desarrollo	f
2577	700	Scrum Master	f
2578	700	Product Owner	f
2579	700	Gerencia	f
2580	700	Stakeholders	f
2581	701	Cualquier obstáculo que impide el progreso del equipo	f
2582	701	Una tarea priorizada del Product Backlog	f
2583	701	Un tipo de reunión Scrum	f
2584	701	Un entregable del proyecto	f
2585	701	Una herramienta para planificación	f
2586	702	A) Scrum Master	f
2587	702	B) Product Owner	f
2588	702	C) Development Team	f
2589	702	D) Stakeholder	f
2590	702	E) Project Manager	f
2591	703	1879	f
2592	703	1884	f
2593	703	1866	f
2594	703	1890	f
2595	703	1902	f
2596	704	Guerra del Pacífico	f
2597	704	Guerra civil española	f
2598	704	Primera Guerra Mundial	f
2599	704	Guerra de los Cien Años	f
2600	704	Guerra de Secesión	f
2601	705	Ultraman Hayata	t
2602	705	Ultraman Taro	f
2603	705	Ultraman Leo	f
2604	705	Ultraman Jack	f
2605	705	Ultraman Zero	f
2606	706	A) Berlín	f
2607	706	B) Madrid	f
2608	706	C) París	f
2609	706	D) Roma	f
2610	706	E) Lisboa	f
2611	707	Un personaje de una serie de ciencia ficción japonesa	f
2612	707	Una banda de música pop	f
2613	707	Una película de terror	f
2614	707	Un videojuego de estrategia	f
2615	707	Un libro de aventuras	f
2616	708	Shin Hayata	t
2617	708	Takeshi Hongo	f
2618	708	Kamen Rider	f
2619	708	Ultraseven	f
2620	708	Daigo Madoka	f
2621	709	A. Shin Hayata	t
2622	709	B. Kenzo Tomioka	f
2623	709	C. Takuya Yamano	f
2624	709	D. Hikaru Raido	f
2625	709	E. Daigo Madoka	f
2626	710	A. Shin Hayata	t
2627	710	B. Kenzo Tomioka	f
2628	710	C. Takuya Yamano	f
2629	710	D. Hikaru Raido	f
2630	710	E. Daigo Madoka	f
2631	711	A. Shin Hayata	t
2632	711	B. Dan Moroboshi	f
2633	711	C. Seiji Hokuto	f
2634	711	D. Hideki Goh	f
2635	711	E. Saburo Shinagawa	f
3662	951	Un programa ejecutable	f
3663	951	Un tipo de hardware	f
3664	951	Un contrato entre desarrollador y usuario	t
3665	951	Un lenguaje de programación	f
3666	951	Un sistema operativo	f
3667	952	El usuario final	f
3668	952	El gobierno	f
3669	952	El desarrollador o propietario de derechos	t
3670	952	El sistema operativo	f
3671	952	Internet	f
3672	953	El código fuente	f
3293	870	Verdadero	t
3294	870	Falso	f
3295	871	Verdadero	f
3296	871	Falso	t
3297	872	Verdadero	t
3298	872	Falso	f
3299	873	Verdadero	f
3300	873	Falso	t
3301	874	Verdadero	t
3302	874	Falso	f
3303	875	A. Pain	f
3304	875	B. Obito Uchiha	f
3305	875	C. Madara Uchiha	t
3306	875	D. Kisame Hoshigaki	f
3307	875	E. Zetsu	f
3308	876	A. Tsukuyomi	t
3309	876	B. Chidori	f
3310	876	C. Rasengan	f
3673	953	Un producto o invención explotable	t
3674	953	El sistema operativo	f
3675	953	El hardware	f
3676	953	Los usuarios	f
3677	954	Solo software	f
3678	954	Solo música	f
3679	954	Obras originales (literarias, artísticas, etc.)	t
3680	954	Solo hardware	f
3681	954	Solo videojuegos	f
3682	955	Solo usar el programa	f
3683	955	Solo modificarlo	f
3684	955	Usar, estudiar, modificar y redistribuir	t
3685	955	Solo venderlo	f
3686	955	Solo copiarlo	f
3687	956	Ejecutar el programa	f
3688	956	Estudiarlo	f
3689	956	Modificarlo	f
3690	956	Prohibir su uso	t
3691	956	Redistribuirlo	f
3090	817	Es gratuito	f
3091	817	Permite estudiar, modificar y distribuir el código	t
3092	817	Solo funciona en Linux	f
3093	817	Es propiedad de empresas	f
3094	818	Menor velocidad	f
3095	818	Mayor costo	f
3096	818	Auditoría del código	t
3097	818	Uso limitado	f
3098	819	Restricción de acceso	f
3099	819	Innovación colaborativa	t
3100	819	Dependencia tecnológica	f
3101	819	Uso individual	f
3102	820	Bajo rendimiento siempre	f
3103	820	Fragmentación del ecosistema	t
3104	820	Falta de usuarios	f
3105	820	Alto costo obligatorio	f
3106	821	Tener un solo sistema	f
3107	821	Muchas distribuciones diferentes	t
3108	821	Falta de internet	f
3109	821	Software cerrado	f
3110	822	Mejora el soporte	f
3111	822	Facilita la interoperabilidad	f
3112	822	Dificulta la estandarización	t
3113	822	Reduce opciones	f
3114	823	Un sistema operativo gratuito sin soporte	f
3115	823	Una empresa que vende hardware	f
3116	823	Una empresa que ofrece soluciones de software libre con soporte	t
3117	823	Un lenguaje de programación	f
3118	824	Venta de licencias	f
3119	824	Suscripciones y soporte	t
3120	824	Publicidad	f
3121	824	Donaciones únicamente	f
3122	825	Solo software	f
3123	825	Juegos	f
3124	825	Soporte técnico y actualizaciones	t
3125	825	Hardware	f
3126	826	Por moda	f
3127	826	Para reducir costos e independencia tecnológica	t
3128	826	Por falta de software propietario	f
3129	826	Por seguridad baja	f
3130	827	Un lenguaje	f
3131	827	Un sistema operativo propietario	f
3132	827	Proyecto de migración a Linux en Múnich	t
3133	827	Una empresa	f
3134	828	Más dependencia	f
3135	828	Mayor costo	f
3136	828	Ahorro y control tecnológico	t
3137	828	Menos seguridad	f
3138	829	Prohibió Linux	f
3139	829	Adoptó software libre en educación	t
3140	829	Solo usó Windows	f
3141	829	Cerró escuelas	f
3142	830	Menos aprendizaje	f
3143	830	Mejora de competencias digitales	t
3144	830	Aumento de costos	f
3145	830	Menor acceso	f
2736	732	A) GPL	t
2737	732	B) EULA	f
2738	732	C) NDA	f
2739	732	D) MIT	f
2740	732	E) Apache	f
2741	733	A) Código cerrado	f
2742	733	B) Sólo disponible para servidor	f
2743	733	C) Acceso al código fuente	t
2744	733	D) Pago obligatorio para usar	f
2745	733	E) Sólo se puede modificar por el creador	f
2746	734	A) Prohibir la redistribución	f
2747	734	B) Permitir cambiar el código sin compartir modificaciones	f
2748	734	C) Mantener la libertad de distribuir copias y versiones modificadas	t
2749	734	D) Uso comercial sin restricciones	f
2750	734	E) El software es obligatorio para uso público	f
2751	735	A) Software que se distribuye sólo para educación	f
2752	735	B) Software que es gratuito y se puede usar sin restricciones	f
2753	735	C) Software que permite usar, estudiar, modificar y distribuir libremente	t
2754	735	D) Software exclusivo para desarrolladores certificados	f
2755	735	E) Software que sólo funciona en sistemas operativos libres	f
2756	736	A) Microsoft Word	f
2757	736	B) Adobe Photoshop	f
2758	736	C) Linux	t
2759	736	D) Windows 10	f
2760	736	E) MacOS	f
2761	737	A) FSF (Free Software Foundation)	t
2762	737	B) IEEE	f
2763	737	C) ISO	f
2764	737	D) W3C	f
2765	737	E) IETF	f
2766	738	A) Software siempre gratuito	f
2767	738	B) Acceso y control sobre su software	t
2768	738	C) Garantía de soporte técnico oficial	f
2769	738	D) Software solo para uso personal	f
2770	738	E) Actualizaciones automáticas pagadas	f
2771	739	A) Usar el software para cualquier propósito	f
2772	739	B) Estudiar cómo funciona y adaptarlo	f
3146	831	Exceso de dinero	f
3147	831	Dependencia de pocos desarrolladores	t
3148	831	Demasiados usuarios	f
3149	831	Falta de internet	f
3150	832	Menos usuarios	f
3151	832	Financiamiento y comunidad	t
3152	832	Cerrar el código	f
3153	832	Reducir colaboración	f
3154	833	Mayor compatibilidad	f
3155	833	Mejor comunicación	f
3156	833	Dificultan el intercambio de documentos	t
3692	957	Es siempre de pago	f
2773	739	C) Copiar y distribuir copias	f
2774	739	D) Vender copias modificadas	f
2775	739	E) Recibir soporte técnico oficial pagado	t
2776	740	A) Liderar el equipo de desarrollo técnicamente	f
2777	740	B) Asignar tareas a los miembros del equipo	f
2778	740	C) Facilitar el proceso Scrum y eliminar impedimentos	t
2779	740	D) Definir los requerimientos del producto	f
2780	740	E) Aprobador final de entregas	f
2781	741	A) Una reunión diaria	f
2782	741	B) Periodo fijo para desarrollar un conjunto de tareas	t
2783	741	C) Documento con requisitos	f
2784	741	D) Prueba final antes de liberar el producto	f
2785	741	E) Herramienta para seguimiento de errores	f
2786	742	A) El trabajo realizado en el Sprint para recibir feedback	t
2787	742	B) El plan del siguiente Sprint	f
2788	742	C) El presupuesto del proyecto	f
2789	742	D) La lista de impedimentos	f
2790	742	E) Revisión de documentación	f
2791	743	A) Scrum Master	f
2792	743	B) Product Owner	t
2793	743	C) Equipo de desarrollo	f
2794	743	D) Stakeholders	f
2795	743	E) Cliente externo	f
2796	744	A) La planificación del Sprint	f
2797	744	B) Una reunión diaria de 15 minutos para coordinación	t
2798	744	C) Revisión mensual del proyecto	f
2799	744	D) Reunión de cierre del Sprint	f
2800	744	E) Reunión con el cliente	f
2801	745	A) Mostrar el producto al cliente	f
2802	745	B) Planificar el próximo Sprint	f
2803	745	C) Evaluar y mejorar el proceso de trabajo	t
2804	745	D) Asignar nuevas tareas	f
2805	745	E) Actualizar el Product Backlog	f
2806	746	A) Descargar la imagen ISO de Ubuntu	t
2807	746	B) Configurar el BIOS para Windows	f
2808	746	C) Crear una cuenta en Ubuntu.com	f
2809	746	D) Instalar controladores	f
2810	746	E) Formatear el disco duro desde Windows	f
2811	747	A) Tener conexión a internet durante la instalación	f
2812	747	B) Un USB con suficiente espacio y una herramienta para grabar la ISO	t
2813	747	C) Un disco DVD original de Ubuntu	f
2814	747	D) Permisos de administrador en Ubuntu	f
2815	747	E) Tener Windows instaldo previamente	f
2816	748	A) 'Actualizar Ubuntu'	f
2817	748	B) 'Reparar el sistema'	f
2818	748	C) 'Instalar junto a otros sistemas operativos' o 'Borrar disco e instalar'	t
2819	748	D) 'Configurar red'	f
2820	748	E) 'Instalar paquetes adicionales'	f
2821	749	A) KDE Plasma	f
2822	749	B) XFCE	f
2823	749	C) GNOME	t
2824	749	D) LXDE	f
2825	749	E) Cinnamon	f
2826	750	A) Para actualizar el BIOS	f
2827	750	B) Para instalar actualizaciones y parches del sistema operativo	t
2828	750	C) Para descargar juegos	f
2829	750	D) Para cambiar la contraseña de usuario	f
2830	750	E) Para crear una copia de seguridad	f
2831	751	A) Descargar otro sistema operativo	f
2832	751	B) Cambiar el orden de booteo en BIOS/UEFI	t
2833	751	C) Instalar Windows primero	f
2834	751	D) Borrar el USB completamente	f
2835	751	E) Reiniciar el equipo varias veces	f
3157	833	Reducen costos	f
3158	834	Software propietario	f
3159	834	Estándares abiertos (ODF)	t
3160	834	Menos usuarios	f
3161	834	Más restricciones	f
3162	835	Excel	f
3163	835	GitHub	t
3164	835	Word	f
3165	835	Paint	f
3166	836	Clean Code	f
3167	836	The Cathedral and the Bazaar	t
3168	836	Windows Guide	f
3169	836	Linux Manual	f
3311	876	D. Amaterasu	f
3312	876	E. Susanoo	f
3313	877	A. Raiton	t
3314	877	B. Futton	f
3315	877	C. Suiton	f
3316	877	D. Katon	f
3317	877	E. Doton	f
3318	878	A. Jiraiya	f
3319	878	B. Minato Namikaze	t
3320	878	C. Kakashi	f
3321	878	D. Orochimaru	f
3322	878	E. Tsunade	f
3323	879	A. Madara Uchiha	f
3324	879	B. Obito Uchiha	t
3325	879	C. Sasuke Uchiha	f
3326	879	D. Nagato	f
3327	879	E. Zetsu	f
3328	880	Verdadero	t
3329	880	Falso	f
3330	881	Verdadero	t
3331	881	Falso	f
3332	882	Verdadero	f
3333	882	Falso	t
3334	883	Verdadero	t
3335	883	Falso	f
3336	884	A. Genin	f
3337	884	B. Chunin	f
3338	884	C. Jonin	f
3339	884	D. Hokage	t
3340	884	E. Anbu	f
3341	885	A. Clan Uchiha	f
3342	885	B. Clan Senju	f
3343	885	C. Clan Uzumaki	t
3344	885	D. Clan Hyuga	f
3345	885	E. Clan Aburame	f
3346	886	A. Edo Tensei	f
3347	886	B. Fushi Tensei	t
3348	886	C. Kuchiyose	f
3349	886	D. Izanagi	f
3350	886	E. Reincarnation Jutsu	f
3351	887	Verdadero	t
3352	887	Falso	f
3353	888	Verdadero	f
3354	888	Falso	t
3355	889	A. Indra Otsutsuki	t
3356	889	B. Madara Uchiha	f
3357	889	C. Itachi Uchiha	f
3693	957	No permite modificaciones	f
3694	957	Cumple criterios de distribución libre y acceso al código	t
3695	957	Es privado	f
3696	957	No tiene código fuente	f
3697	958	Solo empresas pueden usarlo	f
3698	958	Nadie puede usarlo	f
3699	958	Cualquier persona o grupo puede usarlo	t
3700	958	Solo estudiantes	f
3701	958	Solo gobiernos	f
3702	959	Restricciones	f
3703	959	Uso exclusivo	f
3704	959	Interoperabilidad y acceso	t
3705	959	Software cerrado	f
3706	959	Pago obligatorio	f
3707	960	Tiene copyright	f
3708	960	No puede usarse	f
3709	960	No está protegido por copyright	t
3710	960	Es ilegal	f
3711	960	Es privado	f
3712	961	Prohibición de uso	f
3713	961	Permite agregar restricciones	f
3714	961	Obliga a mantener el software libre en versiones derivadas	t
3715	961	Es software propietario	f
3716	961	Es hardware	f
3717	962	Uso comercial libre	f
3718	962	Uso sin restricciones	f
3719	962	Uso sin fines de lucro	t
3720	962	Solo modificar	f
3721	962	Solo vender	f
3722	963	Software modificable	f
3723	963	Software con código abierto	f
3724	963	Software gratis pero sin modificar	t
3725	963	Software ilegal	f
3726	963	Software comercial	f
3727	964	Es completamente libre	f
3728	964	Nunca se paga	f
3729	964	Se puede probar pero requiere pago continuo	t
3730	964	No se distribuye	f
3731	964	No se usa	f
3732	965	Es libre	f
3733	965	Permite todo	f
3734	965	Tiene restricciones de uso/modificación	t
3735	965	Es público	f
3736	965	No tiene dueño	f
3737	966	No genera dinero	f
3738	966	Es siempre libre	f
3739	966	Busca obtener ganancias	t
3740	966	No tiene licencia	f
3741	966	Es ilegal	f
3742	967	El software debe venderse	f
3743	967	El software es conocimiento y debe ser libre	t
3744	967	No debe compartirse	f
3745	967	Solo empresas lo usan	f
3746	967	Es privado	f
3747	968	Filosofía únicamente	f
3748	968	Beneficios técnicos y económicos	t
3749	968	Prohibir uso	f
3750	968	Eliminar software	f
3751	968	Evitar innovación	f
3752	969	Hacer el software privado	f
3753	969	Cobrar siempre	f
3754	969	Mantener las versiones derivadas como libres	t
3755	969	No distribuir	f
3756	969	No modificar	f
3757	970	Solo uso privado	f
3758	970	No modificar	f
3460	910	 head>	t
3461	910	 top>	f
3462	910	 header>	f
3463	910	 section>	f
3464	910	 nav>	f
3465	911	padding	f
3466	911	margin	t
3467	911	border	f
3468	911	width	f
3469	911	display	f
3470	912	position:flex	f
3471	912	flex-direction	f
3472	912	display:flex	t
3473	912	align:flex	f
3474	912	justify:flex	f
3475	913	align-items	f
3476	913	justify-content: space-around	f
3477	913	flex-wrap	f
3478	913	margin:auto	t
3479	913	padding	f
3480	914	justify-content	f
3481	914	align-items	f
3482	914	text-align	t
3483	914	line-height	f
3484	914	display	f
3485	915	#	f
3486	915	.	t
3487	915	*	f
3488	915	@	f
3489	915	&	f
3490	916	.	f
3491	916	#	t
3492	916	*	f
3493	916	$	f
3494	916	%	f
3495	917	color	f
3496	917	background	f
3497	917	background-color	f
3498	917	fill	f
3499	917	B y C	t
3500	918	border	f
3501	918	border-radius	t
3502	918	shape	f
3503	918	circle	f
3504	918	radius	f
3505	919	width	f
3506	919	size	f
3507	919	height	t
3508	919	padding	f
3509	919	margin	f
3510	920	align-items	f
3511	920	justify-content	f
3512	920	text-align	t
3513	920	margin	f
3514	920	padding	f
3515	921	margin	f
3516	921	padding	t
3517	921	border	f
3518	921	width	f
3519	921	height	f
3520	922	outline	f
3521	922	border	t
3522	922	line	f
3523	922	edge	f
3524	922	stroke	f
3525	923	block	f
3526	923	inline	f
3527	923	grid	f
3528	923	flex	t
3529	923	none	f
3530	924	100%	f
3531	924	25%	f
3532	924	75%	f
3533	924	50%	t
3534	924	10%	f
3535	925	padding	f
3536	925	line-height	t
3537	925	margin	f
3538	925	align-items	f
3539	925	display	f
3540	926	article>	f
3541	926	header>	f
3542	926	section>	f
3543	926	footer>	f
3544	926	todas	t
3545	927	3	f
3546	927	4	f
3547	927	5	f
3548	927	6	t
3549	927	2	f
3550	928	display:flex	t
3551	928	float	f
3552	928	position	f
3553	928	grid	f
3554	928	inline	f
3555	929	bottom>	f
3556	929	end>	f
3557	929	footer>	t
3558	929	section>	f
3559	929	div>	f
3759	970	Usar el código incluso en software propietario	t
3760	970	Prohibir distribución	f
3761	970	Solo educación	f
3787	976	Un programa de diseño gráfico	f
3788	976	Un conjunto organizado de datos accesible electrónicamente	t
3789	976	Un sistema operativo	f
3790	976	Un lenguaje de programación	f
3791	977	HTML	f
3792	977	CSS	f
3793	977	Relacional	t
3794	977	API	f
3795	978	Datos no estructurados	f
3796	978	Esquema flexible	f
3797	978	Tablas con filas y columnas	t
3798	978	Uso exclusivo en móviles	f
3799	979	Esquema rígido	f
3800	979	Escalabilidad horizontal	t
3801	979	Solo funciona en local	f
3802	979	No permite JSON	f
3803	980	Costos elevados	f
3804	980	Restricción de uso	f
3805	980	Código cerrado	f
3806	980	Bajo costo y libertad de uso	t
3807	981	PostgreSQL	f
3808	981	MySQL	f
3809	981	MongoDB	t
3810	981	SQL Server	f
3811	982	No soporta transacciones	f
3812	982	SQL avanzado y ACID	t
3813	982	Solo funciona en web	f
3814	982	No permite extensiones	f
3815	983	Solo básica	f
3816	983	GIN y GiST	t
3817	983	XML	f
3818	983	CSS	f
3819	984	Es propietario	f
3820	984	Menor rendimiento	f
3821	984	Código abierto y comunidad	t
3822	984	No es compatible	f
3823	985	Requiere servidor	f
3824	985	Es pesado	f
3825	985	Solo en la nube	f
3826	985	Ligero y embebido	t
3827	986	Apps simples	f
3828	986	Juegos	f
3829	986	Aplicaciones complejas	t
3830	986	Solo móviles	f
3831	987	Notepad	f
3832	987	DBeaver	t
3833	987	Excel	f
3834	987	Paint	f
3835	988	phpMyAdmin	f
3836	988	PgAdmin	t
3837	988	Word	f
3838	988	Chrome	f
3839	989	Editar imágenes	f
3840	989	Administrar MySQL/MariaDB	t
3841	989	Programar en Java	f
3842	989	Crear videos	f
3843	990	Por costo alto	f
3844	990	Por ser privada	f
3845	990	Por rendimiento y código abierto	t
3846	990	Por falta de opciones	f
3847	991	Solo almacenamiento	f
3848	991	Manejo de millones de tiendas	t
3849	991	Diseño gráfico	f
3850	991	Edición de videos	f
3851	992	Solo texto	f
3852	992	No escala	f
3853	992	Manejo de datos estructurados y JSON	t
3854	992	Uso offline	f
3855	993	sudo install db	f
3856	993	apt run postgres	f
3857	993	sudo apt install postgresql	t
3858	993	run sql	f
3859	994	Usar contraseñas débiles	f
3860	994	No hacer backups	f
3861	994	Usar privilegios máximos	f
3862	994	Aplicar mínimos privilegios	t
3863	995	Desactivar logs	f
3864	995	No usar cifrado	f
3865	995	Plugin pgaudit	t
3866	995	Eliminar usuarios	f
3889	1007	Verdadero	t
3890	1007	Falso	f
3891	1008	Verdadero	f
3892	1008	Falso	t
3893	1009	Verdadero	t
3894	1009	Falso	f
3895	1010	Verdadero	f
3896	1010	Falso	t
3897	1011	Verdadero	t
3898	1011	Falso	f
3899	1012	Verdadero	f
3900	1012	Falso	t
3901	1013	Verdadero	t
3902	1013	Falso	f
3903	1014	Verdadero	f
3904	1014	Falso	t
3905	1015	Verdadero	t
3906	1015	Falso	f
3907	1016	Verdadero	f
3908	1016	Falso	t
3909	1017	Verdadero	t
3910	1017	Falso	f
3956	1027	Los Ángeles	t
3957	1027	San Diego	f
3958	1027	San Francisco	f
3959	1027	Nueva York	f
3960	1027	Chicago	f
3961	1028	La fuerza bruta vence siempre	f
3962	1028	La paciencia y el equilibrio son clave	t
3963	1028	Ganar a toda costa	f
3964	1028	Solo importa la técnica	f
3965	1028	El combate es cuestión de suerte	f
3966	1029	Mr. Miyagi	t
3967	1029	Sr. Han	f
3968	1029	Mr. Lee	f
3969	1029	Sensei Kreese	f
3970	1029	Sr. Fuji	f
3971	1030	Crane Kick	t
3972	1030	Crane Technique	f
3973	1030	Crane Block	f
3974	1030	Crane Style	f
3975	1030	Crane Form	f
3976	1031	Lavar el auto	f
3977	1031	Pintar la cerca	f
3978	1031	Dar cera y pulir	t
3979	1031	Cortar el césped	f
\.


--
-- Data for Name: planes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.planes (id, tipo, nombre, precio, admins, profesores, alumnos, quizzes, activo, orden) FROM stdin;
1	individual	BASICO	40	1	1	20	15	t	1
4	individual	TEST	0	1	1	15	5	t	0
2	individual	COORDINADOR	50	1	5	100	50	t	2
3	empresarial	EMPRESARIAL	400	2	\N	\N	\N	t	3
\.


--
-- Data for Name: preguntas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.preguntas (id, quiz_id, texto, tipo, explicacion, norden) FROM stdin;
412	15	¿Qué es JavaScript?	multiple	\N	\N
413	15	¿Cuál es la forma correcta de declarar una variable en JavaScript?	multiple	\N	\N
414	15	3. ¿Cuál de estos es un tipo de dato en JavaScript?	multiple	\N	\N
415	15	4. ¿Qué símbolo se usa para comentarios de una sola línea?	multiple	\N	\N
416	15	5. ¿Qué función se usa para mostrar un mensaje en la consola?	multiple	\N	\N
792	45	La SUNAT es la entidad encargada de la recaudación tributaria en Perú.	vf	La SUNAT administra y fiscaliza los tributos internos en Perú.	1
793	45	La SUNAT solo se encarga del cobro del IGV.	vf	Además del IGV, SUNAT gestiona otros impuestos como el Impuesto a la Renta.	2
794	45	Es obligatorio para las empresas emitir comprobantes electrónicos autorizados por la SUNAT.	vf	La SUNAT regula la emisión de comprobantes electrónicos para mejorar la fiscalización.	3
122	6	Goku es un Saiyajin.	vf		1
123	6	Vegeta siempre fue más fuerte que Goku.	vf		2
124	6	Freezer puede sobrevivir en el espacio.	vf		3
125	6	Gohan derrotó a Cell.	vf		4
126	6	Piccolo es un villano en toda la serie.	vf		5
127	6	Trunks mató a Freezer.	vf		6
128	6	Krillin es el humano más fuerte.	vf		7
129	6	Majin Buu es invencible.	vf		8
130	6	Goku aprendió el Kamehameha solo.	vf	Lo aprendio del maestro Rosh	9
131	6	Vegeta se sacrifica contra Majin Buu.	vf		10
5	3	Es corrrecto	vf	Es corrrecto	1
48	5	Goku fue enviado a la Tierra cuando era un bebé.	vf	Fue enviado por su padre Bardock para sobrevivir.	1
49	5	Vegeta es el príncipe de los Saiyajin.	vf	Es el príncipe de la raza Saiyajin.	2
50	5	Gohan es hijo de Vegeta.	vf	Gohan es hijo de Goku.	3
51	5	Freezer destruyó el planeta Vegeta.	vf	Freezer destruyó el planeta por miedo a los Saiyajin.	4
52	5	Piccolo es originalmente un Namekiano.	vf	Pertenece a la raza Namekiana.	5
53	5	Goku puede transformarse en Super Saiyajin.	vf	Es una de sus transformaciones principales.	6
54	5	Krillin es un Saiyajin.	vf	Krillin es humano.	7
55	5	Cell fue creado por el Dr. Gero.	vf	Fue creado con células de los guerreros más fuertes.	8
56	5	Majin Buu tiene múltiples formas.	vf	Tiene varias transformaciones a lo largo de la saga.	9
57	5	Trunks viene del futuro.	vf	Viaja al pasado para advertir sobre los androides.	10
195	14	Una tabla puede tener más de una clave primaria.	vf	(solo puede tener una clave primaria, aunque puede ser compuesta)	\N
795	45	La SUNAT no tiene facultad para realizar auditorías tributarias.	vf	La SUNAT realiza auditorías para verificar el cumplimiento tributario.	4
196	14	Nueva Una base de datos es un conjunto organizado de datos que se pueden almacenar y consultar.pregunta VF	vf		\N
822	46	¿Qué problema genera la fragmentación?	multiple	\N	\N
823	46	¿Qué es Red Hat?	multiple	\N	\N
417	15	6. ¿Cuál operador se usa para comparar igualdad estricta?	multiple	\N	\N
418	15	7. ¿Qué estructura se usa para tomar decisiones?	multiple	\N	\N
419	15	8. ¿Cómo se define una función en JavaScript?	multiple	\N	\N
824	46	¿Cuál es el modelo de negocio de Red Hat?	multiple	\N	\N
825	46	¿Qué ofrece una suscripción de Red Hat?	multiple	\N	\N
826	46	¿Por qué Alemania migró a Linux?	multiple	\N	\N
827	46	¿Qué fue LiMux?	multiple	\N	\N
828	46	¿Qué beneficio obtuvo Alemania con Linux?	multiple	\N	\N
829	46	¿Qué hizo Extremadura en España?	multiple	\N	\N
830	46	¿Qué impacto tuvo el software libre en educación?	multiple	\N	\N
197	16	Naruto es Hokage.	vf	Se convierte en el séptimo Hokage	1
203	17	La etiqueta <p> se usa para definir párrafos.	vf	La etiqueta <p> delimita un párrafo de texto en HTML.	5
187	14	En SQL Server, una tabla puede existir sin columnas.	vf		\N
188	14	La instrucción SELECT se usa para consultar datos en una base de datos.Nueva pregunta VF	vf		\N
189	14	La cláusula WHERE permite filtrar registros en una consulta.	vf		\N
190	14	INSERT se utiliza para eliminar datos de una tabla.	vf		\N
191	14	Una clave primaria (PRIMARY KEY) puede contener valores duplicados.	vf	(debe ser única)	\N
192	14	El comando DELETE elimina todos los registros de una tabla automáticamente sin condición.	vf	(solo si no se usa WHERE, pero no es obligatorio)	\N
193	14	SQL Server permite tener varias bases de datos en una misma instancia.	vf		\N
194	14	La instrucción UPDATE sirve para modificar datos existentes en una tabla.	vf		\N
198	16	¿Quién es el rival de Naruto?	multiple	\N	2
199	17	El elemento <html> es la raíz de un documento HTML.	vf	El elemento <html> contiene todo el contenido de la página web.	1
200	17	La etiqueta <head> contiene el contenido visible de la página.	vf	La etiqueta <head> contiene información meta y recursos, no contenido visible.	2
201	17	El atributo 'href' en un enlace especifica la URL de destino.	vf	El atributo href en la etiqueta <a> indica la dirección a donde lleva el enlace.	3
202	17	CSS se utiliza para dar estilo a las páginas web.	vf	CSS controla la presentación y estilo visual de los elementos HTML.	4
204	17	El CSS se puede escribir dentro de la etiqueta <body>.	vf	El CSS generalmente se escribe en la etiqueta <style> dentro del <head> o en un archivo externo.	6
205	17	La propiedad CSS 'color' cambia el color del texto.	vf	La propiedad color define el color de la fuente de un elemento.	7
206	17	El elemento <img> requiere el atributo 'src' para mostrar una imagen.	vf	El atributo src especifica la ruta de la imagen a mostrar.	8
207	17	La etiqueta <div> es utilizada para agrupar elementos y aplicar estilos.	vf	El <div> actúa como un contenedor genérico para aplicar estilos o scripts.	9
208	17	En CSS, '#' indica que estamos seleccionando una clase.	vf	'#' indica un id, mientras que '.' indica una clase en CSS.	10
209	17	El atributo 'alt' en <img> ofrece texto alternativo si la imagen no carga.	vf	El atributo alt mejora accesibilidad mostrando texto cuando la imagen falla.	11
82	4	El software libre siempre es gratuito.	vf		1
83	4	El software libre permite modificar el código.	vf		2
796	45	El RUC es el Registro Único de Contribuyentes que registra a las personas y empresas para efectos tributarios.	vf	El RUC es un identificador obligatorio para todas las actividades económicas.	5
831	46	¿Qué es un problema de sostenibilidad en software libre?	multiple	\N	\N
832	46	¿Qué ayuda a la sostenibilidad?	multiple	\N	\N
833	46	¿Qué problema generan los formatos cerrados?	multiple	\N	\N
834	46	¿Qué solución mejora la interoperabilidad?	multiple	\N	\N
662	19	En JavaScript, "var" se utiliza para declarar variables.	vf		\N
663	19	Las variables declaradas con "let" tienen alcance de bloque.	vf		\N
84	4	Open source y software libre son exactamente lo mismo.	vf		3
78	2	Quien invento la rueda fue caramilla	multiple	\N	\N
79	2	Saco la loteria en el 1993 fue picnocho	vf		\N
80	2	La mejor version de ti y es el espejo	vf		\N
81	2	Quien mato a Kenedy	multiple	\N	\N
664	19	"const" permite cambiar el valor de una variable después de declararla.	vf		\N
665	19	JavaScript es un lenguaje con tipado dinámico.	vf		\N
666	19	Se puede declarar una variable sin asignarle valor inicial.	vf		\N
667	19	"var" respeta el alcance de bloque igual que "let".	vf		\N
668	19	Una variable puede cambiar de tipo de dato en JavaScript.	vf		\N
68	7	¿Cómo se llama el protagonista?	multiple	\N	1
69	7	¿Qué le sucede a la familia de Tanjiro?	multiple	\N	2
70	7	¿Cómo se llama la hermana de Tanjiro?	multiple	\N	3
71	7	¿Qué tipo de respiración usa Tanjiro principalmente?	multiple	\N	4
72	7	¿Quién es el principal antagonista?	multiple	\N	5
73	7	¿Qué característica especial tiene Nezuko como demonio?	multiple	\N	6
74	7	¿Cómo se llama el grupo que caza demonios?	multiple	\N	7
75	7	¿Qué arma utilizan los cazadores de demonios?	multiple	\N	8
76	7	¿Qué pilar usa la respiración del insecto?	multiple	\N	9
77	7	¿Qué usa Zenitsu cuando pelea?	multiple	\N	10
85	4	La GPL permite cerrar el código modificado.	vf		4
86	4	Linux es un ejemplo de software libre.	vf		5
87	4	Red Hat vende licencias del software.	vf		6
88	4	El kernel es el núcleo del sistema operativo.	vf		7
89	4	Open source se enfoca en la ética principalmente.	vf		8
90	4	Software libre garantiza 4 libertades.	vf		9
91	4	Android usa Linux.	vf		10
92	4	MIT es una licencia restrictiva.	vf		11
93	4	BSD permite uso comercial.	vf		12
94	4	Open source obliga a compartir cambios.	vf		13
95	4	GPL es copyleft.	vf		14
96	4	Red Hat contribuye a la comunidad.	vf		15
97	4	Linux nació en 1980.	vf		16
98	4	FSF promueve software propietario.	vf		17
99	4	GNU es un sistema operativo libre.	vf		18
100	4	Open source siempre es gratis.	vf		19
101	4	El software libre puede venderse.	vf		20
102	4	¿Quién creó el movimiento de software libre?	multiple	\N	21
103	4	¿Qué es el kernel?	multiple	\N	22
104	4	¿Linux es?	multiple	\N	23
105	4	¿Qué licencia usa copyleft?	multiple	\N	24
106	4	¿Red Hat gana dinero con?	multiple	\N	25
107	4	Open source se enfoca en:	multiple	\N	26
108	4	Software libre garantiza:	multiple	\N	27
109	4	FSF significa:	multiple	\N	28
110	4	GNU fue creado en:	multiple	\N	29
111	4	Linux nació en:	multiple	\N	30
112	4	¿Qué empresa compró Red Hat?	multiple	\N	31
113	4	¿Qué tipo de licencia es MIT?	multiple	\N	32
114	4	¿Qué hace Red Hat?	multiple	\N	33
115	4	¿Qué es OpenShift?	multiple	\N	34
116	4	¿Qué es Ansible?	multiple	\N	35
117	4	¿Qué es la GPL?	multiple	\N	36
118	4	¿Qué significa copyleft?	multiple	\N	37
119	4	¿Qué promueve el software libre?	multiple	\N	38
120	4	¿Qué promueve open source?	multiple	\N	39
121	4	¿Qué demuestra Red Hat?	multiple	\N	40
669	19	"const" requiere inicializar la variable al momento de declararla.	vf		\N
670	19	Es obligatorio usar punto y coma al final de cada declaración.	vf		\N
671	19	El nombre de una variable puede comenzar con un número.	vf		\N
672	19	¿Cuál es la forma correcta de declarar una variable?	multiple	\N	\N
673	19	¿Qué palabra clave crea una variable de bloque?	multiple	\N	\N
674	19	¿Cuál de estas opciones NO es válida en JavaScript?	multiple	\N	\N
675	19	¿Qué sucede si declaras una variable con "const"?	multiple	\N	\N
676	19	¿Cuál es el tipo de dato de una variable sin valor asignado?	multiple	\N	\N
835	46	¿Qué plataforma fomenta el desarrollo colaborativo?	multiple	\N	\N
836	46	¿Qué libro analiza el modelo Open Source colaborativo?	multiple	\N	\N
839	47	Nueva pregunta múltiple	multiple	\N	\N
392	22	¿Qué es el software?	multiple	\N	\N
393	22	¿Cómo se clasifica el software según sus libertades?	multiple	\N	\N
394	22	¿Qué permite el software libre?	multiple	\N	\N
395	22	¿Quién definió el concepto de Copyleft?	multiple	\N	\N
396	22	¿Qué es un sistema operativo?	multiple	\N	\N
397	22	¿Qué caracteriza a un sistema operativo libre?	multiple	\N	\N
398	22	¿Qué significa “transparencia” en software libre?	multiple	\N	\N
399	22	¿Cuál es una ventaja del software libre?	multiple	\N	\N
400	22	¿Cuál es una desventaja del software libre?	multiple	\N	\N
210	17	La etiqueta <span> es un contenedor en línea usado para estilizar partes de texto.	vf	<span> permite aplicar estilos sin romper la estructura en línea.	12
211	17	Para aplicar estilos a varios elementos con la misma clase, se usa el selector '.' en CSS.	vf	Se usa '.' seguido del nombre de clase para seleccionar todos los elementos con esa clase.	13
212	17	La propiedad CSS 'background-color' cambia el color de fondo de un elemento.	vf	Esta propiedad define el color de fondo de un elemento HTML.	14
213	17	El atributo 'id' puede ser usado varias veces en una misma página HTML.	vf	El id debe ser único en cada documento HTML.	15
214	17	La etiqueta <link> se usa para enlazar archivos CSS externos.	vf	Se utiliza en el <head> para conectar hojas de estilo externas.	16
215	17	Las etiquetas <h1> a <h6> definen diferentes niveles de encabezados.	vf	Los encabezados van del más importante (<h1>) al menos (<h6>).	17
216	17	La propiedad CSS 'margin' controla el espacio dentro del borde de un elemento.	vf	'margin' controla el espacio fuera del borde; el espacio interno se controla con padding.	18
217	17	El atributo 'style' se puede usar directamente en una etiqueta HTML para aplicar CSS en línea.	vf	El atributo style permite añadir CSS directamente al elemento.	19
218	17	El documento HTML siempre debe comenzar con <!DOCTYPE html>.	vf	Esta declaración indica al navegador que el documento es HTML5.	20
420	15	9. ¿Qué palabra clave se usa para declarar constantes?	multiple	\N	\N
421	15	10. ¿Qué resultado devuelve typeof 10?	multiple	\N	\N
432	24	El lenguaje HTML se usa para estructurar una página web.	vf	HTML define la estructura y el contenido básico de una página web.	1
433	24	CSS se utiliza para definir el comportamiento de una página web.	vf	CSS se usa para estilos visuales; el comportamiento se controla con JavaScript.	2
434	24	El elemento <p> en HTML se utiliza para definir un párrafo.	vf	La etiqueta <p> es para párrafos en HTML.	3
435	24	El atributo 'href' se usa en HTML para enlazar a otras páginas.	vf	El atributo href especifica la URL del enlace en una etiqueta <a>.	4
436	24	La etiqueta <div> se usa para crear enlaces en HTML.	vf	La etiqueta <div> es un contenedor genérico, no un enlace.	5
437	24	En CSS, la propiedad 'color' define el color del texto.	vf	La propiedad color cambia el color del texto en CSS.	6
438	24	La etiqueta <img> en HTML se usa para insertar imágenes.	vf	La etiqueta <img> permite mostrar imágenes en la página.	7
439	24	El atributo 'src' en <img> define la ruta de la imagen.	vf	El atributo src especifica la ubicación del archivo de imagen.	8
440	24	En HTML, la etiqueta h1 representa el título de mayor importancia.	vf	Los encabezados van de <h1> a <h6>, siendo <h1> el más importante.	9
441	24	La propiedad CSS 'background-color' cambia el color del fondo de un elemento.	vf	background-color establece el color de fondo en CSS.	10
442	24	El elemento <span> en HTML crea un contenedor en bloque por defecto.	vf	<span> es un contenedor en línea, no en bloque.	11
443	24	En CSS, 'font-size' controla el tamaño del texto.	vf	font-size define el tamaño de la fuente.	12
444	24	La etiqueta "ul" se usa para crear una lista desordenada en HTML.	vf	La etiqueta <ul> crea listas con viñetas.	13
445	24	La etiqueta <link> en HTML se usa para enlazar archivos CSS.	vf	La etiqueta <link> incluye hojas de estilo externas.	14
401	22	¿Cuál es el sistema operativo libre más popular?	multiple	\N	\N
402	22	¿Qué es FreeBSD?	multiple	\N	\N
403	22	¿Qué es ReactOS?	multiple	\N	\N
404	22	¿Qué es una distribución (distro)?	multiple	\N	\N
405	22	¿Cuál es una distro amigable para principiantes?	multiple	\N	\N
406	22	¿Qué distro es altamente personalizable y para avanzados?	multiple	\N	\N
407	22	¿Dónde se usan los sistemas operativos libres?	multiple	\N	\N
408	22	¿Qué sistema móvil está basado en Linux?	multiple	\N	\N
409	22	¿Cuál es alternativa libre a Microsoft Office?	multiple	\N	\N
410	22	¿Por qué usar software libre en educación?	multiple	\N	\N
411	22	¿Qué organización usa sistemas libres?	multiple	\N	\N
677	19	¿Qué palabra clave tiene alcance global o de función?	multiple	\N	\N
678	19	¿Cuál es un nombre de variable válido?	multiple	\N	\N
679	19	¿Qué permite JavaScript respecto a los tipos de variables?	multiple	\N	\N
422	1	Te gusta este quizz	multiple	\N	\N
423	1	te gusta este probema	multiple	\N	\N
424	1	y la frase	multiple	\N	\N
425	1	y este	multiple	\N	\N
426	1	y este otro	multiple	\N	\N
427	1	y esta otra mas	vf		\N
428	1	y esta otra mas otra	multiple	\N	\N
429	1	y esta otra	vf	por que si	\N
337	21	¿Qué significa SQL?	multiple	\N	1
338	21	¿Cuál de las siguientes es una operación básica de SQL?	multiple	\N	2
339	21	¿Qué tipo de dato se usa para almacenar texto en una base de datos?	multiple	\N	3
340	21	¿Cuál es la función principal de una clave primaria en una tabla?	multiple	\N	4
341	21	¿Qué instrucción SQL se usa para insertar datos en una tabla?	multiple	\N	5
342	21	¿Qué comando SQL se usa para modificar datos existentes?	multiple	\N	6
343	21	¿Cuál es la función de la cláusula WHERE en una consulta SQL?	multiple	\N	7
344	21	¿Qué representa una 'tabla' en una base de datos relacional?	multiple	\N	8
345	21	¿Cuál es el propósito de una 'clave foránea' (foreign key)?	multiple	\N	9
346	21	¿Qué significa 'NULL' en una base de datos?	multiple	\N	10
347	21	Una base de datos permite almacenar grandes cantidades de datos estructurados.	vf	Las bases de datos están diseñadas para almacenar y administrar grandes volúmenes de datos organizados.	11
348	21	El comando DROP sirve para actualizar datos existentes en una tabla.	vf	DROP elimina tablas o bases de datos, pero no actualiza datos.	12
349	21	La sentencia SELECT se usa para obtener datos de una base de datos.	vf	SELECT permite extraer datos almacenados en las tablas.	13
350	21	Una clave primaria puede aceptar valores NULL.	vf	La clave primaria debe contener valores únicos y no puede ser NULL.	14
351	21	Una consulta SQL siempre devuelve datos ordenados automáticamente.	vf	Para ordenar datos, se usa la cláusula ORDER BY explícitamente.	15
431	23	Es verdad o falso	vf	Po que si	\N
446	24	En CSS, 'margin' define el espacio dentro del borde de un elemento.	vf	margin es el espacio fuera del borde; padding el espacio dentro.	15
447	24	El atributo 'alt' en <img> proporciona texto alternativo para la imagen.	vf	El atributo alt es importante para accesibilidad y cuando la imagen no carga.	16
448	24	La etiqueta <form> se usa para definir un formulario en HTML.	vf	El elemento <form> agrupa controles para entrada de usuario.	17
449	24	En CSS, la propiedad 'border' agrega un borde al elemento.	vf	border controla tamaño, estilo y color del borde en CSS.	18
450	24	El atributo 'class' en HTML se utiliza para aplicar estilos CSS a grupos de elementos.	vf	Class permite seleccionar y dar estilos a múltiples elementos.	19
451	24	La estructura básica de un documento HTML comienza con la etiqueta <html>.	vf	La etiqueta <html> contiene todo el contenido de la página HTML.	20
472	25	El modelo conceptual de bases de datos se utiliza para describir los datos a un nivel lógico e independiente de la implementación física.	vf	El modelo conceptual representa una abstracción lógica de la información sin considerar detalles físicos.	\N
473	25	En un modelo conceptual, una entidad representa un objeto del mundo real que puede ser identificado de manera única.	vf	Una entidad es una cosa u objeto con existencia independiente sobre la que se almacena información.	\N
474	25	Las relaciones en un modelo conceptual solo pueden ser de tipo uno a uno.	vf	Las relaciones pueden ser uno a uno, uno a muchos o muchos a muchos, dependiendo de la asociación entre entidades.	\N
853	48	Nueva pregunta VF	vf		\N
854	48	Nueva pregunta múltiple	multiple	\N	\N
855	48	Destruyo lo que amas	multiple	\N	\N
856	48	un preguna mas	multiple	\N	\N
680	19	¿Cuál es la forma correcta de declarar una constante?	multiple	\N	\N
681	19	¿Qué sucede si redeclaras una variable con "let" en el mismo bloque?	multiple	\N	\N
703	32	¿En qué año comenzó la Guerra del Pacífico entre Chile, Perú y Bolivia?	multiple	\N	1
706	35	¿Cuál es la capital de Francia?	multiple	\N	1
709	38	¿Cuál es el nombre del protagonista principal en la serie original de Ultraman?	multiple	Shin Hayata es el personaje que se transforma en Ultraman en la serie original.	1
864	50	¿Quién es el mejor amigo y rival de Naruto en la serie?	multiple	Sasuke Uchiha es el rival y mejor amigo de Naruto durante toda la serie.	5
860	50	¿Cuál es el nombre completo del protagonista de Naruto?	multiple	Naruto Uzumaki es el nombre completo del protagonista de la serie.	1
840	47	la sensasiocn es gustosa	vf	LA sensasicon deberia ser ssiempre psalada	\N
861	50	¿A qué aldea ninja pertenece Naruto?	multiple	Naruto es un ninja de la Aldea Oculta de la Hoja (Konohagakure).	2
682	30	¿Cuál es el rol principal del Scrum Master en un equipo Scrum?	multiple	\N	1
683	30	¿Qué artefacto Scrum representa la lista priorizada de trabajo para el equipo?	multiple	\N	2
684	30	¿Con qué frecuencia se realiza un Sprint en Scrum?	multiple	\N	3
685	30	¿Quién es responsable de maximizar el valor del producto en Scrum?	multiple	\N	4
686	30	¿Qué evento Scrum se utiliza para revisar el trabajo completado y adaptar el Product Backlog?	multiple	\N	5
687	30	¿Cuál es la duración típica de un Daily Scrum?	multiple	\N	6
688	30	¿Qué elemento representa el incremento de producto utilizable y potencialmente entregable al final de cada sprint?	multiple	\N	7
689	30	¿Cuál es el propósito principal de la Sprint Retrospective?	multiple	\N	8
690	30	¿Quién participa activamente en la Sprint Planning?	multiple	\N	9
691	30	¿Cuál es la característica principal de un equipo Scrum?	multiple	\N	10
692	30	¿Qué significa que un Sprint es 'time-boxed'?	multiple	\N	11
693	30	¿Qué se entiende por 'Definition of Done' en Scrum?	multiple	\N	12
694	30	¿En qué momento se crea el Sprint Backlog?	multiple	\N	13
695	30	¿Qué evento permite al equipo sincronizar actividades y crear un plan para las próximas 24 horas?	multiple	\N	14
696	30	¿Cuál de estas no es una responsabilidad del Product Owner?	multiple	\N	15
697	30	¿Qué se entiende por 'empírica' en el marco de trabajo Scrum?	multiple	\N	16
698	30	¿Cuál es el propósito del Product Backlog Refinement (Refinamiento del Product Backlog)?	multiple	\N	17
699	30	¿Cuál es el objetivo principal del Sprint Review?	multiple	\N	18
700	30	¿Qué equipo en Scrum es responsable de decidir cómo realizar el trabajo durante un Sprint?	multiple	\N	19
701	30	¿Qué es un 'Impedimento' en el contexto Scrum?	multiple	\N	20
704	33	¿En qué guerra estuvo involucrado Chile en el siglo XIX?	multiple	\N	1
707	36	¿Qué es UltraSiete?	multiple	\N	1
710	39	¿Cuál es el nombre del protagonista principal en la serie original de Ultraman?	multiple	Shin Hayata es el personaje que se transforma en Ultraman en la serie original.	1
756	42	¿Cuál es la debilidad principal de los demonios en Demon Slayer?	multiple	Los demonios mueren expuestos a la luz solar, su debilidad más conocida.	5
862	50	¿Cuál es la técnica especial más conocida de Naruto?	multiple	El Rasengan es la técnica especial creada por el Cuarto Hokage y dominada por Naruto.	3
863	50	Naruto tiene dentro de su interior al nueve colas, Kurama.	vf	Kurama, el Zorro de Nueve Colas, está sellado dentro de Naruto desde su nacimiento.	4
865	50	¿Qué posición alcanza Naruto en la Aldea al final de la serie?	multiple	Naruto se convierte en el Séptimo Hokage, líder de la Aldea Oculta de la Hoja.	6
866	50	Sakura Haruno es la sensei de Naruto durante la mayor parte de la serie.	vf	Kakashi Hatake es el sensei de Naruto, no Sakura.	7
930	29	¿Qué hace parseInt(prompt(...))?	multiple	\N	\N
931	29	¿Qué tipo de dato es num1?	multiple	\N	\N
932	29	¿Qué operación realiza :    num1 / num2?	multiple	\N	\N
933	29	¿Qué hace parseInt(division)?	multiple	\N	\N
934	29	¿Cómo se obtiene la parte decimal?	multiple	\N	\N
935	29	¿Qué hace toString()?	multiple	\N	\N
936	29	¿Qué hace .length?	multiple	\N	\N
937	29	En el ejercicio en clase....¿Por qué se usa largo=largo-2?	multiple	\N	\N
938	29	¿Qué hace Math.pow(10,largo)?	multiple	\N	\N
939	29	En el ejercicio visto en clase.....¿Qué hace valor=multi*decimal?	multiple	\N	\N
750	41	¿Para qué sirve la opción 'Actualizar ahora' después de instalar Ubuntu?	multiple	\N	\N
751	41	¿Qué se debe hacer si el USB no arranca al instalar Ubuntu?	multiple	\N	\N
752	42	¿Cuál es el nombre del protagonista de Demon Slayer?	multiple	Tanjiro Kamado es el protagonista principal que busca salvar a su hermana.	1
753	42	¿Qué tipo de criatura es Nezuko Kamado después de la transformación?	multiple	Nezuko se convierte en demonio tras el ataque de Muzan Kibutsuji.	2
754	42	¿Cuál es el estilo de espada que usa Tanjiro principalmente?	multiple	Tanjiro utiliza la Respiración de Agua como su técnica principal de combate.	3
755	42	¿Quién es el líder de los Hashira (Pilares) en la aldea de Demon Slayer?	multiple	Los Hashira son un grupo de élite sin un único líder, sino que todos son igual de importantes.	4
940	29	¿Qué hace document.write()?	multiple	\N	\N
762	43	¿En qué año comenzó la Segunda Guerra Mundial?	multiple	\N	\N
763	43	¿Cuál fue el principal país aliado en la Segunda Guerra Mundial junto a Estados Unidos y Reino Unido?	multiple	\N	\N
764	43	¿Qué evento marcó el final de la Segunda Guerra Mundial en Asia?	multiple	\N	\N
765	43	¿Quién fue el líder de la Alemania nazi durante la Segunda Guerra Mundial?	multiple	\N	\N
766	43	La Primera Guerra Mundial terminó en 1918.	vf	La Primera Guerra Mundial finalizó en 1918 con la firma del armisticio.	\N
791	44	La SUNAT también supervisa y controla el cumplimiento de las obligaciones aduaneras.	vf	Una de las funciones de la SUNAT es la administración aduanera para controlar importaciones y exportaciones.	\N
787	44	La SUNAT es la entidad encargada de la administración tributaria en Perú.	vf	La SUNAT administra y fiscaliza el cumplimiento de las obligaciones tributarias en Perú.	\N
788	44	¿Qué documento debe emitir un contribuyente para acreditar una operación ante SUNAT?	multiple	\N	\N
789	44	¿Cuál es la función principal de la SUNAT?	multiple	\N	\N
790	44	¿Cuál de los siguientes impuestos NO es administrado directamente por la SUNAT?	multiple	\N	\N
475	25	Un atributo puede ser una clave primaria en un modelo conceptual si identifica de forma única a una entidad.	vf	El atributo o conjunto de atributos que identifican unívocamente a una entidad es la clave primaria.	\N
476	25	El modelo Entidad-Relación es un ejemplo común de modelo conceptual de bases de datos.	vf	El modelo ER es ampliamente utilizado para diseñar y representar modelos conceptuales.	\N
477	25	Los atributos multivaluados en el modelo conceptual solo pueden tener un valor por instancia de entidad.	vf	Un atributo multivaluado puede tener más de un valor para una misma entidad.	\N
478	25	La cardinalidad en una relación indica el número mínimo y máximo de instancias que pueden participar en dicha relación.	vf	La cardinalidad expresa las restricciones sobre la cantidad de entidades relacionadas.	\N
479	25	La generalización es un proceso en el modelo conceptual que permite definir una superclase a partir de varias subclases.	vf	La generalización es el proceso inverso: agrupa varias subclases en una superclase común.	\N
480	25	Una entidad débil depende de la existencia de otra entidad para ser identificada.	vf	Las entidades débiles no tienen clave primaria propia y dependen de una entidad fuerte para su identificación.	\N
481	25	El modelo conceptual define cómo se almacenan físicamente los datos en el sistema de gestión de bases de datos.	vf	El modelo conceptual es independiente de la implementación física, la cual se define en el modelo físico.	\N
482	25	Las jerarquías de generalización permiten representar clases con atributos y relaciones compartidos en un modelo conceptual.	vf	Permiten organizar entidades similares en superclases y subclases con herencia de atributos y relaciones.	\N
483	25	Un atributo derivado es aquel cuyo valor puede obtenerse de otros atributos en el modelo conceptual.	vf	Los atributos derivados no se almacenan directamente sino que se calculan en base a otros atributos.	\N
484	25	Las relaciones recursivas son aquellas en las que una entidad se relaciona consigo misma.	vf	Son relaciones en las que la misma entidad participa más de una vez en diferentes roles.	\N
485	25	En un modelo conceptual, no existen restricciones sobre la selección de claves primarias para las entidades.	vf	La clave primaria debe seleccionar atributos que permitan identificar inequívocamente a cada instancia de entidad.	\N
486	25	El modelo conceptual facilita la comunicación entre los diseñadores de bases de datos y los usuarios finales.	vf	Este modelo usa conceptos cercanos al mundo real, facilitando la comprensión mutua.	\N
487	25	En el modelo conceptual, una entidad compuesta es una entidad que tiene varios atributos simples.	vf	Una entidad compuesta no es un término usual; hay atributos compuestos formados por subatributos, pero la entidad sigue siendo una entidad.	\N
488	25	Las restricciones de integridad en el modelo conceptual se usan para limitar las estructuras de datos y asegurar su consistencia.	vf	Definen reglas que deben cumplirse para mantener la validez de los datos en el modelo.	\N
489	25	El modelo conceptual siempre debe transformarse en un modelo lógico antes de la implementación física.	vf	La transformación al modelo lógico adapta el diseño conceptual al modelo específico de base de datos (relacional, orientado a objetos, etc.).	\N
490	25	El modelo conceptual incluye detalles como índices y métodos de almacenamiento en disco.	vf	Los detalles físicos como índices y almacenamiento corresponden al modelo físico, no al conceptual.	\N
491	25	Una relación en el modelo conceptual puede tener atributos propios además de los atributos de las entidades relacionadas.	vf	Las relaciones pueden tener atributos que describen la asociación entre entidades, como fecha de inicio o tipo de relación.	\N
492	18	¿Cuál de las siguientes palabras clave se utiliza para declarar una variable en JavaScript?	multiple	\N	\N
493	18	¿Cuál es la forma preferida actualmente para declarar variables que pueden cambiar su valor?	multiple	\N	\N
494	18	¿Qué palabra clave se usa para declarar una constante en JavaScript?	multiple	\N	\N
495	18	Las variables declaradas con var tienen ámbito global o local a la función en la que se declaran.	vf	Las variables con var tienen ámbito global o de función, no de bloque.	\N
496	18	Las variables declaradas con let tienen ámbito de bloque.	vf	let limita la variable al bloque donde se define, como en if o for.	\N
497	18	¿Qué ocurrirá si se declara dos veces una variable con var dentro de la misma función?	multiple	\N	\N
498	18	¿Cuál es el valor por defecto de una variable declarada pero no inicializada en JavaScript?	multiple	\N	\N
499	18	Una variable declarada con const puede ser reasignada después de su declaración.	vf	Las constantes no pueden cambiar su valor una vez asignado.	\N
500	18	¿Cuál de estos nombres NO es un identificador válido para una variable en JavaScript?	multiple	\N	\N
501	18	¿Cuál es la diferencia principal entre var y let?	multiple	\N	\N
502	18	Puedes usar la variable antes de declararla si usas var.	vf	Por hoisting, var es inicializada como undefined antes de la línea de declaración.	\N
503	18	No se puede declarar una variable con el nombre 'let' en JavaScript.	vf	'let' es una palabra reservada y no se puede usar como nombre de variable.	\N
504	18	¿Cómo se inicializa una variable llamada 'edad' con el número 30?	multiple	\N	\N
505	18	¿Cuál de las siguientes no es una forma válida para declarar una variable en JavaScript?	multiple	\N	\N
506	18	Las variables declaradas con let y const no pueden ser redeclaradas en el mismo ámbito.	vf	A diferencia de var, let y const no permiten redeclaraciones en el mismo ámbito.	\N
507	18	¿Qué palabra clave debería usar si quiero declarar una variable cuyo valor no cambiará?	multiple	\N	\N
508	18	El valor de una variable const que es un objeto puede ser modificado.	vf	El objeto puede cambiar sus propiedades, pero la referencia no puede cambiar.	\N
509	18	¿Cuál es el ámbito de una variable declarada dentro de un bloque if con let?	multiple	\N	\N
510	18	¿Qué pasa si declaras una variable con var dentro de un bloque for y la usas fuera del bloque?	multiple	\N	\N
511	18	¿Qué mostrará la siguiente instrucción? var x = 5; console.log(typeof x);	multiple	\N	\N
702	31	¿Cuál es el rol principal responsable de maximizar el valor del producto en Scrum?	multiple	\N	1
705	34	¿Cuál es el nombre del Ultraman original que apareció por primera vez en 1966?	multiple	\N	1
708	37	¿Cuál es el nombre del protagonista que se transforma en Ultraman?	multiple	\N	1
711	40	¿Cuál es el nombre del personaje que se transforma en Ultraman?	multiple	Shin Hayata es el primer humano en transformarse en Ultraman en la serie original.	1
732	41	¿Cuál es una licencia común de software libre?	multiple	\N	\N
532	26	¿Qué caracteriza principalmente al software libre?	multiple	\N	\N
533	26	¿Qué ventaja clave ofrece la transparencia del software libre?	multiple	\N	\N
534	26	¿Qué promueve la comunidad en el software libre?	multiple	\N	\N
535	26	¿Cuál es un desafío del software libre?	multiple	\N	\N
536	26	¿Qué significa fragmentación en Linux?	multiple	\N	\N
537	26	¿Qué problema genera la fragmentación?	multiple	\N	\N
538	26	¿Qué es Red Hat?	multiple	\N	\N
539	26	¿Cuál es el modelo de negocio de Red Hat?	multiple	\N	\N
540	26	¿Qué ofrece una suscripción de Red Hat?	multiple	\N	\N
541	26	¿Por qué Alemania migró a Linux?	multiple	\N	\N
542	26	¿Qué fue LiMux?	multiple	\N	\N
543	26	¿Qué beneficio obtuvo Alemania con Linux?	multiple	\N	\N
544	26	¿Qué hizo Extremadura en España?	multiple	\N	\N
545	26	¿Qué impacto tuvo el software libre en educación?	multiple	\N	\N
546	26	¿Qué es un problema de sostenibilidad en software libre?	multiple	\N	\N
547	26	¿Qué ayuda a la sostenibilidad?	multiple	\N	\N
548	26	¿Qué problema generan los formatos cerrados?	multiple	\N	\N
549	26	¿Qué solución mejora la interoperabilidad?	multiple	\N	\N
550	26	¿Qué plataforma fomenta el desarrollo colaborativo?	multiple	\N	\N
551	26	¿Qué libro analiza el modelo Open Source colaborativo?	multiple	\N	\N
552	27	Ica es una región ubicada en la costa sur del Perú.	vf	Ica se encuentra en la costa sur del Perú, conocida por su clima desértico y su producción agrícola.	1
553	27	La cultura Paracas se desarrolló en la región de Ica.	vf	La cultura Paracas es una de las culturas precolombinas importantes que se desarrolló en la zona de Ica.	2
554	27	Los Nazca son famosos por sus líneas ubicadas en la región de Ica.	vf	Las Líneas de Nazca son uno de los principales atractivos arqueológicos ubicados en la región de Ica.	3
555	27	La ciudad de Ica fue fundada durante el período colonial español.	vf	La ciudad de Ica fue fundada por los españoles en el siglo XVI durante la época colonial.	4
556	27	Ica es conocida principalmente por su producción de caña de azúcar y uvas.	vf	La agricultura en Ica incluye cultivos como la caña de azúcar y las uvas, especialmente para la producción de vino y pisco.	5
557	27	El desierto de Ica es famoso por sus dunas donde se practica sandboard.	vf	El desierto de Ica es un destino turístico conocido por sus grandes dunas donde se practica sandboard.	6
558	27	Las Líneas de Nazca fueron creadas por la cultura Inca.	vf	Las Líneas de Nazca fueron creadas por la cultura Nazca, anterior al Imperio Inca.	7
559	27	Ica fue un punto estratégico importante durante la guerra de independencia del Perú.	vf	Ica tuvo importancia estratégica en la lucha por la independencia del Perú en el siglo XIX.	8
560	27	El clima de Ica es mayormente tropical y lluvioso durante todo el año.	vf	El clima de Ica es desértico, seco y cálido, con muy poca lluvia durante el año.	9
561	27	La región de Ica limita al sur con la región de Arequipa.	vf	La región de Ica limita al sur con la región de Arequipa; sin embargo, es más común decir que limita al sur con la región de Arequipa, pero oficialmente limita con Moquegua y Arequipa está más al sur.	10
733	41	¿Cuál es una característica del software libre?	multiple	\N	\N
734	41	¿Qué significa 'copyleft' en el contexto del software libre?	multiple	\N	\N
735	41	¿Qué es software libre?	multiple	\N	\N
736	41	¿Cuál es un ejemplo popular de software libre?	multiple	\N	\N
737	41	¿Qué organización promueve el software libre?	multiple	\N	\N
738	41	¿Qué beneficio ofrece el software libre a los usuarios?	multiple	\N	\N
739	41	¿Cuál no es una libertad garantizada por el software libre?	multiple	\N	\N
740	41	¿Cuál es el rol del 'Scrum Master' en Scrum?	multiple	\N	\N
741	41	¿Qué es un 'Sprint' en Scrum?	multiple	\N	\N
742	41	¿Qué se revisa en la 'Sprint Review'?	multiple	\N	\N
743	41	¿Quién es responsable de priorizar el Product Backlog?	multiple	\N	\N
744	41	¿Qué es un 'Daily Scrum'?	multiple	\N	\N
745	41	¿Cuál es el objetivo del Sprint Retrospective?	multiple	\N	\N
746	41	¿Cuál es el primer paso para instalar Ubuntu?	multiple	\N	\N
747	41	¿Cuál es un requisito para crear un USB booteable de Ubuntu?	multiple	\N	\N
748	41	¿Qué opción permite elegir el tipo de instalación en Ubuntu?	multiple	\N	\N
749	41	¿Qué entorno de escritorio es el predeterminado en Ubuntu moderno?	multiple	\N	\N
817	46	¿Qué caracteriza principalmente al software libre?	multiple	\N	\N
818	46	¿Qué ventaja clave ofrece la transparencia del software libre?	multiple	\N	\N
819	46	¿Qué promueve la comunidad en el software libre?	multiple	\N	\N
820	46	¿Cuál es un desafío del software libre?	multiple	\N	\N
821	46	¿Qué significa fragmentación en Linux?	multiple	\N	\N
867	50	¿Cuál es el nombre del equipo original al que pertenece Naruto?	multiple	Naruto pertenece al Equipo 7 junto a Sasuke, Sakura y su sensei Kakashi.	8
868	50	¿Quién es el creador del Rasengan, la técnica que utiliza Naruto?	multiple	Minato Namikaze, el Cuarto Hokage y padre de Naruto, creó el Rasengan.	9
869	50	El Sharingan es una habilidad que posee Naruto desde el inicio de la serie.	vf	El Sharingan es un dojutsu del clan Uchiha, no posee Naruto.	10
870	51	Naruto Uzumaki es el Jinchuriki del Zorro de Nueve Colas (Kurama).	vf	Naruto lleva dentro de sí al Nueve Colas, Kurama, que le otorga gran poder.	1
871	51	El Sharingan es una técnica exclusiva del clan Hyuga.	vf	El Sharingan es exclusivo del clan Uchiha, no del clan Hyuga.	2
872	51	El Rasengan fue creado por Minato Namikaze.	vf	Minato, el Cuarto Hokage, desarrolló el Rasengan basándose en la manipulación de chakra rotatorio.	3
873	51	Sasuke Uchiha es el hermano mayor de Itachi Uchiha.	vf	Itachi es el hermano mayor de Sasuke, aunque es más fuerte y maduro.	4
874	51	La técnica de Invocación de Naruto le permite llamar a sapos gigantes.	vf	Naruto puede invocar sapos gigantes como Gamabunta gracias a un contrato con ellos.	5
875	51	¿Cuál es el nombre del líder original de Akatsuki?	multiple	Madara Uchiha fue el fundador original de Akatsuki.	6
876	51	¿Cuál de los siguientes jutsus es un genjutsu?	multiple	Tsukuyomi es un genjutsu que controla la mente y el tiempo en la percepción de la víctima.	7
877	51	¿Qué elemento de chakra usa principalmente Kakashi Hatake?	multiple	Kakashi usa principalmente el elemento Raiton, o chakra de rayo.	8
878	51	¿Quién fue el maestro de Naruto en la técnica Rasengan?	multiple	Minato Namikaze enseñó el Rasengan a Naruto, además de ser su padre.	9
879	51	¿Cuál es la verdadera identidad de Tobi dentro de Akatsuki?	multiple	Tobi es en realidad Obito Uchiha, que se hizo pasar por Madara.	10
880	51	El Byakugan permite ver a través de objetos y el flujo de chakra de oponentes.	vf	El Byakugan otorga visión casi 360° y la capacidad de ver el sistema de chakra del adversario.	11
881	51	Sakura Haruno es experta en técnicas médicos y posee la fuerza sobrehumana por su entrenamiento con Tsunade.	vf	Sakura adquirió la fuerza y habilidades médicas avanzadas gracias a Tsunade.	12
882	51	El Susanoo es una técnica exclusiva del clan Hyuga.	vf	Susanoo es una técnica del clan Uchiha, no del Hyuga.	13
883	51	Naruto logra controlar el chakra de Kurama completamente durante la Cuarta Gran Guerra Ninja.	vf	Durante la guerra, Naruto se sincronizó completamente con Kurama para un mayor poder.	14
884	51	¿Cuál es el rango máximo de Naruto al final de Shippuden?	multiple	Naruto finalmente se convierte en el Séptimo Hokage al concluir Shippuden.	15
885	51	¿Qué linaje es conocido por tener el Kekkei Genkai del Fūinjutsu que usa el clan Uzumaki?	multiple	El clan Uzumaki es famoso por sus poderosos sellos y técnicas de Fūinjutsu.	16
886	51	¿Cuál es la técnica prohibida usada por Orochimaru para reproducirse y transferir su alma?	multiple	Orochimaru utiliza Fushi Tensei para transferir su alma a cuerpos nuevos.	17
887	51	El Rasenshuriken es una evolución del Rasengan que incorpora chakra viento.	vf	Naruto añade chakra viento al Rasengan para crear el Rasenshuriken.	18
888	51	Killer Bee es el Jinchuriki del Zorro de Nueve Colas.	vf	Killer Bee es el Jinchuriki del Ocho Colas (Gyuki), no del Nueve Colas.	19
889	51	¿Quién fue el primer maestro del clan Uchiha conocido por perfeccionar el Sharingan?	multiple	Indra Otsutsuki es el ancestro del clan Uchiha y primer usuario del Sharingan.	20
910	28	¿Qué etiqueta se usa para definir la cabecera de la página?	multiple	\N	\N
911	28	¿Qué propiedad CSS centra el contenido horizontalmente con margin:auto?	multiple	\N	\N
912	28	¿Qué propiedad se usa para aplicar Flexbox en el header?	multiple	\N	\N
913	28	¿Qué propiedad distribuye los elementos con espacio alrededor?	multiple	\N	\N
914	28	¿Qué propiedad alinea verticalmente los elementos en el centro?	multiple	\N	\N
915	28	¿Qué selector se usa para clases?	multiple	\N	\N
916	28	¿Qué selector se usa para IDs?	multiple	\N	\N
917	28	¿Qué propiedad cambia el color de fondo?	multiple	\N	\N
918	28	¿Qué propiedad hace un elemento circular?	multiple	\N	\N
919	28	¿Qué propiedad define el alto de un elemento?	multiple	\N	\N
920	28	¿Qué propiedad centra texto horizontalmente?	multiple	\N	\N
921	28	¿Qué propiedad se usa para separar el contenido interno?	multiple	\N	\N
922	28	¿Qué propiedad define el borde de un elemento?	multiple	\N	\N
923	28	¿Qué valor de display se usa en article?	multiple	\N	\N
924	28	¿Qué porcentaje de ancho tiene .img?	multiple	\N	\N
925	28	¿Qué propiedad permite centrar verticalmente texto usando altura?	multiple	\N	\N
926	28	¿Qué etiqueta puede contener texto	multiple	\N	\N
927	28	¿Cuántos elementos .menu hay en el header?	multiple	\N	\N
928	28	¿Qué propiedad se usa para distribuir los .box en fila?	multiple	\N	\N
929	28	¿Qué etiqueta se usa para el pie de página?	multiple	\N	\N
941	29	num1*num2......¿Cuál es el resultado si num1=10 y num2=2?	multiple	\N	\N
942	29	¿Qué pasa si num2 es 0?	multiple	\N	\N
943	29	¿Qué hace este if? if(num2==0){ alert()}	multiple	\N	\N
944	29	¿Qué operador es ==?	multiple	\N	\N
945	29	¿Qué hace toUpperCase()?	multiple	\N	\N
946	29	¿Qué hace toLowerCase()?	multiple	\N	\N
947	29	¿Qué hace if(valor > 10)?	multiple	\N	\N
948	29	¿Qué palabra clave inicia una condición?	multiple	\N	\N
949	29	¿Qué hace var?	multiple	\N	\N
950	49	esta es una pregunta importante si o no	vf	Por que si	\N
951	52	¿Qué es una licencia de software?	multiple		1
952	52	¿Quién elige la licencia de un software?	multiple		2
953	52	¿Qué protege una patente?	multiple		3
954	52	¿Qué protege el copyright?	multiple		4
955	52	El software libre permite:	multiple		5
956	52	¿Qué NO es una libertad del software libre?	multiple		6
957	52	¿Qué caracteriza al software de fuente abierta?	multiple		7
958	52	¿Qué significa “no discriminación” en open source?	multiple		8
959	52	Un estándar abierto promueve:	multiple		9
960	52	El software de dominio público:	multiple		10
961	52	¿Qué es el copyleft?	multiple		11
962	52	El software semi libre permite:	multiple		12
963	52	Freeware significa:	multiple		13
964	52	¿Qué caracteriza al shareware?	multiple		14
965	52	El software privativo:	multiple		15
966	52	El software comercial:	multiple		16
967	52	La motivación ética del software libre dice que:	multiple		17
968	52	La motivación pragmática busca:	multiple		18
969	52	La licencia GPL obliga a:	multiple		19
970	52	La licencia BSD permite:	multiple		20
971	53	¿En qué año comenzó la Guerra del Pacífico (Guerra con Chile)?	multiple	La Guerra del Pacífico comenzó en 1879 entre Chile, Perú y Bolivia.	1
972	53	¿Cuál era uno de los principales recursos disputados en la Guerra con Chile?	multiple	El guano y el salitre eran recursos valiosos en la región y motivo principal del conflicto.	2
973	53	¿Qué país quedó sin salida al mar tras la Guerra con Chile?	multiple	Bolivia perdió su costa y quedó sin salida soberana al océano Pacífico.	3
974	53	¿Cuál fue una de las batallas más importantes de la Guerra con Chile?	multiple	La Batalla de Arica fue una confrontación clave en 1880 durante la guerra.	4
975	53	¿Qué tratado puso fin oficialmente a la Guerra con Chile?	multiple	El Tratado de Ancón en 1883 marcó el fin de la guerra entre Chile y Perú.	5
976	54	¿Qué es una base de datos?	multiple		1
977	54	¿Cuál es un tipo de base de datos?	multiple		2
978	54	¿Qué característica distingue a SQL?	multiple		3
979	54	¿Cuál es una ventaja de NoSQL?	multiple		4
980	54	¿Qué beneficio tiene el software libre en bases de datos?	multiple		5
981	54	¿Qué base de datos es NoSQL?	multiple		6
982	54	¿Cuál es una característica de PostgreSQL?	multiple		7
983	54	¿Qué tipo de indexación usa PostgreSQL?	multiple		8
984	54	¿Cuál es una ventaja de MariaDB sobre MySQL?	multiple		9
985	54	¿Qué caracteriza a SQLite?	multiple		10
986	54	¿Cuál es el uso ideal de PostgreSQL?	multiple		11
987	54	¿Qué herramienta es gráfica para bases de datos?	multiple		12
988	54	¿Qué herramienta está especializada en PostgreSQL?	multiple		13
989	54	¿Qué permite phpMyAdmin?	multiple		14
990	54	¿Por qué Wikipedia usa MariaDB?	multiple		15
991	54	¿Qué permite MySQL en Shopify?	multiple		16
992	54	¿Qué característica clave tiene PostgreSQL en Instagram?	multiple		17
993	54	¿Qué comando instala PostgreSQL en Linux?	multiple		18
994	54	¿Qué es una buena práctica de seguridad?	multiple		19
995	54	¿Qué ayuda a la seguridad en PostgreSQL?	multiple		20
1007	55	Marco Antonio se alió con la faraona Cleopatra para obtener recursos económicos.	vf	Marco Antonio estableció una relación con Cleopatra para asegurar recursos financieros necesarios para su campaña.	\N
1008	55	El Segundo Triunvirato estuvo formado por Julio César, Marco Antonio y Octavio.	vf	El Segundo Triunvirato estuvo compuesto por Marco Antonio, Octavio y Marco Emilio Lépido, no Julio César.	\N
1009	55	Publio Ventidio recuperó Anatolia para Roma tras vencer en las Puertas Cilicias y Monte Amano.	vf	En 39 a. C., Publio Ventidio derrotó a los partos y logró recuperar Anatolia para Roma.	\N
1010	55	Marco Antonio dejó Armenia bien protegida tras abandonarla en su campaña contra Partia.	vf	Al abandonar Armenia, Marco Antonio la dejó desguarnecida, lo que permitió la rebelión del rey.	\N
1011	55	La capital partida, Ctesifonte, fue atacada directamente por Marco Antonio y sus tropas.	vf	Las fuerzas romanas marcharon hacia Ctesifonte, la capital partida, en varias ocasiones durante la campaña.	\N
1012	55	El rey Polemón I apoyó a Marco Antonio sin pedir nada a cambio.	vf	Para asegurarse la lealtad del rey Polemón I, Marco Antonio dejó diez mil soldados en su reino.	\N
1013	55	Marco Antonio perdió alrededor de treinta mil hombres durante la campaña parta.	vf	Las fuerzas romanas sufrieron una fuerte derrota, perdiendo aproximadamente treinta mil soldados.	\N
1014	55	Artavasdes II fue arrestado y ejecutado después de ser derrotado por Marco Antonio.	vf	Artavasdes II fue arrestado y llevado a Alejandría, donde fue ejecutado en el año 34 a. C.	\N
1015	55	Con la derrota de Artavasdes II, Roma colocó a Artaxas II en el trono de Armenia.	vf	Después de la caída de Artavasdes II, Roma apoyó a Artaxas II como rey en Armenia.	\N
1016	55	Los reyes sirios y judíos apoyaron la invasión parto porque querían liberarse del dominio romano.	vf	Los reyes sirios y judíos recibieron a los partos como libertadores, descontentos con el control romano.	\N
1017	55	Durante su avance, Marco Antonio cruzó el río Arasse donde fue atacado por Fraates IV.	vf	Al cruzar el río Arasse, las fuerzas romanas fueron emboscadas por tropas partas lideradas por Fraates IV.	\N
1027	56	¿En qué ciudad tiene lugar la mayoría de la trama de la primera película Karate Kid?	multiple	\N	\N
1028	56	¿Qué filosofía o principio de vida resalta Mr. Miyagi durante su entrenamiento?	multiple	\N	\N
1029	56	¿Cuál es el nombre del sensei que entrena a Daniel LaRusso en la película original de Karate Kid (1984)?	multiple	\N	\N
1030	56	¿Cómo se llama la técnica de defensa que Mr. Miyagi enseña a Daniel y que consiste en bloquear ataques usando movimientos de manos? 	multiple	\N	\N
1031	56	¿Qué tarea doméstica hace Daniel como parte de su entrenamiento inicial con Mr. Miyagi?	multiple	\N	\N
1032	56	¿Cuál es el nombre del antagonista principal y campeón del torneo de karate en Karate Kid (1984)?	multiple	\N	\N
1033	56	¿Qué relación tiene el personaje de Ali Mills con Daniel LaRusso?	multiple	\N	\N
1034	56	¿Cuál es el resultado final para Daniel en el torneo de karate al final de Karate Kid (1984)?	multiple	\N	\N
1035	56	¿Qué objeto importante le da Mr. Miyagi a Daniel para protegerse de los ataques del antagonista? 	multiple	\N	\N
\.


--
-- Data for Name: quiz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz (id, titulo, codigo, fcreacion, fmodificacion, usuario, estado, multiple_intentos, enviar_solucionario, cempre, usuario_id) FROM stdin;
26	202610 - UCS - SoftwareLibre	\N	2026-04-18 00:37:54.570707	\N	pardoalf	A	t	t	1	2
27	Historia de Ica - Nivel Basico	WUUSGQ	2026-04-19 13:25:30.202917	\N	pardoalf	A	t	t	1	2
19	Javascript Basico - tema - Variables	HBHM7D	2026-04-08 16:15:29.745451	\N	pardoalf	A	f	t	1	2
30	Software Libre - semana 4 - Scrum Agile	\N	2026-04-24 19:27:48.893276	2026-04-24 19:58:33.550478	pardoalf	I	t	t	1	2
31		\N	2026-04-24 20:00:16.338262	2026-04-24 20:29:09.611805	pardoalf	I	t	t	1	2
32		\N	2026-04-24 20:22:28.074719	2026-04-24 20:29:12.917449	pardoalf	I	t	t	1	2
33		\N	2026-04-24 20:28:56.900572	2026-04-25 15:31:46.101353	pardoalf	I	t	t	1	2
40		\N	2026-04-25 15:23:15.145681	2026-04-25 15:31:50.31365	pardoalf	I	t	t	1	2
39	Quiz Demo2	\N	2026-04-25 14:52:59.318863	2026-04-25 15:31:54.202592	pardoalf	I	t	t	1	2
38	Quiz Demo2	\N	2026-04-25 13:01:45.596961	2026-04-25 15:31:57.751431	pardoalf	I	t	t	1	2
37	ultraman 1 pregunta	\N	2026-04-25 08:53:06.508333	2026-04-25 15:32:00.785014	pardoalf	I	t	t	1	2
36	ultrasiete	\N	2026-04-25 08:41:29.383818	2026-04-25 15:32:04.497426	pardoalf	I	t	t	1	2
35	ultrasiete	\N	2026-04-25 08:38:11.557204	2026-04-25 15:32:07.590438	pardoalf	I	t	t	1	2
34	ultraman	\N	2026-04-25 08:25:18.377192	2026-04-25 15:32:11.064224	pardoalf	I	t	t	1	2
21	Base de datos - Nivel Basico - 1859 Jueves 	HZSHGL	2026-04-09 21:02:55.819535	\N	pardoalf	A	f	t	1	2
22	Quiz 2 - Software Libre	7ZFS6W	2026-04-10 10:46:55.111322	\N	pardoalf	A	f	t	1	2
4	Software Libre y Open Source	GCN5X1	2026-04-03 23:41:21.474401	\N	\N	A	f	t	1	2
15	Intrducción a la Programación (Javascript Basico)	X27IRL	2026-04-07 23:24:16.268049	\N	pardoalf	A	f	t	1	2
20	Quiz prueba	\N	2026-04-09 15:01:07.237677	2026-04-12 15:49:36.228832	pardoalf	I	f	t	1	2
41	Software Libre simulacro Parcial A	\N	2026-04-25 15:35:14.396363	\N	pardoalf	A	t	t	1	2
51	test - comic2 - Naruto avanzado	4GZZ44	2026-05-03 22:44:49.018304	\N	pardoenr	A	t	f	1	6
28	Quiz -Diseño Web - Semana 3	\N	2026-04-21 15:19:16.004499	\N	pardoalf	A	t	t	1	2
29	Introduccion a la Programacion  - JavaScript - Semana3	\N	2026-04-21 16:07:05.7069	\N	pardoalf	A	t	t	1	2
49	Test de prueba por profesor	ZCF0VG	2026-05-02 00:58:10.927321	\N	pardoalf	A	t	t	1	2
52	Software Libre Semana 6	\N	2026-05-08 23:10:36.66025	\N	pardoalf	A	f	t	1	2
54	Software libre - semana 7 - Base de datos	VXLYV9	2026-05-15 21:38:47.258672	\N	pardoalf	A	t	f	1	2
56	karate kid nivel dificil	8CNPJY	2026-05-24 12:49:04.991599	\N	pardoalf	A	t	t	1	2
42	Demo Slayer quiz basico	ZD23DR	2026-04-28 12:12:18.243202	\N	pardoalf	A	t	t	1	2
43	test Primera guerra mundial	\N	2026-04-28 16:42:05.047969	\N	pardoalf	A	t	t	1	2
44	Quiz Sunat 5 preguntas	\N	2026-04-29 08:40:43.65553	\N	pardoalf	A	t	t	1	2
1	Quiz Demo	ABC123	2026-04-03 23:41:21.474401	\N	\N	A	f	t	1	2
5	Dragon Ball	69XQAG	2026-04-03 23:41:21.474401	\N	\N	A	f	t	1	2
7	Demon Slayer Basico	KVNUNN	2026-04-03 23:41:21.474401	\N	\N	A	f	t	1	2
6	Sabes de Dragon Ball Z experto	J4VEX4	2026-04-03 23:41:21.474401	\N	\N	A	f	t	1	2
2	Software Libre	9XNT9Y	2026-04-03 23:41:21.474401	2026-04-06 14:37:54.393711	\N	I	f	t	1	2
3	Software Libre	L38RA9	2026-04-03 23:41:21.474401	2026-04-06 14:42:19.625619	\N	I	f	t	1	2
13		\N	2026-04-07 16:50:27.706053	2026-04-07 23:05:13.312342	pardoalf	I	f	t	1	2
11	Historia Universal	\N	2026-04-03 23:42:14.562574	2026-04-07 23:05:18.448961	\N	I	f	t	1	2
14	Basico de Base de datos	J09M2A	2026-04-07 23:01:49.486145	\N	pardoalf	A	f	t	1	2
16		\N	2026-04-08 13:59:45.460287	2026-04-08 15:05:06.741826	pardoalf	I	f	t	1	2
12		\N	2026-04-07 16:50:16.29218	2026-04-08 15:05:13.470272	pardoalf	I	f	t	1	2
10	Guerra con Chile	\N	2026-04-03 23:41:21.474401	2026-04-08 15:05:17.855233	\N	I	f	t	1	2
17	Diseño Web Basico - Verdadero Falso	JFRUEC	2026-04-08 15:27:01.027345	\N	pardoalf	A	f	t	1	2
23	Quiz facil	WH95G1	2026-04-12 22:41:48.194841	\N	pardoalf	A	f	t	1	2
24	Basico  Diseño Web  clase 1	\N	2026-04-13 16:06:45.620113	\N	pardoalf	A	t	t	1	2
25	Base de datos - Modelo Conceptual	\N	2026-04-14 16:58:10.679745	\N	pardoalf	A	f	t	1	2
18	Quiz de Introduccion a la Programación - Nivel Basico - 20p	8CR69Y	2026-04-08 15:29:36.155707	\N	pardoalf	A	f	t	1	2
45	Sunat - 5 preg	\N	2026-04-29 10:27:53.97476	\N	pardoalf	A	t	f	1	2
46	Software libre test	\N	2026-04-29 10:29:35.415788	\N	pardoalf	A	t	f	1	2
47	test	571E2M	2026-04-29 13:59:00.299788	\N	pardoalf	A	t	f	1	2
48	test 2	AB1W2V	2026-04-29 16:10:10.168218	\N	pardoalf	A	t	t	1	2
50	test - opciones- naruto	XSA6XD	2026-05-03 22:36:16.146842	\N	pardoenr	A	t	f	1	6
53	test 1 guerra con chile	\N	2026-05-10 12:47:33.024483	\N	pardoalf	A	t	f	1	2
55	Roma, campaña Marco Antonio segun texto	\N	2026-05-24 11:45:15.362673	\N	pardoalf	A	t	t	1	2
\.


--
-- Data for Name: respuestas_alumno; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.respuestas_alumno (id, alumno_id, pregunta_id, opcion_id, salon_quiz_id, quiz_id, intento_id) FROM stdin;
11326	1	989	3840	\N	54	4
11327	1	990	3845	\N	54	4
11316	1	979	3800	\N	54	4
11317	1	980	3806	\N	54	4
11318	1	981	3809	\N	54	4
11319	1	982	3812	\N	54	4
11329	1	992	3853	\N	54	4
11330	1	993	3855	\N	54	4
11331	1	994	3862	\N	54	4
11332	1	995	3863	\N	54	4
11328	1	991	3848	\N	54	4
11313	1	976	3788	\N	54	4
11325	1	988	3836	\N	54	4
11324	1	987	3832	\N	54	4
11323	1	986	3829	\N	54	4
11322	1	985	3826	\N	54	4
11320	1	983	3816	\N	54	4
11314	1	977	3793	\N	54	4
11321	1	984	3821	\N	54	4
11315	1	978	3797	\N	54	4
23	2	48	153	\N	5	5
24	2	49	155	\N	5	5
25	2	50	158	\N	5	5
26	2	51	159	\N	5	5
27	2	52	161	\N	5	5
28	2	53	163	\N	5	5
29	2	54	166	\N	5	5
30	2	55	167	\N	5	5
31	2	56	170	\N	5	5
32	2	57	171	\N	5	5
125	2	70	207	\N	7	6
123	2	68	198	\N	7	6
124	2	69	202	\N	7	6
126	2	71	210	\N	7	6
9057	101	503	1700	16	18	107
9050	101	496	1675	16	18	107
9049	101	495	1672	16	18	107
9048	101	494	1667	16	18	107
9047	101	493	1663	16	18	107
9046	101	492	1657	16	18	107
9051	101	497	1677	16	18	107
9052	101	498	1681	16	18	107
9053	101	499	1687	16	18	107
9054	101	500	1688	16	18	107
9055	101	501	1694	16	18	107
9056	101	502	1699	16	18	107
11334	159	1027	3956	\N	56	142
11335	159	1028	3962	\N	56	142
11336	159	1029	3966	\N	56	142
11337	159	1030	3973	\N	56	142
11338	159	1031	3978	\N	56	142
11339	159	1032	3981	\N	56	142
11340	159	1033	3987	\N	56	142
11341	159	1034	3992	\N	56	142
11342	159	1035	3998	\N	56	142
11309	1	992	3853	\N	54	3
11310	1	993	3857	\N	54	3
11311	1	994	3861	\N	54	3
11312	1	995	3865	\N	54	3
11296	1	979	3800	\N	54	3
11295	1	978	3797	\N	54	3
11294	1	977	3793	\N	54	3
11293	1	976	3787	\N	54	3
11307	1	990	3845	\N	54	3
11308	1	991	3847	\N	54	3
11304	1	987	3832	\N	54	3
11303	1	986	3827	\N	54	3
11302	1	985	3826	\N	54	3
11301	1	984	3821	\N	54	3
11305	1	988	3836	\N	54	3
11306	1	989	3840	\N	54	3
11300	1	983	3817	\N	54	3
11299	1	982	3814	\N	54	3
11298	1	981	3809	\N	54	3
11297	1	980	3806	\N	54	3
127	2	72	214	\N	7	6
128	2	73	218	\N	7	6
129	2	74	223	\N	7	6
130	2	75	226	\N	7	6
131	2	76	230	\N	7	6
132	2	77	234	\N	7	6
205	5	70	207	\N	7	9
206	5	71	210	\N	7	9
207	5	72	214	\N	7	9
208	5	73	218	\N	7	9
203	5	68	198	\N	7	9
204	5	69	202	\N	7	9
8100	5	87	260	\N	4	8
8105	5	92	270	\N	4	8
8104	5	91	267	\N	4	8
8103	5	90	265	\N	4	8
8102	5	89	264	\N	4	8
8101	5	88	261	\N	4	8
8099	5	86	257	\N	4	8
8098	5	85	256	\N	4	8
8097	5	84	254	\N	4	8
8096	5	83	251	\N	4	8
8095	5	82	250	\N	4	8
8134	5	121	366	\N	4	8
8133	5	120	361	\N	4	8
8132	5	119	358	\N	4	8
8131	5	118	354	\N	4	8
8130	5	117	350	\N	4	8
8129	5	116	346	\N	4	8
8128	5	115	342	\N	4	8
8127	5	114	338	\N	4	8
8126	5	113	334	\N	4	8
8125	5	112	331	\N	4	8
8124	5	111	325	\N	4	8
8123	5	110	321	\N	4	8
8122	5	109	317	\N	4	8
8121	5	108	314	\N	4	8
8120	5	107	311	\N	4	8
8119	5	106	306	\N	4	8
8118	5	105	303	\N	4	8
8117	5	104	299	\N	4	8
8116	5	103	294	\N	4	8
8115	5	102	290	\N	4	8
8114	5	101	287	\N	4	8
8113	5	100	286	\N	4	8
8112	5	99	283	\N	4	8
8111	5	98	282	\N	4	8
8110	5	97	280	\N	4	8
8109	5	96	277	\N	4	8
8108	5	95	275	\N	4	8
8107	5	94	274	\N	4	8
8106	5	93	271	\N	4	8
209	5	74	223	\N	7	9
210	5	75	226	\N	7	9
211	5	76	230	\N	7	9
212	5	77	234	\N	7	9
8050	5	407	1431	\N	22	10
8040	5	397	1381	\N	22	10
8041	5	398	1386	\N	22	10
8042	5	399	1391	\N	22	10
8043	5	400	1396	\N	22	10
8044	5	401	1401	\N	22	10
8045	5	402	1405	\N	22	10
8046	5	403	1410	\N	22	10
8047	5	404	1415	\N	22	10
8048	5	405	1420	\N	22	10
8054	5	411	1450	\N	22	10
8053	5	410	1446	\N	22	10
8052	5	409	1440	\N	22	10
8051	5	408	1436	\N	22	10
8049	5	406	1426	\N	22	10
10423	5	549	1885	20	26	11
10424	5	550	1889	20	26	11
10425	5	551	1893	20	26	11
10406	5	532	1817	20	26	11
10407	5	533	1822	20	26	11
10408	5	534	1825	20	26	11
10409	5	535	1829	20	26	11
10410	5	536	1833	20	26	11
10411	5	537	1838	20	26	11
10412	5	538	1842	20	26	11
10413	5	539	1845	20	26	11
10414	5	540	1850	20	26	11
10415	5	541	1853	20	26	11
10416	5	542	1858	20	26	11
10417	5	543	1862	20	26	11
10418	5	544	1865	20	26	11
8076	6	103	294	\N	4	12
8068	6	95	275	\N	4	12
8067	6	94	274	\N	4	12
8066	6	93	271	\N	4	12
8065	6	92	270	\N	4	12
8064	6	91	267	\N	4	12
8094	6	121	366	\N	4	12
8093	6	120	361	\N	4	12
8092	6	119	358	\N	4	12
8091	6	118	354	\N	4	12
8063	6	90	265	\N	4	12
8062	6	89	264	\N	4	12
8061	6	88	261	\N	4	12
8060	6	87	259	\N	4	12
8059	6	86	257	\N	4	12
8058	6	85	256	\N	4	12
8057	6	84	254	\N	4	12
8056	6	83	251	\N	4	12
8055	6	82	250	\N	4	12
8090	6	117	350	\N	4	12
8089	6	116	346	\N	4	12
8088	6	115	342	\N	4	12
8087	6	114	338	\N	4	12
8086	6	113	334	\N	4	12
8085	6	112	331	\N	4	12
8084	6	111	325	\N	4	12
8083	6	110	321	\N	4	12
8082	6	109	317	\N	4	12
8081	6	108	314	\N	4	12
8080	6	107	311	\N	4	12
8079	6	106	306	\N	4	12
8078	6	105	303	\N	4	12
8077	6	104	299	\N	4	12
8075	6	102	290	\N	4	12
8074	6	101	287	\N	4	12
8073	6	100	286	\N	4	12
8072	6	99	283	\N	4	12
8071	6	98	282	\N	4	12
8070	6	97	280	\N	4	12
8069	6	96	277	\N	4	12
215	6	70	207	\N	7	13
218	6	73	218	\N	7	13
219	6	74	224	\N	7	13
220	6	75	226	\N	7	13
221	6	76	232	\N	7	13
222	6	77	234	\N	7	13
216	6	71	210	\N	7	13
217	6	72	213	\N	7	13
213	6	68	198	\N	7	13
214	6	69	202	\N	7	13
10426	6	532	1817	20	26	15
10439	6	545	1869	20	26	15
10438	6	544	1865	20	26	15
10437	6	543	1862	20	26	15
10436	6	542	1858	20	26	15
10435	6	541	1853	20	26	15
10427	6	533	1822	20	26	15
10431	6	537	1838	20	26	15
10430	6	536	1833	20	26	15
10440	6	546	1873	20	26	15
10441	6	547	1877	20	26	15
10442	6	548	1882	20	26	15
10443	6	549	1885	20	26	15
10444	6	550	1889	20	26	15
10445	6	551	1893	20	26	15
10429	6	535	1829	20	26	15
10428	6	534	1825	20	26	15
10434	6	540	1850	20	26	15
10433	6	539	1845	20	26	15
10432	6	538	1842	20	26	15
9999	10	505	1707	17	18	17
9990	10	496	1674	17	18	17
9989	10	495	1672	17	18	17
9988	10	494	1667	17	18	17
9987	10	493	1662	17	18	17
9991	10	497	1676	17	18	17
9986	10	492	1657	17	18	17
9996	10	502	1698	17	18	17
10005	10	511	1731	17	18	17
10004	10	510	1726	17	18	17
10003	10	509	1721	17	18	17
10002	10	508	1720	17	18	17
10001	10	507	1714	17	18	17
10000	10	506	1712	17	18	17
9992	10	498	1685	17	18	17
9993	10	499	1687	17	18	17
9994	10	500	1689	17	18	17
9995	10	501	1693	17	18	17
9997	10	503	1700	17	18	17
9998	10	504	1702	17	18	17
9574	11	500	1688	17	18	19
9566	11	492	1657	17	18	19
9567	11	493	1662	17	18	19
9568	11	494	1667	17	18	19
9569	11	495	1672	17	18	19
9570	11	496	1674	17	18	19
9571	11	497	1676	17	18	19
9572	11	498	1682	17	18	19
9573	11	499	1687	17	18	19
9575	11	501	1697	17	18	19
9576	11	502	1699	17	18	19
9577	11	503	1700	17	18	19
9578	11	504	1702	17	18	19
9579	11	505	1707	17	18	19
9580	11	506	1712	17	18	19
9581	11	507	1714	17	18	19
9582	11	508	1719	17	18	19
9583	11	509	1724	17	18	19
9584	11	510	1726	17	18	19
9585	11	511	1731	17	18	19
9094	12	500	1691	17	18	21
9093	12	499	1687	17	18	21
9092	12	498	1684	17	18	21
9091	12	497	1676	17	18	21
9090	12	496	1674	17	18	21
9089	12	495	1672	17	18	21
9088	12	494	1667	17	18	21
9087	12	493	1662	17	18	21
9935	13	481	1635	18	25	23
9940	13	486	1645	18	25	23
9939	13	485	1644	18	25	23
9938	13	484	1641	18	25	23
9937	13	483	1639	18	25	23
9936	13	482	1637	18	25	23
9942	13	488	1649	18	25	23
9943	13	489	1651	18	25	23
9944	13	490	1654	18	25	23
9945	13	491	1655	18	25	23
9941	13	487	1648	18	25	23
9926	13	472	1617	18	25	23
9927	13	473	1619	18	25	23
9928	13	474	1622	18	25	23
9929	13	475	1623	18	25	23
9930	13	476	1625	18	25	23
9792	14	498	1681	17	18	24
9791	14	497	1676	17	18	24
9790	14	496	1674	17	18	24
9789	14	495	1672	17	18	24
9788	14	494	1667	17	18	24
9787	14	493	1662	17	18	24
9786	14	492	1657	17	18	24
9805	14	511	1733	17	18	24
9804	14	510	1726	17	18	24
9803	14	509	1721	17	18	24
9802	14	508	1719	17	18	24
9801	14	507	1714	17	18	24
9799	14	505	1707	17	18	24
8341	15	447	1567	12	24	26
8339	15	445	1563	12	24	26
8326	15	432	1537	12	24	26
8327	15	433	1540	12	24	26
8328	15	434	1541	12	24	26
8329	15	435	1543	12	24	26
8330	15	436	1546	12	24	26
8331	15	437	1547	12	24	26
8332	15	438	1549	12	24	26
8333	15	439	1551	12	24	26
8334	15	440	1553	12	24	26
8335	15	441	1555	12	24	26
8336	15	442	1558	12	24	26
8337	15	443	1559	12	24	26
8338	15	444	1561	12	24	26
8345	15	451	1576	12	24	26
8344	15	450	1573	12	24	26
8343	15	449	1571	12	24	26
8342	15	448	1569	12	24	26
8340	15	446	1566	12	24	26
334	16	210	639	\N	17	27
333	16	209	636	\N	17	27
332	16	208	635	\N	17	27
331	16	207	632	\N	17	27
327	16	203	624	\N	17	27
335	16	211	640	\N	17	27
342	16	218	654	\N	17	27
341	16	217	652	\N	17	27
330	16	206	630	\N	17	27
329	16	205	628	\N	17	27
328	16	204	627	\N	17	27
340	16	216	650	\N	17	27
339	16	215	648	\N	17	27
338	16	214	646	\N	17	27
337	16	213	644	\N	17	27
336	16	212	642	\N	17	27
8350	16	436	1546	12	24	28
8351	16	437	1547	12	24	28
8352	16	438	1549	12	24	28
8353	16	439	1551	12	24	28
8354	16	440	1553	12	24	28
8365	16	451	1575	12	24	28
8361	16	447	1567	12	24	28
8364	16	450	1573	12	24	28
8363	16	449	1571	12	24	28
8362	16	448	1569	12	24	28
8355	16	441	1555	12	24	28
8356	16	442	1558	12	24	28
8357	16	443	1559	12	24	28
8358	16	444	1561	12	24	28
8359	16	445	1563	12	24	28
8346	16	432	1537	12	24	28
8347	16	433	1540	12	24	28
8348	16	434	1541	12	24	28
8349	16	435	1543	12	24	28
8360	16	446	1565	12	24	28
343	17	199	616	\N	17	29
362	17	218	655	\N	17	29
361	17	217	652	\N	17	29
360	17	216	651	\N	17	29
359	17	215	648	\N	17	29
358	17	214	646	\N	17	29
357	17	213	645	\N	17	29
356	17	212	642	\N	17	29
355	17	211	640	\N	17	29
354	17	210	638	\N	17	29
353	17	209	637	\N	17	29
352	17	208	635	\N	17	29
351	17	207	632	\N	17	29
350	17	206	630	\N	17	29
349	17	205	628	\N	17	29
348	17	204	626	\N	17	29
347	17	203	624	\N	17	29
346	17	202	623	\N	17	29
345	17	201	621	\N	17	29
344	17	200	618	\N	17	29
8389	17	435	1544	12	24	30
8391	17	437	1547	12	24	30
8392	17	438	1549	12	24	30
8394	17	440	1553	12	24	30
8395	17	441	1556	12	24	30
8396	17	442	1558	12	24	30
8397	17	443	1559	12	24	30
8398	17	444	1561	12	24	30
8399	17	445	1563	12	24	30
8400	17	446	1566	12	24	30
8401	17	447	1567	12	24	30
8402	17	448	1569	12	24	30
8403	17	449	1571	12	24	30
8404	17	450	1574	12	24	30
8405	17	451	1575	12	24	30
8393	17	439	1551	12	24	30
8386	17	432	1537	12	24	30
8387	17	433	1539	12	24	30
8388	17	434	1542	12	24	30
8390	17	436	1545	12	24	30
423	21	199	616	\N	17	32
9837	21	483	1639	18	25	34
9839	21	485	1644	18	25	34
9840	21	486	1645	18	25	34
9841	21	487	1647	18	25	34
9842	21	488	1649	18	25	34
9843	21	489	1652	18	25	34
9844	21	490	1653	18	25	34
9845	21	491	1655	18	25	34
9826	21	472	1618	18	25	34
9827	21	473	1619	18	25	34
9828	21	474	1622	18	25	34
9829	21	475	1623	18	25	34
9830	21	476	1625	18	25	34
9831	21	477	1628	18	25	34
9832	21	478	1629	18	25	34
9833	21	479	1631	18	25	34
9834	21	480	1634	18	25	34
9835	21	481	1636	18	25	34
9836	21	482	1637	18	25	34
9838	21	484	1642	18	25	34
2560	22	216	651	\N	17	35
2561	22	217	652	\N	17	35
2562	22	218	654	\N	17	35
2547	22	203	624	\N	17	35
2546	22	202	622	\N	17	35
2545	22	201	620	\N	17	35
2544	22	200	619	\N	17	35
2543	22	199	616	\N	17	35
2550	22	206	630	\N	17	35
2549	22	205	628	\N	17	35
2548	22	204	627	\N	17	35
2551	22	207	632	\N	17	35
2552	22	208	635	\N	17	35
2553	22	209	636	\N	17	35
2554	22	210	638	\N	17	35
2555	22	211	640	\N	17	35
2556	22	212	642	\N	17	35
2557	22	213	645	\N	17	35
2558	22	214	646	\N	17	35
2559	22	215	648	\N	17	35
2768	23	204	626	\N	17	36
2763	23	199	616	\N	17	36
2764	23	200	618	\N	17	36
2765	23	201	621	\N	17	36
2766	23	202	622	\N	17	36
2767	23	203	624	\N	17	36
2769	23	205	628	\N	17	36
2770	23	206	630	\N	17	36
2771	23	207	632	\N	17	36
2772	23	208	635	\N	17	36
2773	23	209	637	\N	17	36
2774	23	210	639	\N	17	36
2775	23	211	640	\N	17	36
2776	23	212	642	\N	17	36
2777	23	213	644	\N	17	36
2778	23	214	646	\N	17	36
2779	23	215	648	\N	17	36
2780	23	216	650	\N	17	36
2781	23	217	652	\N	17	36
2782	23	218	655	\N	17	36
3908	24	204	626	\N	17	37
3909	24	205	628	\N	17	37
3911	24	207	633	\N	17	37
3912	24	208	634	\N	17	37
3913	24	209	637	\N	17	37
3914	24	210	638	\N	17	37
3915	24	211	640	\N	17	37
3903	24	199	616	\N	17	37
3904	24	200	618	\N	17	37
3905	24	201	621	\N	17	37
3906	24	202	622	\N	17	37
3907	24	203	625	\N	17	37
3922	24	218	655	\N	17	37
3921	24	217	652	\N	17	37
3920	24	216	650	\N	17	37
8035	5	392	1356	\N	22	10
8036	5	393	1360	\N	22	10
8037	5	394	1366	\N	22	10
8038	5	395	1372	\N	22	10
8039	5	396	1375	\N	22	10
9101	12	507	1714	17	18	21
9105	12	511	1731	17	18	21
9104	12	510	1726	17	18	21
9103	12	509	1721	17	18	21
9102	12	508	1719	17	18	21
9100	12	506	1713	17	18	21
9099	12	505	1708	17	18	21
9098	12	504	1702	17	18	21
9097	12	503	1701	17	18	21
9096	12	502	1698	17	18	21
9095	12	501	1693	17	18	21
3919	24	215	648	\N	17	37
3918	24	214	646	\N	17	37
3917	24	213	645	\N	17	37
3916	24	212	642	\N	17	37
3910	24	206	630	\N	17	37
8146	26	413	1461	\N	15	38
8145	26	412	1455	\N	15	38
8151	26	418	1486	\N	15	38
8150	26	417	1481	\N	15	38
8149	26	416	1475	\N	15	38
8148	26	415	1471	\N	15	38
8147	26	414	1464	\N	15	38
9716	26	502	1698	17	18	39
9718	26	504	1702	17	18	39
9719	26	505	1707	17	18	39
9720	26	506	1712	17	18	39
9721	26	507	1714	17	18	39
9722	26	508	1719	17	18	39
9723	26	509	1721	17	18	39
9724	26	510	1726	17	18	39
9725	26	511	1731	17	18	39
9706	26	492	1657	17	18	39
9707	26	493	1662	17	18	39
9708	26	494	1667	17	18	39
9709	26	495	1672	17	18	39
9710	26	496	1674	17	18	39
9711	26	497	1676	17	18	39
9712	26	498	1681	17	18	39
9713	26	499	1687	17	18	39
9714	26	500	1692	17	18	39
9715	26	501	1693	17	18	39
9717	26	503	1700	17	18	39
9756	29	482	1637	18	25	40
9758	29	484	1641	18	25	40
9759	29	485	1644	18	25	40
9760	29	486	1645	18	25	40
9761	29	487	1648	18	25	40
9762	29	488	1650	18	25	40
9763	29	489	1651	18	25	40
9764	29	490	1654	18	25	40
9765	29	491	1656	18	25	40
9746	29	472	1617	18	25	40
9747	29	473	1619	18	25	40
9748	29	474	1622	18	25	40
9749	29	475	1623	18	25	40
9750	29	476	1625	18	25	40
9751	29	477	1628	18	25	40
9752	29	478	1629	18	25	40
9753	29	479	1631	18	25	40
9754	29	480	1633	18	25	40
9755	29	481	1636	18	25	40
9757	29	483	1639	18	25	40
10131	31	477	1628	18	25	42
10130	31	476	1625	18	25	42
10145	31	491	1656	18	25	42
10144	31	490	1653	18	25	42
10143	31	489	1652	18	25	42
10142	31	488	1649	18	25	42
10141	31	487	1647	18	25	42
10140	31	486	1645	18	25	42
10139	31	485	1644	18	25	42
10138	31	484	1641	18	25	42
10137	31	483	1639	18	25	42
10136	31	482	1637	18	25	42
10126	31	472	1617	18	25	42
10127	31	473	1619	18	25	42
10128	31	474	1622	18	25	42
10129	31	475	1623	18	25	42
10135	31	481	1635	18	25	42
10134	31	480	1633	18	25	42
10133	31	479	1631	18	25	42
10132	31	478	1630	18	25	42
7509	33	193	601	\N	14	44
7510	33	194	603	\N	14	44
7511	33	195	605	\N	14	44
7512	33	196	607	\N	14	44
7570	34	349	1149	\N	21	45
7558	34	337	1094	\N	21	45
7559	34	338	1099	\N	21	45
7560	34	339	1104	\N	21	45
7561	34	340	1109	\N	21	45
7562	34	341	1115	\N	21	45
7563	34	342	1121	\N	21	45
7564	34	343	1124	\N	21	45
7565	34	344	1129	\N	21	45
7566	34	345	1135	\N	21	45
7567	34	346	1139	\N	21	45
7568	34	347	1144	\N	21	45
7569	34	348	1147	\N	21	45
7571	34	350	1151	\N	21	45
7572	34	351	1152	\N	21	45
10235	34	481	1636	19	25	46
10236	34	482	1637	19	25	46
10237	34	483	1639	19	25	46
10238	34	484	1642	19	25	46
10239	34	485	1644	19	25	46
10240	34	486	1645	19	25	46
10228	34	474	1622	19	25	46
10229	34	475	1623	19	25	46
10245	34	491	1656	19	25	46
10244	34	490	1654	19	25	46
10243	34	489	1651	19	25	46
10242	34	488	1649	19	25	46
10241	34	487	1648	19	25	46
10226	34	472	1617	19	25	46
10227	34	473	1619	19	25	46
10230	34	476	1626	19	25	46
10231	34	477	1628	19	25	46
10232	34	478	1629	19	25	46
10233	34	479	1632	19	25	46
10234	34	480	1633	19	25	46
7739	35	338	1103	\N	21	47
7752	35	351	1152	\N	21	47
7751	35	350	1151	\N	21	47
7750	35	349	1149	\N	21	47
7749	35	348	1147	\N	21	47
7738	35	337	1094	\N	21	47
7740	35	339	1104	\N	21	47
7741	35	340	1109	\N	21	47
7742	35	341	1116	\N	21	47
7743	35	342	1119	\N	21	47
7744	35	343	1127	\N	21	47
7748	35	347	1144	\N	21	47
7747	35	346	1139	\N	21	47
7746	35	345	1134	\N	21	47
7745	35	344	1129	\N	21	47
7514	36	338	1099	\N	21	48
7515	36	339	1108	\N	21	48
7516	36	340	1113	\N	21	48
7517	36	341	1114	\N	21	48
7518	36	342	1120	\N	21	48
7519	36	343	1124	\N	21	48
7520	36	344	1129	\N	21	48
7521	36	345	1134	\N	21	48
7522	36	346	1139	\N	21	48
7527	36	351	1152	\N	21	48
7526	36	350	1151	\N	21	48
7525	36	349	1148	\N	21	48
7524	36	348	1147	\N	21	48
7523	36	347	1144	\N	21	48
7513	36	337	1094	\N	21	48
10156	36	482	1637	19	25	49
10157	36	483	1639	19	25	49
10158	36	484	1641	19	25	49
10165	36	491	1655	19	25	49
10164	36	490	1654	19	25	49
10163	36	489	1651	19	25	49
10162	36	488	1649	19	25	49
10161	36	487	1648	19	25	49
10160	36	486	1645	19	25	49
10159	36	485	1644	19	25	49
10146	36	472	1617	19	25	49
10147	36	473	1619	19	25	49
10148	36	474	1622	19	25	49
10149	36	475	1623	19	25	49
10150	36	476	1625	19	25	49
10151	36	477	1628	19	25	49
10152	36	478	1629	19	25	49
10153	36	479	1631	19	25	49
10154	36	480	1633	19	25	49
10155	36	481	1636	19	25	49
7606	37	340	1109	\N	21	50
7607	37	341	1114	\N	21	50
7608	37	342	1120	\N	21	50
7609	37	343	1124	\N	21	50
7610	37	344	1129	\N	21	50
7611	37	345	1135	\N	21	50
7612	37	346	1139	\N	21	50
7613	37	347	1144	\N	21	50
7614	37	348	1146	\N	21	50
7615	37	349	1148	\N	21	50
7616	37	350	1151	\N	21	50
7617	37	351	1152	\N	21	50
7603	37	337	1094	\N	21	50
7604	37	338	1099	\N	21	50
7605	37	339	1104	\N	21	50
10120	37	486	1645	19	25	51
10106	37	472	1617	19	25	51
10121	37	487	1648	19	25	51
10122	37	488	1649	19	25	51
10123	37	489	1652	19	25	51
10124	37	490	1654	19	25	51
10118	37	484	1641	19	25	51
10117	37	483	1639	19	25	51
10116	37	482	1637	19	25	51
10115	37	481	1636	19	25	51
10114	37	480	1633	19	25	51
10125	37	491	1655	19	25	51
10113	37	479	1632	19	25	51
10112	37	478	1629	19	25	51
10111	37	477	1628	19	25	51
10110	37	476	1625	19	25	51
10109	37	475	1623	19	25	51
10108	37	474	1622	19	25	51
10107	37	473	1619	19	25	51
10119	37	485	1644	19	25	51
7806	38	344	1129	\N	21	52
7804	38	342	1119	\N	21	52
7805	38	343	1124	\N	21	52
7807	38	345	1135	\N	21	52
7808	38	346	1139	\N	21	52
7809	38	347	1144	\N	21	52
7811	38	348	1147	\N	21	52
7813	38	349	1148	\N	21	52
7815	38	350	1151	\N	21	52
7817	38	351	1153	\N	21	52
10291	38	477	1628	19	25	53
10304	38	490	1654	19	25	53
10303	38	489	1651	19	25	53
10287	38	473	1619	19	25	53
10288	38	474	1622	19	25	53
10289	38	475	1623	19	25	53
10302	38	488	1649	19	25	53
10296	38	482	1637	19	25	53
10295	38	481	1636	19	25	53
10294	38	480	1633	19	25	53
10293	38	479	1631	19	25	53
10297	38	483	1639	19	25	53
10298	38	484	1641	19	25	53
10299	38	485	1644	19	25	53
10300	38	486	1645	19	25	53
10301	38	487	1648	19	25	53
10290	38	476	1625	19	25	53
10292	38	478	1629	19	25	53
10305	38	491	1655	19	25	53
10286	38	472	1617	19	25	53
7530	39	339	1104	\N	21	54
7529	39	338	1100	\N	21	54
7528	39	337	1094	\N	21	54
7542	39	351	1152	\N	21	54
7531	39	340	1109	\N	21	54
7532	39	341	1115	\N	21	54
7533	39	342	1123	\N	21	54
7534	39	343	1126	\N	21	54
7535	39	344	1129	\N	21	54
7536	39	345	1135	\N	21	54
7537	39	346	1139	\N	21	54
7538	39	347	1144	\N	21	54
7540	39	349	1148	\N	21	54
7539	39	348	1146	\N	21	54
7541	39	350	1151	\N	21	54
10249	39	475	1623	19	25	55
10260	39	486	1645	19	25	55
10259	39	485	1644	19	25	55
10261	39	487	1648	19	25	55
10262	39	488	1649	19	25	55
10263	39	489	1651	19	25	55
10264	39	490	1654	19	25	55
10265	39	491	1655	19	25	55
10246	39	472	1617	19	25	55
10247	39	473	1619	19	25	55
10248	39	474	1622	19	25	55
10250	39	476	1625	19	25	55
10251	39	477	1628	19	25	55
10252	39	478	1629	19	25	55
10253	39	479	1631	19	25	55
10254	39	480	1633	19	25	55
10255	39	481	1636	19	25	55
10256	39	482	1637	19	25	55
10257	39	483	1639	19	25	55
10258	39	484	1641	19	25	55
7585	40	349	1149	\N	21	56
7584	40	348	1146	\N	21	56
7583	40	347	1144	\N	21	56
7582	40	346	1143	\N	21	56
7581	40	345	1135	\N	21	56
7574	40	338	1099	\N	21	56
7587	40	351	1152	\N	21	56
7573	40	337	1094	\N	21	56
7575	40	339	1107	\N	21	56
7576	40	340	1109	\N	21	56
7577	40	341	1117	\N	21	56
7578	40	342	1120	\N	21	56
7579	40	343	1125	\N	21	56
7580	40	344	1129	\N	21	56
7586	40	350	1151	\N	21	56
10317	40	483	1639	19	25	57
10307	40	473	1619	19	25	57
10316	40	482	1637	19	25	57
10315	40	481	1636	19	25	57
10311	40	477	1628	19	25	57
10310	40	476	1625	19	25	57
10309	40	475	1623	19	25	57
10306	40	472	1617	19	25	57
10314	40	480	1633	19	25	57
10313	40	479	1631	19	25	57
10325	40	491	1655	19	25	57
10324	40	490	1653	19	25	57
10322	40	488	1649	19	25	57
10308	40	474	1622	19	25	57
10312	40	478	1629	19	25	57
10323	40	489	1651	19	25	57
10321	40	487	1648	19	25	57
10320	40	486	1645	19	25	57
10319	40	485	1644	19	25	57
10318	40	484	1641	19	25	57
7832	41	341	1114	\N	21	58
7834	41	343	1124	\N	21	58
7835	41	344	1129	\N	21	58
7836	41	345	1135	\N	21	58
7837	41	346	1139	\N	21	58
7842	41	351	1152	\N	21	58
7828	41	337	1094	\N	21	58
7829	41	338	1099	\N	21	58
7830	41	339	1104	\N	21	58
7831	41	340	1109	\N	21	58
7841	41	350	1150	\N	21	58
7840	41	349	1148	\N	21	58
7839	41	348	1146	\N	21	58
7838	41	347	1144	\N	21	58
7833	41	342	1119	\N	21	58
7554	42	348	1147	\N	21	59
7543	42	337	1095	\N	21	59
7552	42	346	1139	\N	21	59
7551	42	345	1135	\N	21	59
7550	42	344	1131	\N	21	59
7549	42	343	1128	\N	21	59
7548	42	342	1120	\N	21	59
7547	42	341	1114	\N	21	59
7546	42	340	1109	\N	21	59
7545	42	339	1107	\N	21	59
7544	42	338	1101	\N	21	59
7557	42	351	1152	\N	21	59
7556	42	350	1150	\N	21	59
7553	42	347	1144	\N	21	59
7555	42	349	1149	\N	21	59
10210	42	476	1625	19	25	60
10206	42	472	1617	19	25	60
10207	42	473	1619	19	25	60
10208	42	474	1622	19	25	60
10209	42	475	1623	19	25	60
10211	42	477	1628	19	25	60
10212	42	478	1629	19	25	60
10213	42	479	1631	19	25	60
10214	42	480	1633	19	25	60
10215	42	481	1635	19	25	60
10216	42	482	1637	19	25	60
10217	42	483	1639	19	25	60
10218	42	484	1641	19	25	60
10219	42	485	1643	19	25	60
10220	42	486	1645	19	25	60
10221	42	487	1647	19	25	60
10222	42	488	1649	19	25	60
10223	42	489	1651	19	25	60
10224	42	490	1654	19	25	60
10225	42	491	1655	19	25	60
7735	43	349	1148	\N	21	61
7734	43	348	1147	\N	21	61
7733	43	347	1144	\N	21	61
7732	43	346	1139	\N	21	61
7736	43	350	1151	\N	21	61
7731	43	345	1136	\N	21	61
7730	43	344	1131	\N	21	61
7729	43	343	1126	\N	21	61
7728	43	342	1121	\N	21	61
7727	43	341	1115	\N	21	61
7726	43	340	1113	\N	21	61
7725	43	339	1108	\N	21	61
7724	43	338	1099	\N	21	61
7723	43	337	1094	\N	21	61
7737	43	351	1152	\N	21	61
10081	43	487	1648	19	25	62
10082	43	488	1649	19	25	62
10083	43	489	1651	19	25	62
10084	43	490	1654	19	25	62
10085	43	491	1655	19	25	62
10078	43	484	1641	19	25	62
10067	43	473	1619	19	25	62
10068	43	474	1622	19	25	62
10069	43	475	1623	19	25	62
10070	43	476	1625	19	25	62
10071	43	477	1628	19	25	62
10072	43	478	1629	19	25	62
10073	43	479	1632	19	25	62
10074	43	480	1633	19	25	62
10075	43	481	1636	19	25	62
10076	43	482	1637	19	25	62
10077	43	483	1639	19	25	62
10066	43	472	1617	19	25	62
10079	43	485	1644	19	25	62
10080	43	486	1645	19	25	62
7602	44	351	1152	\N	21	63
7601	44	350	1151	\N	21	63
7600	44	349	1148	\N	21	63
7599	44	348	1146	\N	21	63
7598	44	347	1144	\N	21	63
7597	44	346	1139	\N	21	63
7596	44	345	1135	\N	21	63
7595	44	344	1129	\N	21	63
7594	44	343	1127	\N	21	63
7593	44	342	1121	\N	21	63
7592	44	341	1114	\N	21	63
7591	44	340	1109	\N	21	63
7590	44	339	1104	\N	21	63
7589	44	338	1099	\N	21	63
7588	44	337	1094	\N	21	63
10403	44	489	1651	19	25	64
10386	44	472	1617	19	25	64
10387	44	473	1619	19	25	64
10388	44	474	1622	19	25	64
10389	44	475	1623	19	25	64
10390	44	476	1625	19	25	64
10405	44	491	1655	19	25	64
10404	44	490	1654	19	25	64
10402	44	488	1649	19	25	64
10401	44	487	1648	19	25	64
10400	44	486	1645	19	25	64
10399	44	485	1644	19	25	64
10398	44	484	1641	19	25	64
10397	44	483	1639	19	25	64
10396	44	482	1637	19	25	64
10395	44	481	1636	19	25	64
10394	44	480	1633	19	25	64
10393	44	479	1631	19	25	64
10392	44	478	1629	19	25	64
10391	44	477	1628	19	25	64
7779	45	348	1147	\N	21	65
7780	45	349	1148	\N	21	65
7777	45	346	1139	\N	21	65
7781	45	350	1151	\N	21	65
7776	45	345	1134	\N	21	65
7775	45	344	1129	\N	21	65
7778	45	347	1144	\N	21	65
7774	45	343	1128	\N	21	65
7773	45	342	1119	\N	21	65
7772	45	341	1114	\N	21	65
7771	45	340	1111	\N	21	65
7770	45	339	1107	\N	21	65
7769	45	338	1103	\N	21	65
7768	45	337	1096	\N	21	65
7644	46	348	1146	\N	21	66
7647	46	351	1152	\N	21	66
7646	46	350	1151	\N	21	66
7645	46	349	1149	\N	21	66
7643	46	347	1144	\N	21	66
7642	46	346	1139	\N	21	66
7641	46	345	1135	\N	21	66
7640	46	344	1129	\N	21	66
7639	46	343	1127	\N	21	66
7638	46	342	1121	\N	21	66
7637	46	341	1117	\N	21	66
7636	46	340	1113	\N	21	66
7635	46	339	1107	\N	21	66
7634	46	338	1100	\N	21	66
7633	46	337	1094	\N	21	66
7762	47	346	1139	\N	21	67
7763	47	347	1144	\N	21	67
7764	47	348	1147	\N	21	67
7765	47	349	1148	\N	21	67
7766	47	350	1151	\N	21	67
7767	47	351	1152	\N	21	67
7761	47	345	1135	\N	21	67
7755	47	339	1104	\N	21	67
7756	47	340	1109	\N	21	67
7757	47	341	1114	\N	21	67
7758	47	342	1119	\N	21	67
7759	47	343	1124	\N	21	67
7760	47	344	1129	\N	21	67
7753	47	337	1094	\N	21	67
7754	47	338	1099	\N	21	67
10274	47	480	1633	19	25	68
10267	47	473	1619	19	25	68
10268	47	474	1622	19	25	68
10269	47	475	1623	19	25	68
10270	47	476	1625	19	25	68
10271	47	477	1628	19	25	68
10285	47	491	1655	19	25	68
10272	47	478	1629	19	25	68
10266	47	472	1617	19	25	68
10284	47	490	1654	19	25	68
10283	47	489	1651	19	25	68
10282	47	488	1649	19	25	68
10281	47	487	1648	19	25	68
10280	47	486	1645	19	25	68
10279	47	485	1644	19	25	68
10278	47	484	1641	19	25	68
10277	47	483	1639	19	25	68
10276	47	482	1637	19	25	68
10275	47	481	1636	19	25	68
10273	47	479	1631	19	25	68
7621	48	340	1109	\N	21	69
7622	48	341	1115	\N	21	69
7632	48	351	1153	\N	21	69
7631	48	350	1150	\N	21	69
7630	48	349	1148	\N	21	69
7629	48	348	1147	\N	21	69
7628	48	347	1144	\N	21	69
7627	48	346	1139	\N	21	69
7626	48	345	1135	\N	21	69
7625	48	344	1133	\N	21	69
7624	48	343	1126	\N	21	69
7623	48	342	1120	\N	21	69
7618	48	337	1094	\N	21	69
7619	48	338	1099	\N	21	69
7620	48	339	1104	\N	21	69
10168	48	474	1622	19	25	70
10166	48	472	1617	19	25	70
10185	48	491	1655	19	25	70
10184	48	490	1654	19	25	70
10183	48	489	1651	19	25	70
10182	48	488	1649	19	25	70
10181	48	487	1648	19	25	70
10180	48	486	1645	19	25	70
10179	48	485	1644	19	25	70
10178	48	484	1641	19	25	70
10177	48	483	1639	19	25	70
10176	48	482	1637	19	25	70
10175	48	481	1635	19	25	70
10174	48	480	1633	19	25	70
10173	48	479	1631	19	25	70
10172	48	478	1629	19	25	70
10171	48	477	1628	19	25	70
10170	48	476	1625	19	25	70
10169	48	475	1623	19	25	70
10167	48	473	1619	19	25	70
7707	49	351	1153	\N	21	71
7705	49	349	1148	\N	21	71
7704	49	348	1147	\N	21	71
7693	49	337	1096	\N	21	71
7706	49	350	1151	\N	21	71
7703	49	347	1144	\N	21	71
7699	49	343	1126	\N	21	71
7702	49	346	1143	\N	21	71
7698	49	342	1120	\N	21	71
7697	49	341	1114	\N	21	71
7696	49	340	1112	\N	21	71
7695	49	339	1107	\N	21	71
7694	49	338	1101	\N	21	71
7701	49	345	1136	\N	21	71
7700	49	344	1133	\N	21	71
10194	50	480	1633	19	25	73
10193	50	479	1632	19	25	73
10187	50	473	1619	19	25	73
10188	50	474	1621	19	25	73
10189	50	475	1623	19	25	73
10190	50	476	1625	19	25	73
10191	50	477	1628	19	25	73
10192	50	478	1629	19	25	73
10200	50	486	1645	19	25	73
10201	50	487	1648	19	25	73
10202	50	488	1649	19	25	73
10203	50	489	1651	19	25	73
10204	50	490	1654	19	25	73
10205	50	491	1655	19	25	73
10186	50	472	1618	19	25	73
10197	50	483	1639	19	25	73
10196	50	482	1637	19	25	73
10195	50	481	1636	19	25	73
10198	50	484	1641	19	25	73
10199	50	485	1644	19	25	73
7677	51	351	1152	\N	21	74
7663	51	337	1094	\N	21	74
7676	51	350	1150	\N	21	74
7675	51	349	1148	\N	21	74
7674	51	348	1147	\N	21	74
7673	51	347	1144	\N	21	74
7672	51	346	1139	\N	21	74
7671	51	345	1135	\N	21	74
7670	51	344	1129	\N	21	74
7669	51	343	1126	\N	21	74
7664	51	338	1099	\N	21	74
7665	51	339	1104	\N	21	74
7666	51	340	1111	\N	21	74
7667	51	341	1116	\N	21	74
7668	51	342	1123	\N	21	74
7689	52	348	1147	\N	21	75
7692	52	351	1153	\N	21	75
7682	52	341	1114	\N	21	75
7683	52	342	1120	\N	21	75
7688	52	347	1144	\N	21	75
7687	52	346	1139	\N	21	75
7686	52	345	1135	\N	21	75
7685	52	344	1129	\N	21	75
7681	52	340	1109	\N	21	75
7680	52	339	1104	\N	21	75
7679	52	338	1099	\N	21	75
7678	52	337	1094	\N	21	75
7684	52	343	1124	\N	21	75
7691	52	350	1151	\N	21	75
7690	52	349	1148	\N	21	75
10093	52	479	1631	19	25	76
10094	52	480	1633	19	25	76
10098	52	484	1641	19	25	76
10099	52	485	1644	19	25	76
10105	52	491	1655	19	25	76
10104	52	490	1654	19	25	76
10103	52	489	1652	19	25	76
10102	52	488	1649	19	25	76
10101	52	487	1648	19	25	76
10100	52	486	1645	19	25	76
10095	52	481	1636	19	25	76
10096	52	482	1637	19	25	76
10097	52	483	1639	19	25	76
10086	52	472	1617	19	25	76
10087	52	473	1620	19	25	76
10088	52	474	1622	19	25	76
10089	52	475	1623	19	25	76
10090	52	476	1625	19	25	76
10091	52	477	1628	19	25	76
10092	52	478	1629	19	25	76
7721	53	350	1151	\N	21	77
7720	53	349	1148	\N	21	77
7708	53	337	1094	\N	21	77
7719	53	348	1146	\N	21	77
7718	53	347	1144	\N	21	77
7717	53	346	1139	\N	21	77
7716	53	345	1136	\N	21	77
7715	53	344	1133	\N	21	77
7709	53	338	1099	\N	21	77
7710	53	339	1105	\N	21	77
7711	53	340	1112	\N	21	77
7712	53	341	1115	\N	21	77
7713	53	342	1120	\N	21	77
7714	53	343	1125	\N	21	77
7722	53	351	1152	\N	21	77
7649	54	338	1099	\N	21	78
7662	54	351	1152	\N	21	78
7661	54	350	1151	\N	21	78
7660	54	349	1148	\N	21	78
7659	54	348	1147	\N	21	78
7658	54	347	1144	\N	21	78
7657	54	346	1139	\N	21	78
7656	54	345	1135	\N	21	78
7655	54	344	1129	\N	21	78
7654	54	343	1127	\N	21	78
7653	54	342	1120	\N	21	78
7652	54	341	1117	\N	21	78
7651	54	340	1109	\N	21	78
7650	54	339	1104	\N	21	78
7648	54	337	1095	\N	21	78
7863	55	342	1123	\N	21	79
7862	55	341	1115	\N	21	79
7872	55	351	1152	\N	21	79
7871	55	350	1151	\N	21	79
7870	55	349	1149	\N	21	79
7869	55	348	1147	\N	21	79
7868	55	347	1144	\N	21	79
7867	55	346	1139	\N	21	79
7866	55	345	1135	\N	21	79
7865	55	344	1129	\N	21	79
7858	55	337	1094	\N	21	79
7859	55	338	1099	\N	21	79
7860	55	339	1104	\N	21	79
7861	55	340	1112	\N	21	79
7864	55	343	1127	\N	21	79
10363	55	489	1651	19	25	80
10364	55	490	1654	19	25	80
10365	55	491	1656	19	25	80
7847	56	341	1114	\N	21	81
7857	56	351	1153	\N	21	81
7856	56	350	1150	\N	21	81
7855	56	349	1149	\N	21	81
7854	56	348	1147	\N	21	81
7853	56	347	1144	\N	21	81
7852	56	346	1139	\N	21	81
7851	56	345	1135	\N	21	81
7850	56	344	1129	\N	21	81
7849	56	343	1125	\N	21	81
7848	56	342	1121	\N	21	81
7846	56	340	1109	\N	21	81
7845	56	339	1104	\N	21	81
7844	56	338	1101	\N	21	81
7843	56	337	1094	\N	21	81
10385	56	491	1655	19	25	82
10366	56	472	1617	19	25	82
10367	56	473	1619	19	25	82
10368	56	474	1622	19	25	82
10369	56	475	1623	19	25	82
10370	56	476	1625	19	25	82
10371	56	477	1628	19	25	82
10372	56	478	1629	19	25	82
10373	56	479	1632	19	25	82
10374	56	480	1633	19	25	82
10375	56	481	1636	19	25	82
10376	56	482	1637	19	25	82
10377	56	483	1639	19	25	82
10378	56	484	1641	19	25	82
10379	56	485	1644	19	25	82
10380	56	486	1645	19	25	82
10381	56	487	1648	19	25	82
10382	56	488	1649	19	25	82
10383	56	489	1651	19	25	82
10384	56	490	1654	19	25	82
9551	59	497	1676	17	18	83
9565	59	511	1731	17	18	83
9550	59	496	1674	17	18	83
9549	59	495	1672	17	18	83
9548	59	494	1667	17	18	83
9547	59	493	1662	17	18	83
9546	59	492	1657	17	18	83
9564	59	510	1726	17	18	83
9563	59	509	1721	17	18	83
9562	59	508	1719	17	18	83
9561	59	507	1714	17	18	83
9560	59	506	1712	17	18	83
9559	59	505	1707	17	18	83
9558	59	504	1702	17	18	83
9557	59	503	1701	17	18	83
9556	59	502	1698	17	18	83
9555	59	501	1693	17	18	83
9554	59	500	1689	17	18	83
9553	59	499	1687	17	18	83
9552	59	498	1681	17	18	83
7895	60	189	593	\N	14	84
7893	60	187	590	\N	14	84
7894	60	188	591	\N	14	84
7896	60	190	596	\N	14	84
7897	60	191	597	\N	14	84
7898	60	192	600	\N	14	84
7899	60	193	601	\N	14	84
7900	60	194	604	\N	14	84
7901	60	195	606	\N	14	84
7902	60	196	607	\N	14	84
9888	60	474	1622	18	25	85
9900	60	486	1645	18	25	85
9899	60	485	1644	18	25	85
9898	60	484	1641	18	25	85
9897	60	483	1639	18	25	85
9896	60	482	1637	18	25	85
9895	60	481	1636	18	25	85
9894	60	480	1633	18	25	85
9893	60	479	1631	18	25	85
9892	60	478	1629	18	25	85
9891	60	477	1628	18	25	85
9890	60	476	1625	18	25	85
9889	60	475	1623	18	25	85
9902	60	488	1649	18	25	85
9903	60	489	1651	18	25	85
9905	60	491	1655	18	25	85
9904	60	490	1654	18	25	85
9901	60	487	1648	18	25	85
9886	60	472	1617	18	25	85
9887	60	473	1619	18	25	85
7932	61	196	607	\N	14	86
7925	61	189	593	\N	14	86
7926	61	190	596	\N	14	86
7927	61	191	598	\N	14	86
7928	61	192	599	\N	14	86
7929	61	193	601	\N	14	86
7930	61	194	603	\N	14	86
7931	61	195	606	\N	14	86
7924	61	188	591	\N	14	86
7923	61	187	590	\N	14	86
7910	61	206	630	\N	17	87
7911	61	207	632	\N	17	87
7912	61	208	635	\N	17	87
7905	61	201	620	\N	17	87
7913	61	209	636	\N	17	87
7904	61	200	619	\N	17	87
7914	61	210	639	\N	17	87
7915	61	211	640	\N	17	87
7916	61	212	642	\N	17	87
7917	61	213	644	\N	17	87
7918	61	214	646	\N	17	87
7922	61	218	654	\N	17	87
7921	61	217	652	\N	17	87
7920	61	216	651	\N	17	87
7919	61	215	648	\N	17	87
7903	61	199	616	\N	17	87
7906	61	202	622	\N	17	87
7907	61	203	624	\N	17	87
7908	61	204	626	\N	17	87
7909	61	205	628	\N	17	87
9858	61	484	1641	18	25	89
9859	61	485	1644	18	25	89
9860	61	486	1645	18	25	89
9861	61	487	1648	18	25	89
9862	61	488	1649	18	25	89
9855	61	481	1636	18	25	89
9854	61	480	1633	18	25	89
9852	61	478	1629	18	25	89
9851	61	477	1628	18	25	89
9850	61	476	1625	18	25	89
9863	61	489	1651	18	25	89
9849	61	475	1623	18	25	89
9848	61	474	1622	18	25	89
9847	61	473	1619	18	25	89
9846	61	472	1617	18	25	89
9857	61	483	1639	18	25	89
9856	61	482	1637	18	25	89
9864	61	490	1654	18	25	89
9865	61	491	1655	18	25	89
9853	61	479	1632	18	25	89
9493	63	499	1687	17	18	90
9505	63	511	1731	17	18	90
9504	63	510	1726	17	18	90
9503	63	509	1721	17	18	90
9502	63	508	1719	17	18	90
9501	63	507	1714	17	18	90
9500	63	506	1712	17	18	90
9499	63	505	1707	17	18	90
9498	63	504	1702	17	18	90
9497	63	503	1700	17	18	90
9496	63	502	1698	17	18	90
9495	63	501	1693	17	18	90
9494	63	500	1689	17	18	90
9492	63	498	1681	17	18	90
9491	63	497	1676	17	18	90
9490	63	496	1674	17	18	90
9489	63	495	1672	17	18	90
9488	63	494	1667	17	18	90
9487	63	493	1662	17	18	90
9486	63	492	1657	17	18	90
9729	63	475	1623	18	25	91
9730	63	476	1625	18	25	91
9726	63	472	1617	18	25	91
9737	63	483	1639	18	25	91
9736	63	482	1637	18	25	91
9735	63	481	1636	18	25	91
9734	63	480	1633	18	25	91
9733	63	479	1631	18	25	91
9732	63	478	1629	18	25	91
9731	63	477	1628	18	25	91
9745	63	491	1655	18	25	91
9744	63	490	1654	18	25	91
9743	63	489	1651	18	25	91
9742	63	488	1649	18	25	91
9741	63	487	1648	18	25	91
9740	63	486	1645	18	25	91
9739	63	485	1644	18	25	91
9738	63	484	1642	18	25	91
9727	63	473	1619	18	25	91
9728	63	474	1622	18	25	91
7966	64	190	596	\N	14	92
7965	64	189	593	\N	14	92
7964	64	188	591	\N	14	92
7963	64	187	590	\N	14	92
9382	65	508	1719	17	18	93
9380	65	506	1712	17	18	93
9381	65	507	1718	17	18	93
9385	65	511	1731	17	18	93
9384	65	510	1727	17	18	93
9378	65	504	1703	17	18	93
9369	65	495	1672	17	18	93
9370	65	496	1674	17	18	93
9371	65	497	1676	17	18	93
9372	65	498	1681	17	18	93
9373	65	499	1687	17	18	93
9374	65	500	1689	17	18	93
9375	65	501	1693	17	18	93
9376	65	502	1698	17	18	93
9379	65	505	1708	17	18	93
9377	65	503	1700	17	18	93
9383	65	509	1721	17	18	93
9964	67	510	1726	17	18	94
9962	67	508	1719	17	18	94
9961	67	507	1714	17	18	94
9960	67	506	1712	17	18	94
9959	67	505	1707	17	18	94
9958	67	504	1702	17	18	94
9957	67	503	1700	17	18	94
9956	67	502	1698	17	18	94
9955	67	501	1693	17	18	94
9954	67	500	1689	17	18	94
9953	67	499	1687	17	18	94
9952	67	498	1681	17	18	94
9951	67	497	1676	17	18	94
9950	67	496	1674	17	18	94
9949	67	495	1672	17	18	94
9948	67	494	1667	17	18	94
9947	67	493	1662	17	18	94
9946	67	492	1657	17	18	94
9965	67	511	1731	17	18	94
9963	67	509	1721	17	18	94
9870	70	476	1625	18	25	97
9885	70	491	1655	18	25	97
9884	70	490	1654	18	25	97
9883	70	489	1651	18	25	97
9882	70	488	1649	18	25	97
9881	70	487	1648	18	25	97
9880	70	486	1645	18	25	97
9879	70	485	1644	18	25	97
9878	70	484	1641	18	25	97
9877	70	483	1639	18	25	97
9876	70	482	1637	18	25	97
9875	70	481	1636	18	25	97
9874	70	480	1633	18	25	97
9873	70	479	1632	18	25	97
9872	70	478	1629	18	25	97
9871	70	477	1628	18	25	97
9869	70	475	1623	18	25	97
9868	70	474	1622	18	25	97
9867	70	473	1619	18	25	97
9866	70	472	1617	18	25	97
8299	71	445	1563	12	24	98
8298	71	444	1561	12	24	98
8297	71	443	1559	12	24	98
8296	71	442	1558	12	24	98
8295	71	441	1555	12	24	98
8294	71	440	1553	12	24	98
8293	71	439	1551	12	24	98
8292	71	438	1549	12	24	98
8291	71	437	1547	12	24	98
8290	71	436	1545	12	24	98
8305	71	451	1575	12	24	98
8304	71	450	1573	12	24	98
8303	71	449	1571	12	24	98
8302	71	448	1569	12	24	98
8301	71	447	1568	12	24	98
8300	71	446	1566	12	24	98
8318	73	444	1562	12	24	99
8313	73	439	1551	12	24	99
8314	73	440	1553	12	24	99
8315	73	441	1555	12	24	99
8325	73	451	1576	12	24	99
8316	73	442	1557	12	24	99
8317	73	443	1559	12	24	99
8319	73	445	1563	12	24	99
8320	73	446	1565	12	24	99
8321	73	447	1567	12	24	99
8322	73	448	1569	12	24	99
8323	73	449	1571	12	24	99
8324	73	450	1573	12	24	99
8306	73	432	1537	12	24	99
8307	73	433	1539	12	24	99
8308	73	434	1541	12	24	99
8309	73	435	1544	12	24	99
8310	73	436	1546	12	24	99
8311	73	437	1547	12	24	99
8312	73	438	1549	12	24	99
8420	74	446	1566	12	24	100
8406	74	432	1537	12	24	100
8407	74	433	1540	12	24	100
8408	74	434	1541	12	24	100
8409	74	435	1543	12	24	100
8410	74	436	1546	12	24	100
8411	74	437	1547	12	24	100
8412	74	438	1549	12	24	100
8413	74	439	1552	12	24	100
8414	74	440	1553	12	24	100
8415	74	441	1555	12	24	100
8416	74	442	1558	12	24	100
8417	74	443	1559	12	24	100
8418	74	444	1562	12	24	100
8425	74	451	1575	12	24	100
8424	74	450	1573	12	24	100
8423	74	449	1571	12	24	100
8419	74	445	1563	12	24	100
8422	74	448	1569	12	24	100
8421	74	447	1567	12	24	100
8374	75	440	1553	12	24	101
8385	75	451	1575	12	24	101
8384	75	450	1574	12	24	101
8383	75	449	1571	12	24	101
8382	75	448	1569	12	24	101
8381	75	447	1568	12	24	101
8380	75	446	1566	12	24	101
8379	75	445	1563	12	24	101
8378	75	444	1561	12	24	101
8377	75	443	1560	12	24	101
8376	75	442	1558	12	24	101
8375	75	441	1555	12	24	101
8373	75	439	1551	12	24	101
8372	75	438	1549	12	24	101
8371	75	437	1547	12	24	101
8370	75	436	1546	12	24	101
8369	75	435	1543	12	24	101
8368	75	434	1541	12	24	101
8367	75	433	1540	12	24	101
8366	75	432	1537	12	24	101
8459	76	445	1563	12	24	102
8446	76	432	1537	12	24	102
8447	76	433	1539	12	24	102
8448	76	434	1541	12	24	102
8449	76	435	1543	12	24	102
8450	76	436	1545	12	24	102
8451	76	437	1547	12	24	102
8452	76	438	1549	12	24	102
8453	76	439	1552	12	24	102
8454	76	440	1553	12	24	102
8455	76	441	1556	12	24	102
8456	76	442	1557	12	24	102
8457	76	443	1560	12	24	102
8458	76	444	1561	12	24	102
8465	76	451	1575	12	24	102
8464	76	450	1574	12	24	102
8463	76	449	1572	12	24	102
8462	76	448	1569	12	24	102
8461	76	447	1567	12	24	102
8460	76	446	1566	12	24	102
8445	77	451	1576	12	24	103
8426	77	432	1537	12	24	103
8427	77	433	1539	12	24	103
8428	77	434	1541	12	24	103
8429	77	435	1543	12	24	103
8430	77	436	1546	12	24	103
8431	77	437	1547	12	24	103
8432	77	438	1549	12	24	103
8433	77	439	1551	12	24	103
8434	77	440	1553	12	24	103
8435	77	441	1555	12	24	103
8436	77	442	1557	12	24	103
8437	77	443	1559	12	24	103
8438	77	444	1561	12	24	103
8439	77	445	1563	12	24	103
8440	77	446	1566	12	24	103
8441	77	447	1567	12	24	103
8442	77	448	1569	12	24	103
8443	77	449	1571	12	24	103
8444	77	450	1573	12	24	103
8466	78	432	1537	12	24	104
8469	78	435	1543	12	24	104
8468	78	434	1541	12	24	104
8467	78	433	1540	12	24	104
9058	101	504	1703	16	18	107
9059	101	505	1707	16	18	107
9060	101	506	1712	16	18	107
9061	101	507	1714	16	18	107
9062	101	508	1720	16	18	107
9063	101	509	1721	16	18	107
9064	101	510	1726	16	18	107
9065	101	511	1732	16	18	107
9424	103	490	1654	14	25	109
9406	103	472	1617	14	25	109
9425	103	491	1655	14	25	109
9407	103	473	1620	14	25	109
9408	103	474	1622	14	25	109
9409	103	475	1623	14	25	109
9410	103	476	1625	14	25	109
9411	103	477	1628	14	25	109
9412	103	478	1630	14	25	109
9413	103	479	1631	14	25	109
9414	103	480	1633	14	25	109
9415	103	481	1635	14	25	109
9416	103	482	1638	14	25	109
9417	103	483	1639	14	25	109
9418	103	484	1641	14	25	109
9419	103	485	1644	14	25	109
9420	103	486	1645	14	25	109
9421	103	487	1648	14	25	109
9422	103	488	1649	14	25	109
9423	103	489	1651	14	25	109
9072	105	478	1629	14	25	111
9081	105	487	1647	14	25	111
9080	105	486	1646	14	25	111
9079	105	485	1644	14	25	111
9066	105	472	1617	14	25	111
9067	105	473	1619	14	25	111
9068	105	474	1622	14	25	111
9069	105	475	1623	14	25	111
9070	105	476	1625	14	25	111
9071	105	477	1627	14	25	111
9078	105	484	1642	14	25	111
9077	105	483	1639	14	25	111
9076	105	482	1637	14	25	111
9075	105	481	1635	14	25	111
9074	105	480	1633	14	25	111
9073	105	479	1631	14	25	111
9667	107	473	1620	14	25	113
9666	107	472	1617	14	25	113
9685	107	491	1656	14	25	113
9684	107	490	1654	14	25	113
9683	107	489	1651	14	25	113
9682	107	488	1649	14	25	113
9681	107	487	1648	14	25	113
9680	107	486	1645	14	25	113
9679	107	485	1643	14	25	113
9678	107	484	1641	14	25	113
9677	107	483	1639	14	25	113
9676	107	482	1637	14	25	113
9675	107	481	1635	14	25	113
9674	107	480	1634	14	25	113
9673	107	479	1631	14	25	113
9672	107	478	1629	14	25	113
9671	107	477	1627	14	25	113
9670	107	476	1625	14	25	113
9669	107	475	1623	14	25	113
9668	107	474	1622	14	25	113
9386	108	472	1617	14	25	114
9387	108	473	1619	14	25	114
9388	108	474	1622	14	25	114
9389	108	475	1623	14	25	114
9390	108	476	1625	14	25	114
9391	108	477	1628	14	25	114
9392	108	478	1629	14	25	114
9393	108	479	1632	14	25	114
9394	108	480	1633	14	25	114
9395	108	481	1636	14	25	114
9396	108	482	1637	14	25	114
9397	108	483	1639	14	25	114
9398	108	484	1641	14	25	114
9399	108	485	1644	14	25	114
9400	108	486	1645	14	25	114
9401	108	487	1647	14	25	114
9402	108	488	1650	14	25	114
9403	108	489	1651	14	25	114
9404	108	490	1653	14	25	114
9405	108	491	1655	14	25	114
9466	109	472	1617	14	25	115
9485	109	491	1655	14	25	115
9484	109	490	1654	14	25	115
9483	109	489	1651	14	25	115
9482	109	488	1649	14	25	115
9481	109	487	1648	14	25	115
9480	109	486	1645	14	25	115
9479	109	485	1644	14	25	115
9478	109	484	1641	14	25	115
9477	109	483	1639	14	25	115
9476	109	482	1637	14	25	115
9475	109	481	1636	14	25	115
9474	109	480	1633	14	25	115
9473	109	479	1631	14	25	115
9472	109	478	1629	14	25	115
9471	109	477	1628	14	25	115
9470	109	476	1625	14	25	115
9469	109	475	1623	14	25	115
306	15	202	622	\N	17	25
305	15	201	620	\N	17	25
304	15	200	619	\N	17	25
314	15	210	638	\N	17	25
313	15	209	636	\N	17	25
315	15	211	640	\N	17	25
316	15	212	642	\N	17	25
317	15	213	644	\N	17	25
318	15	214	646	\N	17	25
319	15	215	648	\N	17	25
303	15	199	616	\N	17	25
322	15	218	654	\N	17	25
321	15	217	652	\N	17	25
320	15	216	651	\N	17	25
307	15	203	624	\N	17	25
308	15	204	626	\N	17	25
309	15	205	628	\N	17	25
310	15	206	630	\N	17	25
311	15	207	632	\N	17	25
312	15	208	635	\N	17	25
325	16	201	620	\N	17	27
324	16	200	619	\N	17	27
323	16	199	616	\N	17	27
326	16	202	622	\N	17	27
563	20	199	616	\N	17	31
439	21	215	648	\N	17	32
441	21	217	652	\N	17	32
442	21	218	654	\N	17	32
424	21	200	619	\N	17	32
425	21	201	620	\N	17	32
426	21	202	622	\N	17	32
427	21	203	624	\N	17	32
428	21	204	627	\N	17	32
429	21	205	628	\N	17	32
430	21	206	631	\N	17	32
431	21	207	632	\N	17	32
432	21	208	635	\N	17	32
433	21	209	637	\N	17	32
434	21	210	638	\N	17	32
435	21	211	641	\N	17	32
436	21	212	642	\N	17	32
437	21	213	645	\N	17	32
438	21	214	646	\N	17	32
440	21	216	651	\N	17	32
9085	105	491	1655	14	25	111
9084	105	490	1654	14	25	111
9083	105	489	1651	14	25	111
9082	105	488	1649	14	25	111
9468	109	474	1622	14	25	115
9467	109	473	1619	14	25	115
9130	110	476	1625	14	25	116
9132	110	477	1628	14	25	116
9139	110	484	1641	14	25	116
9138	110	483	1639	14	25	116
9137	110	482	1637	14	25	116
9136	110	481	1636	14	25	116
9135	110	480	1633	14	25	116
9134	110	479	1631	14	25	116
9133	110	478	1629	14	25	116
9126	110	472	1617	14	25	116
9127	110	473	1619	14	25	116
9128	110	474	1621	14	25	116
9129	110	475	1623	14	25	116
9464	111	510	1726	17	18	117
9448	111	494	1667	17	18	117
9449	111	495	1672	17	18	117
9450	111	496	1675	17	18	117
9451	111	497	1676	17	18	117
9452	111	498	1683	17	18	117
9453	111	499	1686	17	18	117
9454	111	500	1688	17	18	117
9455	111	501	1693	17	18	117
9456	111	502	1699	17	18	117
9457	111	503	1700	17	18	117
9458	111	504	1702	17	18	117
9459	111	505	1708	17	18	117
9460	111	506	1713	17	18	117
9461	111	507	1717	17	18	117
9462	111	508	1719	17	18	117
9463	111	509	1721	17	18	117
9465	111	511	1731	17	18	117
9446	111	492	1657	17	18	117
9447	111	493	1662	17	18	117
9606	112	472	1617	14	25	118
9625	112	491	1655	14	25	118
9624	112	490	1654	14	25	118
9623	112	489	1651	14	25	118
9622	112	488	1649	14	25	118
9621	112	487	1647	14	25	118
9620	112	486	1645	14	25	118
9619	112	485	1644	14	25	118
9618	112	484	1641	14	25	118
9617	112	483	1640	14	25	118
9616	112	482	1637	14	25	118
9615	112	481	1636	14	25	118
9614	112	480	1634	14	25	118
9613	112	479	1632	14	25	118
581	20	217	652	\N	17	31
580	20	216	651	\N	17	31
579	20	215	648	\N	17	31
578	20	214	646	\N	17	31
577	20	213	645	\N	17	31
576	20	212	642	\N	17	31
575	20	211	640	\N	17	31
574	20	210	638	\N	17	31
573	20	209	636	\N	17	31
572	20	208	634	\N	17	31
571	20	207	632	\N	17	31
570	20	206	630	\N	17	31
569	20	205	628	\N	17	31
568	20	204	626	\N	17	31
567	20	203	624	\N	17	31
566	20	202	622	\N	17	31
565	20	201	620	\N	17	31
564	20	200	618	\N	17	31
582	20	218	654	\N	17	31
7506	33	190	596	\N	14	44
7507	33	191	598	\N	14	44
7508	33	192	600	\N	14	44
9806	11	472	1617	18	25	20
9807	11	473	1619	18	25	20
9808	11	474	1622	18	25	20
9809	11	475	1623	18	25	20
9810	11	476	1625	18	25	20
9811	11	477	1628	18	25	20
9812	11	478	1630	18	25	20
9813	11	479	1631	18	25	20
9814	11	480	1633	18	25	20
9815	11	481	1635	18	25	20
9800	14	506	1712	17	18	24
9798	14	504	1702	17	18	24
9797	14	503	1700	17	18	24
9796	14	502	1698	17	18	24
9795	14	501	1693	17	18	24
9794	14	500	1689	17	18	24
9793	14	499	1687	17	18	24
9823	11	489	1651	18	25	20
9825	11	491	1655	18	25	20
9816	11	482	1637	18	25	20
9817	11	483	1639	18	25	20
9818	11	484	1641	18	25	20
9822	11	488	1649	18	25	20
9821	11	487	1647	18	25	20
9819	11	485	1644	18	25	20
9820	11	486	1645	18	25	20
9824	11	490	1654	18	25	20
9931	13	477	1628	18	25	23
9932	13	478	1629	18	25	23
9933	13	479	1631	18	25	23
9934	13	480	1633	18	25	23
10419	5	545	1869	20	26	11
10420	5	546	1873	20	26	11
10421	5	547	1877	20	26	11
10422	5	548	1882	20	26	11
9612	112	478	1629	14	25	118
9611	112	477	1628	14	25	118
9610	112	476	1625	14	25	118
9609	112	475	1623	14	25	118
9608	112	474	1622	14	25	118
9607	112	473	1619	14	25	118
9506	113	472	1617	14	25	119
9525	113	491	1655	14	25	119
9524	113	490	1654	14	25	119
9523	113	489	1651	14	25	119
9522	113	488	1649	14	25	119
9521	113	487	1647	14	25	119
9520	113	486	1645	14	25	119
9519	113	485	1643	14	25	119
9518	113	484	1642	14	25	119
9517	113	483	1639	14	25	119
9516	113	482	1637	14	25	119
9515	113	481	1636	14	25	119
9514	113	480	1633	14	25	119
9513	113	479	1631	14	25	119
9512	113	478	1629	14	25	119
9511	113	477	1628	14	25	119
9510	113	476	1625	14	25	119
9509	113	475	1623	14	25	119
9508	113	474	1622	14	25	119
9507	113	473	1619	14	25	119
9649	114	475	1623	14	25	120
9665	114	491	1656	14	25	120
9664	114	490	1654	14	25	120
9663	114	489	1651	14	25	120
9662	114	488	1649	14	25	120
9661	114	487	1647	14	25	120
9660	114	486	1645	14	25	120
9659	114	485	1644	14	25	120
9658	114	484	1641	14	25	120
9657	114	483	1639	14	25	120
9656	114	482	1637	14	25	120
9655	114	481	1635	14	25	120
9654	114	480	1633	14	25	120
9653	114	479	1631	14	25	120
9652	114	478	1629	14	25	120
9651	114	477	1628	14	25	120
9650	114	476	1625	14	25	120
9648	114	474	1622	14	25	120
9647	114	473	1619	14	25	120
9646	114	472	1617	14	25	120
9433	115	479	1631	14	25	121
9432	115	478	1629	14	25	121
9431	115	477	1628	14	25	121
9430	115	476	1625	14	25	121
9429	115	475	1623	14	25	121
9428	115	474	1622	14	25	121
9427	115	473	1620	14	25	121
9426	115	472	1617	14	25	121
9444	115	490	1654	14	25	121
9443	115	489	1651	14	25	121
9442	115	488	1650	14	25	121
9441	115	487	1647	14	25	121
9440	115	486	1645	14	25	121
9439	115	485	1643	14	25	121
9438	115	484	1642	14	25	121
9445	115	491	1655	14	25	121
9437	115	483	1639	14	25	121
9436	115	482	1637	14	25	121
9435	115	481	1635	14	25	121
9434	115	480	1633	14	25	121
9545	116	491	1655	14	25	122
9528	116	474	1622	14	25	122
9529	116	475	1623	14	25	122
9530	116	476	1625	14	25	122
9531	116	477	1628	14	25	122
9532	116	478	1629	14	25	122
9533	116	479	1631	14	25	122
9526	116	472	1617	14	25	122
9534	116	480	1633	14	25	122
9535	116	481	1635	14	25	122
9536	116	482	1638	14	25	122
9537	116	483	1639	14	25	122
9538	116	484	1641	14	25	122
9539	116	485	1644	14	25	122
9540	116	486	1645	14	25	122
9541	116	487	1647	14	25	122
9542	116	488	1650	14	25	122
9543	116	489	1651	14	25	122
9544	116	490	1654	14	25	122
9527	116	473	1620	14	25	122
9633	117	479	1631	14	25	123
9632	117	478	1629	14	25	123
9631	117	477	1628	14	25	123
9630	117	476	1625	14	25	123
9629	117	475	1623	14	25	123
9628	117	474	1621	14	25	123
9627	117	473	1619	14	25	123
9626	117	472	1617	14	25	123
9645	117	491	1655	14	25	123
9644	117	490	1653	14	25	123
9643	117	489	1651	14	25	123
9642	117	488	1649	14	25	123
9641	117	487	1647	14	25	123
9640	117	486	1645	14	25	123
9639	117	485	1643	14	25	123
9638	117	484	1642	14	25	123
9637	117	483	1639	14	25	123
9636	117	482	1638	14	25	123
9635	117	481	1635	14	25	123
9634	117	480	1633	14	25	123
9601	118	487	1648	14	25	124
9586	118	472	1617	14	25	124
9587	118	473	1619	14	25	124
9588	118	474	1622	14	25	124
9589	118	475	1623	14	25	124
9590	118	476	1625	14	25	124
9591	118	477	1628	14	25	124
9592	118	478	1629	14	25	124
9593	118	479	1632	14	25	124
9594	118	480	1633	14	25	124
9595	118	481	1636	14	25	124
9596	118	482	1638	14	25	124
9597	118	483	1639	14	25	124
9598	118	484	1641	14	25	124
9599	118	485	1643	14	25	124
9600	118	486	1645	14	25	124
9602	118	488	1649	14	25	124
9603	118	489	1651	14	25	124
9604	118	490	1654	14	25	124
9605	118	491	1655	14	25	124
9687	119	493	1662	16	18	125
9686	119	492	1657	16	18	125
9705	119	511	1731	16	18	125
9704	119	510	1726	16	18	125
9703	119	509	1721	16	18	125
9702	119	508	1719	16	18	125
9701	119	507	1714	16	18	125
9700	119	506	1712	16	18	125
9699	119	505	1707	16	18	125
9698	119	504	1702	16	18	125
9697	119	503	1700	16	18	125
9696	119	502	1699	16	18	125
9695	119	501	1693	16	18	125
9694	119	500	1689	16	18	125
9693	119	499	1687	16	18	125
9692	119	498	1681	16	18	125
9691	119	497	1676	16	18	125
9690	119	496	1675	16	18	125
9689	119	495	1672	16	18	125
9688	119	494	1667	16	18	125
9785	120	491	1655	18	25	126
9784	120	490	1654	18	25	126
9783	120	489	1651	18	25	126
9782	120	488	1649	18	25	126
9781	120	487	1648	18	25	126
9780	120	486	1645	18	25	126
9779	120	485	1644	18	25	126
9778	120	484	1641	18	25	126
9777	120	483	1639	18	25	126
9776	120	482	1637	18	25	126
9775	120	481	1636	18	25	126
9774	120	480	1633	18	25	126
9773	120	479	1631	18	25	126
9772	120	478	1629	18	25	126
9771	120	477	1627	18	25	126
9770	120	476	1625	18	25	126
9769	120	475	1623	18	25	126
9768	120	474	1622	18	25	126
9767	120	473	1619	18	25	126
9766	120	472	1617	18	25	126
10047	121	493	1664	16	18	127
10065	121	511	1731	16	18	127
10064	121	510	1726	16	18	127
10063	121	509	1721	16	18	127
10062	121	508	1719	16	18	127
10061	121	507	1714	16	18	127
10060	121	506	1712	16	18	127
10059	121	505	1707	16	18	127
10058	121	504	1702	16	18	127
10057	121	503	1700	16	18	127
10056	121	502	1698	16	18	127
10055	121	501	1693	16	18	127
10054	121	500	1689	16	18	127
10053	121	499	1687	16	18	127
10052	121	498	1681	16	18	127
10051	121	497	1676	16	18	127
10050	121	496	1674	16	18	127
10049	121	495	1672	16	18	127
10048	121	494	1667	16	18	127
10046	121	492	1657	16	18	127
9908	122	494	1667	17	18	128
9907	122	493	1662	17	18	128
9906	122	492	1657	17	18	128
9912	122	498	1681	17	18	128
9916	122	502	1698	17	18	128
9917	122	503	1701	17	18	128
9918	122	504	1702	17	18	128
9919	122	505	1708	17	18	128
9920	122	506	1712	17	18	128
9921	122	507	1714	17	18	128
9922	122	508	1719	17	18	128
9923	122	509	1721	17	18	128
9924	122	510	1726	17	18	128
9925	122	511	1731	17	18	128
9913	122	499	1687	17	18	128
9914	122	500	1688	17	18	128
9915	122	501	1693	17	18	128
9911	122	497	1676	17	18	128
9910	122	496	1674	17	18	128
9909	122	495	1672	17	18	128
9972	123	498	1681	16	18	129
9973	123	499	1687	16	18	129
9974	123	500	1689	16	18	129
9975	123	501	1693	16	18	129
9976	123	502	1698	16	18	129
9977	123	503	1700	16	18	129
9978	123	504	1703	16	18	129
9979	123	505	1707	16	18	129
9980	123	506	1713	16	18	129
9981	123	507	1714	16	18	129
9982	123	508	1719	16	18	129
9983	123	509	1721	16	18	129
9984	123	510	1727	16	18	129
9985	123	511	1731	16	18	129
9966	123	492	1657	16	18	129
9967	123	493	1662	16	18	129
9968	123	494	1667	16	18	129
9969	123	495	1672	16	18	129
9970	123	496	1674	16	18	129
9971	123	497	1676	16	18	129
10025	124	511	1731	17	18	130
10006	124	492	1657	17	18	130
10007	124	493	1662	17	18	130
10008	124	494	1669	17	18	130
10009	124	495	1672	17	18	130
10010	124	496	1674	17	18	130
10011	124	497	1676	17	18	130
10012	124	498	1682	17	18	130
10013	124	499	1686	17	18	130
10014	124	500	1689	17	18	130
10015	124	501	1695	17	18	130
10016	124	502	1699	17	18	130
10017	124	503	1700	17	18	130
10018	124	504	1703	17	18	130
10019	124	505	1707	17	18	130
10020	124	506	1712	17	18	130
10021	124	507	1714	17	18	130
10022	124	508	1719	17	18	130
10023	124	509	1721	17	18	130
10024	124	510	1726	17	18	130
10032	125	498	1681	17	18	131
10033	125	499	1687	17	18	131
10034	125	500	1689	17	18	131
10035	125	501	1693	17	18	131
10036	125	502	1699	17	18	131
10037	125	503	1701	17	18	131
10038	125	504	1702	17	18	131
10039	125	505	1707	17	18	131
10044	125	510	1726	17	18	131
10043	125	509	1721	17	18	131
10042	125	508	1719	17	18	131
10041	125	507	1714	17	18	131
10040	125	506	1712	17	18	131
10045	125	511	1731	17	18	131
10026	125	492	1657	17	18	131
10027	125	493	1662	17	18	131
10028	125	494	1667	17	18	131
10029	125	495	1672	17	18	131
10030	125	496	1674	17	18	131
10031	125	497	1676	17	18	131
7497	7	191	598	\N	14	16
7502	7	196	607	\N	14	16
7501	7	195	605	\N	14	16
7500	7	194	603	\N	14	16
7499	7	193	601	\N	14	16
7498	7	192	599	\N	14	16
7496	7	190	596	\N	14	16
7495	7	189	593	\N	14	16
7494	7	188	591	\N	14	16
7493	7	187	590	\N	14	16
7486	11	190	596	\N	14	18
7485	11	189	593	\N	14	18
7484	11	188	591	\N	14	18
7483	11	187	590	\N	14	18
7492	11	196	607	\N	14	18
7491	11	195	605	\N	14	18
7490	11	194	603	\N	14	18
7489	11	193	601	\N	14	18
7488	11	192	600	\N	14	18
7487	11	191	598	\N	14	18
7465	31	189	593	\N	14	41
7472	31	196	607	\N	14	41
7471	31	195	606	\N	14	41
7470	31	194	603	\N	14	41
7469	31	193	601	\N	14	41
7468	31	192	600	\N	14	41
7467	31	191	598	\N	14	41
7466	31	190	596	\N	14	41
7464	31	188	591	\N	14	41
7463	31	187	590	\N	14	41
7473	32	187	590	\N	14	43
7474	32	188	592	\N	14	43
7475	32	189	593	\N	14	43
7476	32	190	596	\N	14	43
7477	32	191	598	\N	14	43
7478	32	192	599	\N	14	43
7479	32	193	601	\N	14	43
7480	32	194	603	\N	14	43
7481	32	195	606	\N	14	43
7482	32	196	607	\N	14	43
7503	33	187	590	\N	14	44
7504	33	188	591	\N	14	44
7505	33	189	594	\N	14	44
7803	38	341	1114	\N	21	52
7802	38	340	1109	\N	21	52
7800	38	339	1108	\N	21	52
7799	38	338	1099	\N	21	52
7798	38	337	1094	\N	21	52
7782	45	351	1152	\N	21	65
7793	50	347	1144	\N	21	72
7785	50	339	1105	\N	21	72
7790	50	344	1129	\N	21	72
7792	50	346	1140	\N	21	72
7786	50	340	1110	\N	21	72
7795	50	349	1148	\N	21	72
7787	50	341	1115	\N	21	72
7788	50	342	1119	\N	21	72
7796	50	350	1150	\N	21	72
7797	50	351	1152	\N	21	72
7789	50	343	1124	\N	21	72
7794	50	348	1146	\N	21	72
7791	50	345	1135	\N	21	72
7783	50	337	1094	\N	21	72
7784	50	338	1102	\N	21	72
9086	12	492	1657	17	18	21
7971	64	195	606	\N	14	92
7967	64	191	598	\N	14	92
7968	64	192	600	\N	14	92
7969	64	193	601	\N	14	92
7970	64	194	603	\N	14	92
7972	64	196	607	\N	14	92
8225	2	431	1535	11	23	7
8257	21	443	1559	12	24	33
8265	21	451	1576	12	24	33
8264	21	450	1573	12	24	33
8263	21	449	1571	12	24	33
8262	21	448	1569	12	24	33
8261	21	447	1567	12	24	33
8260	21	446	1565	12	24	33
8259	21	445	1563	12	24	33
8246	21	432	1537	12	24	33
8247	21	433	1539	12	24	33
8248	21	434	1541	12	24	33
8249	21	435	1544	12	24	33
8250	21	436	1545	12	24	33
8251	21	437	1547	12	24	33
8252	21	438	1549	12	24	33
8253	21	439	1552	12	24	33
8254	21	440	1553	12	24	33
8255	21	441	1555	12	24	33
8258	21	444	1562	12	24	33
8256	21	442	1558	12	24	33
8152	26	419	1490	\N	15	38
8153	26	420	1496	\N	15	38
8154	26	421	1500	\N	15	38
8281	61	447	1567	12	24	88
8267	61	433	1540	12	24	88
8266	61	432	1537	12	24	88
8274	61	440	1553	12	24	88
8275	61	441	1555	12	24	88
8276	61	442	1558	12	24	88
8277	61	443	1559	12	24	88
8278	61	444	1561	12	24	88
8279	61	445	1563	12	24	88
8280	61	446	1566	12	24	88
8268	61	434	1541	12	24	88
8282	61	448	1569	12	24	88
8283	61	449	1571	12	24	88
8284	61	450	1573	12	24	88
8285	61	451	1575	12	24	88
8273	61	439	1551	12	24	88
8272	61	438	1549	12	24	88
8271	61	437	1547	12	24	88
8270	61	436	1546	12	24	88
8269	61	435	1543	12	24	88
8162	68	419	1490	\N	15	95
8161	68	418	1486	\N	15	95
8160	68	417	1481	\N	15	95
8159	68	416	1475	\N	15	95
8158	68	415	1471	\N	15	95
8157	68	414	1464	\N	15	95
8156	68	413	1461	\N	15	95
8155	68	412	1455	\N	15	95
8164	68	421	1500	\N	15	95
8163	68	420	1496	\N	15	95
8171	69	193	601	\N	14	96
8173	69	195	606	\N	14	96
8174	69	196	607	\N	14	96
8169	69	191	598	\N	14	96
8168	69	190	596	\N	14	96
8167	69	189	593	\N	14	96
8166	69	188	591	\N	14	96
8165	69	187	590	\N	14	96
8170	69	192	599	\N	14	96
8172	69	194	603	\N	14	96
8286	71	432	1537	12	24	98
8287	71	433	1540	12	24	98
8288	71	434	1541	12	24	98
8289	71	435	1543	12	24	98
8473	78	439	1551	12	24	104
8474	78	440	1553	12	24	104
8485	78	451	1576	12	24	104
8484	78	450	1573	12	24	104
8482	78	448	1569	12	24	104
8483	78	449	1571	12	24	104
8475	78	441	1555	12	24	104
8476	78	442	1558	12	24	104
8477	78	443	1559	12	24	104
8478	78	444	1561	12	24	104
8479	78	445	1563	12	24	104
8480	78	446	1566	12	24	104
8481	78	447	1568	12	24	104
8472	78	438	1549	12	24	104
8471	78	437	1547	12	24	104
8470	78	436	1546	12	24	104
8498	79	444	1562	12	24	105
8486	79	432	1537	12	24	105
8487	79	433	1539	12	24	105
8488	79	434	1542	12	24	105
8489	79	435	1544	12	24	105
8490	79	436	1545	12	24	105
8491	79	437	1547	12	24	105
8492	79	438	1549	12	24	105
8493	79	439	1551	12	24	105
8494	79	440	1553	12	24	105
8495	79	441	1555	12	24	105
8496	79	442	1557	12	24	105
8497	79	443	1559	12	24	105
8499	79	445	1563	12	24	105
8500	79	446	1565	12	24	105
8501	79	447	1567	12	24	105
8502	79	448	1569	12	24	105
8503	79	449	1571	12	24	105
8504	79	450	1573	12	24	105
8505	79	451	1576	12	24	105
9040	100	506	1712	16	18	106
9026	100	492	1657	16	18	106
9027	100	493	1662	16	18	106
9028	100	494	1667	16	18	106
9029	100	495	1672	16	18	106
9030	100	496	1674	16	18	106
9031	100	497	1676	16	18	106
9032	100	498	1681	16	18	106
9033	100	499	1687	16	18	106
9034	100	500	1689	16	18	106
9035	100	501	1693	16	18	106
9036	100	502	1698	16	18	106
9037	100	503	1700	16	18	106
9038	100	504	1702	16	18	106
9039	100	505	1707	16	18	106
9045	100	511	1731	16	18	106
9044	100	510	1728	16	18	106
9043	100	509	1721	16	18	106
9042	100	508	1719	16	18	106
9041	100	507	1714	16	18	106
9116	102	482	1637	14	25	108
9125	102	491	1655	14	25	108
9124	102	490	1654	14	25	108
9123	102	489	1651	14	25	108
9122	102	488	1649	14	25	108
9121	102	487	1647	14	25	108
9120	102	486	1645	14	25	108
9119	102	485	1644	14	25	108
9118	102	484	1641	14	25	108
9117	102	483	1639	14	25	108
9115	102	481	1635	14	25	108
9114	102	480	1633	14	25	108
9113	102	479	1631	14	25	108
9112	102	478	1629	14	25	108
9111	102	477	1628	14	25	108
9110	102	476	1625	14	25	108
9109	102	475	1623	14	25	108
9108	102	474	1622	14	25	108
9107	102	473	1619	14	25	108
9106	102	472	1617	14	25	108
9144	110	489	1651	14	25	116
9143	110	488	1649	14	25	116
9142	110	487	1647	14	25	116
9141	110	486	1645	14	25	116
9146	110	491	1656	14	25	116
9145	110	490	1654	14	25	116
9140	110	485	1644	14	25	116
9295	13	501	1693	17	18	22
9296	13	502	1698	17	18	22
9297	13	503	1700	17	18	22
9298	13	504	1702	17	18	22
9299	13	505	1707	17	18	22
9300	13	506	1712	17	18	22
9301	13	507	1714	17	18	22
9302	13	508	1720	17	18	22
9303	13	509	1721	17	18	22
9304	13	510	1726	17	18	22
9305	13	511	1731	17	18	22
9286	13	492	1659	17	18	22
9287	13	493	1662	17	18	22
9288	13	494	1667	17	18	22
9289	13	495	1672	17	18	22
9290	13	496	1674	17	18	22
9291	13	497	1676	17	18	22
9292	13	498	1681	17	18	22
9293	13	499	1687	17	18	22
9294	13	500	1689	17	18	22
9368	65	494	1667	17	18	93
9367	65	493	1662	17	18	93
9366	65	492	1657	17	18	93
9326	104	472	1617	14	25	110
9327	104	473	1619	14	25	110
9328	104	474	1622	14	25	110
9329	104	475	1623	14	25	110
9330	104	476	1625	14	25	110
9331	104	477	1628	14	25	110
9332	104	478	1629	14	25	110
9333	104	479	1632	14	25	110
9334	104	480	1633	14	25	110
9335	104	481	1635	14	25	110
9336	104	482	1638	14	25	110
9337	104	483	1639	14	25	110
9338	104	484	1641	14	25	110
9339	104	485	1644	14	25	110
9340	104	486	1645	14	25	110
9341	104	487	1647	14	25	110
9342	104	488	1649	14	25	110
9343	104	489	1651	14	25	110
9344	104	490	1653	14	25	110
9345	104	491	1656	14	25	110
9306	106	472	1617	14	25	112
9307	106	473	1620	14	25	112
9308	106	474	1622	14	25	112
9309	106	475	1623	14	25	112
9310	106	476	1625	14	25	112
9311	106	477	1628	14	25	112
9312	106	478	1629	14	25	112
9313	106	479	1632	14	25	112
9314	106	480	1633	14	25	112
9315	106	481	1635	14	25	112
9316	106	482	1637	14	25	112
9317	106	483	1640	14	25	112
9318	106	484	1641	14	25	112
9319	106	485	1643	14	25	112
9320	106	486	1645	14	25	112
9321	106	487	1648	14	25	112
9322	106	488	1649	14	25	112
9325	106	491	1655	14	25	112
9323	106	489	1651	14	25	112
9324	106	490	1654	14	25	112
10361	55	487	1647	19	25	80
10362	55	488	1649	19	25	80
10346	55	472	1617	19	25	80
10347	55	473	1620	19	25	80
10348	55	474	1622	19	25	80
10349	55	475	1623	19	25	80
10350	55	476	1625	19	25	80
10351	55	477	1627	19	25	80
10358	55	484	1642	19	25	80
10352	55	478	1629	19	25	80
10353	55	479	1631	19	25	80
10354	55	480	1634	19	25	80
10355	55	481	1635	19	25	80
10356	55	482	1637	19	25	80
10357	55	483	1639	19	25	80
10359	55	485	1644	19	25	80
10360	55	486	1645	19	25	80
10334	127	480	1633	19	25	132
10331	127	477	1628	19	25	132
10330	127	476	1625	19	25	132
10329	127	475	1623	19	25	132
10328	127	474	1622	19	25	132
10327	127	473	1620	19	25	132
10326	127	472	1617	19	25	132
10332	127	478	1630	19	25	132
10333	127	479	1631	19	25	132
10335	127	481	1635	19	25	132
10336	127	482	1637	19	25	132
10337	127	483	1640	19	25	132
10338	127	484	1642	19	25	132
10339	127	485	1644	19	25	132
10340	127	486	1645	19	25	132
10341	127	487	1647	19	25	132
10342	127	488	1649	19	25	132
10343	127	489	1651	19	25	132
10344	127	490	1654	19	25	132
10345	127	491	1655	19	25	132
10608	6	394	1366	22	22	14
10610	6	396	1375	22	22	14
10611	6	397	1381	22	22	14
10612	6	398	1386	22	22	14
10613	6	399	1391	22	22	14
10614	6	400	1396	22	22	14
10621	6	407	1431	22	22	14
10622	6	408	1436	22	22	14
10623	6	409	1440	22	22	14
10624	6	410	1446	22	22	14
10625	6	411	1450	22	22	14
10606	6	392	1356	22	22	14
10607	6	393	1360	22	22	14
10620	6	406	1426	22	22	14
10619	6	405	1420	22	22	14
10618	6	404	1415	22	22	14
10617	6	403	1410	22	22	14
10616	6	402	1405	22	22	14
10615	6	401	1401	22	22	14
10609	6	395	1372	22	22	14
10633	131	429	1531	\N	1	133
10631	131	427	1524	\N	1	133
10630	131	426	1523	\N	1	133
10629	131	425	1518	\N	1	133
10628	131	424	1513	\N	1	133
10627	131	423	1508	\N	1	133
10626	131	422	1507	\N	1	133
10632	131	428	1530	\N	1	133
10634	132	431	1535	11	23	134
10663	139	429	1531	10	1	135
10656	139	422	1504	10	1	135
10657	139	423	1508	10	1	135
10658	139	424	1509	10	1	135
10660	139	426	1523	10	1	135
10661	139	427	1524	10	1	135
10659	139	425	1514	10	1	135
10662	139	428	1530	10	1	135
11187	1	839	3177	\N	47	1
11188	1	840	3182	\N	47	1
11198	1	853	3229	\N	48	2
11199	1	854	3231	\N	48	2
11200	1	855	3236	\N	48	2
11201	1	856	3245	\N	48	2
11191	158	839	3177	\N	47	136
11192	158	840	3182	\N	47	136
\.


--
-- Data for Name: salon; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salon (id, codigo, descripcion, fecha_creacion, usuario, estado, cempre, usuario_id) FROM stdin;
3	test	test001	2026-04-12 20:08:17.315333	pardolf	A	1	2
5	intro01	202610 Introducción a la programacion Lunes 9pm	2026-04-14 10:57:03.869206	pardolf	A	1	2
6	Base002	202610 Base de datos Martes	2026-04-14 16:56:06.797009	pardolf	A	1	2
7	202610-2630	202610 - Introduccion Prog - 2630 - Martes 7pm	2026-04-15 14:14:14.811914	pardolf	A	1	2
8	202610-2645	202610 - Introduccion Prog - 2645 - Miercoles - 7pm	2026-04-15 14:55:39.29007	pardolf	A	1	2
9	202610-SoftwareLibre	202610 - UCS - Software Libre	2026-04-18 00:47:41.887156	pardolf	A	1	2
1	Base Datos Basico Q1	202610 Base de datos Jueves 9pm 	2026-04-12 15:53:04.151882	pardolf	A	1	2
2	Base de Datos  BAsico Q2	202610 Base de datos Miercoles 7pm	2026-04-12 15:53:45.804551	pardolf	A	1	2
10	pruea	prba	2026-04-19 12:41:35.703973	pardolf	I	1	2
4	202610-Web	202610 - DIseño Web  Lunes 7pm	2026-04-13 16:07:26.61639	pardolf	A	1	2
12	comics 202610	test 202610  Comics	2026-05-03 22:37:00.173965	pardolf	A	1	6
13	comic2	Naruto 2 - Avanzado	2026-05-03 22:43:27.31479	\N	A	1	6
11	sunat1	Salon SUNAT 001 Profesor Buendia	2026-04-29 08:43:57.438896	pardolf	I	1	2
\.


--
-- Data for Name: salon_quiz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salon_quiz (id, salon_id, quiz_id, codigo, fecha_asignacion, estado, cempre) FROM stdin;
10	3	1	KV53GG	2026-04-12 20:09:04.761377	A	1
11	3	23	0Q0OLH	2026-04-12 22:42:41.773139	A	1
12	4	24	CXKU8Y	2026-04-13 16:07:47.609615	A	1
13	5	19	I0G7Q3	2026-04-14 10:57:57.508094	A	1
16	7	18	AFB644	2026-04-15 14:18:56.309932	A	1
14	6	25	W87F79	2026-04-14 16:59:03.86237	A	1
17	8	18	JAG6T2	2026-04-15 14:55:59.121037	A	1
18	2	25	MSNQ0L	2026-04-15 15:29:56.364979	A	1
19	1	25	QPFGMI	2026-04-17 12:42:40.463891	A	1
20	9	26	4IUCOD	2026-04-18 00:48:04.94303	A	1
21	9	4	6WF9I2	2026-04-18 11:52:39.79742	A	1
22	9	22	ZJAYGU	2026-04-18 11:58:00.413269	A	1
23	4	28	26Z9P3	2026-04-21 15:24:05.437091	A	1
24	5	29	XR2OGI	2026-04-21 16:11:44.221903	A	1
25	9	41	LGHO89	2026-04-25 15:37:03.369315	A	1
26	11	44	05QZXF	2026-04-29 08:44:11.781053	A	1
27	3	48	4ASMLZ	2026-05-01 22:51:13.30554	A	1
29	12	50	GRGRTL	2026-05-03 22:42:26.923271	A	\N
30	12	51	2EYBBG	2026-05-03 22:45:07.588697	A	\N
31	9	52	2JLCU8	2026-05-08 23:10:57.379529	A	\N
32	3	53	RBJGL9	2026-05-10 12:48:13.051372	A	\N
33	9	54	\N	2026-05-15 21:39:21.597757	A	\N
34	9	56	\N	2026-05-29 22:41:01.624517	A	\N
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, usuario, password, rol, dni, nombre, apellido, correo, cempre, fecha_creacion) FROM stdin;
1	root	Renault1234	root	00000000	Luis	Pardon	pardoalf@gmail.com	1	2026-05-02 21:01:10.39683
3	pardolui	Lorena@7@371	admin	06812179	LUIS	LA ROSA	pardoalf@gmail.com	1	2026-05-02 21:29:56.80864
4	parlaral	Lorena@7@371	admin	06775589	alfie	pardon	parlaral@gmail.com	1	2026-05-02 21:40:27.166512
2	pardoalf	1234	profesor	06775568	admin	Test	pardoalf@gmail.com	1	2026-05-02 21:02:34.431357
6	pardoenr	1234	profesor	06775569	Luis Enrique	Pardon test	pardoalf@gmail.com	1	2026-05-03 20:35:18.843073
\.


--
-- Name: alumnos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alumnos_id_seq', 159, true);


--
-- Name: empresa_cempre_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.empresa_cempre_seq', 1, true);


--
-- Name: intentos_quiz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.intentos_quiz_id_seq', 142, true);


--
-- Name: mejoras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mejoras_id_seq', 55, true);


--
-- Name: opciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opciones_id_seq', 4000, true);


--
-- Name: planes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.planes_id_seq', 5, true);


--
-- Name: preguntas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preguntas_id_seq', 1035, true);


--
-- Name: quiz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_id_seq', 56, true);


--
-- Name: respuestas_alumno_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.respuestas_alumno_id_seq', 11342, true);


--
-- Name: salon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.salon_id_seq', 13, true);


--
-- Name: salon_quiz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.salon_quiz_id_seq', 34, true);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 6, true);


--
-- Name: alumnos alumnos_dni_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_dni_key UNIQUE (dni);


--
-- Name: alumnos alumnos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT alumnos_pkey PRIMARY KEY (id);


--
-- Name: empresa empresa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresa
    ADD CONSTRAINT empresa_pkey PRIMARY KEY (cempre);


--
-- Name: intentos_quiz intentos_quiz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intentos_quiz
    ADD CONSTRAINT intentos_quiz_pkey PRIMARY KEY (id);


--
-- Name: mejoras mejoras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mejoras
    ADD CONSTRAINT mejoras_pkey PRIMARY KEY (id);


--
-- Name: opciones opciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opciones
    ADD CONSTRAINT opciones_pkey PRIMARY KEY (id);


--
-- Name: planes planes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes
    ADD CONSTRAINT planes_pkey PRIMARY KEY (id);


--
-- Name: preguntas preguntas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preguntas
    ADD CONSTRAINT preguntas_pkey PRIMARY KEY (id);


--
-- Name: quiz quiz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz
    ADD CONSTRAINT quiz_pkey PRIMARY KEY (id);


--
-- Name: respuestas_alumno respuestas_alumno_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuestas_alumno
    ADD CONSTRAINT respuestas_alumno_pkey PRIMARY KEY (id);


--
-- Name: salon salon_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon
    ADD CONSTRAINT salon_codigo_key UNIQUE (codigo);


--
-- Name: salon salon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon
    ADD CONSTRAINT salon_pkey PRIMARY KEY (id);


--
-- Name: salon_quiz salon_quiz_codigo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz
    ADD CONSTRAINT salon_quiz_codigo_key UNIQUE (codigo);


--
-- Name: salon_quiz salon_quiz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz
    ADD CONSTRAINT salon_quiz_pkey PRIMARY KEY (id);


--
-- Name: usuarios unique_dni_empresa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT unique_dni_empresa UNIQUE (dni, cempre);


--
-- Name: usuarios unique_usuario_empresa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT unique_usuario_empresa UNIQUE (usuario, cempre);


--
-- Name: salon_quiz uq_salon_quiz; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz
    ADD CONSTRAINT uq_salon_quiz UNIQUE (salon_id, quiz_id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_usuario_key UNIQUE (usuario);


--
-- Name: ux_intento_unico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_intento_unico ON public.intentos_quiz USING btree (alumno_id, quiz_id, intento_numero);


--
-- Name: ux_respuesta_unica; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_respuesta_unica ON public.respuestas_alumno USING btree (alumno_id, pregunta_id, intento_id) WHERE (intento_id IS NOT NULL);


--
-- Name: usuarios fk_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_empresa FOREIGN KEY (cempre) REFERENCES public.empresa(cempre);


--
-- Name: respuestas_alumno fk_intento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuestas_alumno
    ADD CONSTRAINT fk_intento FOREIGN KEY (intento_id) REFERENCES public.intentos_quiz(id);


--
-- Name: intentos_quiz fk_intento_alumno; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intentos_quiz
    ADD CONSTRAINT fk_intento_alumno FOREIGN KEY (alumno_id) REFERENCES public.alumnos(id);


--
-- Name: intentos_quiz fk_intento_quiz; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intentos_quiz
    ADD CONSTRAINT fk_intento_quiz FOREIGN KEY (quiz_id) REFERENCES public.quiz(id);


--
-- Name: quiz fk_quiz_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz
    ADD CONSTRAINT fk_quiz_empresa FOREIGN KEY (cempre) REFERENCES public.empresa(cempre);


--
-- Name: salon_quiz fk_salon_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz
    ADD CONSTRAINT fk_salon_empresa FOREIGN KEY (cempre) REFERENCES public.empresa(cempre);


--
-- Name: alumnos fk_salon_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alumnos
    ADD CONSTRAINT fk_salon_empresa FOREIGN KEY (cempre) REFERENCES public.empresa(cempre);


--
-- Name: salon fk_salon_empresa; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon
    ADD CONSTRAINT fk_salon_empresa FOREIGN KEY (cempre) REFERENCES public.empresa(cempre);


--
-- Name: respuestas_alumno fk_salon_quiz; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.respuestas_alumno
    ADD CONSTRAINT fk_salon_quiz FOREIGN KEY (salon_quiz_id) REFERENCES public.salon_quiz(id);


--
-- Name: salon_quiz salon_quiz_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz
    ADD CONSTRAINT salon_quiz_quiz_id_fkey FOREIGN KEY (quiz_id) REFERENCES public.quiz(id);


--
-- Name: salon_quiz salon_quiz_salon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salon_quiz
    ADD CONSTRAINT salon_quiz_salon_id_fkey FOREIGN KEY (salon_id) REFERENCES public.salon(id);


--
-- PostgreSQL database dump complete
--

