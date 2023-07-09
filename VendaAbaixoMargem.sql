/*
Autor: Álvaro Felipe
Descrição: Venda abaixo da margem
Setor: Financeiro
SQL para somar: round(sum(PCPEDI.pvenda - PCPEDI.VLCUSTOFIN * PCPEDI.QT),2)*-1 VALOR   
informativo do relatório:

var Msg: String;
begin
  Msg := Msg  
   + 'Este ponto de auditoria tem como finalidade exibir as vendas abaixo da margem, exporte o relatório em excel';
 ShowMessage(msg);
 end;
*/


SELECT  *
            FROM PCPEDC, PCPEDI, PCCLIENT, 
                 PCUSUARI, PCPRODUT, PCTABPR,
                 PCPRACA
           WHERE PCPEDC.CODCLI = PCCLIENT.CODCLI
             AND PCPEDC.CODUSUR = PCUSUARI.CODUSUR
             AND PCPEDC.NUMPED = PCPEDI.NUMPED
             AND PCPEDI.CODPROD = PCPRODUT.CODPROD
             AND PCCLIENT.CODPRACA = PCPRACA.CODPRACA
             AND PCPEDI.CODPROD = PCTABPR.CODPROD
             AND PCPRACA.NUMREGIAO = PCTABPR.NUMREGIAO
             AND PCPEDC.POSICAO IN ('F', 'L', 'M', 'P', 'B')
             AND PCPEDC.DATA>=TRUNC(SYSDATE)-30
           --  AND ((PCPEDC.CODFILIAL IN ([FILIAL])) OR ('99' IN ([FILIAL])))
          ---   AND ((PCPRODUT.CODEPTO IN ([DEPARTAMENTO])) OR ( '9999' IN ([DEPARTAMENTO])))
             and PCPEDI.PVENDA < PCPEDI.VLCUSTOFIN                    
             AND PCPEDC.CONDVENDA NOT IN (4, 5, 6, 8, 10, 13,11)
