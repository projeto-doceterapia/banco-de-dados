DROP DATABASE IF EXISTS doce_terapia;
CREATE DATABASE IF NOT EXISTS doce_terapia;
USE doce_terapia;

-- TABELAS DE APOIO


CREATE TABLE categoria_produto (
    id_categoria_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    descricao VARCHAR(245)
);

CREATE TABLE categoria_insumo (
    id_categoria_insumo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    descricao VARCHAR(245)
);

-- =====================================
-- TABELAS PRINCIPAIS
-- =====================================

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    telefone CHAR(12) NOT NULL,
    endereco VARCHAR(245) NOT NULL,
    tipo_cliente VARCHAR(45),
    status TINYINT NOT NULL DEFAULT 1,
    observacao VARCHAR(245),

    CONSTRAINT chk_cliente_status
        CHECK (status IN (0, 1))
);

CREATE TABLE produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    fk_categoria_produto INT NOT NULL,
    nome VARCHAR(45) NOT NULL,
    custo_estimado DECIMAL(10,2),
    preco_atual DECIMAL(10,2),
    preco_sugerido DECIMAL(10,2),
    margem_lucro DECIMAL(10,2),
    unidade_producao VARCHAR(45),
    status TINYINT NOT NULL DEFAULT 1,
    descricao VARCHAR(245),

    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (fk_categoria_produto)
        REFERENCES categoria_produto(id_categoria_produto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_produto_status
        CHECK (status IN (0, 1)),

    CONSTRAINT chk_produto_custo
        CHECK (custo_estimado IS NULL OR custo_estimado >= 0),

    CONSTRAINT chk_produto_preco_atual
        CHECK (preco_atual IS NULL OR preco_atual >= 0),

    CONSTRAINT chk_produto_preco_sugerido
        CHECK (preco_sugerido IS NULL OR preco_sugerido >= 0)
);

