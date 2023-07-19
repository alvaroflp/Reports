SELECT X.*, (ROUND(((X.PERCLUCRO-X.PERCLUCROMETA)*X.VLVENDA),2)/100) FLEX FROM (
SELECT 
  AFSIS.CODSUPERVISOR, 
  AFSIS.NOME,
  AFSIS.QTPED, 
  AFSIS.MEDIAQTITENS,
  AFSIS.QTITENS,
  AFSIS.QTRCAS, 
  AFSIS.VLVENDA, 
  AFSIS.VLBONIF, 
  AFSIS.VLCMVANTESAPLVERBA,
  AFSIS.VLLUCRO,
    ROUND(ABS((((AFSIS.VLCMVANTESAPLVERBA/AFSIS.VLVENDA)*100)-100)),2) PERCLUCRO,
  17 PERCLUCROMETA
 FROM (
SELECT PCPEDC.CODSUPERVISOR,
       NVL(PCSUPERV.NOME, '* NAO VINCULADO *') NOME,
       COUNT(PCPEDC.NUMPED) QTPED,
       COUNT(DISTINCT(PCPEDC.CODUSUR)) QTRCAS,
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
                  PCPEDC.VLATEND - NVL(PCPEDC.VLOUTRASDESP, 0) -
                  NVL(PCPEDC.VLFRETE, 0))) VLVENDA,
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
            WHERE I.NUMPED = PCPEDC.NUMPED)) VLLUCRO,
       SUM(DECODE(PCPEDC.CONDVENDA,
                  5,
                  0,
                  6,
                  0,
                  11,
                  0,
                  12,
                  0,
                  PCPEDC.VLTABELA - NVL(PCPEDC.VLOUTRASDESP, 0) -
                  NVL(PCPEDC.VLFRETE, 0) - NVL(PCPEDC.VLBONIFIC, 0))) VLTABELA,
       SUM(DECODE(PCPEDC.CONDVENDA,
                  5,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  6,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  11,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  1,
                  NVL(PCPEDC.VLBONIFIC, 0),
                  14,
                  NVL(PCPEDC.VLBONIFIC, 0)
                  
                 ,
                  12,
                  NVL(PCPEDC.VLBONIFIC, PCPEDC.VLTABELA),
                  0)) VLBONIF,
       SUM((SELECT SUM(NVL(I.VLCUSTOREAL, 0) * NVL(I.QT, 0))
             FROM PCPEDI I
            WHERE I.NUMPED = PCPEDC.NUMPED)) VLCUSTOREAL,
       SUM((SELECT SUM(NVL(I.VLCUSTOFIN, 0) * NVL(I.QT, 0))
             FROM PCPEDI I
            WHERE I.NUMPED = PCPEDC.NUMPED)) VLCUSTOFIN,
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
                0)) * PCPEDC.PRAZOMEDIO) /
       DECODE(SUM(NVL(NVL(DECODE(PCPEDC.CONDVENDA,
                                 5,
                                 0,
                                 6,
                                 0,
                                 11,
                                 0,
                                 12,
                                 0,
                                 PCPEDC.VLATEND -
                                 NVL(PCPEDC.VLOUTRASDESP, 0) -
                                 NVL(PCPEDC.VLFRETE, 0)),
                          0),
                      0)),
              0,
              1,
              SUM(NVL(NVL(DECODE(PCPEDC.CONDVENDA,
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
                          0),
                      0))) clNUMDIAS,
       COUNT(DISTINCT PCPEDC.CODCLI) QTMIXCLI,
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
       MAX(NVL((SELECT SUM(NVL(PCMETASUP.VLVENDAPREV, 0))
                 FROM PCMETASUP
                WHERE 0 = 0
                  AND PCMETASUP.DATA BETWEEN '&DTINI' AND '&DTFIM'
                  AND PCMETASUP.CODFILIAL IN (&CODFILIAL)
                     
                  AND PCMETASUP.CODSUPERVISOR(+) = PCPEDC.CODSUPERVISOR),
               0)) VLVENDAPREV,
       SUM(NVL(PCPEDC.TOTPESO, 0)) TOTPESO,
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
  FROM PCSUPERV, PCUSUARI, PCPLPAG, PCPEDC
 WHERE PCPEDC.CODPLPAG = PCPLPAG.CODPLPAG
   AND PCPEDC.CODUSUR = PCUSUARI.CODUSUR
   AND PCPEDC.CODSUPERVISOR = PCSUPERV.CODSUPERVISOR(+)
   AND PCPEDC.CODSUPERVISOR NOT IN (2)
   AND PCPEDC.CONDVENDA NOT IN (4, 8, 10, 13, 20, 98, 99)
   AND PCPEDC.DTCANCEL IS NULL
   AND PCPEDC.DATA BETWEEN '&DTINI' AND '&DTFIM'
   AND PCPEDC.CODFILIAL IN (&CODFILIAL)
 GROUP BY PCPEDC.CODSUPERVISOR,
          NVL(PCSUPERV.NOME, '* NAO VINCULADO *')
 ORDER BY VLVENDA DESC ) AFSIS
 WHERE 1 = 1 ) X
