DROP DATABASE IF EXISTS doce_terapia;
CREATE DATABASE IF NOT EXISTS doce_terapia;
USE doce_terapia;

-- =====================================
-- TABELAS
-- =====================================

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    telefone CHAR(12) NOT NULL,
    endereco VARCHAR(245) NOT NULL,
    descricao_log VARCHAR(1000),
    data_hora_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TINYINT NOT NULL DEFAULT 1,

    CONSTRAINT chk_cliente_status
        CHECK (status IN (0, 1))
);

CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fk_cliente INT NOT NULL,
    data_realizado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descricao_log VARCHAR(1000),
    data_hora_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TINYINT NOT NULL DEFAULT 1,
    anotacao VARCHAR(245),

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (fk_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_pedido_status
        CHECK (status IN (0, 1))
);

CREATE TABLE produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    tipo VARCHAR(45),
    quantidade INT,
    descricao_log VARCHAR(1000),
    data_hora_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TINYINT NOT NULL DEFAULT 1,
    descricao VARCHAR(225),

    CONSTRAINT uq_produto_nome_tipo_descricao
        UNIQUE (nome, tipo, descricao),

    CONSTRAINT chk_produto_quantidade
        CHECK (quantidade IS NULL OR quantidade >= 0),

    CONSTRAINT chk_produto_status
        CHECK (status IN (0, 1))
);

CREATE TABLE produto_pedido (
    id_produto_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fk_pedido INT NOT NULL,
    fk_produto INT NOT NULL,
    quantidade INT,
    tipo_entrega TINYINT,
    endereco_entrega VARCHAR(245),
    data_entrega DATE,
    valor DECIMAL(10,2),
    descricao_log VARCHAR(1000),
    data_hora_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TINYINT NOT NULL DEFAULT 1,
    observacao VARCHAR(245),

    CONSTRAINT fk_produto_pedido_pedido
        FOREIGN KEY (fk_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_produto_pedido_produto
        FOREIGN KEY (fk_produto)
        REFERENCES produto(id_produto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_produto_pedido_quantidade
        CHECK (quantidade IS NULL OR quantidade > 0),

    CONSTRAINT chk_produto_pedido_tipo_entrega
        CHECK (tipo_entrega IN (0, 1)),

    CONSTRAINT chk_produto_pedido_valor
        CHECK (valor IS NULL OR valor >= 0),

    CONSTRAINT chk_produto_pedido_status
        CHECK (status IN (0, 1))
);

CREATE TABLE insumo (
    id_insumo INT PRIMARY KEY AUTO_INCREMENT,
    fk_produto INT NOT NULL,
    nome VARCHAR(45),
    quantidade DECIMAL(4,2),
    unidade VARCHAR(45),
    tipo VARCHAR(245),
    descricao_log VARCHAR(1000),
    data_hora_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TINYINT NOT NULL DEFAULT 1,
    marca VARCHAR(45),

    CONSTRAINT fk_insumo_produto
        FOREIGN KEY (fk_produto)
        REFERENCES produto(id_produto)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_insumo_quantidade
        CHECK (quantidade IS NULL OR quantidade >= 0),

    CONSTRAINT chk_insumo_status
        CHECK (status IN (0, 1))
);

-- =====================================
-- TRIGGERS CLIENTE
-- =====================================

DELIMITER $$

CREATE TRIGGER trg_cliente_bi
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    SET NEW.status = IFNULL(NEW.status, 1);
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'INSERT cliente | nome=', NEW.nome,
        ' | telefone=', NEW.telefone,
        ' | endereco=', NEW.endereco,
        ' | status=', NEW.status
    );
END$$

CREATE TRIGGER trg_cliente_bu
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'UPDATE cliente | ',
        'nome: [', IFNULL(OLD.nome, 'NULL'), '] -> [', IFNULL(NEW.nome, 'NULL'), ']',
        ' | telefone: [', IFNULL(OLD.telefone, 'NULL'), '] -> [', IFNULL(NEW.telefone, 'NULL'), ']',
        ' | endereco: [', IFNULL(OLD.endereco, 'NULL'), '] -> [', IFNULL(NEW.endereco, 'NULL'), ']',
        ' | status: [', IFNULL(OLD.status, 'NULL'), '] -> [', IFNULL(NEW.status, 'NULL'), ']'
    );
END$$

CREATE TRIGGER trg_cliente_bd
BEFORE DELETE ON cliente
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado em cliente. Use UPDATE status = 0 para manter rastreabilidade.';
END$$

