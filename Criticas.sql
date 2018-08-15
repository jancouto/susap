--Queries para tratamento e pesquisas de criticas
--------------------------------------------------------------------------------------------------

--Query que retorna todas as criticas de um RDI para um nível desejado
 SELECT *
        FROM (SELECT CRI.SQL_TEXT,
                     CRI.T235_ID,
                     CRI.ROWID AS CRIROWID,
                     CRO.FLG_ACTIVE,
                     CRO.D510_ID
                FROM SAS_CRITICA_RDI_ORIGEM CRO,
                     SAS_CRITICA            CRI
               WHERE CRO.COD_ORIG IN ('AAA', 'JUR')
                 AND CRO.D510_ID IN ('AAA','SINPGRC')
                 AND CRO.COD_NIV_VLD = 06
                 AND CRO.COD_SUB_NIV_VLD = 0
                 AND CRI.T235_ID = CRO.T235_ID
                 AND CRO.COD_ORIG || CRO.D510_ID =
                     (SELECT MAX(S1.COD_ORIG || S1.D510_ID)
                        FROM SAS_CRITICA_RDI_ORIGEM S1
                       WHERE S1.COD_ORIG IN ('AAA', 'JUR')
                         AND S1.D510_ID IN ('AAA', 'SINPGRC')
                         AND S1.T235_ID = CRI.T235_ID
                         AND S1.COD_NIV_VLD = 06))
       WHERE FLG_ACTIVE = 'Y'
       ORDER BY T235_ID;
       
--Query que critica a data do arquivo em relação ao período contábil 
--Para acertar esse problema faça o update abaixo da tabela SAS_PER_CONT_NEW
SELECT 'DATA DO ARQUIVO MAIOR QUE A DATA DO INICIO DO PERIODO CONTABIL' DSC_ERRO,
       TO_CHAR(MV.DAT_PRDO_MOV, 'YYYYMM') DATA_ARQUIVO,
       MV.COD_ORIG,
       MV.COD_TIP_MOV,
       (SELECT DISTINCT TO_CHAR(BEGIN_DT, 'YYYYMM')
          FROM SAS_PER_CONT_NEW SP
         WHERE SP.COD_ORIG = 'JUR'
           AND SP.COD_TIP_MOV = 'PAGS') PER_CONTABIL                  
   FROM MOVIMENTO MV, 
       INTERFACE INT
  WHERE MV.COD_MOV = '220170100006085'
    AND MV.COD_ORIG <> 'RCI'
    AND MV.COD_INTER = INT.COD_INTER
    AND INT.FLG_STS_PROCESSAMENTO = 'A'
    AND TO_CHAR(MV.DAT_PRDO_MOV, 'YYYYMM') >
       (SELECT DISTINCT TO_CHAR(BEGIN_DT, 'YYYYMM')
           FROM SAS_PER_CONT_NEW SP
          WHERE SP.COD_ORIG = MV.COD_ORIG
            AND SP.COD_TIP_MOV = MV.COD_TIP_MOV)     
