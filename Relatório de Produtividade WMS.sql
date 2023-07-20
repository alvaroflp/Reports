SELECT *
  FROM (SELECT tab.data, tab.MATRICULA,
               tab.NOME,
               Count(tab.numvol) AS numero,
               'QT END' AS unidade,
               0 AS numero2,
               '' AS unidade2,
               0 AS numero3,
               '' AS unidade3,
               TRUNC(Count(tab.numvol) / 10) AS pontos,
               TRUNC(Count(tab.numvol) / 10) * ('&valorempilhadeira') AS valor,
               'OP. EMPILHADEIRA' AS funcao
              -- '&data1',
               --'&data2'
          FROM (SELECT m.data, r.MATRICULA, r.NOME, m.NUMOS, m.CODENDERECO AS numvol
                  FROM pcmovendpend m, pcempr r
                 WHERE m.CODFUNCOS = r.MATRICULA
                   AND m.DTESTORNO IS NULL
                   AND Nvl(m.NUMBONUS, 0) = 0
                   AND m.POSICAO = 'C'
                   AND m.CODFILIAL = 1
                   AND m.CODFUNCOS NOT IN (94,
                                           142,
                                           1020,
                                           1403,
                                           177,
                                           8930,
                                           171,
                                           172,
                                           2606,
                                           96,
                                           132,
                                           134)
                   AND m.CODOPER = 'E'
                   AND m.CODROTINA IN
                       (1722, 1752, 1723, 1793, 3714, 1709, 3709)
                   AND m.DATA BETWEEN '&data1' AND '&data2'
                UNION ALL
                SELECT m.data, r.MATRICULA, r.NOME, m.NUMOS, m.CODENDERECO AS numvol
                  FROM pcmovendpend m, pcempr r
                 WHERE m.CODFUNCOS = r.MATRICULA
                   AND m.DTESTORNO IS NULL
                   AND m.POSICAO = 'C'
                   AND m.CODFILIAL = 1
                   AND m.CODFUNCOS NOT IN (94,
                                           142,
                                           1020,
                                           1403,
                                           177,
                                           8930,
                                           171,
                                           172,
                                           2606,
                                           96,
                                           132,
                                           134)
                   AND m.TIPOOS = 17
                   AND m.DATA BETWEEN '&data1' AND '&data2'
                UNION ALL
                SELECT m.data, r.MATRICULA, r.NOME, m.NUMOS, m.CODENDERECO AS numvol
                  FROM pcmovendpend m, pcempr r
                 WHERE m.CODFUNCOS = r.MATRICULA
                   AND m.DTESTORNO IS NULL
                   AND Nvl(m.NUMBONUS, 0) > 0
                   AND m.POSICAO = 'C'
                   AND m.CODOPER = 'E'
                   AND m.CODFILIAL = 1
                   AND m.CODFUNCOS NOT IN (94,
                                           142,
                                           1020,
                                           1403,
                                           177,
                                           8930,
                                           171,
                                           172,
                                           2606,
                                           96,
                                           132,
                                           134)
                   AND m.CODROTINA IN (1704, 1708, 1771, 3712)
                   AND m.DATA BETWEEN '&data1' AND '&data2') tab
         GROUP BY tab.data, tab.MATRICULA, tab.NOME
         ORDER BY 9 DESC)