-- =====================================
-- TRIGGERS PEDIDO
-- =====================================

CREATE TRIGGER trg_pedido_bi
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN
    SET NEW.status = IFNULL(NEW.status, 1);
    SET NEW.data_realizado = IFNULL(NEW.data_realizado, CURRENT_TIMESTAMP);
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'INSERT pedido | fk_cliente=', NEW.fk_cliente,
        ' | data_realizado=', NEW.data_realizado,
        ' | status=', NEW.status,
        ' | anotacao=', IFNULL(NEW.anotacao, 'NULL')
    );
END$$

CREATE TRIGGER trg_pedido_bu
BEFORE UPDATE ON pedido
FOR EACH ROW
BEGIN
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'UPDATE pedido | ',
        'fk_cliente: [', OLD.fk_cliente, '] -> [', NEW.fk_cliente, ']',
        ' | data_realizado: [', OLD.data_realizado, '] -> [', NEW.data_realizado, ']',
        ' | status: [', IFNULL(OLD.status, 'NULL'), '] -> [', IFNULL(NEW.status, 'NULL'), ']',
        ' | anotacao: [', IFNULL(OLD.anotacao, 'NULL'), '] -> [', IFNULL(NEW.anotacao, 'NULL'), ']'
    );
END$$

CREATE TRIGGER trg_pedido_bd
BEFORE DELETE ON pedido
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado em pedido. Use UPDATE status = 0 para manter rastreabilidade.';
END$$

-- =====================================
-- TRIGGERS PRODUTO
-- =====================================

CREATE TRIGGER trg_produto_bi
BEFORE INSERT ON produto
FOR EACH ROW
BEGIN
    SET NEW.status = IFNULL(NEW.status, 1);
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'INSERT produto | nome=', NEW.nome,
        ' | tipo=', IFNULL(NEW.tipo, 'NULL'),
        ' | quantidade=', IFNULL(NEW.quantidade, 'NULL'),
        ' | descricao=', IFNULL(NEW.descricao, 'NULL'),
        ' | status=', NEW.status
    );
END$$

CREATE TRIGGER trg_produto_bu
BEFORE UPDATE ON produto
FOR EACH ROW
BEGIN
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'UPDATE produto | ',
        'nome: [', IFNULL(OLD.nome, 'NULL'), '] -> [', IFNULL(NEW.nome, 'NULL'), ']',
        ' | tipo: [', IFNULL(OLD.tipo, 'NULL'), '] -> [', IFNULL(NEW.tipo, 'NULL'), ']',
        ' | quantidade: [', IFNULL(OLD.quantidade, 'NULL'), '] -> [', IFNULL(NEW.quantidade, 'NULL'), ']',
        ' | descricao: [', IFNULL(OLD.descricao, 'NULL'), '] -> [', IFNULL(NEW.descricao, 'NULL'), ']',
        ' | status: [', IFNULL(OLD.status, 'NULL'), '] -> [', IFNULL(NEW.status, 'NULL'), ']'
    );
END$$

CREATE TRIGGER trg_produto_bd
BEFORE DELETE ON produto
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado em produto. Use UPDATE status = 0 para manter rastreabilidade.';
END$$

-- =====================================
-- TRIGGERS PRODUTO_PEDIDO
-- =====================================

CREATE TRIGGER trg_produto_pedido_bi
BEFORE INSERT ON produto_pedido
FOR EACH ROW
BEGIN
    DECLARE v_data_realizado TIMESTAMP;

    SELECT data_realizado
      INTO v_data_realizado
      FROM pedido
     WHERE id_pedido = NEW.fk_pedido;

    IF NEW.data_entrega IS NOT NULL AND NEW.data_entrega < DATE(v_data_realizado) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'data_entrega não pode ser anterior à data_realizado do pedido.';
    END IF;

    SET NEW.status = IFNULL(NEW.status, 1);
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'INSERT produto_pedido | fk_pedido=', NEW.fk_pedido,
        ' | fk_produto=', NEW.fk_produto,
        ' | quantidade=', IFNULL(NEW.quantidade, 'NULL'),
        ' | tipo_entrega=', IFNULL(NEW.tipo_entrega, 'NULL'),
        ' | endereco_entrega=', IFNULL(NEW.endereco_entrega, 'NULL'),
        ' | data_entrega=', IFNULL(NEW.data_entrega, 'NULL'),
        ' | valor=', IFNULL(NEW.valor, 'NULL'),
        ' | observacao=', IFNULL(NEW.observacao, 'NULL'),
        ' | status=', NEW.status
    );
