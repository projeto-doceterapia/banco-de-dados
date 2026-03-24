DROP DATABASE IF EXISTS doceTerapia;
CREATE DATABASE IF NOT EXISTS doceTerapia;
USE doceTerapia;


-- CLIENTE
CREATE TABLE cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    telefone CHAR(12) NOT NULL,
    endereco VARCHAR(225) NOT NULL
);


-- PEDIDO
CREATE TABLE pedido (
    idPedido INT PRIMARY KEY AUTO_INCREMENT,
    fkCliente INT NOT NULL,
    dataRealizado DATE NOT NULL,
    dataEntrega DATE NOT NULL,
    valor DECIMAL(10,2),
    status TINYINT,
    anotacao VARCHAR(225),

    CONSTRAINT fkPedidoCliente
        FOREIGN KEY (fkCliente) REFERENCES cliente(idCliente)
);


-- PRODUTO
CREATE TABLE produto (
    idProduto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    tipo VARCHAR(45),
    quantidade VARCHAR(45),
    descricao VARCHAR(225)
);



-- PEDIDO x PRODUTO
CREATE TABLE produtoPedido (
    fkPedido INT,
    fkProduto INT,
    quantidade INT,
    tipoEntrega TINYINT,
    enderecoEntrega VARCHAR(245),
    observacao VARCHAR(245),

    PRIMARY KEY (fkPedido, fkProduto),

    CONSTRAINT fkProdutoPedidoPedido
        FOREIGN KEY (fkPedido) REFERENCES pedido(idPedido),

    CONSTRAINT fkProdutoPedidoProduto
        FOREIGN KEY (fkProduto) REFERENCES produto(idProduto)
);


-- INGREDIENTE

CREATE TABLE ingrediente (
    idIngrediente INT PRIMARY KEY AUTO_INCREMENT,
    fkProduto INT,
    nome VARCHAR(45),
    quantidade VARCHAR(45),
    tipo VARCHAR(45),
    marca VARCHAR(45),

    CONSTRAINT fkIngredienteProduto
        FOREIGN KEY (fkProduto) REFERENCES produto(idProduto)
);


-- LOG PEDIDO

CREATE TABLE logPedido (
    idLogPedido INT PRIMARY KEY AUTO_INCREMENT,
    fkPedido INT,
    descricao VARCHAR(245),
    dataHora DATE,

    CONSTRAINT fkLogPedidoPedido
        FOREIGN KEY (fkPedido) REFERENCES pedido(idPedido)
);


-- LOG PRODUTO

CREATE TABLE logProduto (
    idLogProduto INT PRIMARY KEY AUTO_INCREMENT,
    fkProduto INT,
    descricao VARCHAR(245),
    dataHora DATE,

    CONSTRAINT fkLogProdutoProduto
        FOREIGN KEY (fkProduto) REFERENCES produto(idProduto)
);


-- LOG INGREDIENTE

CREATE TABLE logIngrediente (
    idLogIngrediente INT PRIMARY KEY AUTO_INCREMENT,
    fkIngrediente INT,
    descricao VARCHAR(245),
    dataHora DATE,

    CONSTRAINT fkLogIngredienteIngrediente
        FOREIGN KEY (fkIngrediente) REFERENCES ingrediente(idIngrediente)
);

INSERT INTO cliente (nome, telefone, endereco) VALUES
('João Silva', '11999999999', 'Rua A, 123'),
('Maria Souza', '11988888888', 'Rua B, 456'),
('Carlos Lima', '11977777777', 'Rua C, 789');


INSERT INTO produto (nome, tipo, quantidade, descricao) VALUES
('Pizza Calabresa', 'Alimento', '1 unidade', 'Pizza tradicional'),
('Hamburguer', 'Alimento', '1 unidade', 'Hamburguer artesanal'),
('Suco Natural', 'Bebida', '500ml', 'Suco de laranja');

INSERT INTO pedido (fkCliente, dataRealizado, dataEntrega, valor, status, anotacao) VALUES
(1, '2026-03-20', '2026-03-20', 75.50, 1, 'Sem cebola'),
(2, '2026-03-21', '2026-03-21', 45.00, 1, 'Entrega rápida'),
(1, '2026-03-22', '2026-03-22', 30.00, 0, 'Pedido pendente');

