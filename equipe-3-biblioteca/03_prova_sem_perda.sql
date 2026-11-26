-- Consultas que remontam cada planilha a partir das tabelas novas e comparam com a original
USE normalizacao_biblioteca;


-- Cenário 3: Biblioteca Saber
-- 03_prova_sem_perda.sql: prova de que a normalização não perdeu dados.
-- Ideia: juntar (JOIN) as tabelas novas para reconstruir as planilhas originais
-- e comparar nos dois sentidos. Todo resultado "diferencas" deve ser 0.

USE normalizacao_biblioteca;

-- =====================================================
-- 1) CONTAGENS: quantos registros distintos existem em cada lado
-- =====================================================
SELECT 'curso' AS tabela,
       (SELECT COUNT(DISTINCT cod_curso, nome_curso) FROM planilha) AS origem,
       (SELECT COUNT(*) FROM curso) AS destino
UNION ALL
SELECT 'editora',
       (SELECT COUNT(DISTINCT cod_editora, editora) FROM planilha),
       (SELECT COUNT(*) FROM editora)
UNION ALL
SELECT 'leitor',
       (SELECT COUNT(DISTINCT matricula_leitor, nome_leitor, cod_curso) FROM planilha),
       (SELECT COUNT(*) FROM leitor)
UNION ALL
SELECT 'livro',
       (SELECT COUNT(DISTINCT isbn, titulo, cod_editora) FROM planilha),
       (SELECT COUNT(*) FROM livro)
UNION ALL
SELECT 'emprestimo',
       (SELECT COUNT(DISTINCT cod_emprestimo) FROM planilha),
       (SELECT COUNT(*) FROM emprestimo)
UNION ALL
SELECT 'emprestimo_livro',
       (SELECT COUNT(DISTINCT cod_emprestimo, isbn) FROM planilha),
       (SELECT COUNT(*) FROM emprestimo_livro)
UNION ALL
SELECT 'bibliotecario',
       (SELECT COUNT(DISTINCT bibliotecario, area) FROM planilha_fnbc),
       (SELECT COUNT(*) FROM bibliotecario)
UNION ALL
SELECT 'leitor_bibliotecario',
       (SELECT COUNT(DISTINCT leitor, bibliotecario) FROM planilha_fnbc),
       (SELECT COUNT(*) FROM leitor_bibliotecario)
UNION ALL
SELECT 'livro_autor',
       (SELECT COUNT(DISTINCT isbn, autor) FROM planilha_4fn),
       (SELECT COUNT(*) FROM livro_autor)
UNION ALL
SELECT 'livro_palavra_chave',
       (SELECT COUNT(DISTINCT isbn, palavra_chave) FROM planilha_4fn),
       (SELECT COUNT(*) FROM livro_palavra_chave);

-- =====================================================
-- 2) RECONSTRUÇÃO DA PLANILHA (1FN/2FN/3FN) COM JOIN
--    (os telefones são verificados separadamente, no passo 3)
-- =====================================================
CREATE OR REPLACE VIEW v_planilha_reconstruida AS
SELECT
  e.cod_emprestimo,
  e.data_emprestimo,
  e.data_devolucao,
  l.matricula_leitor,
  l.nome_leitor,
  c.cod_curso,
  c.nome_curso,
  li.isbn,
  li.titulo,
  ed.cod_editora,
  ed.editora
FROM emprestimo_livro el
JOIN emprestimo e  ON e.cod_emprestimo   = el.cod_emprestimo
JOIN leitor     l  ON l.matricula_leitor = e.matricula_leitor
JOIN curso      c  ON c.cod_curso        = l.cod_curso
JOIN livro      li ON li.isbn            = el.isbn
JOIN editora    ed ON ed.cod_editora     = li.cod_editora;

-- 2a) Linhas da planilha original que NÃO aparecem na reconstrução (deve ser 0)
SELECT '2a) planilha -> reconstruida' AS verificacao, COUNT(*) AS diferencas
FROM (SELECT DISTINCT cod_emprestimo, data_emprestimo, data_devolucao,
             matricula_leitor, nome_leitor, cod_curso, nome_curso,
             isbn, titulo, cod_editora, editora
      FROM planilha) p
WHERE NOT EXISTS (
  SELECT 1 FROM v_planilha_reconstruida r
  WHERE r.cod_emprestimo  <=> p.cod_emprestimo
    AND r.data_emprestimo <=> p.data_emprestimo
    AND r.data_devolucao  <=> p.data_devolucao
    AND r.matricula_leitor <=> p.matricula_leitor
    AND r.nome_leitor     <=> p.nome_leitor
    AND r.cod_curso       <=> p.cod_curso
    AND r.nome_curso      <=> p.nome_curso
    AND r.isbn            <=> p.isbn
    AND r.titulo          <=> p.titulo
    AND r.cod_editora     <=> p.cod_editora
    AND r.editora         <=> p.editora
);