END$$

CREATE TRIGGER trg_produto_pedido_bu
BEFORE UPDATE ON produto_pedido
FOR EACH ROW
BEGIN
    DECLARE v_data_realizado TIMESTAMP;

    SELECT data_realizado
      INTO v_data_realizado
      FROM pedido
     WHERE id_pedido = NEW.fk_pedido;

    IF NEW.data_entrega IS NOT NULL AND NEW.data_entrega < DATE(v_data_realizado) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'data_entrega não pode ser anterior à data_realizado do pedido.';
    END IF;

    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'UPDATE produto_pedido | ',
        'fk_pedido: [', OLD.fk_pedido, '] -> [', NEW.fk_pedido, ']',
        ' | fk_produto: [', OLD.fk_produto, '] -> [', NEW.fk_produto, ']',
        ' | quantidade: [', IFNULL(OLD.quantidade, 'NULL'), '] -> [', IFNULL(NEW.quantidade, 'NULL'), ']',
        ' | tipo_entrega: [', IFNULL(OLD.tipo_entrega, 'NULL'), '] -> [', IFNULL(NEW.tipo_entrega, 'NULL'), ']',
        ' | endereco_entrega: [', IFNULL(OLD.endereco_entrega, 'NULL'), '] -> [', IFNULL(NEW.endereco_entrega, 'NULL'), ']',
        ' | data_entrega: [', IFNULL(OLD.data_entrega, 'NULL'), '] -> [', IFNULL(NEW.data_entrega, 'NULL'), ']',
        ' | valor: [', IFNULL(OLD.valor, 'NULL'), '] -> [', IFNULL(NEW.valor, 'NULL'), ']',
        ' | observacao: [', IFNULL(OLD.observacao, 'NULL'), '] -> [', IFNULL(NEW.observacao, 'NULL'), ']',
        ' | status: [', IFNULL(OLD.status, 'NULL'), '] -> [', IFNULL(NEW.status, 'NULL'), ']'
    );
END$$

CREATE TRIGGER trg_produto_pedido_bd
BEFORE DELETE ON produto_pedido
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado em produto_pedido. Use UPDATE status = 0 para manter rastreabilidade.';
END$$

-- =====================================
-- TRIGGERS INSUMO
-- =====================================

CREATE TRIGGER trg_insumo_bi
BEFORE INSERT ON insumo
FOR EACH ROW
BEGIN
    SET NEW.status = IFNULL(NEW.status, 1);
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'INSERT insumo | fk_produto=', NEW.fk_produto,
        ' | nome=', IFNULL(NEW.nome, 'NULL'),
        ' | quantidade=', IFNULL(NEW.quantidade, 'NULL'),
        ' | unidade=', IFNULL(NEW.unidade, 'NULL'),
        ' | tipo=', IFNULL(NEW.tipo, 'NULL'),
        ' | marca=', IFNULL(NEW.marca, 'NULL'),
        ' | status=', NEW.status
    );
END$$

CREATE TRIGGER trg_insumo_bu
BEFORE UPDATE ON insumo
FOR EACH ROW
BEGIN
    SET NEW.data_hora_log = CURRENT_TIMESTAMP;
    SET NEW.descricao_log = CONCAT(
        'UPDATE insumo | ',
        'fk_produto: [', OLD.fk_produto, '] -> [', NEW.fk_produto, ']',
        ' | nome: [', IFNULL(OLD.nome, 'NULL'), '] -> [', IFNULL(NEW.nome, 'NULL'), ']',
        ' | quantidade: [', IFNULL(OLD.quantidade, 'NULL'), '] -> [', IFNULL(NEW.quantidade, 'NULL'), ']',
        ' | unidade: [', IFNULL(OLD.unidade, 'NULL'), '] -> [', IFNULL(NEW.unidade, 'NULL'), ']',
        ' | tipo: [', IFNULL(OLD.tipo, 'NULL'), '] -> [', IFNULL(NEW.tipo, 'NULL'), ']',
        ' | marca: [', IFNULL(OLD.marca, 'NULL'), '] -> [', IFNULL(NEW.marca, 'NULL'), ']',
        ' | status: [', IFNULL(OLD.status, 'NULL'), '] -> [', IFNULL(NEW.status, 'NULL'), ']'
    );
END$$

