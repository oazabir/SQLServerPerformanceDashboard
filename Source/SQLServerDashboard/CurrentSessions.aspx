<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CurrentSessions.aspx.cs" Inherits="SQLServerDashboard.CurrentSessions" %>
<%@ OutputCache NoStore="true" Location="None" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Sessions</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <script src="js/jquery-1.11.1.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">        
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="
SELECT ER.session_id,
	CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), ' 
        + CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, ' 
        + CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' as running_time, 
	ER.cpu_time,
	DB_NAME(ER.database_id), 
	ER.command,
	ER.blocking_session_id as Blocker, 
	case when EXISTS(select 1 from sys.dm_exec_requests r where r.blocking_session_id = session_id) then 'Yes' else '' END AS Blocking,
	LAST_WAIT_TYPE,
	SUBSTRING(est.text, (ER.statement_start_offset/2)+1,  
        ((CASE ER.statement_end_offset 
         WHEN -1 THEN DATALENGTH(est.text) 
         ELSE ER.statement_end_offset 
         END - ER.statement_start_offset)/2) + 1) AS QueryText,
	SS.HOST_NAME,SS.LOGIN_TIME,SS.LOGIN_NAME,SS.PROGRAM_NAME,
/* This piece of code has been taken from article. Nice code to get time criteria's 
http://beyondrelational.com/blogs/geniiius/archive/2011/11/01/backup-restore-checkdb-shrinkfile-progress.aspx 
*/     
    CAST((estimated_completion_time/3600000) as varchar) + ' hour(s), ' 
        + CAST((estimated_completion_time %3600000)/60000 as varchar) + 'min, ' 
        + CAST((estimated_completion_time %60000)/1000 as varchar) + ' sec' as est_time_to_go, 
    DATEADD(second,estimated_completion_time/1000, getdate()) as est_completion_time, 
/* End of Article Code */       

TEXT
FROM sys.dm_exec_requests ER 
INNER JOIN sys.dm_exec_sessions SS ON SS.session_id = ER.session_id
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(er.sql_handle) EST 
WHERE ER.session_id != @@SPID AND Command != 'WAITFOR' AND
                     [LAST_WAIT_TYPE] NOT IN (
        N'BROKER_EVENTHANDLER',         N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',            N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',          N'CHECKPOINT_QUEUE',
        N'CHKPT',                       N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',            N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',          N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',       N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',             N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                    N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',           N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',        N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',             N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',              N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',           N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',             N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',         N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',        N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',            N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',         N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',       N'WAIT_FOR_RESULTS',
        N'WAITFOR',                     N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',          N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',         N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',          N'XE_TIMER_EVENT')
    
ORDER BY
	Blocking DESC,
	SS.Status DESC,
	ER.CPU_TIME DESC  
  
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">                    
                    <EmptyDataTemplate>
                        No session running at the moment. 
                    </EmptyDataTemplate>               
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%# Convert.ToInt32(Eval("CPU_TIME")) > 3000 ? "<span class='label label-warning'>High CPU</span>" : "" %>                                
                                <%# Convert.ToInt32(Eval("Blocker")) > 0 ? "<span class='label label-warning'>Blocking</span>" : "" %>                                                                
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>      
                </asp:GridView>            
    </form>
</body>
    <script>
        var refreshtimer = window.setTimeout(function () { window.location.reload(); }, 5000);

        document.ondblclick = function () {
            window.clearTimeout(refreshtimer);
        }


        $('tr').each(function (i, tr) {
            $('td:eq(10), td:last', tr).each(function (i, e) {
                var td = $(e);
                td.html('<div>' + td.html() + '</div>');
                td.addClass('large-cell');
                td.find('div').click(function () {
                    alert($(this).text())
                });
            });
            var td = $('td:eq(9)', tr);
            
            td.append($('<a>')
                        .attr('href', 'http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/')
                        .attr('target', '_blank')
                        .html("?"));
                        
        });

    </script>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
