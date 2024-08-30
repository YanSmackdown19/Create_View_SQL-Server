CREATE PROCEDURE SP_Corrige_Parcelas
    @idPagamentoVenda INT,
    @qtParcelas INT,
    @taxaAdministracao DECIMAL(18, 2)
AS
BEGIN
    -- Verifica se todas as parcelas estão com status 'aberta'
    IF EXISTS (
        SELECT 1
        FROM card.tbParcela
        WHERE idPagamentoVenda = @idPagamentoVenda
        AND idStatusParcela != 1 
    )
    BEGIN
        RAISERROR('Não é possível corrigir o pagamento. Existem parcelas com status diferente de "aberta".', 16, 1);
        RETURN;
    END

    -- Atualiza a quantidade de parcelas na tabela tbPagamentoVenda
    UPDATE card.tbPagamentoVenda
    SET qtParcelas = @qtParcelas
    WHERE idPagamentoVenda = @idPagamentoVenda;

    -- Calcula o valor de cada parcela
    DECLARE @vlPagamento DECIMAL(18, 2);
    SELECT @vlPagamento = vlPagamento
    FROM card.tbPagamentoVenda
    WHERE idPagamentoVenda = @idPagamentoVenda;

    DECLARE @vlParcela DECIMAL(18, 2) = @vlPagamento / @qtParcelas;

    -- Insere as novas parcelas na tabela tbParcela
    DECLARE @i INT = 1;
    WHILE @i <= @qtParcelas
    BEGIN
        -- Verifica se a parcela já existe
        IF NOT EXISTS (
            SELECT 1 
            FROM card.tbParcela
            WHERE idPagamentoVenda = @idPagamentoVenda
            AND nrParcela = @i
        )
        BEGIN
            INSERT INTO card.tbParcela (
                idPagamentoVenda,
                nrParcela,
                idEmpresa,
                dtEmissao,
                dtVencimento,
                vlParcela,
                vlTaxaAdministracao,
                dtPagamento,
                vlPago,
                idStatusParcela,
                idMovimentoBanco,
                idContaCorrente 
            )
            SELECT
                @idPagamentoVenda,
                @i,
                idEmpresa,
                dtEmissao,
                DATEADD(DAY, (@i - 1) * 30, dtEmissao),  -- Calcula a data de vencimento com base na emissão
                @vlParcela,
                @vlParcela * @taxaAdministracao / 100,  -- Calcula a taxa de administração
                NULL,
                NULL,
                1,  
                NULL,
                1 
            FROM card.tbPagamentoVenda
            WHERE idPagamentoVenda = @idPagamentoVenda;
        END

        SET @i = @i + 1;
    END

    -- Mensagem de sucesso
    PRINT 'As parcelas foram corrigidas com sucesso.';
END;