-- 2b) Linhas da reconstrução que NÃO existem na planilha (nada inventado; deve ser 0)
SELECT '2b) reconstruida -> planilha' AS verificacao, COUNT(*) AS diferencas
FROM v_planilha_reconstruida r
WHERE NOT EXISTS (
  SELECT 1 FROM planilha p
  WHERE r.cod_emprestimo  <=> p.cod_emprestimo
    AND r.data_emprestimo <=> p.data_emprestimo
    AND r.data_devolucao  <=> p.data_devolucao
    AND r.matricula_leitor <=> p.matricula_leitor
    AND r.nome_leitor     <=> p.nome_leitor
    AND r.cod_curso       <=> p.cod_curso
    AND r.nome_curso      <=> p.nome_curso
    AND r.isbn            <=> p.isbn
    AND r.titulo          <=> p.titulo
    AND r.cod_editora     <=> p.cod_editora
    AND r.editora         <=> p.editora
);

-- =====================================================
-- 3) TELEFONES (coluna com vários valores separados por ';')
-- =====================================================
DROP TEMPORARY TABLE IF EXISTS tmp_telefones_origem;

CREATE TEMPORARY TABLE tmp_telefones_origem AS
SELECT DISTINCT
  p.matricula_leitor,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.telefones, ';', n.n), ';', -1)) AS telefone
FROM planilha p
JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
  ON n.n <= 1 + LENGTH(p.telefones) - LENGTH(REPLACE(p.telefones, ';', ''));

-- 3a) Telefone da planilha que não foi para leitor_telefone (deve ser 0)
SELECT '3a) telefones origem -> leitor_telefone' AS verificacao, COUNT(*) AS diferencas
FROM tmp_telefones_origem t
LEFT JOIN leitor_telefone lt
  ON lt.matricula_leitor = t.matricula_leitor AND lt.telefone = t.telefone
WHERE lt.matricula_leitor IS NULL;

-- 3b) Telefone em leitor_telefone que não existia na planilha (deve ser 0)
SELECT '3b) leitor_telefone -> telefones origem' AS verificacao, COUNT(*) AS diferencas
FROM leitor_telefone lt
LEFT JOIN tmp_telefones_origem t
  ON lt.matricula_leitor = t.matricula_leitor AND lt.telefone = t.telefone
WHERE t.matricula_leitor IS NULL;

-- =====================================================
-- 4) FNBC: leitor_bibliotecario JOIN bibliotecario = planilha_fnbc
-- =====================================================
CREATE OR REPLACE VIEW v_fnbc_reconstruida AS
SELECT lb.leitor, lb.bibliotecario, b.area
FROM leitor_bibliotecario lb
JOIN bibliotecario b ON b.bibliotecario = lb.bibliotecario;

SELECT '4a) planilha_fnbc -> reconstruida' AS verificacao, COUNT(*) AS diferencas
FROM (SELECT DISTINCT leitor, bibliotecario, area FROM planilha_fnbc) p
WHERE NOT EXISTS (
  SELECT 1 FROM v_fnbc_reconstruida r
  WHERE r.leitor <=> p.leitor
    AND r.bibliotecario <=> p.bibliotecario
    AND r.area <=> p.area
);

SELECT '4b) reconstruida -> planilha_fnbc' AS verificacao, COUNT(*) AS diferencas
FROM v_fnbc_reconstruida r
WHERE NOT EXISTS (
  SELECT 1 FROM planilha_fnbc p
  WHERE r.leitor <=> p.leitor
    AND r.bibliotecario <=> p.bibliotecario
    AND r.area <=> p.area
);

-- =====================================================
-- 5) 4FN: livro_autor JOIN livro_palavra_chave = planilha_4fn
--    (para cada livro, todas as combinações autor x palavra-chave)
-- =====================================================
CREATE OR REPLACE VIEW v_4fn_reconstruida AS
SELECT la.isbn, la.autor, lp.palavra_chave
FROM livro_autor la
JOIN livro_palavra_chave lp ON lp.isbn = la.isbn;

SELECT '5a) planilha_4fn -> reconstruida' AS verificacao, COUNT(*) AS diferencas
FROM (SELECT DISTINCT isbn, autor, palavra_chave FROM planilha_4fn) p
WHERE NOT EXISTS (
  SELECT 1 FROM v_4fn_reconstruida r
  WHERE r.isbn <=> p.isbn
    AND r.autor <=> p.autor
    AND r.palavra_chave <=> p.palavra_chave
);

SELECT '5b) reconstruida -> planilha_4fn' AS verificacao, COUNT(*) AS diferencas
FROM v_4fn_reconstruida r
WHERE NOT EXISTS (
  SELECT 1 FROM planilha_4fn p
  WHERE r.isbn <=> p.isbn
    AND r.autor <=> p.autor
    AND r.palavra_chave <=> p.palavra_chave
);

-- Se todas as verificações (2a a 5b) retornarem 0 e as contagens do passo 1
-- forem iguais, a migração foi feita SEM PERDA de dados.
