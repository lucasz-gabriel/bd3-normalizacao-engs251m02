# Equipe 3: Biblioteca Saber

**Nome do time:** Equipe Murilo

| Nome | Usuário do GitHub |
| Lucas Roque | [Roque](https://github.com/lucasz-gabriel) |
| Paulo Gabriel |[Paulo](https://github.com/paulogabriel-KH) |
| Marcos Gabriel|[Marcos](https://github.com/Marcos-Mousinho) |
| Ítalo Pereira |[Ítalo](https://github.com/Italo-P) |
| Gabriel Mayck |[Mayck](https://github.com/gabriel-mayck) |
| Lucas Trindade |[Trindade](https://github.com/Lucasxo1) |
| Fernando Lima |[Fernando](https://github.com/Unando1337) |
| Murilo Camurça |[Murilo](https://github.com/mcamurca1) |

## O cenário

O sistema da Biblioteca Saber hoje é uma planilha. Rode o `00_planilha.sql` no MySQL: ele cria o banco `normalizacao_biblioteca` com 3 tabelas que reproduzem a planilha (também em `planilha.xlsx`).

| Tabela | O que guarda |
| --- | --- |
| `planilha` | Cada linha é um livro de um empréstimo. Cada empréstimo é de um leitor; cada leitor é de um curso; cada livro é de uma editora. |
| `planilha_fnbc` | Regra: em cada área, o leitor tem um único bibliotecário de referência; cada bibliotecário atende uma única área. |
| `planilha_4fn` | Cada livro tem vários autores e várias palavras-chave, sem relação entre autor e palavra-chave. |

> Apague as instruções entre colchetes e preencha cada seção.

## 1. Anomalias


A planilha da Biblioteca Saber apresenta anomalias porque reúne informações de empréstimos, leitores, cursos, livros e editoras em uma única tabela, causando repetição de dados.

| Anomalia | Exemplo na planilha |
| --- | --- |
| Inserção | O livro Direito Civil (ISBN 978-85-03) aparece associado ao empréstimo 9002. Se fosse necessário cadastrá-lo antes de qualquer empréstimo, os campos do empréstimo ficariam vazios. |
| Exclusão | Ao excluir o empréstimo 9002, também perderíamos os dados da leitora Lara Mendes e do curso de Direito, pois aparecem somente nesse registro. |
| Modificação | A editora Alta Books aparece em quatro registros. Se seu nome mudar, será necessário atualizar todas as ocorrências para evitar informações inconsistentes. |


## 2. Dependências funcionais da `planilha`


| Determinante | Determina | Tipo (total, parcial ou transitiva) |
| --- | --- | --- |
| cod_emprestimo | data_emprestimo, matricula_leitor, data_devolucao | Parcial |
| isbn | titulo, cod_editora | Parcial |
| matricula_leitor | nome_leitor, telefones, cod_curso | Transitiva em relação à chave |
| cod_curso | nome_curso | Transitiva em relação à chave |
| cod_editora | editora | Transitiva em relação à chave |

**Chave primária proposta da `planilha`:** (`cod_emprestimo`, `isbn`).

**Dependências totais:** Nenhum atributo não-chave depende exclusivamente da chave composta completa. As dependências identificadas são parciais ou transitivas.


## 3. Normalização passo a passo

**1FN:** [o que não era atômico e como ficou]

**2FN:** [quais dependências parciais e como ficou]

**3FN:** [quais dependências transitivas e como ficou]

**Esquema final em 3FN:** [Tabela(atributos), com PK sublinhada ou em negrito e FK indicada]

## 4. FNBC: `planilha_fnbc`

- Chaves candidatas: [ ]
- Dependência que viola a FNBC: [ ]
- Decomposição: [ ]

## 5. 4FN: `planilha_4fn`

- Dependências multivaloradas: [ ]
- Decomposição: [ ]

## 6. Modelagem

### 6.1 Modelo conceitual (Peter Chen)

[Entidades, atributos (identificador sublinhado; multivalorado com elipse dupla), relacionamentos com nome e cardinalidade (mín, máx).]

![Modelo conceitual](modelo_conceitual.png)

### 6.2 Modelo lógico (James Martin, pé de galinha)

[Todas as tabelas finais com seus atributos, PK e FK, e as linhas de relacionamento com a cardinalidade nas pontas.]

![Modelo lógico](modelo_logico.png)

## 7. Dicionário de dados

Preencha o arquivo [`dicionario_dados.md`](dicionario_dados.md) com **todas** as tabelas finais.

## 8. Prova de junção sem perda

[Cole aqui o resultado do `03_prova_sem_perda.sql`: para cada planilha, linhas da original, linhas da reconstruída, faltando = 0 e sobrando = 0.]

```
(cole o resultado)
```

## 9. Desafio: uma decomposição errada

[Mostre uma decomposição da `planilha_fnbc` que **perde** informação: as duas tabelas, a consulta de junção e quantas linhas falsas (tuplas espúrias) ela gera.]
