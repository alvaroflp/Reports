select distinct i.numos,
                i.tipoos,
                o.descricao,
                o.aplicacao,
                i.numtranswms,
                i.codfuncger,
                initcap(e.nome) nomefuncger,
                i.funcpriimp,
                initcap((select pcempr.nome
                   from pcempr
                  where pcempr.matricula = i.funcpriimp)) nomefuncimpr,
                i.numped,
                (select pccarreg.codrotaprinc
                   from pccarreg
                  where pccarreg.numcar = i.numcar) codrota,
                (select pcrotaexp.descricao
                   from pcrotaexp
                  where pcrotaexp.codrota =
                        (select pccarreg.codrotaprinc
                           from pccarreg
                          where pccarreg.numcar = i.numcar)) rota,
                (select pcpedc.codpraca
                   from pcpedc
                  where pcpedc.numped = i.numped) codpraca,
                (select pcpraca.praca
                   from pcpraca
                  where pcpraca.codpraca =
                        (select pcpedc.codpraca
                           from pcpedc
                          where pcpedc.numped = i.numped)) praca,
                (select pcpedc.numseqentrega
                   from pcpedc
                  where pcpedc.numped = i.numped) numseqentrega,
                i.numcar,
                trunc(sysdate) as data
  from pcmovendpend i, pcempr e, pctipoos o
 where 1 = 1
   and o.codigo = i.tipoos
   and e.matricula = i.codfuncger
   and i.numcar in (:numcar)
   and i.dtestorno is null
   order by i.tipoos, (select pcpedc.numseqentrega
                   from pcpedc
                  where pcpedc.numped = i.numped) asc
