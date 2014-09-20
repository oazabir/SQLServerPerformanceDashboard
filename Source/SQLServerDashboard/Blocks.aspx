<%@ Page Language="C#" EnableViewState="false"%>
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
/*SELECT
db.name DBName,
tl.request_session_id,
wt.blocking_session_id,
OBJECT_NAME(p.OBJECT_ID) BlockedObjectName,
tl.resource_type,
h1.TEXT AS RequestingText,
h2.TEXT AS BlockingTest,
tl.request_mode
FROM sys.dm_tran_locks AS tl
INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id =tl.request_session_id
INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id =wt.blocking_session_id
CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2*/

SELECT 
session_id, 
q2.[text] as BlockedQuery,
blocking_Session_id,
(select top 1 [text] FROM sys.dm_exec_requests blocker where blocker.session_id = blocking_session_id ) as BlockerQuery,
DB_NAME(database_id) as DBName,
user_id,
transaction_id
FROM sys.dm_exec_requests
CROSS APPLY sys.dm_exec_sql_text(Sql_handle) AS q2 
WHERE blocking_session_id <> 0 AND Blocking_Session_ID <> Session_ID


                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <EmptyDataTemplate>
                        No blocking session
                    </EmptyDataTemplate>               
                </asp:GridView>            
    </form>
</body>
    <script>
        var refreshtimer = window.setTimeout(function () { window.location.reload(); }, 5000);

        document.ondblclick = function () {
            window.clearTimeout(refreshtimer);
        }

        
        $('tr').each(function (i, tr) {
            $('td:eq(5), td:eq(6)', tr).each(function (i, e) {
                var td = $(e);
                td.html('<div>' + td.html() + '</div>');
                td.addClass('large-cell');
                td.find('div').click(function () {
                    alert($(this).text())
                });
            })                
        });
        
    </script>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
