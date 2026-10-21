DROP DATABASE IF EXISTS doce_terapia;
CREATE DATABASE IF NOT EXISTS doce_terapia
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
USE doce_terapia;

SET NAMES utf8mb4;

-- =====================================
-- TABELAS DE APOIO
-- =====================================

CREATE TABLE categoria_produto (
    id_categoria_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    descricao VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE categoria_insumo (
    id_categoria_insumo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    descricao VARCHAR(255)
) ENGINE=InnoDB;

-- =====================================
-- TABELAS PRINCIPAIS
-- =====================================

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255),
    telefone VARCHAR(20),
    endereco VARCHAR(255),
    tipo_pessoa VARCHAR(20),
    classificacao_cliente VARCHAR(20),
    status VARCHAR(20),
    observacao TEXT,

    CONSTRAINT ck_cliente_status
        CHECK (status IN ('ATIVO', 'INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    fk_categoria_produto INT NOT NULL,
    nome VARCHAR(255),
    custo_estimado DECIMAL(10,2),
    preco_atual DECIMAL(10,2),
    preco_sugerido DECIMAL(10,2),
    margem_lucro DECIMAL(10,2),
    unidade_producao VARCHAR(20),
    status VARCHAR(20),
    quantidade_produzida INT,
    descricao VARCHAR(255),

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (fk_categoria_produto)
        REFERENCES categoria_produto(id_categoria_produto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT ck_produto_status
        CHECK (status IN ('ATIVO', 'INATIVO'))
) ENGINE=InnoDB;

CREATE TABLE insumo (
    id_insumo INT PRIMARY KEY AUTO_INCREMENT,
    fk_categoria_insumo INT,
    nome VARCHAR(255),
    nome_normalizado VARCHAR(120),
    quantidade_atual DECIMAL(10,3) DEFAULT 0,
    quantidade_minima DECIMAL(10,3),
    unidade VARCHAR(20),
    custo_unitario DECIMAL(10,4),
    status VARCHAR(20),
    marca VARCHAR(255),

    CONSTRAINT fk_insumo_categoria
        FOREIGN KEY (fk_categoria_insumo)
        REFERENCES categoria_insumo(id_categoria_insumo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT ck_insumo_status
        CHECK (status IN ('ATIVO', 'INATIVO')),

    KEY idx_insumo_nome_normalizado (nome_normalizado)
) ENGINE=InnoDB;

CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fk_cliente INT NOT NULL,
    tipo_pedido VARCHAR(20) NOT NULL,
    status_pedido VARCHAR(30) NOT NULL,
    forma_entrega VARCHAR(20),
    endereco_entrega VARCHAR(255),
    data_criacao DATETIME(6),
    data_confirmacao DATETIME(6),
    data_entrega DATE,
    anotacao TEXT,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (fk_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pagamento (
    id_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL UNIQUE,
    valor_total DECIMAL(10,2),
    valor_sinal DECIMAL(10,2),
    valor_restante DECIMAL(10,2),
    status_pagamento VARCHAR(20) NOT NULL,
    forma_pagamento VARCHAR(20),
    data_pagamento_sinal DATE,
    data_pagamento_restante DATE,

    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cancelamento_pedido (
    id_cancelamento INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL UNIQUE,
    tipo_cancelamento VARCHAR(30) NOT NULL,
    tipo_retorno VARCHAR(30) NOT NULL,
    valor_retorno DECIMAL(10,2),
    data_cancelamento DATETIME(6),
    observacao TEXT,

    CONSTRAINT fk_cancelamento_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE item_pedido (
    id_produto_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fk_produto INT NOT NULL,
    fk_pedido INT NOT NULL,
    quantidade DECIMAL(10,3),
    preco_original_produto DECIMAL(10,2),
    valor_unitario DECIMAL(10,2),
    valor_total DECIMAL(10,2),
    custo_estimado_item DECIMAL(10,2),
    margem_lucro_item DECIMAL(10,2),
    observacao TEXT,

    CONSTRAINT fk_item_pedido_produto
        FOREIGN KEY (fk_produto)
        REFERENCES produto(id_produto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_item_pedido_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE producao (
    id_producao INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL UNIQUE,
    data_inicio DATE,
    data_prevista DATE,
    data_finalizacao DATE,
    status_producao VARCHAR(45) NOT NULL,
    observacao TEXT,

    CONSTRAINT fk_producao_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE produto_insumo (
    id_produto_insumo INT PRIMARY KEY AUTO_INCREMENT,
    fk_produto INT NOT NULL,
    fk_insumo INT NOT NULL,
    quantidade_utilizada DECIMAL(10,3) NOT NULL,
    unidade VARCHAR(20) NOT NULL,

    CONSTRAINT fk_produto_insumo_produto
        FOREIGN KEY (fk_produto)
        REFERENCES produto(id_produto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_produto_insumo_insumo
        FOREIGN KEY (fk_insumo)
        REFERENCES insumo(id_insumo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_produto_insumo
        UNIQUE (fk_produto, fk_insumo)
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255),
    email VARCHAR(255),
    senha VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE configuracao_farol_agenda (
    id_configuracao_farol INT PRIMARY KEY AUTO_INCREMENT,
    limite_verde INT NOT NULL,
    limite_amarelo INT NOT NULL,
    limite_vermelho INT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE notificacao (
    id_notificacao INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(30) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    mensagem TEXT NOT NULL,
    data_criacao DATETIME(6) NOT NULL,
    lida BIT(1) NOT NULL DEFAULT b'0',
    chave_unicidade VARCHAR(150),
    janela_inicio DATETIME(6),
    janela_fim DATETIME(6),
    template_key VARCHAR(80),
    parametros TEXT,
    status_envio VARCHAR(20) NOT NULL DEFAULT 'NAO_ENVIAR',
    enviado_em DATETIME(6),
    canal_message_id VARCHAR(120),
    fk_pedido INT,
    fk_insumo INT,

    CONSTRAINT uq_notificacao_chave_unicidade
        UNIQUE (chave_unicidade),

    CONSTRAINT fk_notificacao_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT fk_notificacao_insumo
        FOREIGN KEY (fk_insumo)
        REFERENCES insumo(id_insumo)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE configuracao_notificacao (
    id_configuracao_notificacao INT PRIMARY KEY AUTO_INCREMENT,
    inicio_expediente TIME NOT NULL DEFAULT '08:00:00',
    fim_expediente TIME NOT NULL DEFAULT '18:00:00',
    dias_expediente VARCHAR(20) NOT NULL DEFAULT '1,2,3,4,5,6',
    horario_resumo_inicio TIME NOT NULL DEFAULT '08:00:00',
    horario_resumo_fim TIME NOT NULL DEFAULT '17:30:00',
    dias_antecedencia INT NOT NULL DEFAULT 3,
    resumo_inicio_dia_ativo BIT(1) NOT NULL DEFAULT b'1',
    resumo_fim_dia_ativo BIT(1) NOT NULL DEFAULT b'1',
    alerta_estoque_baixo_ativo BIT(1) NOT NULL DEFAULT b'1',
    alerta_dia_lotado_ativo BIT(1) NOT NULL DEFAULT b'1'
) ENGINE=InnoDB;

-- Ledger de estoque (append-only). insumo.quantidade_atual passa a ser um
-- cache escrito apenas pelo servico de movimentacao; o saldo verdadeiro e a
-- soma das movimentacoes.
CREATE TABLE movimentacao_estoque (
    id_movimentacao INT PRIMARY KEY AUTO_INCREMENT,
    fk_insumo INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    quantidade_informada DECIMAL(10,3) NOT NULL,
    unidade_informada VARCHAR(20) NOT NULL,
    custo_unitario DECIMAL(10,4),
    origem VARCHAR(20) NOT NULL,
    chave_nota VARCHAR(44),
    fluxo_id VARCHAR(255),
    chave_idempotencia VARCHAR(120),
    hash_conteudo VARCHAR(64) NOT NULL,
    ocorrido_em DATETIME(6) NOT NULL,
    criado_em DATETIME(6) NOT NULL,

    CONSTRAINT fk_movimentacao_insumo
        FOREIGN KEY (fk_insumo)
        REFERENCES insumo(id_insumo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT uq_movimentacao_chave_idempotencia
        UNIQUE (chave_idempotencia),

    KEY idx_movimentacao_chave_nota (chave_nota)
) ENGINE=InnoDB;

-- =====================================
-- INSERTS DE APOIO
-- =====================================

INSERT INTO categoria_produto (nome, descricao) VALUES
('Bolo', 'Produtos do tipo bolo'),
('Docinhos', 'Doces e brigadeiros'),
('Torta', 'Produtos do tipo torta');

INSERT INTO categoria_insumo (nome, descricao) VALUES
('Secos', 'Ingredientes secos'),
('Laticínios', 'Ingredientes lácteos'),
('Frutas', 'Ingredientes frescos');

-- =====================================
-- INSERTS PRINCIPAIS
-- =====================================

INSERT INTO cliente (nome, telefone, endereco, tipo_pessoa, classificacao_cliente, status, observacao) VALUES
('Ana Souza', '11987654321', 'Rua das Flores, 120', 'FISICA', 'FREQUENTE', 'ATIVO', 'Cliente fiel'),
('Bruno Lima', '11976543210', 'Av. do Café, 450', 'FISICA', 'PADRAO', 'ATIVO', 'Prefere retirada'),
('Carla Mendes', '11965432109', 'Rua dos Doces, 89', 'JURIDICA', 'ALTO_VOLUME', 'ATIVO', 'Cliente corporativa');

INSERT INTO produto (
    fk_categoria_produto, nome, custo_estimado, preco_atual, preco_sugerido,
    margem_lucro, unidade_producao, status, quantidade_produzida, descricao
) VALUES
(1, 'Bolo de Chocolate', 35.00, 85.00, 90.00, 58.76, 'UNIDADE', 'ATIVO', 10, 'Bolo de chocolate com cobertura de brigadeiro'),
(2, 'Brigadeiro Gourmet', 1.20, 3.50, 4.00, 65.71, 'UNIDADE', 'ATIVO', 200, 'Brigadeiro tradicional enrolado com granulado belga'),
(3, 'Torta de Morango', 28.00, 70.00, 75.00, 60.00, 'UNIDADE', 'ATIVO', 8, 'Torta com creme e morangos frescos');

-- nome_normalizado: trim, minusculas, sem acentos, espacos colapsados.
-- Preenchido aqui para os seeds; o back-end mantem a coluna em sincronia.
INSERT INTO insumo (
    fk_categoria_insumo, nome, nome_normalizado, quantidade_atual, quantidade_minima,
    unidade, custo_unitario, status, marca
) VALUES
(1, 'Farinha de trigo', 'farinha de trigo', 5.000, 1.000, 'KG', 6.5000, 'ATIVO', 'Dona Benta'),
(1, 'Chocolate em pó', 'chocolate em po', 2.000, 0.500, 'KG', 22.0000, 'ATIVO', 'Nestlé'),
(2, 'Leite condensado', 'leite condensado', 20.000, 5.000, 'UNIDADE', 6.0000, 'ATIVO', 'Moça'),
(2, 'Creme de leite', 'creme de leite', 10.000, 2.000, 'L', 12.0000, 'ATIVO', 'Italac'),
(3, 'Morango', 'morango', 8.000, 2.000, 'KG', 18.0000, 'ATIVO', 'Hortifruti Premium'),
(1, 'Granulado belga', 'granulado belga', 1.500, 0.300, 'KG', 35.0000, 'ATIVO', 'Callebaut');

INSERT INTO produto_insumo (fk_produto, fk_insumo, quantidade_utilizada, unidade) VALUES
(1, 1, 0.500, 'KG'),
(1, 2, 0.200, 'KG'),
(1, 3, 2.000, 'UNIDADE'),
(2, 3, 0.050, 'UNIDADE'),
(2, 6, 0.010, 'KG'),
(3, 5, 0.500, 'KG'),
(3, 4, 0.300, 'L');

INSERT INTO pedido (
    fk_cliente, tipo_pedido, status_pedido, forma_entrega,
    endereco_entrega, data_criacao, data_entrega, anotacao
) VALUES
(1, 'PEDIDO_CONFIRMADO', 'AGUARDANDO_SINAL', 'ENTREGA', 'Rua das Flores, 120', '2026-03-20 09:00:00', '2026-03-21', 'Pedido para festa de aniversário'),
(2, 'PEDIDO_CONFIRMADO', 'EM_PRODUCAO', 'RETIRADA', NULL, '2026-03-21 10:30:00', '2026-03-22', 'Cliente pediu confirmação antes da retirada'),
(3, 'ORCAMENTO', 'ORCAMENTO', 'ENTREGA', 'Rua dos Doces, 89', '2026-03-22 14:00:00', '2026-03-25', 'Aguardando retorno do cliente');

INSERT INTO pagamento (
    fk_pedido, valor_total, valor_sinal, valor_restante, status_pagamento, forma_pagamento
) VALUES
(1, 155.00, 77.50, 77.50, 'AGUARDANDO_SINAL', 'PIX'),
(2, 70.00, 35.00, 35.00, 'AGUARDANDO_PAGAMENTO', 'CARTAO_CREDITO'),
(3, 220.00, 110.00, 110.00, 'AGUARDANDO_SINAL', 'PIX');

INSERT INTO item_pedido (
    fk_produto, fk_pedido, quantidade, valor_unitario, valor_total, observacao
) VALUES
(1, 1, 1.000, 85.00, 85.00, 'Escrever "Parabéns Ana" no bolo'),
(2, 1, 20.000, 3.50, 70.00, 'Granulado meio amargo'),
(3, 2, 1.000, 70.00, 70.00, 'Somente morango'),
(2, 3, 50.000, 4.40, 220.00, 'Orçamento para evento corporativo');

INSERT INTO producao (
    fk_pedido, data_inicio, data_prevista, status_producao, observacao
) VALUES
(1, '2026-03-20', '2026-03-21', 'ESPERANDO_FAZER', 'Produção do bolo principal'),
(2, '2026-03-21', '2026-03-22', 'EM_PRODUCAO', 'Torta em preparo');

INSERT INTO cancelamento_pedido (
    fk_pedido, tipo_cancelamento, tipo_retorno, valor_retorno, data_cancelamento, observacao
) VALUES
(3, 'CLIENTE_DESISTIU', 'CREDITO_CLIENTE', 110.00, '2026-03-23 11:00:00', 'Cliente optou por crédito');

-- =====================================
-- BACKFILL DO LEDGER DE ESTOQUE
-- =====================================
-- Cria uma movimentacao SALDO_INICIAL para cada insumo com saldo diferente de
-- zero, de modo que a soma das movimentacoes seja igual a quantidade_atual
-- (cache). Rode este bloco apos qualquer carga inicial de dados que escreva
-- quantidade_atual diretamente, para que ledger e cache fiquem consistentes.
-- E idempotente: so insere para insumos que ainda nao possuem SALDO_INICIAL.
INSERT INTO movimentacao_estoque (
    fk_insumo, tipo, quantidade, quantidade_informada, unidade_informada,
    custo_unitario, origem, hash_conteudo, ocorrido_em, criado_em
)
SELECT
    i.id_insumo,
    'SALDO_INICIAL',
    i.quantidade_atual,
    i.quantidade_atual,
    i.unidade,
    i.custo_unitario,
    'MANUAL',
    SHA2(CONCAT('SALDO_INICIAL:', i.id_insumo, ':', i.quantidade_atual), 256),
    NOW(6),
    NOW(6)
FROM insumo i
WHERE COALESCE(i.quantidade_atual, 0) <> 0
  AND NOT EXISTS (
      SELECT 1 FROM movimentacao_estoque m
      WHERE m.fk_insumo = i.id_insumo
        AND m.tipo = 'SALDO_INICIAL'
  );

-- =====================================
-- CONSULTAS PRINCIPAIS
-- =====================================

-- PEDIDO POR CLIENTE
SELECT
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(c.nome) AS 'Cliente',
    CONCAT(p.tipo_pedido) AS 'Tipo do pedido',
    CONCAT(p.status_pedido) AS 'Status do pedido',
    CONCAT(p.forma_entrega) AS 'Forma de entrega',
    CONCAT(DATE_FORMAT(p.data_criacao, '%d/%m/%Y')) AS 'Data de criação',
    CONCAT(IFNULL(DATE_FORMAT(p.data_entrega, '%d/%m/%Y'), 'Não definida')) AS 'Data de entrega',
    CONCAT(IFNULL(p.anotacao, 'Nenhuma')) AS 'Observação'
FROM cliente c
JOIN pedido p
    ON p.fk_cliente = c.id_cliente;

-- ITEM POR PEDIDO
SELECT
    CONCAT('Item por pedido') AS 'Tipo de consulta',
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(pr.nome) AS 'Produto',
    CONCAT(ip.quantidade) AS 'Quantidade',
    CONCAT('R$ ', FORMAT(ip.valor_unitario, 2, 'pt_BR')) AS 'Valor unitário',
    CONCAT('R$ ', FORMAT(ip.valor_total, 2, 'pt_BR')) AS 'Valor total',
    CONCAT(IFNULL(ip.observacao, 'Nenhuma')) AS 'Observação'
FROM pedido p
JOIN item_pedido ip
    ON ip.fk_pedido = p.id_pedido
JOIN produto pr
    ON pr.id_produto = ip.fk_produto;

-- COMPOSIÇÃO DO PRODUTO
SELECT
    CONCAT(pr.nome) AS 'Produto',
    CONCAT(i.nome) AS 'Insumo',
    CONCAT(pi.quantidade_utilizada) AS 'Quantidade utilizada',
    CONCAT(pi.unidade) AS 'Unidade'
FROM produto pr
JOIN produto_insumo pi
    ON pi.fk_produto = pr.id_produto
JOIN insumo i
    ON i.id_insumo = pi.fk_insumo;

-- PAGAMENTO POR PEDIDO
SELECT
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(c.nome) AS 'Cliente',
    CONCAT('R$ ', FORMAT(pg.valor_total, 2, 'pt_BR')) AS 'Valor total',
    CONCAT('R$ ', FORMAT(pg.valor_sinal, 2, 'pt_BR')) AS 'Valor do sinal',
    CONCAT('R$ ', FORMAT(pg.valor_restante, 2, 'pt_BR')) AS 'Valor restante',
    CONCAT(pg.status_pagamento) AS 'Status do pagamento'
FROM pedido p
JOIN cliente c
    ON c.id_cliente = p.fk_cliente
JOIN pagamento pg
    ON pg.fk_pedido = p.id_pedido;

-- PRODUÇÃO POR PEDIDO
SELECT
    CONCAT('#', prd.id_producao) AS 'Produção',
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(c.nome) AS 'Cliente',
    CONCAT(IFNULL(DATE_FORMAT(prd.data_inicio, '%d/%m/%Y'), 'Não iniciada')) AS 'Data de início',
    CONCAT(IFNULL(DATE_FORMAT(prd.data_prevista, '%d/%m/%Y'), 'Sem previsão')) AS 'Data prevista',
    CONCAT(prd.status_producao) AS 'Status da produção'
FROM producao prd
JOIN pedido p
    ON p.id_pedido = prd.fk_pedido
JOIN cliente c
    ON c.id_cliente = p.fk_cliente;

-- CANCELAMENTO POR PEDIDO
SELECT
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(cp.tipo_cancelamento) AS 'Tipo de cancelamento',
    CONCAT(cp.tipo_retorno) AS 'Tipo de retorno',
    CONCAT('R$ ', FORMAT(cp.valor_retorno, 2, 'pt_BR')) AS 'Valor de retorno',
    CONCAT(DATE_FORMAT(cp.data_cancelamento, '%d/%m/%Y')) AS 'Data do cancelamento',
    CONCAT(IFNULL(cp.observacao, 'Nenhuma')) AS 'Observação'
FROM cancelamento_pedido cp
JOIN pedido p
    ON p.id_pedido = cp.fk_pedido;

-- PRODUTO POR CATEGORIA
SELECT
    CONCAT(cp.nome) AS 'Categoria do produto',
    CONCAT(p.nome) AS 'Produto',
    CONCAT('R$ ', FORMAT(p.preco_atual, 2, 'pt_BR')) AS 'Preço atual',
    CONCAT('R$ ', FORMAT(p.preco_sugerido, 2, 'pt_BR')) AS 'Preço sugerido',
    CONCAT(FORMAT(p.margem_lucro, 2), '%') AS 'Margem de lucro'
FROM categoria_produto cp
JOIN produto p
    ON p.fk_categoria_produto = cp.id_categoria_produto;

-- INSUMO POR CATEGORIA
SELECT
    CONCAT(ci.nome) AS 'Categoria do insumo',
    CONCAT(i.nome) AS 'Insumo',
    CONCAT(i.quantidade_atual) AS 'Quantidade atual',
    CONCAT(i.quantidade_minima) AS 'Quantidade mínima',
    CONCAT(i.unidade) AS 'Unidade'
FROM categoria_insumo ci
JOIN insumo i
    ON i.fk_categoria_insumo = ci.id_categoria_insumo;
