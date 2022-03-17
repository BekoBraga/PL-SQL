declare

cursor cDeleteImpostoDir
is

select  COD_HOLDING, 
        COD_MATRIZ, 
        COD_FILIAL, 
        DATA, 
        DATA_COMP, 
        DOCNUM_CONT, 
        TP_IMPOSTO, 
        COD_IMPOSTO, 
        COD_RETENCAO, 
        NUM_NF, 
        CATEGORIA, 
        ALIQUOTA, 
        COD_LOC_PREST_SV, 
        COD_COND_PAGTO, 
        COD_SERVICO,
        base_calculo,
        cod_clifor,
        Lpad (num_nf,9,'0') as num_nf_nota              
    FROM LF.LF_IMPOSTO_DIRETO_SAP
        WHERE COD_HOLDING = 'PETRO'
         AND COD_MATRIZ = '2000'
         AND DOCNUM_CONT LIKE '28%'
         AND COD_IMPOSTO = '51'
         AND VALOR_IMPOSTO = '0,00'
         AND COD_LOC_PREST_SV = ' '
         AND DSC_LOC_PREST_SV = ' '
         AND UF_LOC_PREST_SV = ' '
         AND COD_STATUS = '01';
                                  
 v_delete_impostodir cDeleteImpostoDir%rowtype;
 v_quantidade number := 0;

begin
  
dbms_output.enable(buffer_size => null);
open cDeleteImpostoDir;
fetch cDeleteImpostoDir into v_delete_impostodir;

while cDeleteImpostoDir%found loop

    select count(*) into v_quantidade
        from lf.lf_nf_entrada
         where cod_holding     = v_delete_impostodir.cod_holding
           and cod_matriz      = v_delete_impostodir.cod_matriz
           and cod_filial      = v_delete_impostodir.cod_filial
           and num_nf          = v_delete_impostodir.num_nf_nota
           and cod_modelo      = '57'
           and cod_status      = '01'
           and icms_base_total = v_delete_impostodir.base_calculo;
       
       if v_quantidade = 0 then -- nota existe apenas na nf_entrada
              dbms_output.put_line('passei aqui, encontrei a nota' || ' - num_nf: ' || v_delete_impostodir.num_nf || ' - filial: ' || v_delete_impostodir.cod_filial  || ' - Qtde de notas: ' || v_quantidade);
          else -- nota existe em ambas
                  delete LF.LF_IMPOSTO_DIRETO_SAP
                      where COD_HOLDING       = v_delete_impostodir.COD_HOLDING
                        and COD_MATRIZ        = v_delete_impostodir.cod_matriz
                        and COD_FILIAL        = v_delete_impostodir.cod_filial
                        and DATA              = v_delete_impostodir.data
                        and DATA_COMP         = v_delete_impostodir.data_comp
                        and DOCNUM_CONT       = v_delete_impostodir.docnum_cont
                        and TP_IMPOSTO        = v_delete_impostodir.tp_imposto
                        and COD_IMPOSTO       = v_delete_impostodir.cod_imposto 
                        and COD_RETENCAO      = v_delete_impostodir.cod_retencao
                        and NUM_NF            = v_delete_impostodir.num_nf
                        and CATEGORIA         = v_delete_impostodir.categoria
                        and ALIQUOTA          = v_delete_impostodir.aliquota
                        and COD_LOC_PREST_SV  = v_delete_impostodir.cod_loc_prest_sv
                        and COD_COND_PAGTO    = v_delete_impostodir.cod_cond_pagto
                        and nvl(COD_SERVICO, '*') = nvl(v_delete_impostodir.cod_servico, '*')
                        and base_calculo      = v_delete_impostodir.base_calculo
                        and cod_clifor        = v_delete_impostodir.cod_clifor      
                        and VALOR_IMPOSTO     = '0,00'
                        and DSC_LOC_PREST_SV  = ' '
                        and UF_LOC_PREST_SV   = ' '
                        and COD_STATUS        = '01';
                        
                       commit;

          end if;
        fetch cDeleteImpostoDir into v_delete_impostodir;
      end loop;
    close cDeleteImpostoDir;
    commit;
end;
