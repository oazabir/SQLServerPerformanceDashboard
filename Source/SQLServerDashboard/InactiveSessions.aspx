<%@ Page Language="C#" EnableViewState="false" %>
<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Inactive Sessions</title>
</head>
<body>
        <form id="form1" runat="server">        
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="

DECLARE @days_old SMALLINT 
SELECT @days_old = 1 
 
SELECT des.session_id , 
DATEDIFF(dd, des.last_request_end_time, GETDATE()) as days,
 des.login_time , 
 des.last_request_start_time , 
 des.last_request_end_time , 
 des.[status] , 
 des.[program_name] , 
 des.cpu_time , 
 des.total_elapsed_time , 
 des.memory_usage , 
 des.total_scheduled_time , 
 des.total_elapsed_time , 
 des.reads , 
 des.writes , 
 des.logical_reads , 
 des.row_count , 
 des.is_user_process 
FROM sys.dm_exec_sessions des 
 INNER JOIN sys.dm_tran_session_transactions dtst 
 ON des.session_id = dtst.session_id 
WHERE des.is_user_process = 1 
 AND DATEDIFF(dd, des.last_request_end_time, GETDATE()) > @days_old 
 AND des.status != 'Running' 
ORDER BY des.last_request_end_time
                    
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>         
                    <EmptyDataTemplate>
                        No inactive sessions older than 1 day.
                    </EmptyDataTemplate>           
                </asp:GridView>            
    </form>
</body>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
