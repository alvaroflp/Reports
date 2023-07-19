CREATE OR REPLACE TRIGGER TRG_CTRLACESSOLOG
AFTER INSERT OR UPDATE OR DELETE ON PCCONTRO
FOR EACH ROW
DECLARE
    v_alteracao varchar2(30);
BEGIN
    IF inserting THEN
        v_alteracao := 'INSERT';
    ELSIF updating THEN
        v_alteracao := 'UPDATE';
    ELSE
        v_alteracao := 'DELETE';
    END IF;
    
    INSERT INTO CTRLACESSOLOG (
        DTALTERACAO,
        ALTERACAO,
        TABELA,
        CODROTINA,
        CODCONTROLE,
        CODUSUARIO,
        VALOROLD,
        VALORNEW,
        USUARIO,
        MAQUINA,
        PROGRAMA,
        IP
    ) VALUES (
        SYSDATE,
        v_alteracao,
        'PCCONTRO',
        :NEW.CODROTINA,
        NULL,
        :NEW.CODUSUARIO,
        :OLD.ACESSO,
        :NEW.ACESSO,
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS_CONTEXT('USERENV', 'HOST'),
        SYS_CONTEXT('USERENV', 'MODULE'),
        SYS_CONTEXT('USERENV', 'IP_ADDRESS')
    );
END;