CREATE TABLE insumo (
    id_insumo INT PRIMARY KEY AUTO_INCREMENT,
    fk_categoria_insumo INT NOT NULL,
    nome VARCHAR(45) NOT NULL,
    quantidade_atual DECIMAL(10,3) NOT NULL DEFAULT 0,
    quantidade_minima DECIMAL(10,3) NOT NULL DEFAULT 0,
    unidade VARCHAR(45) NOT NULL,
    status TINYINT NOT NULL DEFAULT 1,
    marca VARCHAR(45),

    CONSTRAINT fk_insumo_categoria
        FOREIGN KEY (fk_categoria_insumo)
        REFERENCES categoria_insumo(id_categoria_insumo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_insumo_status
        CHECK (status IN (0, 1)),

    CONSTRAINT chk_insumo_qtd_atual
        CHECK (quantidade_atual >= 0),

    CONSTRAINT chk_insumo_qtd_minima
        CHECK (quantidade_minima >= 0)
);

CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fk_cliente INT NOT NULL,
    tipo_pedido VARCHAR(45) NOT NULL,
    status_pedido VARCHAR(245) NOT NULL,
    forma_entrega VARCHAR(45) NOT NULL,
    endereco_entrega VARCHAR(225),
    data_criacao DATE NOT NULL,
    data_entrega DATE,
    anotacao VARCHAR(245),

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (fk_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE pagamento (
    id_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL UNIQUE,
    valor_total DECIMAL(10,2) NOT NULL,
    valor_sinal DECIMAL(10,2) NOT NULL,
    valor_restante DECIMAL(10,2) NOT NULL,
    status_pagamento VARCHAR(245) NOT NULL,

    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_pagamento_total
        CHECK (valor_total >= 0),

    CONSTRAINT chk_pagamento_sinal
        CHECK (valor_sinal >= 0),

    CONSTRAINT chk_pagamento_restante
        CHECK (valor_restante >= 0)
);

CREATE TABLE cancelamento_pedido (
    id_cancelamento INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL UNIQUE,
    tipo_cancelamento VARCHAR(45) NOT NULL,
    valor_retorno DECIMAL(10,2),
    data_cancelamento DATE NOT NULL,
    observacao VARCHAR(245),

    CONSTRAINT fk_cancelamento_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_cancelamento_valor
        CHECK (valor_retorno IS NULL OR valor_retorno >= 0)
);

CREATE TABLE item_pedido (
    id_produto_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fk_produto INT NOT NULL,
    fk_pedido INT NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    observacao VARCHAR(245),

    CONSTRAINT fk_item_pedido_produto
        FOREIGN KEY (fk_produto)
        REFERENCES produto(id_produto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_item_pedido_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_item_pedido_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT chk_item_pedido_valor_unitario
        CHECK (valor_unitario >= 0),

    CONSTRAINT chk_item_pedido_valor_total
        CHECK (valor_total >= 0)
);

CREATE TABLE producao (
    id_producao INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL,
    fk_item_pedido INT NOT NULL,
    data_inicio DATE,
    data_prevista DATE,
    status_producao VARCHAR(45) NOT NULL,
    prioridade VARCHAR(45),
    observacao VARCHAR(245),

    CONSTRAINT fk_producao_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_producao_item_pedido
        FOREIGN KEY (fk_item_pedido)
        REFERENCES item_pedido(id_produto_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE produto_insumo (
    id_produto_insumo INT PRIMARY KEY AUTO_INCREMENT,
    fk_produto INT NOT NULL,
    fk_insumo INT NOT NULL,
    quantidade_utilizada DECIMAL(10,3) NOT NULL,
    unidade VARCHAR(45) NOT NULL,

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

    CONSTRAINT chk_produto_insumo_qtd
        CHECK (quantidade_utilizada > 0),

    CONSTRAINT uq_produto_insumo
        UNIQUE (fk_produto, fk_insumo)
);



-- INSERTS DE APOIO


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

INSERT INTO cliente (nome, telefone, endereco, tipo_cliente, observacao) VALUES
('Ana Souza', '11987654321', 'Rua das Flores, 120', 'recorrente', 'Cliente fiel'),
('Bruno Lima', '11976543210', 'Av. do Café, 450', 'comum', 'Prefere retirada'),
('Carla Mendes', '11965432109', 'Rua dos Doces, 89', 'vip', 'Cliente corporativa');

INSERT INTO produto (
    fk_categoria_produto, nome, custo_estimado, preco_atual, preco_sugerido,
    margem_lucro, unidade_producao, status, descricao
) VALUES
(1, 'Bolo de Chocolate', 35.00, 85.00, 90.00, 58.76, 'unidade', 1, 'Bolo de chocolate com cobertura de brigadeiro'),
(2, 'Brigadeiro Gourmet', 1.20, 3.50, 4.00, 65.71, 'unidade', 1, 'Brigadeiro tradicional enrolado com granulado belga'),
(3, 'Torta de Morango', 28.00, 70.00, 75.00, 60.00, 'unidade', 1, 'Torta com creme e morangos frescos');

INSERT INTO insumo (
    fk_categoria_insumo, nome, quantidade_atual, quantidade_minima,
    unidade, status, marca
) VALUES
(1, 'Farinha de trigo', 5.000, 1.000, 'kg', 1, 'Dona Benta'),
(1, 'Chocolate em pó', 2.000, 0.500, 'kg', 1, 'Nestlé'),
(2, 'Leite condensado', 20.000, 5.000, 'unidade', 1, 'Moça'),
(2, 'Creme de leite', 10.000, 2.000, 'litro', 1, 'Italac'),
(3, 'Morango', 8.000, 2.000, 'kg', 1, 'Hortifruti Premium'),
(1, 'Granulado belga', 1.500, 0.300, 'kg', 1, 'Callebaut');

INSERT INTO produto_insumo (fk_produto, fk_insumo, quantidade_utilizada, unidade) VALUES
(1, 1, 0.500, 'kg'),
(1, 2, 0.200, 'kg'),
(1, 3, 2.000, 'unidade'),
(2, 3, 0.050, 'unidade'),
(2, 6, 0.010, 'kg'),
(3, 5, 0.500, 'kg'),
(3, 4, 0.300, 'litro');

INSERT INTO pedido (
    fk_cliente, tipo_pedido, status_pedido, forma_entrega,
    endereco_entrega, data_criacao, data_entrega, anotacao
) VALUES
(1, 'pedido', 'aguardando_sinal', 'entrega', 'Rua das Flores, 120', '2026-03-20', '2026-03-21', 'Pedido para festa de aniversário'),
(2, 'pedido', 'em_producao', 'retirada', NULL, '2026-03-21', '2026-03-22', 'Cliente pediu confirmação antes da retirada'),
(3, 'orcamento', 'orcamento', 'entrega', 'Rua dos Doces, 89', '2026-03-22', '2026-03-25', 'Aguardando retorno do cliente');

INSERT INTO pagamento (
    fk_pedido, valor_total, valor_sinal, valor_restante, status_pagamento
) VALUES
(1, 155.00, 77.50, 77.50, 'aguardando_sinal'),
(2, 70.00, 35.00, 35.00, 'sinal_pago'),
(3, 220.00, 110.00, 110.00, 'aguardando_sinal');

INSERT INTO item_pedido (
    fk_produto, fk_pedido, quantidade, valor_unitario, valor_total, observacao
) VALUES
(1, 1, 1, 85.00, 85.00, 'Escrever "Parabéns Ana" no bolo'),
(2, 1, 20, 3.50, 70.00, 'Granulado meio amargo'),
(3, 2, 1, 70.00, 70.00, 'Somente morango'),
(2, 3, 50, 4.40, 220.00, 'Orçamento para evento corporativo');

INSERT INTO producao (
    fk_pedido, fk_item_pedido, data_inicio, data_prevista, status_producao, prioridade, observacao
) VALUES
(1, 1, '2026-03-20', '2026-03-21', 'pendente', 'alta', 'Produção do bolo principal'),
(2, 3, '2026-03-21', '2026-03-22', 'em_producao', 'media', 'Torta em preparo');

INSERT INTO cancelamento_pedido (
    fk_pedido, tipo_cancelamento, valor_retorno, data_cancelamento, observacao
) VALUES
(3, 'credito', 110.00, '2026-03-23', 'Cliente optou por crédito');


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


-- PRODUÇÃO POR ITEM

SELECT
    CONCAT('#', prd.id_producao) AS 'Produção',
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(prod.nome) AS 'Produto',
    CONCAT(IFNULL(DATE_FORMAT(prd.data_inicio, '%d/%m/%Y'), 'Não iniciada')) AS 'Data de início',
    CONCAT(IFNULL(DATE_FORMAT(prd.data_prevista, '%d/%m/%Y'), 'Sem previsão')) AS 'Data prevista',
    CONCAT(prd.status_producao) AS 'Status da produção',
    CONCAT(IFNULL(prd.prioridade, 'Normal')) AS 'Prioridade'
FROM producao prd
JOIN pedido p
    ON p.id_pedido = prd.fk_pedido
JOIN item_pedido ip
    ON ip.id_produto_pedido = prd.fk_item_pedido
JOIN produto prod
    ON prod.id_produto = ip.fk_produto;


-- CANCELAMENTO POR PEDIDO
SELECT
    CONCAT('#', p.id_pedido) AS 'Pedido',
    CONCAT(cp.tipo_cancelamento) AS 'Tipo de cancelamento',
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