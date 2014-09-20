<%@ Page Language="C#" EnableViewState="false" %>
<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Sessions</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />    
</head>
<body>
    <form id="form1" runat="server">        
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="
                    
                    SELECT dec.client_net_address as IP, des.host_name as Host, COUNT(dec.session_id) AS Connections, des.program_name as Program FROM sys.dm_exec_sessions AS des INNER JOIN sys.dm_exec_connections AS dec ON des.session_id = dec.session_id GROUP BY dec.client_net_address, des.program_name, des.host_name ORDER BY Connections desc
                    
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%#Convert.ToInt32(Eval("Connections"))>Convert.ToInt32(ConfigurationManager.AppSettings["Warn above connection number"]) ? "<span class='label label-warning'>High connections</span>" : ""%>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>                    
                </asp:GridView>
    </form>
</body>
    <script>
        var refreshtimer = window.setTimeout(function () { window.location.reload(); }, 10000);

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
