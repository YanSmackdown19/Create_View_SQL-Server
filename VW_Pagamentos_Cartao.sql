CREATE VIEW [dbo].[VW_Pagamentos_Cartao] AS
 SELECT DISTINCT
    card.tbEmpresa.nrCNPJ CNPJ, 
	CONVERT(VARCHAR(41),card.tbPagamentoVenda.nrNSU) NSU,
   CONVERT(VARCHAR(10), card.tbPagamentoVenda.dtEmissao) 'Data do Pagamento', 
	CONVERT(VARCHAR(10),card.tbBandeira.idBandeira) 'Codigo da Bandeira',
	CONVERT(VARCHAR(50),card.tbBandeira.dsBandeira) 'Descrição da Bandeira',
	CONVERT(DECIMAL, card.tbPagamentoVenda.vlPagamento) 'Valor do Pagamento',
    CONVERT(INTEGER, card.tbPagamentoVenda.qtParcelas) 'Quantidade de Parcelas',
   	CONVERT(VARCHAR(40),card.tbPagamentoVenda.idPagamentoVenda) 'Codigo de Pagamento ' 
	

FROM 
    card.tbPagamentoVenda

INNER JOIN card.tbEmpresa
	ON card.tbEmpresa.idEmpresa = card.tbEmpresa.idEmpresa

INNER JOIN card.tbFormaPagamento
    ON card.tbFormaPagamento.idFormaPagamento = card.tbFormaPagamento.idFormaPagamento 
	
	
INNER JOIN card.tbBandeira
    ON card.tbPagamentoVenda.idBandeira = card.tbBandeira.idBandeira
	
INNER JOIN card.tbParcela
	on card.tbPagamentoVenda.idPagamentoVenda = card.tbParcela.idPagamentoVenda
	
INNER JOIN card.tbMovimentoBanco
    ON card.tbPagamentoVenda.idEmpresa = card.tbMovimentoBanco.idEmpresa
	
	

	WHERE card.tbFormaPagamento.dsFormaPagamento in ('Cartão de Crédito', 'Cartão de Débito');
	