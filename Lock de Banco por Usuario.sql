 /*lock de banco por usuario*/
 select tab.username, tab.osuser, tab.program from (
 select decode(s.blocker_session,
              s.sid,
              '1.' || s.sid,
              decode(s.blocking_session, null, '2', '1.' || s.blocking_session || '.1')) as id_session_lock, 
       decode(s.blocker_session,
              s.sid,
              '1',
              decode(s.blocking_session, null, '2', '1.1')) as status_lock,               
       case when s.blocking_session is not null
              or s.blocker_session is not null then              
          (select max(o.OBJECT_NAME)
           from v$locked_object l, all_objects o
           where s.sID = l.SESSION_ID 
           and o.object_id = l.OBJECT_ID) 
        else null end AS OBJETO,       
       s.*
  from (SELECT 'N' SELECIONADO,
               NVL(s.username, '(oracle)') AS username,
               s.osuser,
               s.sid,
               s.serial#,
               p.spid,
               s.lockwait,
               s.status,
               s.module,
               s.machine,
               s.program,
               s.logon_Time,
               s.blocking_session,
               (select MAX(x.blocking_session)
                  from v$session x
                 where x.BLOCKING_SESSION = s.sid) blocker_session,
               s.inst_id,
               Round((SYSDATE - s.logon_Time) * 24 * 60, 2) AS TEMPODEUSO,               
               s.SQL_ID
          FROM gv$session s, v$process p
         where p.addr = s.paddr
           and s.osuser <> 'SYSTEM'
           and s.username <> 'SYSMAN'
        CONNECT BY PRIOR s.sid = s.blocking_session
         START WITH s.blocking_session IS NULL) S
order by id_session_lock) tab
where program like '%AFLP%'
and osuser in (SELECT osuser
    FROM V$SESSION_CONNECT_INFO
   WHERE SID = SYS_CONTEXT('USERENV', 'SID')
     AND ROWNUM <= 1)
