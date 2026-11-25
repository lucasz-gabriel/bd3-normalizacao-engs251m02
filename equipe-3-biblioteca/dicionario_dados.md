# Dicionário de dados

Uma tabela de dicionário para **cada** tabela do modelo final, usando os tipos do MySQL. O exemplo abaixo (de outro sistema) mostra o nível de detalhe esperado.

**Exemplo: tabela `produto`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_produto | CHAR | 5 | Não | PK | Código do produto | Formato P0000 |
| nome | VARCHAR | 60 | Não |  | Nome do produto |  |
| preco | DECIMAL | 8,2 | Não |  | Preço de venda em R$ | Maior que 0 |
| cod_categoria | CHAR | 2 | Não | FK → categoria | Categoria do produto | Deve existir em `categoria` |

----------------------------------------------------------------------------------------------------------------------------------------

# Dicionário de dados

Uma tabela de dicionário para **cada** tabela do modelo final, usando os tipos do MySQL. O exemplo abaixo (de outro sistema) mostra o nível de detalhe esperado.

**Exemplo: tabela `produto`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_produto | CHAR | 5 | Não | PK | Código do produto | Formato P0000 |
| nome | VARCHAR | 60 | Não |  | Nome do produto |  |
| preco | DECIMAL | 8,2 | Não |  | Preço de venda em R$ | Maior que 0 |
| cod_categoria | CHAR | 2 | Não | FK → categoria | Categoria do produto | Deve existir em `categoria` |

---

# Tabelas da Biblioteca Saber

Banco `normalizacao_biblioteca` (MySQL). São 11 tabelas: 7 vindas da `planilha` (3FN), 2 da `planilha_fnbc` (FNBC) e 2 da `planilha_4fn` (4FN).

---

## Tabelas da `planilha` (3FN)

**Tabela: `curso`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_curso | CHAR | 2 | Não | PK | Código do curso | Formato C + dígito (ex.: C1) |
| nome_curso | VARCHAR | 40 | Não |  | Nome do curso | |

**Tabela: `editora`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_editora | CHAR | 2 | Não | PK | Código da editora | Formato E + dígito (ex.: E1) |
| editora | VARCHAR | 30 | Não |  | Nome da editora | |

**Tabela: `leitor`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| matricula_leitor | INT | | Não | PK | Matrícula do leitor | Número inteiro positivo |
| nome_leitor | VARCHAR | 60 | Não |  | Nome completo do leitor | |
| cod_curso | CHAR | 2 | Não | FK → curso | Curso do leitor | Deve existir em `curso` |

**Tabela: `leitor_telefone`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| matricula_leitor | INT | | Não | PK, FK → leitor | Leitor dono do telefone | Deve existir em `leitor` |
| telefone | VARCHAR | 20 | Não | PK | Número de telefone do leitor | Formato (92) 9XXXX-XXXX; um número por registro |

**Tabela: `livro`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| isbn | VARCHAR | 13 | Não | PK | ISBN do livro | Formato 978-85-NN |
| titulo | VARCHAR | 60 | Não |  | Título do livro | |
| cod_editora | CHAR | 2 | Não | FK → editora | Editora do livro | Deve existir em `editora` |

**Tabela: `emprestimo`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_emprestimo | INT | | Não | PK | Código do empréstimo | Número inteiro positivo |
| data_emprestimo | DATE | | Não |  | Data em que o empréstimo foi feito | |
| data_devolucao | DATE | | Sim |  | Data de devolução | Não pode ser anterior a `data_emprestimo`; nulo se ainda não devolvido |
| matricula_leitor | INT | | Não | FK → leitor | Leitor que fez o empréstimo | Deve existir em `leitor` |

**Tabela: `emprestimo_livro`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| cod_emprestimo | INT | | Não | PK, FK → emprestimo | Empréstimo | Deve existir em `emprestimo` |
| isbn | VARCHAR | 13 | Não | PK, FK → livro | Livro emprestado | Deve existir em `livro` |

---

## Tabelas da `planilha_fnbc` (FNBC)

**Tabela: `bibliotecario`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| bibliotecario | VARCHAR | 60 | Não | PK | Nome do bibliotecário | |
| area | VARCHAR | 30 | Não |  | Área que o bibliotecário atende | Cada bibliotecário atende uma única área |

**Tabela: `leitor_bibliotecario`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| leitor | VARCHAR | 60 | Não | PK | Nome do leitor | |
| bibliotecario | VARCHAR | 60 | Não | PK, FK → bibliotecario | Bibliotecário de referência do leitor | Deve existir em `bibliotecario`; em cada área, o leitor tem um único bibliotecário (regra garantida à parte) |

---

## Tabelas da `planilha_4fn` (4FN)

**Tabela: `livro_autor`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| isbn | VARCHAR | 13 | Não | PK, FK → livro | Livro | Deve existir em `livro` |
| autor | VARCHAR | 60 | Não | PK | Nome do autor do livro | Um livro pode ter vários autores |

**Tabela: `livro_palavra_chave`**

| Atributo | Tipo | Tamanho | Nulo? | Chave | Descrição | Restrição / domínio |
| --- | --- | --- | --- | --- | --- | --- |
| isbn | VARCHAR | 13 | Não | PK, FK → livro | Livro | Deve existir em `livro` |
| palavra_chave | VARCHAR | 30 | Não | PK | Palavra-chave do livro | Um livro pode ter várias palavras-chave |

