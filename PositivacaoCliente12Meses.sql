SELECT COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '01', (NVL((AFSIS.CODCLI), 0))))) AS JANEIRO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '02', (NVL((AFSIS.CODCLI), 0))))) AS FEVEREIRO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '03', (NVL((AFSIS.CODCLI), 0))))) AS MARCO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '04', (NVL((AFSIS.CODCLI), 0))))) AS ABRIL,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '05', (NVL((AFSIS.CODCLI), 0))))) AS MAIO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '06', (NVL((AFSIS.CODCLI), 0))))) AS JUNHO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '07', (NVL((AFSIS.CODCLI), 0))))) AS JULHO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '08', (NVL((AFSIS.CODCLI), 0))))) AS AGOSTO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '09', (NVL((AFSIS.CODCLI), 0))))) AS SETEMBRO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '10', (NVL((AFSIS.CODCLI), 0))))) AS OUTUBRO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '11', (NVL((AFSIS.CODCLI), 0))))) AS NOVEMBRO,
       COUNT(DISTINCT(DECODE(TO_CHAR(AFSIS.DATA, 'MM'), '12', (NVL((AFSIS.CODCLI), 0))))) AS DEZEMBRO
  FROM (SELECT ROWNUM CONTADOR,
               CODCLI,
               CLIENTE,
               FANTASIA,
               CODATIV,
               RAMO,
               QT,
               DATA,
               PVENDA,
               PVENDA_SEMST,
               TOTPESO,
               TOTMIXPROD,
               VOLUME,
               LITRAGEM,
               TOTQTUNIT,
               TOTQTUNITCX,
               PBONIFIC
          FROM (SELECT PCCLIENT.CODCLI,
                       PCCLIENT.CLIENTE,
                       PCPEDC.DATA,
                       PCCLIENT.FANTASIA,
                       PCATIVI.CODATIV,
                       PCATIVI.RAMO,
                       SUM(ROUND(NVL(PCPEDI.QT, 0) *
                                 (NVL(PCPEDI.PVENDA, 0) +
                                  NVL(PCPEDI.VLOUTRASDESP, 0) +
                                  NVL(PCPEDI.VLFRETE, 0)),
                                 2)) AS PVENDA,
                       ROUND(SUM(NVL(PCPEDI.QT, 0) *
                                 (NVL(PCPEDI.PVENDA, 0) - NVL(PCPEDI.ST, 0))),
                             2) AS PVENDA_SEMST,
                       ROUND(SUM(NVL(PCPRODUT.PESOBRUTO, 0) *
                                 NVL(PCPEDI.QT, 0)),
                             2) AS TOTPESO,
                       ROUND(SUM(NVL(PCPRODUT.VOLUME, 0) * NVL(PCPEDI.QT, 0)),
                             2) Volume,
                       ROUND(SUM(NVL(PCPRODUT.LITRAGEM, 0) *
                                 NVL(PCPEDI.QT, 0)),
                             2) LITRAGEM,
                       COUNT(DISTINCT(PCPEDI.CODPROD)) TOTMIXPROD,
                       SUM(NVL(PCPEDI.QT, 0) /
                           DECODE(NVL(PCPRODUT.QTUNIT, 0),
                                  0,
                                  1,
                                  NVL(PCPRODUT.QTUNIT, 1))) TOTQTUNIT,
                       SUM(NVL(PCPEDI.QT, 0) /
                           DECODE(NVL(PCPRODUT.QTUNITCX, 0),
                                  0,
                                  1,
                                  NVL(PCPRODUT.QTUNITCX, 1))) TOTQTUNITCX,
                       SUM(PCPEDI.QT) AS QT,
                       ROUND(SUM(NVL(PCPEDI.QT, 0) * NVL(PCPEDI.PBONIFIC, 0)),
                             2) PBONIFIC
                  FROM PCPEDI,
                       PCPEDC,
                       PCPRODUT,
                       PCFORNEC,
                       PCDEPTO,
                       PCCLIENT,
                       PCUSUARI,
                       PCATIVI,
                       PCPRACA
                 WHERE PCPEDI.NUMPED = PCPEDC.NUMPED
                   AND PCUSUARI.CODSUPERVISOR NOT IN ('9999')
                   AND PCPEDC.DATA BETWEEN :DTINI AND :DTFIM
                   AND PCPEDC.CODFILIAL IN (:CODFILIAL)
                   AND PCPEDC.CONDVENDA IN
                       (1, 2, 3, 7, 9, 14, 15, 17, 18, 19, 98)
                   AND NVL(PCPEDI.BONIFIC, 'N') = 'N'
                   AND PCPEDC.POSICAO = 'F'
                   AND NVL(PCPEDC.CODEMITENTE, 0) IN (8888)
                   AND PCPEDC.CODCLI = PCCLIENT.CODCLI(+)
                   AND PCCLIENT.CODATV1 = PCATIVI.CODATIV(+)
                   AND PCPEDC.DTCANCEL IS NULL
                   AND PCPEDI.CODPROD = PCPRODUT.CODPROD(+)
                   AND PCPRODUT.CODEPTO = PCDEPTO.CODEPTO(+)
                   AND PCPRODUT.CODFORNEC = PCFORNEC.CODFORNEC(+)
                   AND PCPEDC.CODUSUR = PCUSUARI.CODUSUR
                   AND PCPEDC.CODPRACA = PCPRACA.CODPRACA(+)
                 GROUP BY PCCLIENT.CODCLI,
                          PCPEDC.DATA,
                          PCCLIENT.CLIENTE,
                          PCCLIENT.FANTASIA,
                          PCATIVI.CODATIV,
                          PCATIVI.RAMO
                 ORDER BY PVENDA DESC)) AFSIS
