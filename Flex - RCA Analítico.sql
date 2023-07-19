SELECT X.*, (ROUND(((X.PERCLUCRO-X.PERCLUCROMETA)*X.VLVENDA),2)/100) FLEX FROM (
SELECT 
  AFSIS.CODSUPERVISOR, 
  AFSIS.SUPERVISOR,
  AFSIS.CODUSUR,
  AFSIS.NOME,
  AFSIS.QTPED, 
  AFSIS.MEDIAQTITENS,
  AFSIS.QTITENS, 
  AFSIS.VLVENDA, 
  AFSIS.VLBONIF, 
  AFSIS.VLCMVANTESAPLVERBA,
    ROUND(ABS((((AFSIS.VLCMVANTESAPLVERBA/AFSIS.VLVENDA)*100)-100)),2) PERCLUCRO,
  14 PERCLUCROMETA
 FROM (
 SELECT PCPEDC.CODSUPERVISOR,
       NVL(PCSUPERV.NOME, '* NAO VINCULADO *') SUPERVISOR,
       PCPEDC.CODUSUR,
       PCUSUARI.NOME,      
       COUNT(PCPEDC.NUMPED) QTPED,
       SUM(NVL(DECODE(PCPEDC.CONDVENDA,
                      5,
                      0,
                      6,
                      0,
                      
                      1,
                      (SELECT COUNT(*)
                         FROM PCPEDI I
                        WHERE I.NUMPED = PCPEDC.NUMPED
                          AND NVL(I.BONIFIC, 'N') = 'N'),
                      14,
                      (SELECT COUNT(*)
                         FROM PCPEDI I
                        WHERE I.NUMPED = PCPEDC.NUMPED
                          AND NVL(I.BONIFIC, 'N') = 'N'),
                      PCPEDC.NUMITENS),
               0)) QTITENS,
       AVG(NVL(PCPEDC.NUMITENS, 0)) MEDIAQTITENS,
       SUM(DECODE(PCPEDC.CONDVENDA,
                  5,
                  0,
                  6,
                  0,
                  11,
                  0,
                  12,
                  0,
                  NVL(PCPEDC.VLATEND - NVL(PCPEDC.VLOUTRASDESP, 0) -
                      NVL(PCPEDC.VLFRETE, 0),
                      0))) VLVENDA,
       SUM(DECODE(PCPEDC.CONDVENDA,
                  5,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  6,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  11,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  1,
                  PCPEDC.VLBONIFIC,
                  14,
                  PCPEDC.VLBONIFIC
                  
                 ,
                  12,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  0)) VLBONIF,
       SUM(DECODE(PCPEDC.CONDVENDA,
                  5,
                  0,
                  6,
                  0,
                  11,
                  0,
                  12,
                  0,
                  NVL(PCPEDC.VLTABELA - NVL(PCPEDC.VLBONIFIC, 0) -
                      NVL(PCPEDC.VLOUTRASDESP, 0) - NVL(PCPEDC.VLFRETE, 0),
                      0))) VLTABELA,
       SUM((SELECT SUM(NVL(I.VLCUSTOREAL, 0) * NVL(I.QT, 0))
             FROM PCPEDI I
            WHERE I.NUMPED = PCPEDC.NUMPED)) VLCUSTOREAL,
       SUM((SELECT SUM(NVL(I.VLCUSTOFIN, 0) * NVL(I.QT, 0))
             FROM PCPEDI I
            WHERE I.NUMPED = PCPEDC.NUMPED)) VLCUSTOFIN,
       COUNT(DISTINCT(PCPEDC.CODCLI)) QTCLIPOS,
       SUM(PCPEDC.TOTPESO) TOTPESO,
       MAX(NVL((SELECT SUM(NVL(PCMETARCA.VLVENDAPREV, 0))
                 FROM PCMETARCA
                WHERE 0 = 0
                  AND PCMETARCA.DATA BETWEEN '&DTINI' AND '&DTFIM'
                  AND PCMETARCA.CODFILIAL IN (&CODFILIAL)
                     
                  AND PCMETARCA.CODUSUR = PCPEDC.CODUSUR),
               0)) VLVENDAPREV,
       NVL(MAX(NVL(VISITAS.CLIENTES, 0)), 0) TOTVISITAS,
       SUM(NVL(PCPEDC.VLOUTRASDESP, 0)) VLOUTRASDESP,
       SUM(NVL(PCPEDC.VLFRETE, 0)) VLFRETE
       
      ,
       SUM((SELECT SUM(NVL(I.VLCUSTOFIN, 0) * NVL(I.QT, 0))
              FROM PCPEDI I
             WHERE I.NUMPED = PCPEDC.NUMPED) + NVL(PCPEDC.VLVERBACMV, 0) +
           NVL(PCPEDC.VLVERBACMVCLI, 0) +
           (SELECT NVL(SUM(NVL(AP.VLVERBACMV, 0)), 0)
              FROM PCAPLICVERBAPEDI AP, PCPEDI I
             WHERE I.NUMPED = PCPEDC.NUMPED
               AND AP.NUMPED = I.NUMPED
               AND AP.CODPROD = I.CODPROD)) VLCMVANTESAPLVERBA,
       SUM((NVL(DECODE(PCPEDC.CONDVENDA,
                       5,
                       0,
                       6,
                       0,
                       11,
                       0,
                       12,
                       0,
                       PCPEDC.VLATEND - NVL(PCPEDC.VLOUTRASDESP, 0) -
                       NVL(PCPEDC.VLFRETE, 0)),
                0))) -
       SUM((SELECT SUM(NVL(I.VLCUSTOFIN, 0) * NVL(I.QT, 0))
              FROM PCPEDI I
             WHERE I.NUMPED = PCPEDC.NUMPED) + NVL(PCPEDC.VLVERBACMV, 0) +
           NVL(PCPEDC.VLVERBACMVCLI, 0) +
           (SELECT NVL(SUM(NVL(AP.VLVERBACMV, 0)), 0)
              FROM PCAPLICVERBAPEDI AP, PCPEDI I
             WHERE I.NUMPED = PCPEDC.NUMPED
               AND AP.NUMPED = I.NUMPED
               AND AP.CODPROD = I.CODPROD)) VLLUCROANTESAPLVERBA
  FROM PCUSUARI,
       PCSUPERV,
       PCPLPAG,
       PCPEDC,
       (SELECT CODUSUR, SUM(CLIENTES) CLIENTES
          FROM (SELECT PCPEDC.DATA,
                       PCPEDC.CODUSUR,
                       COUNT(DISTINCT(PCPEDC.CODCLI)) CLIENTES
                  FROM PCPEDC
                 WHERE PCPEDC.DTCANCEL IS NULL
                   AND PCPEDC.CONDVENDA NOT IN (4, 8, 10, 13, 20, 98, 99)
                   AND PCPEDC.DATA BETWEEN '&DTINI' AND '&DTFIM'
                   AND PCPEDC.CODFILIAL IN (&CODFILIAL)
                
                 GROUP BY PCPEDC.DATA, PCPEDC.CODUSUR) VISITAS2
         GROUP BY CODUSUR) VISITAS
 WHERE PCPEDC.CODPLPAG = PCPLPAG.CODPLPAG
   AND PCPEDC.CODUSUR = VISITAS.CODUSUR(+)
   AND PCPEDC.CODUSUR = PCUSUARI.CODUSUR
   AND PCPEDC.CODSUPERVISOR = PCSUPERV.CODSUPERVISOR(+)
   AND PCPEDC.CODSUPERVISOR = 2
   AND PCPEDC.CONDVENDA NOT IN (4, 8, 10, 13, 20, 98, 99)
   AND PCPEDC.DTCANCEL IS NULL
   AND PCPEDC.CODSUPERVISOR IN (2)
   AND PCPEDC.DATA BETWEEN '&DTINI' AND '&DTFIM'
   AND PCPEDC.CODFILIAL IN (&CODFILIAL)
 GROUP BY PCPEDC.CODSUPERVISOR,
          NVL(PCSUPERV.NOME, '* NAO VINCULADO *'),
          PCPEDC.CODUSUR,
          PCUSUARI.NOME
 ORDER BY VLVENDA DESC) AFSIS
 WHERE 1 = 1 ) X
