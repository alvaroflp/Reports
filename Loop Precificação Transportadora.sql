begin
  for i in (select rowid,
                   numregiao,
                   codprod,
                   ptabela,
                   ptabela1,
                   ptabela2,
                   ptabela3,
                   ptabela4,
                   ptabela5,
                   ptabela6,
                   ptabela7,
                   ptabelaatac,
                   ptabelaatac1,
                   ptabelaatac2,
                   ptabelaatac3,
                   ptabelaatac4,
                   ptabelaatac5,
                   ptabelaatac6,
                   ptabelaatac7,
                   pvenda,
                   pvenda1,
                   pvenda2,
                   pvenda3,
                   pvenda4,
                   pvenda5,
                   pvenda6,
                   pvenda7,
                   pvendaatac,
                   pvendaatac1,
                   pvendaatac2,
                   pvendaatac3,
                   pvendaatac4,
                   pvendaatac5,
                   pvendaatac6,
                   pvendaatac7,
                   indicepreco
              from pctabpr
             where codprod in (&codprod)
               and numregiao in (1)) loop
    begin
      update pctabpr
         set ptabela      = i.ptabela,
             ptabela1     = i.ptabela1,
             ptabela2     = i.ptabela2,
             ptabela3     = i.ptabela3,
             ptabela4     = i.ptabela4,
             ptabela5     = i.ptabela5,
             ptabela6     = i.ptabela6,
             ptabela7     = i.ptabela7,
             ptabelaatac  = i.ptabelaatac,
             ptabelaatac1 = i.ptabelaatac1,
             ptabelaatac2 = i.ptabelaatac2,
             ptabelaatac3 = i.ptabelaatac3,
             ptabelaatac4 = i.ptabelaatac4,
             ptabelaatac5 = i.ptabelaatac5,
             ptabelaatac6 = i.ptabelaatac6,
             ptabelaatac7 = i.ptabelaatac7,
             pvenda       = i.pvenda,
             pvenda1      = i.pvenda1,
             pvenda2      = i.pvenda2,
             pvenda3      = i.pvenda3,
             pvenda4      = i.pvenda4,
             pvenda5      = i.pvenda5,
             pvenda6      = i.pvenda6,
             pvenda7      = i.pvenda7,
             pvendaatac   = i.pvendaatac,
             pvendaatac1  = i.pvendaatac1,
             pvendaatac2  = i.pvendaatac2,
             pvendaatac3  = i.pvendaatac3,
             pvendaatac4  = i.pvendaatac4,
             pvendaatac5  = i.pvendaatac5,
             pvendaatac6  = i.pvendaatac6,
             pvendaatac7  = i.pvendaatac7,
             indicepreco       = i.indicepreco
       where codprod = i.codprod
         and numregiao = 8;
    
    exception
      when dup_val_on_index then
        null;
    end;
  end loop;
end;
