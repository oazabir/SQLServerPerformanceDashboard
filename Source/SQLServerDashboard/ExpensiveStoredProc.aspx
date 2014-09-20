<%@ Page Language="C#" EnableViewState="false" %>
<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Expensive Stored Proc</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    
</head>
<body>
 <form id="form1" runat="server">        
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="

-- Top Cached SPs By Total Logical Reads (SQL 2008 only). 
-- Logical reads relate to memory pressure 
SELECT TOP ( 25 ) 
 p.name AS [SP Name] , 
 deps.total_logical_reads AS [TotalLogicalReads] , 
 deps.total_logical_reads / deps.execution_count AS [AvgLogicalReads] , 
 deps.total_logical_writes / deps.execution_count AS [AvgLogicalWrites] , 
 deps.execution_count , 
 ISNULL(deps.execution_count / DATEDIFF(Second, deps.cached_time, 
 GETDATE()), 0) AS [Calls/Second] , 
 deps.total_elapsed_time , 
 deps.total_elapsed_time / deps.execution_count AS [avg_elapsed_time] , 
 deps.cached_time 
FROM sys.procedures AS p 
 INNER JOIN sys.dm_exec_procedure_stats 
 AS deps ON p.[object_id] = deps.[object_id] 
WHERE deps.database_id = DB_ID() 
ORDER BY deps.total_logical_reads DESC ;
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            
                        </asp:TemplateField>
                    </Columns>                    
                </asp:GridView>            
    </form>
        <script>
            var refreshtimer = window.setTimeout(function () { window.location.reload(); }, 15000);

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
</body>
    
</html>
