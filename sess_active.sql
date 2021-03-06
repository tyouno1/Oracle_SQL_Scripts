
COLUMN sid               FORMAT 99999            HEADING 'SID'
COLUMN S_client_Pid           FORMAT a12            HEADING 'S_CLIENT_PID'
COLUMN serial_id         FORMAT 999999           HEADING 'Serial#'
COLUMN session_status    FORMAT a9               HEADING 'Status'          JUSTIFY right
COLUMN oracle_username   FORMAT a12              HEADING 'User'
COLUMN CLIENT_IDENTIFIER   FORMAT a12              HEADING 'CLIENT|IDENTIFIER'
COLUMN os_username       FORMAT a9               HEADING 'O/S User'        JUSTIFY right
COLUMN os_pid            FORMAT a8               HEADING 'O/S PID'
COLUMN session_program   FORMAT a30              HEADING 'Session Program' TRUNC
COLUMN module            Format a30              Heading 'Module'          TRUNC
COLUMN session_machine   FORMAT a14              HEADING 'Machine'         JUSTIFY right TRUNC
COLUMN Logical_Reads     FORMAT 999,999,999,999  Heading 'Logical Reads'
COLUMN SQLID_CHD#            FORMAT a16              Heading 'SQLID_CHD#'

prompt
prompt +----------------------------------------------------+
prompt | Active User Sessions                               |
prompt +----------------------------------------------------+

SELECT
    s.sid                sid
  , lpad(s.status,9)     session_status
  , lpad(s.username,12)  oracle_username
  , lpad(s.osuser,9)     os_username
  , p.spid               os_pid
  , s.module             MODULE
  , s.process            S_client_Pid
  , s.sql_id|| ' ' || s.SQL_CHILD_NUMBER            SQLID_CHD#
 -- , s.SQL_CHILD_NUMBER
  , s.last_call_et
	,decode(s.COMMAND, '0', 'NOT RECD','1','CREATE TAB','2','INSERT','3','SELECT','6','UPDATE',
       '7','DELETE','9','CREATE IDX','10','DROP IDX','12','DROP TAB','26','LOCK TAB','40','ALTER TBS',
			 '44','COMMIT','45','ROLLBACK','85','TRUNCT TAB','OTHERS') CMD_TYPE
	, s.program            session_program		 
	, ss.VALUE             Logical_Reads
  , lpad(s.machine,14)   session_machine
  , s.PREV_SQL_ID
  , TO_CHAR (logon_time, 'DD-MON-YY HH24:MI:SS') "Logged On"
  , sw.state
  ,decode(sw.state, 'WAITING','Waiting',
                'Working') "state2"
  , sw.EVENT
  ,decode(sw.state,
                'WAITING',
                'So far '||sw.seconds_in_wait,
                'Last waited '||
                sw.wait_time/100)||
        ' secs for '||sw.event
        "Event Description"
  , sw.SECONDS_IN_WAIT
  , sw.wait_time
  , sw.SEQ#
  , s.BLOCKING_SESSION
  , s.BLOCKING_INSTANCE
--  , s.process            S_client_Pid
--  , sstat.value          cpu_value
FROM
    v$process  p
  , v$session  s
  , v$sesstat  ss
  , v$statname st
  , v$session_wait sw
WHERE p.addr(+) = s.paddr
     AND s.SID = ss.SID
     AND st.statistic# = ss.statistic#
	 AND s.sid=sw.sid
     AND s.status = 'ACTIVE'
     AND s.TYPE != 'BACKGROUND'
     AND st.NAME = 'session logical reads'
		 and s.sid != userenv('sid') -- do not caputre my own session
ORDER BY 9;