CREATE TRIGGER trg_insumo_bd
BEFORE DELETE ON insumo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'DELETE físico bloqueado em insumo. Use UPDATE status = 0 para manter rastreabilidade.';
END$$

DELIMITER ;

-- =====================================
-- INSERTS
-- =====================================

INSERT INTO cliente (nome, telefone, endereco) VALUES
('Ana Souza', '11987654321', 'Rua das Flores, 120'),
('Bruno Lima', '11976543210', 'Av. do Café, 450'),
('Carla Mendes', '11965432109', 'Rua dos Doces, 89');

INSERT INTO produto (nome, tipo, quantidade, descricao) VALUES
('Bolo de Chocolate', 'Bolo', 10, 'Bolo de chocolate com cobertura de brigadeiro'),
('Brigadeiro Gourmet', 'Doce', 200, 'Brigadeiro tradicional enrolado com granulado belga'),
('Torta de Morango', 'Torta', 8, 'Torta com creme e morangos frescos');

INSERT INTO pedido (fk_cliente, data_realizado, status, anotacao) VALUES
(1, '2026-03-20 10:15:00', 1, 'Pedido para festa de aniversário'),
(2, '2026-03-21 14:30:00', 1, 'Cliente pediu confirmação antes da entrega'),
(3, '2026-03-22 09:00:00', 1, 'Entregar na portaria do condomínio');

INSERT INTO produto_pedido (fk_pedido, fk_produto, quantidade, tipo_entrega, endereco_entrega, data_entrega, valor, observacao) VALUES
(1, 1, 1, 1, 'Rua das Flores, 120', '2026-03-21', 85.00, 'Escrever "Parabéns Ana" no bolo'),
(1, 2, 20, 1, 'Rua das Flores, 120', '2026-03-21', 3.50, 'Granulado meio amargo'),
(2, 3, 1, 1, 'Av. do Café, 450', '2026-03-22', 70.00, 'Sem kiwi, somente morango'),
(3, 2, 50, 0, 'Rua dos Doces, 89', '2026-03-22', 3.00, 'Brigadeiros para retirada no balcão');

INSERT INTO insumo (fk_produto, nome, quantidade, unidade, tipo, marca) VALUES
(1, 'Farinha de trigo', 2.00, 'kg', 'Seco', 'Dona Benta'),
(1, 'Chocolate em pó', 0.50, 'kg', 'Seco', 'Nestlé'),
(1, 'Leite condensado', 2.00, 'unidade', 'Lácteo', 'Moça'),
(2, 'Leite condensado', 1.00, 'unidade', 'Lácteo', 'Moça'),
(2, 'Granulado belga', 0.30, 'kg', 'Confeitaria', 'Callebaut'),
(3, 'Morango', 1.50, 'kg', 'Fruta', 'Hortifruti Premium'),
(3, 'Creme de leite', 0.50, 'litro', 'Lácteo', 'Italac');

-- =====================================
-- SELECTS PRINCIPAIS
-- =====================================

-- Pedidos por cliente
SELECT 
    c.id_cliente,
    c.nome,
    p.id_pedido,
    p.data_realizado,
    p.status,
    p.anotacao,
    p.descricao_log,
    p.data_hora_log
FROM cliente c
JOIN pedido p 
    ON c.id_cliente = p.fk_cliente;

-- Produtos por pedido
SELECT 
    p.id_pedido,
    pr.id_produto,
    pr.nome AS produto,
    pp.quantidade,
    pp.tipo_entrega,
    pp.endereco_entrega,
    pp.data_entrega,
    pp.valor,
    pp.observacao,
    pp.status,
    pp.descricao_log,
    pp.data_hora_log
FROM pedido p
JOIN produto_pedido pp 
    ON p.id_pedido = pp.fk_pedido
JOIN produto pr 
    ON pr.id_produto = pp.fk_produto;

-- Quantidade de produtos por pedido
SELECT 
    p.id_pedido,
    SUM(pp.quantidade) AS total_itens
FROM pedido p
JOIN produto_pedido pp 
    ON p.id_pedido = pp.fk_pedido
WHERE pp.status = 1
GROUP BY p.id_pedido;

-- Insumo por produto
SELECT 
    pr.id_produto,
    pr.nome AS produto,
    i.id_insumo,
    i.nome AS insumo,
    i.quantidade,
    i.unidade,
    i.marca,
    i.status,
    i.descricao_log,
    i.data_hora_log
FROM produto pr
JOIN insumo i 
    ON pr.id_produto = i.fk_produto;

