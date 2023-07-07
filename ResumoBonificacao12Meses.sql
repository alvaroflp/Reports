/* este relatório está no formato 12 meses com os dados pivotados, está sendo retornado o valor do custo financeiro*/

SELECT *
  FROM (SELECT AFSIS.MES, SUM(AFSIS.VLCUSTOFIN) VLCUSTOBONIFIC
          FROM (SELECT TO_CHAR(PCNFSAID.DTSAIDA, 'MM') MES,
                       SUM(
                           DECODE(NVL(PCMOVCOMPLE.VLSUBTOTITEM, 0), 0, (NVL(PCMOV.QT, 0) *
                           DECODE(PCNFSAID.CONDVENDA, 1, CASE WHEN PCMOV.CODOPER = 'SB' THEN NVL(PCMOV.PBONIFIC, 0) ELSE 0 END, 14, CASE WHEN PCMOV.CODOPER = 'SB' THEN NVL(PCMOV.PBONIFIC, 0) ELSE 0 END, 5,
                           DECODE(NVL(PCMOV.PBONIFIC, 0), 0, NVL(PCMOV.PTABELA, 0) + NVL(PCMOV.VLDESCONTO, 0), PCMOV.PBONIFIC + NVL(PCMOV.VLDESCONTO, 0)), 6,
                           DECODE(NVL(PCMOV.PBONIFIC, 0), 0, NVL(PCMOV.PTABELA, 0) + NVL(PCMOV.VLDESCONTO, 0), PCMOV.PBONIFIC + NVL(PCMOV.VLDESCONTO, 0)), 11,
                           DECODE(NVL(PCMOV.PBONIFIC, 0), 0, NVL(PCMOV.PTABELA, 0) + NVL(PCMOV.VLDESCONTO, 0), PCMOV.PBONIFIC + NVL(PCMOV.VLDESCONTO, 0)), 12,
                           DECODE(NVL(PCMOV.PBONIFIC, 0), 0, NVL(PCMOV.PTABELA, 0) + NVL(PCMOV.VLDESCONTO, 0), PCMOV.PBONIFIC + NVL(PCMOV.VLDESCONTO, 0)), 0)),
                                  NVL(PCMOVCOMPLE.VLSUBTOTITEM, 0))
                          ) VLATEND,
                       SUM(PCMOV.QT * PCMOV.CUSTOFIN) VLCUSTOFIN
                  FROM PCNFSAID, PCCLIENT, PCMOV, PCMOVCOMPLE
                 WHERE PCNFSAID.CODCLI = PCCLIENT.CODCLI
                   AND PCMOVCOMPLE.NUMTRANSITEM = PCMOV.NUMTRANSITEM
                   AND PCNFSAID.NUMTRANSVENDA = PCMOV.NUMTRANSVENDA
                   AND PCNFSAID.CONDVENDA IN (1, 5, 6, 11, 12)
                   AND PCNFSAID.CODFILIAL = PCMOV.CODFILIAL
                   AND PCNFSAID.NUMNOTA = PCMOV.NUMNOTA
                   AND PCNFSAID.DTCANCEL IS NULL
                   AND PCNFSAID.DTSAIDA BETWEEN :DTINICIO AND :DTFIM
                   AND PCNFSAID.CODFILIAL = :CODFILIAL
                   AND ((PCNFSAID.CODCOB IN
                       ('BNF', 'BNFT', 'BNFR', 'BNTR', 'BNRP')) OR
                       ((PCNFSAID.CONDVENDA = 1) AND (PCMOV.CODOPER = 'SB')))
                 GROUP BY PCNFSAID.DTSAIDA
                 ORDER BY VLATEND DESC) AFSIS
         GROUP BY AFSIS.MES)
PIVOT(SUM(VLCUSTOBONIFIC)
   FOR MES IN('01' AS "JANEIRO",
              '02' AS "FEVEREIRO",
              '03' AS "MARCO",
              '04' AS "ABRIL",
              '05' AS "MAIO",
              '06' AS "JUNHO",
              '07' AS "JULHO",
              '08' AS "AGOSTO",
              '09' AS "SETEMBRO",
              '10' AS "OUTUBRO",
              '11' AS "NOVEMBRO",
              '12' AS "DEZEMBRO"))