INSERT INTO produtoPedido (fkPedido, fkProduto, quantidade, tipoEntrega, observacao, enderecoEntrega) VALUES
(1, 1, 2, 1, 'Entrega normal', 'Rua A, 123'),
(1, 3, 1, 1, 'Sem gelo', 'Rua A, 123'),
(2, 2, 1, 2, 'Entrega expressa', 'Rua B, 456'),
(3, 3, 2, 1, 'Bem gelado', 'Rua A, 123');

INSERT INTO ingrediente (fkProduto, nome, quantidade, tipo, marca) VALUES
(1, 'Calabresa', '100g', 'Carne', 'Sadia'),
(1, 'Queijo', '150g', 'Laticínio', 'Itambé'),
(2, 'Carne Bovina', '120g', 'Carne', 'Friboi'),
(2, 'Pão', '1 unidade', 'Padaria', 'Wickbold'),
(3, 'Laranja', '3 unidades', 'Fruta', 'Natural');

INSERT INTO logPedido (fkPedido, descricao, dataHora) VALUES
(1, 'Pedido criado', '2026-03-20'),
(1, 'Pedido saiu para entrega', '2026-03-20'),
(2, 'Pedido criado', '2026-03-21');

INSERT INTO logProduto (fkProduto, descricao, dataHora) VALUES
(1, 'Produto cadastrado', '2026-03-19'),
(2, 'Produto atualizado', '2026-03-20'),
(3, 'Produto em promoção', '2026-03-21');

INSERT INTO logIngrediente (fkIngrediente, descricao, dataHora) VALUES
(1, 'Ingrediente adicionado', '2026-03-19'),
(2, 'Ingrediente atualizado', '2026-03-20'),
(3, 'Ingrediente verificado', '2026-03-21');

-- Pedidos por cliente
SELECT 
    c.idCliente,
    c.nome,
    p.idPedido,
    p.dataRealizado,
    p.valor,
    p.status
FROM cliente c
JOIN pedido p 
    ON c.idCliente = p.fkCliente;


-- Produtos por pedido
SELECT 
    p.idPedido,
    pr.idProduto,
    pr.nome AS produto,
    pp.quantidade,
    pp.tipoEntrega,
    pp.enderecoEntrega
FROM pedido p
JOIN produtoPedido pp 
    ON p.idPedido = pp.fkPedido
JOIN produto pr 
    ON pr.idProduto = pp.fkProduto;
    
    
-- Quantidade de produtos por pedido
SELECT 
    p.idPedido,
    SUM(pp.quantidade) AS total_itens
FROM pedido p
JOIN produtoPedido pp 
    ON p.idPedido = pp.fkPedido
GROUP BY p.idPedido;    

-- Ingrediente por produto
SELECT 
    pr.idProduto,
    pr.nome AS produto,
    i.idIngrediente,
    i.nome AS ingrediente,
    i.quantidade,
    i.marca
FROM produto pr
JOIN ingrediente i 
    ON pr.idProduto = i.fkProduto;

-- Tudo
SELECT 
    c.nome AS cliente,
    p.idPedido,
    pr.nome AS produto,
    pp.quantidade AS qtd_produto,
    pp.enderecoEntrega,
    i.nome AS ingrediente,
    i.quantidade AS qtd_ingrediente
FROM cliente c
JOIN pedido p 
    ON c.idCliente = p.fkCliente
JOIN produtoPedido pp 
    ON p.idPedido = pp.fkPedido
JOIN produto pr 
    ON pr.idProduto = pp.fkProduto
LEFT JOIN ingrediente i 
    ON pr.idProduto = i.fkProduto;
    
-- valor por cliente    
SELECT 
    c.nome,
    SUM(p.valor) AS total_gasto
FROM cliente c
JOIN pedido p 
    ON c.idCliente = p.fkCliente
GROUP BY c.nome;

SELECT 
    c.nome AS cliente,
    p.idPedido,
    pr.nome AS produto,
    pp.enderecoEntrega,
    i.nome AS ingrediente
FROM cliente c
JOIN pedido p ON c.idCliente = p.fkCliente
JOIN produtoPedido pp ON p.idPedido = pp.fkPedido
JOIN produto pr ON pr.idProduto = pp.fkProduto
LEFT JOIN ingrediente i ON pr.idProduto = i.fkProduto;