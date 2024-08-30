CREATE PROCEDURE SP_Baixa_Titulos  
    @dtPagamento DATE,  
    @idEmpresa INT,  
    @idContaCorrente INT,
    @nrDocumento VARCHAR(50),  
    @dsMovimento VARCHAR(100)  
AS  
BEGIN  
    -- Variável para armazenar o valor total pago  
    DECLARE @vlTotalPago DECIMAL(18, 2) = 0;  
    DECLARE @idMovimentoBanco INT;  
  
    -- Selecionar as parcelas que vencem na data de pagamento e pertencem à empresa e conta corrente  
    SELECT @vlTotalPago = SUM(vlParcela - vlTaxaAdministracao)  
    FROM card.tbParcela  
    WHERE dtVencimento = @dtPagamento  
      AND idEmpresa = @idEmpresa  
      AND idContaCorrente = @idContaCorrente  
      AND idStatusParcela = 1; 
  
    -- Verificar se há parcelas a serem liquidadas  
    IF @vlTotalPago > 0  
    BEGIN  
        -- Inserir uma movimentação na tabela tbMovimentoBanco  
        INSERT INTO card.tbMovimentoBanco (  
            idEmpresa,  
            idContaCorrente,  
            nrDocumento,  
            dsMovimento,  
            vlMovimento,  
            tpOperacao,  
            dtMovimento  
        )  
        VALUES (  
            @idEmpresa,  
            @idContaCorrente,  
            @nrDocumento,  -- Usa o parâmetro passado
            @dsMovimento,  -- Usa o parâmetro passado
            @vlTotalPago,  -- Valor do movimento  
            'E',  -- Tipo de operação (E - Entrada)  
            @dtPagamento  -- Data do movimento  
        );  
  
        -- Obter o ID do movimento inserido  
        SET @idMovimentoBanco = SCOPE_IDENTITY();  
  
        -- Atualizar o status das parcelas para 'liquidada' e definir outros campos  
        UPDATE card.tbParcela  
        SET dtPagamento = dtVencimento,  
            vlPago = vlParcela - vlTaxaAdministracao,  
            idStatusParcela = 2,    
            idMovimentoBanco = @idMovimentoBanco  
        WHERE dtVencimento = @dtPagamento  
          AND idEmpresa = @idEmpresa  
          AND idContaCorrente = @idContaCorrente  
          AND idStatusParcela = 1;  
         
        PRINT 'Baixa realizada com sucesso. Valor total pago: ' + CONVERT(VARCHAR, @vlTotalPago);  
    END  
    ELSE  
    BEGIN  
        
        PRINT 'Nenhuma parcela encontrada para a data de pagamento, empresa e conta corrente informados.';  
    END  
END;  
