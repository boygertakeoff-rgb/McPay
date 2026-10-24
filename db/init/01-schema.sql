-- McPay Moçambique - Diagrama Foto 4 - Aprovado Banco de Moçambique
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  telefone VARCHAR(20) UNIQUE NOT NULL,
  nuit VARCHAR(15) UNIQUE,
  username VARCHAR(50) UNIQUE NOT NULL,
  mcpay_id VARCHAR(20) UNIQUE NOT NULL,
  pin_hash VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'ativo',
  data_criacao TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE agents (
  agent_id SERIAL PRIMARY KEY,
  nome_agente VARCHAR(100) NOT NULL,
  codigo_agente VARCHAR(20) UNIQUE NOT NULL,
  localizacao VARCHAR(100),
  provincia VARCHAR(50) DEFAULT 'Nampula',
  saldo_float DECIMAL(12,2) DEFAULT 50000.00,
  status VARCHAR(20) DEFAULT 'ativo',
  data_criacao TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cartoes_virtuais (
  cartao_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id),
  numero_cartao VARCHAR(19),
  validade DATE,
  limite_mzn DECIMAL(12,2) DEFAULT 5000.00,
  status VARCHAR(20) DEFAULT 'ativo',
  data_criacao TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
  transaction_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id),
  agent_id INTEGER REFERENCES agents(agent_id),
  cartao_id INTEGER REFERENCES cartoes_virtuais(cartao_id),
  tipo VARCHAR(20) CHECK (tipo IN ('pagamento','carga','levantamento','transferencia','deposito')),
  valor_mzn DECIMAL(12,2) NOT NULL,
  taxa_mzn DECIMAL(12,2) DEFAULT 0.00,
  moeda VARCHAR(3) DEFAULT 'MZN',
  status VARCHAR(20) DEFAULT 'concluida',
  referencia VARCHAR(50) UNIQUE NOT NULL,
  de_telefone VARCHAR(20),
  para_telefone VARCHAR(20),
  data_transacao TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ledger (
  ledger_id SERIAL PRIMARY KEY,
  transaction_id INTEGER REFERENCES transactions(transaction_id),
  conta VARCHAR(20) CHECK (conta IN ('CAIXA','RECEITA','DESPESA','COMISSAO','SALDO_USER')),
  debito_mzn DECIMAL(12,2) DEFAULT 0.00,
  credito_mzn DECIMAL(12,2) DEFAULT 0.00,
  saldo_corrente_mzn DECIMAL(12,2),
  descricao VARCHAR(200),
  data_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO agents (nome_agente, codigo_agente, localizacao) VALUES 
('Shop MC - Nampula', 'SHOPMC', 'Nampula Cidade'),
('João Muianga - Agente', 'MCP023', 'Mercado Central Nampula');

INSERT INTO users (nome, telefone, username, mcpay_id, pin_hash, nuit) VALUES
('João Silva', '258840000001', 'joao.mz', '8F2K-9MQL-JM77', '1234', '123456789'),
('Maria Chissano', '258820000002', 'maria.mz', '9MQL-JM77-8F2K', '1234', '987654321');
