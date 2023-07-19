begin
  for i in (select t.codprod, t.numregiao, t.codst, t.codtribpiscofins from pctabpr t where numregiao=&reg_origem)  loop
    begin
      update pctabpr
         set codst = i.codst, codtribpiscofins = i.codtribpiscofins
       where codprod = i.codprod
         and numregiao = &reg_destino;
    
    exception
      when dup_val_on_index then
        null;
    end;
  end loop;
end;
