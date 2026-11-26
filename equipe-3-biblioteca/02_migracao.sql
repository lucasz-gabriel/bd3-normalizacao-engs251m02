-- Migração dos dados das planilhas para as tabelas novas (INSERT ... SELECT)
USE normalizacao_biblioteca;

INSERT INTO curso (cod_curso, nome_curso)
SELECT DISTINCT cod_curso, nome_curso
FROM planilha;

INSERT INTO leitor (matricula_leitor, nome_leitor, cod_curso)
SELECT DISTINCT matricula_leitor, nome_leitor, cod_curso
FROM planilha;

INSERT INTO leitor_telefone (matricula_leitor, telefone)
SELECT DISTINCT
  p.matricula_leitor,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.telefones, ';', n.n), ';', -1))
FROM planilha p
JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
  ON n.n <= 1 + LENGTH(p.telefones) - LENGTH(REPLACE(p.telefones, ';', ''));

INSERT INTO editora (cod_editora, editora)
SELECT DISTINCT cod_editora, editora
FROM planilha;

INSERT INTO livro (isbn, titulo, cod_editora)
SELECT DISTINCT isbn, titulo, cod_editora
FROM planilha;

INSERT INTO emprestimo (cod_emprestimo, data_emprestimo, matricula_leitor, data_devolucao)
SELECT DISTINCT cod_emprestimo, data_emprestimo, matricula_leitor, data_devolucao
FROM planilha;

INSERT INTO emprestimo_livro (cod_emprestimo, isbn)
SELECT DISTINCT cod_emprestimo, isbn
FROM planilha;

INSERT INTO bibliotecario (bibliotecario, area)
SELECT DISTINCT bibliotecario, area
FROM planilha_fnbc;

INSERT INTO leitor_bibliotecario (leitor, bibliotecario)
SELECT DISTINCT leitor, bibliotecario
FROM planilha_fnbc;

INSERT INTO livro_autor (isbn, autor)
SELECT DISTINCT isbn, autor
FROM planilha_4fn;

INSERT INTO livro_palavra_chave (isbn, palavra_chave)
SELECT DISTINCT isbn, palavra_chave
FROM planilha_4fn;
