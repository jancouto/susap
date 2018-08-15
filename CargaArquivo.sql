--Querys para carga de Arquivos
--------------------------------------------------------------------------------------------------

--Passo 1...Verificar o próximo lote e ajustar
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--    Número do próximo lote para carga
--    Parametros ... COD_INTER
SELECT NUM_LOTE_SEGUINTE
  FROM MMIDB01.INTERFACE
 WHERE COD_INTER = 48003

--    Ajusta o número do lote na INTERFACE
--update mmidb01.interface set NUM_LOTE_SEGUINTE = 1 WHERE COD_INTER = 58008; 
SELECT * FROM MMIDB01.MOVIMENTO MOV WHERE COD_INTER  = 48003 for update
SELECT max(num_lote)+1 nextNumLote FROM MMIDB01.MOVIMENTO MOV WHERE COD_INTER  = 48003;
commit;

--Passo 2...Ajustar  a sas_exec_arg
-------------------------------------------------------------------------------------------------------------------------------
--    Consulta básica na SAS_EXEC_ARG
select * from mmidb01.sas_exec_arg where job_id = 278 order by arg_id desc for update;
commit;
--    Insert para rodar um RDI em SAS_EXEC_ARG
update mmidb01.sas_exec_arg set flg_used = 'C' where job_id = 278 and flg_used = 'N';
insert into mmidb01.sas_exec_arg VALUES (MMIDB01.SQ_ARG_ID.NEXTVAL,'IT',1000,'SUV.EFAT.TR.DU.05072018V00','N',278,NULL);

select * from mmidb01.sas_exec_arg where job_id = 278 order by arg_id desc;

--    Insert para rodar um RDI em SAS_EXEC_ARG
insert into mmidb01.prev_receb(cod_prev_recebim,dat_prdo_prev_mov,dat_lim_receb_mov,cod_inter,cod_sts_prev_rec,num_lote,num_versao,lastmodby,lastmodts,cod_mov) values (mmidb01.sq_it_cod_prev_recebim.nextval,to_date('05/07/2018','dd/mm/yyyy'),TRUNC(SYSDATE),48003,'AR',2,0,'GERA_DATA_PROCESSAMENTO',sysdate,null);
commit; 


--Passo 3...Verificar a data de previsão do novo arquivo
-------------------------------------------------------------------------------------------------------------------------------
--    Consulta básaica na PREV_RECEV o Status deve ser AR
select * from mmidb01.prev_receb where cod_inter = 48003 for update;
--    Verifica a próxima data de processamento
SELECT * FROM (
    SELECT /*+ index (prev_receb PREVRECB_SI1) */
     COD_PREV_RECEBIM,
     SUBSTR(TO_CHAR(DAT_PRDO_PREV_MOV, 'YYYYMMDD'), 1, 8) AS DAT_PRDO_PREV_MOV,
     MIN(NUM_LOTE) AS NUM_LOTE
      FROM mmidb01.PREV_RECEB
     WHERE COD_INTER = 48003
       AND COD_STS_PREV_REC IN ('AR','AT')
       AND NUM_VERSAO = 0
     GROUP BY COD_PREV_RECEBIM, DAT_PRDO_PREV_MOV
     ORDER BY DAT_PRDO_PREV_MOV, COD_PREV_RECEBIM)
commit;     


--Passo 3...Verificar a data de previsão do novo arquivo
-------------------------------------------------------------------------------------------------------------------------------

verificando a tabela de destino do arquivo

select tabela_rt,tabela_mi from mmidb01.vi_interface where cod_inter = 48003

--Ajustar a tabela da Matriz correta conforme sua necessidade

SELECT PSAU.*
  FROM MMIDB01.MOVIMENTO MOV,
       MMIDB01.PAG_SAUDE PSAU
 WHERE PSAU.COD_MOV = MOV.COD_MOV
   AND MOV.COD_INTER  = 48003 