-- Tudo
SELECT 
    c.nome AS cliente,
    p.id_pedido,
    p.data_realizado,
    pr.nome AS produto,
    pp.quantidade AS qtd_produto,
    pp.valor,
    pp.endereco_entrega,
    pp.data_entrega,
    i.nome AS insumo,
    i.quantidade AS qtd_insumo,
    i.unidade
FROM cliente c
JOIN pedido p 
    ON c.id_cliente = p.fk_cliente
JOIN produto_pedido pp 
    ON p.id_pedido = pp.fk_pedido
JOIN produto pr 
    ON pr.id_produto = pp.fk_produto
LEFT JOIN insumo i 
    ON pr.id_produto = i.fk_produto
WHERE c.status = 1
  AND p.status = 1
  AND pp.status = 1;

-- Valor por cliente
SELECT 
    c.nome,
    SUM(pp.quantidade * pp.valor) AS total_gasto
FROM cliente c
JOIN pedido p 
    ON c.id_cliente = p.fk_cliente
JOIN produto_pedido pp
    ON p.id_pedido = pp.fk_pedido
WHERE c.status = 1
  AND p.status = 1
  AND pp.status = 1
GROUP BY c.nome;

-- Cliente + produto + endereço + insumo
SELECT 
    c.nome AS cliente,
    p.id_pedido,
    pr.nome AS produto,
    pp.endereco_entrega,
    pp.data_entrega,
    i.nome AS insumo
FROM cliente c
JOIN pedido p 
    ON c.id_cliente = p.fk_cliente
JOIN produto_pedido pp 
    ON p.id_pedido = pp.fk_pedido
JOIN produto pr 
    ON pr.id_produto = pp.fk_produto
LEFT JOIN insumo i 
    ON pr.id_produto = i.fk_produto
WHERE c.status = 1
  AND p.status = 1
  AND pp.status = 1;

-- =====================================
-- SELECTS DE RASTREABILIDADE
-- =====================================

-- Auditoria de clientes
SELECT
    id_cliente,
    nome,
    status,
    descricao_log,
    data_hora_log
FROM cliente
ORDER BY data_hora_log DESC;

-- Auditoria de pedidos com cliente
SELECT
    p.id_pedido,
    c.nome AS cliente,
    p.status,
    p.descricao_log,
    p.data_hora_log
FROM pedido p
JOIN cliente c
    ON p.fk_cliente = c.id_cliente
ORDER BY p.data_hora_log DESC;

-- Auditoria de produto_pedido com cliente e produto
SELECT
    pp.id_produto_pedido,
    c.nome AS cliente,
    pr.nome AS produto,
    pp.status,
    pp.descricao_log,
    pp.data_hora_log
FROM produto_pedido pp
JOIN pedido p
    ON pp.fk_pedido = p.id_pedido
JOIN cliente c
    ON p.fk_cliente = c.id_cliente
JOIN produto pr
    ON pp.fk_produto = pr.id_produto
ORDER BY pp.data_hora_log DESC;

-- Auditoria de produtos
SELECT
    id_produto,
    nome,
    status,
    descricao_log,
    data_hora_log
FROM produto
ORDER BY data_hora_log DESC;

-- Auditoria de insumos com produto
SELECT
    i.id_insumo,
    i.nome AS insumo,
    p.nome AS produto,
    i.status,
    i.descricao_log,
    i.data_hora_log
FROM insumo i
JOIN produto p
    ON i.fk_produto = p.id_produto
ORDER BY i.data_hora_log DESC;

-- Visão unificada de auditoria
SELECT 
    'cliente' AS entidade,
    id_cliente AS id_referencia,
    descricao_log,
    data_hora_log,
    status
FROM cliente

UNION ALL

SELECT 
    'pedido' AS entidade,
    id_pedido AS id_referencia,
    descricao_log,
    data_hora_log,
    status
FROM pedido

UNION ALL

SELECT 
    'produto_pedido' AS entidade,
    id_produto_pedido AS id_referencia,
    descricao_log,
    data_hora_log,
    status
FROM produto_pedido

UNION ALL

SELECT 
    'produto' AS entidade,
    id_produto AS id_referencia,
    descricao_log,
    data_hora_log,
    status
FROM produto

UNION ALL

SELECT 
    'insumo' AS entidade,
    id_insumo AS id_referencia,
    descricao_log,
    data_hora_log,
    status
FROM insumo

ORDER BY data_hora_log DESC;