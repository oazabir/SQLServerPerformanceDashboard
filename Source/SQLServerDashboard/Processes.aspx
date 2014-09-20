<%@ Page Language="C#" EnableViewState="false" %>
<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Processes</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />    
    <link href="css/basic.css" rel="stylesheet" />
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/jquery.simplemodal.js"></script>
    
    <style>
        td.large-cell {
            padding: 0px;
            margin: 0px;
            table-layout:fixed;
        }

        td.large-cell div {
            height: 80px;
            overflow: auto;
            cursor: hand;
            cursor: pointer                
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">        
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="
/*SELECT 
   SessionId    = s.session_id, 
   LastCommandBatch = (select text from sys.dm_exec_sql_text(c.most_recent_sql_handle)),
   TotalCPU_ms        = s.cpu_time, 
   UserProcess  = CONVERT(CHAR(1), s.is_user_process),
   LoginInfo    = s.login_name,   
   DbInstance   = ISNULL(db_name(r.database_id), N''), 
   TaskState    = ISNULL(t.task_state, N''), 
   Command      = ISNULL(r.command, N''), 
   App            = ISNULL(s.program_name, N''), 
   WaitTime_ms  = ISNULL(w.wait_duration_ms, 0),
   WaitType     = ISNULL(w.wait_type, N''),
   WaitResource = ISNULL(w.resource_description, N''), 
   BlockBy        = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   HeadBlocker  = 
        CASE 
            -- session has active request; is blocked; blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocking_session_id = 0 THEN 'Yes' 
            -- session idle; has an open tran; blocking others
            WHEN r.session_id IS NULL THEN 'Yes' 
            ELSE ''
        END,    
   TotalPhyIO_mb    = (s.reads + s.writes) * 8 / 1024, 
   MemUsage_kb        = s.memory_usage * 8192 / 1024, 
   OpenTrans        = ISNULL(r.open_transaction_count,0), 
   LoginTime        = s.login_time, 
   LastReqStartTime = s.last_request_start_time,
   HostName            = ISNULL(s.host_name, N''),
   NetworkAddr        = ISNULL(c.client_net_address, N'')
--   ExecContext        = ISNULL(t.exec_context_id, 0),
--   ReqId            = ISNULL(r.request_id, 0),
--   WorkLoadGrp        = N'',
   
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.session_id = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN 
(
    -- Using row_number to select longest wait for each thread, 
    -- should be representative of other wait relationships if thread has multiple involvements. 
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks 
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.session_id = r2.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) as st

WHERE s.session_Id > 50                         -- ignore anything pertaining to the system spids.

AND s.session_Id NOT IN (@@SPID)     -- let's avoid our own query! :)

ORDER BY DBInstance DESC, HeadBlocker desc, BlockBy desc, WaitType DESC, TotalCPU_ms desc;   */
                    
                   
SELECT 
   LoginInfo    = s.login_name,   
   SessionId    = s.session_id, 
   LastCommandBatch = (select text from sys.dm_exec_sql_text(c.most_recent_sql_handle)),
   TotalCPU_ms        = s.cpu_time, 
   UserProcess  = CONVERT(CHAR(1), s.is_user_process),
   DbInstance   = ISNULL(db_name(r.database_id), N''), 
   Command      = ISNULL(r.command, N''), 
   App            = ISNULL(s.program_name, N''), 
   (select top 1 q.blocking_session_id from sys.dm_exec_requests q where q.session_id = s.session_id) as BlockBy,
   HeadBlocker  = 
        CASE 
            -- session has active request; is blocked; blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocking_session_id = 0 THEN 'Yes' 
            -- session idle; has an open tran; blocking others
            WHEN r.session_id IS NULL THEN 'Yes' 
            ELSE ''
        END,    
   TotalPhyIO_mb    = (s.reads + s.writes) * 8 / 1024, 
   MemUsage_kb        = s.memory_usage * 8192 / 1024, 
   OpenTrans        = ISNULL(r.open_transaction_count,0), 
   LoginTime        = s.login_time, 
   LastReqStartTime = s.last_request_start_time,
   HostName            = ISNULL(s.host_name, N''),
   NetworkAddr        = ISNULL(c.client_net_address, N'')
--   ExecContext        = ISNULL(t.exec_context_id, 0),
--   ReqId            = ISNULL(r.request_id, 0),
--   WorkLoadGrp        = N'',
   
FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r ON (s.session_id = r.session_id)
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.session_id = r2.blocking_session_id)
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) as st

WHERE s.session_Id > 50                         -- ignore anything pertaining to the system spids.

AND s.session_Id NOT IN (@@SPID)     -- let's avoid our own query! :)

ORDER BY DBInstance DESC, HeadBlocker desc, BlockBy desc, TotalCPU_ms desc;           
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            
                            <ItemTemplate>
                                <%# Convert.ToString(Eval("BlockBy")).Length > 1 ? "<span class='label label-warning'>Block</span>" : "" %>                                
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>                    
                </asp:GridView>            
    </form>

    <div id="basic-modal-content">
        <pre id="content_text" >

        </pre>
    </div>
</body>
    <script>
        var refreshtimer = window.setTimeout(function () { window.location.reload(); }, 10000);
        $('tr').each(function (i, tr) {
            var td = $('td:eq(3)', tr);
            td.html('<div>' + td.html() + '</div>');
            td.addClass('large-cell');
            td.find('div').click(function () {
                $('#content_text').text($(this).html());
                $('#basic-modal-content').modal();
            });
        });
        document.ondblclick = function () {
            window.clearTimeout(refreshtimer);
        }
    </script>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