UNION ALL
SELECT *
  FROM (SELECT tab2.data, tab2.matricula,
               tab2.nome,
               Count(tab2.CODENDERECO) AS numero,
               'QT END' AS unidade,
               Sum(tab2.qtcx) AS numero2,
               'QT CX' AS unidade2,
               0 AS numero3,
               '' AS unidade3,
               TRUNC(Count(tab2.CODENDERECO) * (&REPOPESO1) / 10 +
                     Sum(tab2.qtcx) * (&REPOPESO2) / 1000) AS pontos,
               TRUNC(Count(tab2.NUMOS) * (&REPOPESO1) / 10 +
                     Sum(tab2.qtcx) * (&REPOPESO2) / 1000) * &valorrepositor AS valor,
               'REPOSITOR' AS funcao
              -- '&data1',
              -- '&data2'
          FROM (SELECT m.data, 0 AS matricula,
                       tab.nome,
                       m.NUMOS,
                       m.CODENDERECO,
                       Sum(trunc(m.QT / wms_qtunitcx(m.CODPROD))) AS qtcx
                  FROM pcmovendpend m,
                       (SELECT e.CODENDERECO,
                               e.DEPOSITO,
                               e.RUA,
                               e.PREDIO,
                               CASE e.RUA
                                 WHEN 1 THEN
                                  'EDENIELTON MADES MENEZES'
                                 WHEN 2 THEN
                                  'EDENIELTON MADES MENEZES'
                                 WHEN 3 THEN
                                  'WANDERSON FREIRE DE MENEZES'
                                 WHEN 4 THEN
                                  'WANDERSON FREIRE DE MENEZES'
                                 WHEN 5 THEN
                                  'WANDERSON FREIRE DE MENEZES'
                                 WHEN 6 THEN
                                  'MARCOS ANTONIO ESPINDOLA FRANCA'
                                 WHEN 7 THEN
                                  'MARCOS ANTONIO ESPINDOLA FRANCA'
                                 WHEN 8 THEN
                                  'WANDERSON FREIRE DE MENEZES'
                                 WHEN 9 THEN
                                  'MARCOS ANTONIO ESPINDOLA FRANCA'
                                 WHEN 10 THEN
                                  'MARCOS ANTONIO ESPINDOLA FRANCA'
                                 WHEN 11 THEN
                                  'FUNC11'
                                 WHEN 12 THEN
                                  'FUNC12'
                                 WHEN 13 THEN
                                  'FUNC13'
                                 WHEN 14 THEN
                                  'FUNC14'
                                 WHEN 15 THEN
                                  'FUNC15'
                                 ELSE
                                  'Outros'
                               END AS nome
                          FROM pcendereco e
                         WHERE e.TIPOENDER = 'AP'
                           AND e.CODFILIAL = 3) tab
                 WHERE m.CODENDERECO = tab.CODENDERECO
                   AND m.DTESTORNO IS NULL
                   AND Nvl(m.NUMBONUS, 0) = 0
                   AND m.POSICAO = 'C'
                   AND m.CODFUNCOS NOT IN (94,
                                           142,
                                           1020,
                                           1403,
                                           177,
                                           8930,
                                           171,
                                           172,
                                           2606,
                                           96,
                                           132,
                                           134)
                   AND m.CODOPER = 'E'
                   AND m.CODFILIAL = 1
                   AND m.CODROTINA IN
                       (1722, 1752, 1723, 1793, 3714, 1709, 3709)
                   AND m.DATA BETWEEN '&data1' AND '&data2'
                 GROUP BY m.data, tab.nome, m.NUMOS, m.CODENDERECO) tab2
         GROUP BY tab2.data, tab2.matricula, tab2.nome
         ORDER BY data asc)
UNION ALL
SELECT *
  FROM (SELECT tab.data, tab.MATRICULA,
               tab.NOME,
               Count(tab.CODENDERECO) AS numero,
               'QT END' AS unidade,
               Sum(tab.qt) AS numero2,
               'QT UN' AS unidade2,
               0 AS numero3,
               '' AS unidade3,
               TRUNC(Count(tab.CODENDERECO) * (&SEPPESO1) / 100 +
                     Sum(tab.qt) * (&SEPPESO2) / 1000) AS pontos,
               TRUNC(Count(tab.CODENDERECO) * (&SEPPESO1) / 100 +
                     Sum(tab.qt) * (&SEPPESO2) / 1000) * &valorseparador AS valor,
               'SEPARADOR' AS funcao
            --   '&data1',
             --  '&data2'
          FROM (SELECT m.data, r.MATRICULA,
                       r.NOME,
                       m.NUMOS,
                       m.CODENDERECO,
                       Sum(m.QT) AS qt
                  FROM pcmovendpend m, pcempr r
                 WHERE m.CODFUNCOS = r.MATRICULA
                   AND m.DTESTORNO IS NULL
                   AND m.POSICAO = 'C'
                   AND m.CODOPER = 'S'
                   AND m.NUMPED IN (SELECT w.NUMPED
                                      FROM pcpedc w
                                     WHERE w.NUMPED = m.NUMPED
                                       AND w.DTCANCEL IS NULL)
                   AND m.CODFUNCOS NOT IN (94,
                                           142,
                                           1020,
                                           1403,
                                           177,
                                           8930,
                                           171,
                                           172,
                                           2606,
                                           96,
                                           132,
                                           134)
                   AND m.TIPOOS IN
                       (9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 22)
                   AND m.DATA BETWEEN '&data1' AND '&data2'
                 GROUP BY m.data, r.MATRICULA, r.NOME, m.NUMOS, m.CODENDERECO) tab
         GROUP BY tab.data, tab.MATRICULA, tab.NOME
         ORDER BY data asc)
