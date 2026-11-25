-- Cenário 3: Biblioteca Saber
-- 01_ddl.sql: tabelas normalizadas (3FN, FNBC e 4FN) com PKs e FKs.

USE normalizacao_biblioteca;

DROP TABLE IF EXISTS livro_autor;
DROP TABLE IF EXISTS livro_palavra_chave;
DROP TABLE IF EXISTS emprestimo_livro;
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS leitor_telefone;
DROP TABLE IF EXISTS leitor;
DROP TABLE IF EXISTS livro;
DROP TABLE IF EXISTS editora;
DROP TABLE IF EXISTS curso;
DROP TABLE IF EXISTS leitor_bibliotecario;
DROP TABLE IF EXISTS bibliotecario;

-- =====================================================
-- 1FN, 2FN e 3FN (origem: planilha)
-- =====================================================

CREATE TABLE curso (
  cod_curso  CHAR(2)     NOT NULL,
  nome_curso VARCHAR(40) NOT NULL,
  PRIMARY KEY (cod_curso)
);

CREATE TABLE editora (
  cod_editora CHAR(2)     NOT NULL,
  editora     VARCHAR(30) NOT NULL,
  PRIMARY KEY (cod_editora)
);

CREATE TABLE leitor (
  matricula_leitor INT         NOT NULL,
  nome_leitor      VARCHAR(60) NOT NULL,
  cod_curso        CHAR(2)     NOT NULL,
  PRIMARY KEY (matricula_leitor),
  FOREIGN KEY (cod_curso) REFERENCES curso (cod_curso)
);

CREATE TABLE leitor_telefone (
  matricula_leitor INT         NOT NULL,
  telefone         VARCHAR(20) NOT NULL,
  PRIMARY KEY (matricula_leitor, telefone),
  FOREIGN KEY (matricula_leitor) REFERENCES leitor (matricula_leitor)
);

CREATE TABLE livro (
  isbn        VARCHAR(13) NOT NULL,
  titulo      VARCHAR(60) NOT NULL,
  cod_editora CHAR(2)     NOT NULL,
  PRIMARY KEY (isbn),
  FOREIGN KEY (cod_editora) REFERENCES editora (cod_editora)
);

CREATE TABLE emprestimo (
  cod_emprestimo   INT  NOT NULL,
  data_emprestimo  DATE NOT NULL,
  data_devolucao   DATE,
  matricula_leitor INT  NOT NULL,
  PRIMARY KEY (cod_emprestimo),
  FOREIGN KEY (matricula_leitor) REFERENCES leitor (matricula_leitor)
);

CREATE TABLE emprestimo_livro (
  cod_emprestimo INT         NOT NULL,
  isbn           VARCHAR(13) NOT NULL,
  PRIMARY KEY (cod_emprestimo, isbn),
  FOREIGN KEY (cod_emprestimo) REFERENCES emprestimo (cod_emprestimo),
  FOREIGN KEY (isbn) REFERENCES livro (isbn)
);

-- =====================================================
-- FNBC (origem: planilha_fnbc)
-- =====================================================

CREATE TABLE bibliotecario (
  bibliotecario VARCHAR(60) NOT NULL,
  area          VARCHAR(30) NOT NULL,
  PRIMARY KEY (bibliotecario)
);

CREATE TABLE leitor_bibliotecario (
  leitor        VARCHAR(60) NOT NULL,
  bibliotecario VARCHAR(60) NOT NULL,
  PRIMARY KEY (leitor, bibliotecario),
  FOREIGN KEY (bibliotecario) REFERENCES bibliotecario (bibliotecario)
);

-- =====================================================
-- 4FN (origem: planilha_4fn)
-- =====================================================

CREATE TABLE livro_autor (
  isbn  VARCHAR(13) NOT NULL,
  autor VARCHAR(60) NOT NULL,
  PRIMARY KEY (isbn, autor),
  FOREIGN KEY (isbn) REFERENCES livro (isbn)
);

CREATE TABLE livro_palavra_chave (
  isbn          VARCHAR(13) NOT NULL,
  palavra_chave VARCHAR(30) NOT NULL,
  PRIMARY KEY (isbn, palavra_chave),
  FOREIGN KEY (isbn) REFERENCES livro (isbn)
);
