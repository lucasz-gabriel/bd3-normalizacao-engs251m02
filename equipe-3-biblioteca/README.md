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

**Observação sobre os telefones:** O campo `telefones` apresenta valores múltiplos. Por exemplo, Pedro Costa possui dois números armazenados no mesmo campo, separados por ponto e vírgula. Isso precisa ser corrigido na 1FN, separando os telefones em registros individuais.

## 3. Normalização passo a passo

**1FN:** O campo `telefones` guardava mais de um valor na mesma célula (por exemplo, dois números de Pedro Costa separados por ponto e vírgula), então não era atômico. Cada número passou a ocupar um registro próprio, na tabela `leitor_telefone(matricula_leitor, telefone)`, com PK composta (`matricula_leitor`, `telefone`). Os demais atributos já eram atômicos e a planilha ficou sem grupos repetidos.

**2FN:** A chave primária é composta (`cod_emprestimo`, `isbn`), e dois grupos de atributos dependiam de apenas uma parte dela:
- `cod_emprestimo` → `data_emprestimo`, `matricula_leitor`, `data_devolucao`. Esses atributos foram para a tabela `emprestimo`.
- `isbn` → `titulo`, `cod_editora`. Esses atributos foram para a tabela `livro`.
  
A ligação entre empréstimo e livro, que é de muitos para muitos, ficou na tabela `emprestimo_livro(cod_emprestimo, isbn)`, que guarda só a chave composta. Os atributos do leitor, do curso e da editora seguiram nas tabelas `emprestimo` e `livro`, e a 3FN trata deles.

**3FN:** Sobraram dependências transitivas, em que um atributo não-chave determina outro:
- Em `emprestimo`: `cod_emprestimo` → `matricula_leitor` → `nome_leitor`, `cod_curso`. Esses atributos foram para a tabela `leitor`.
- Em `leitor`: `matricula_leitor` → `cod_curso` → `nome_curso`. O `nome_curso` foi para a tabela `curso`.
- Em `livro`: `isbn` → `cod_editora` → `editora`. O nome da editora foi para a tabela `editora`.

Com isso, cada atributo não-chave depende somente da chave, de toda a chave e de nada além dela. Os problemas da seção 1 deixam de existir:
- Cadastrar um livro não exige empréstimo.
- Excluir o empréstimo 9002 não apaga a leitora Lara Mendes nem o curso de Direito.
- O nome da Alta Books fica em um único registro.

**Esquema final em 3FN:** 
- **curso**(<ins>cod_curso</ins>, nome_curso)
- **editora**(<ins>cod_editora</ins>, editora)
- **leitor**(<ins>matricula_leitor</ins>, nome_leitor, cod_curso) — FK: `cod_curso` → curso
- **leitor_telefone**(<ins>matricula_leitor</ins>, <ins>telefone</ins>) — FK: `matricula_leitor` → leitor
- **livro**(<ins>isbn</ins>, titulo, cod_editora) — FK: `cod_editora` → editora
- **emprestimo**(<ins>cod_emprestimo</ins>, data_emprestimo, data_devolucao, matricula_leitor) — FK: `matricula_leitor` → leitor
- **emprestimo_livro**(<ins>cod_emprestimo</ins>, <ins>isbn</ins>) — FKs: `cod_emprestimo` → emprestimo; `isbn` → livro

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