UNION ALL
SELECT *
  FROM (SELECT tab3.data, 
               tab3.MATRICULA,
               tab3.NOME,
               tab3.numero,
               tab3.unidade,
               tab3.numero2,
               tab3.unidade2,
               Nvl(tab3.numero3, 0) AS numero3,
               tab3.unidade3,
               TRUNC(Sum(tab3.numero) * (&CONFEXPESO1) / 100 +
                     Sum(tab3.numero2) * (&CONFEXPESO2) / 1000 +
                     Sum(Nvl(tab3.numero3, 0)) * (&CONFEXPESO3) / 100) AS pontos,
               TRUNC(Sum(tab3.numero) * (&CONFEXPESO1) / 100 +
                     Sum(tab3.numero2) * (&CONFEXPESO2) / 1000 +
                     Sum(Nvl(tab3.numero3, 0)) * (&CONFEXPESO3) / 100) *
               '&valorconferentes' AS valor,
               'CONFERENTES' AS funcao
             --  '&data1',
             --  '&data2'
          FROM (SELECT  tab.data, tab.MATRICULA,
                       tab.NOME,
                       Count(DISTINCT tab.NUMOS) AS numero,
                       'QT O.S.' AS unidade,
                       Sum(tab.qt) AS numero2,
                       'QT UN' AS unidade2,
                       (SELECT Sum(tab2.numvol) AS numvol
                          FROM (SELECT q.CODFUNCCONFERENTE AS matricula,
                                       q.NUMOS,
                                       0 AS codendereco,
                                       0 AS qt,
                                       Max(q.NUMVOL) AS numvol
                                  FROM pcwmsconfembarque q, pcempr r
                                 WHERE q.CODFUNCCONFERENTE = r.MATRICULA
                                   AND q.NUMVOL > 0
                                   AND r.MATRICULA NOT IN (94,
                                                           142,
                                                           1020,
                                                           1403,
                                                           177,
                                                           8930,
                                                           171,
                                                           172,
                                                           2606,
                                                           96,
                                                           132,
                                                           134)
                                   AND q.TIPOOS IN (13, 22, 20, 17)
                                   AND trunc(q.DTINICIOCONF) BETWEEN '&data1' AND
                                       '&data2'
                                 GROUP BY q.CODFUNCCONFERENTE, q.NUMOS) tab2
                         WHERE tab2.matricula = tab.MATRICULA
                         GROUP BY tab2.matricula) AS numero3,
                       'QT VOL' AS unidade3
                  FROM (SELECT m.data, r.MATRICULA,
                               r.NOME,
                               m.NUMOS,
                               m.CODENDERECO,
                               Sum(m.QT) AS qt,
                               0 AS numvol
                          FROM pcmovendpend m, pcempr r
                         WHERE m.CODFUNCCONF = r.MATRICULA
                           AND m.DTESTORNO IS NULL
                           AND m.POSICAO = 'C'
                           AND m.CODOPER = 'S'
                           AND m.NUMPED IN
                               (SELECT w.NUMPED
                                  FROM pcpedc w
                                 WHERE w.NUMPED = m.NUMPED
                                   AND w.DTCANCEL IS NULL)
                           AND m.TIPOOS IN (9,
                                            10,
                                            11,
                                            12,
                                            13,
                                            14,
                                            15,
                                            16,
                                            18,
                                            19,
                                            20,
                                            21,
                                            22)
                           AND m.CODFUNCEMBALADOR IS NULL
                           AND m.DATA BETWEEN '&data1' AND '&data2'
                         GROUP BY m.data, r.MATRICULA, r.NOME, m.NUMOS, m.CODENDERECO) tab
                 GROUP BY tab.data, tab.MATRICULA, tab.NOME) tab3 --DAKJGDJASGDJAGSJDGAS
         GROUP BY tab3.data, tab3.MATRICULA,
                  tab3.NOME,
                  tab3.numero,
                  tab3.unidade,
                  tab3.numero2,
                  tab3.unidade2,
                  tab3.unidade3,
                  tab3.numero3) tab3
UNION ALL
SELECT *
  FROM (SELECT tab.datarm, tab.MATRICULA,
               tab.NOME,
               Count(DISTINCT tab.NUMBONUS) AS numero,
               'QT BÔNUS' AS unidade,
               Sum(tab.qtcx) AS numero2,
               'QT CX' AS unidade2,
               0 AS numero3,
               '' AS unidade3,
               trunc(Count(DISTINCT tab.NUMBONUS) * (&RMPESO1) +
                     trunc(Sum(tab.qtcx) / 10000) * (&RMPESO2) / 100) AS pontos,
               trunc(Count(DISTINCT tab.NUMBONUS) * (&RMPESO1) +
                     trunc(Sum(tab.qtcx) / 10000) * (&RMPESO2) / 100) *
               ('&valorconfrecbimento') AS valor,
               'CONF. RECEBIMENTO' AS funcao
              -- ' &data1',
              -- '&data2'
          FROM (SELECT c.datarm,
                       r.MATRICULA,
                       r.NOME,
                       c.NUMBONUS,
                       i.CODPROD,
                       TRUNC(Sum(i.QTENTRADA) / wms_qtunitcx(i.CODPROD)) AS qtcx
                  FROM pcbonusc c, pcbonusi i, pcempr r
                 WHERE c.NUMBONUS = i.NUMBONUS
                   AND c.CODFUNCRM = r.MATRICULA
                   AND r.MATRICULA NOT IN (94,
                                           142,
                                           1020,
                                           1403,
                                           177,
                                           8930,
                                           171,
                                           172,
                                           2606,
                                           96,
                                           132,
                                           134)
                   AND c.DTFECHAMENTO BETWEEN '&data1' AND '&data2'
                   AND c.NUMBONUS IN
                       (SELECT w.NUMBONUS
                          FROM pcwms w
                         WHERE w.NUMBONUS = c.NUMBONUS
                           AND w.DTCANCEL IS NULL
                           AND w.DATAWMS BETWEEN '&data1' AND '&data2'
                           AND w.CODOPER IN ('E', 'ET'))
                 GROUP BY c.datarm, r.MATRICULA, r.NOME, c.NUMBONUS, i.CODPROD) tab
         GROUP BY  tab.datarm, tab.MATRICULA, tab.NOME
         ORDER BY 1 asc)
         ORDER BY 1

