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
                    DECLARE @PERF_COUNTER_BULK_COUNT INT 
SELECT @PERF_COUNTER_BULK_COUNT = 272696576 

--Holds initial state 
DECLARE @baseline TABLE 
   ( 
      object_name NVARCHAR(256) , 
      counter_name NVARCHAR(256) , 
      instance_name NVARCHAR(256) , 
      cntr_value BIGINT , 
      cntr_type INT , 
      time DATETIME DEFAULT ( GETDATE() ) 
   ) 
   
DECLARE @current TABLE 
   ( 
      object_name NVARCHAR(256) , 
      counter_name NVARCHAR(256) , 
      instance_name NVARCHAR(256) , 
      cntr_value BIGINT , 
      cntr_type INT , 
      time DATETIME DEFAULT ( GETDATE() ) 
   ) 

--capture the initial state of bulk counters 
INSERT INTO @baseline 
   ( object_name , 
     counter_name , 
     instance_name , 
     cntr_value , 
     cntr_type 
   ) 
   SELECT object_name , 
          counter_name , 
          instance_name , 
          cntr_value , 
          cntr_type 
   FROM sys.dm_os_performance_counters AS dopc 
   WHERE cntr_type = @PERF_COUNTER_BULK_COUNT 

WAITFOR DELAY '00:00:01' --the code will work regardless of delay chosen

--get the followon state of the counters 
INSERT INTO @current 
   ( object_name , 
     counter_name , 
     instance_name , 
     cntr_value , 
     cntr_type 
   ) 
   SELECT object_name , 
          counter_name , 
          instance_name , 
          cntr_value , 
          cntr_type 
   FROM sys.dm_os_performance_counters AS dopc 
   WHERE cntr_type = @PERF_COUNTER_BULK_COUNT 

SELECT --dopc.object_name , 
       dopc.instance_name , 
       ltrim(rtrim(dopc.counter_name)) as counter_name, 
       --ms to second conversion factor 
       ROUND(1000 * 
       --current value less the previous value 
   ( ( dopc.cntr_value - prev_dopc.cntr_value ) 
       --divided by the number of milliseconds that pass 
       --casted as float to get fractional results. Float 
       --lets really big or really small numbers to work 
       / CAST(DATEDIFF(ms, prev_dopc.time, dopc.time) AS FLOAT) ), 2)
                                                 AS cntr_value 
       --simply join on the names of the counters 
FROM @current AS dopc 
     JOIN @baseline AS prev_dopc ON prev_dopc. object_name = 
dopc. object_name 
                       AND prev_dopc.instance_name = dopc.instance_name
                       AND prev_dopc.counter_name = dopc.counter_name 
WHERE dopc.cntr_type = @PERF_COUNTER_BULK_COUNT 
      AND 1000 * ( ( dopc.cntr_value - prev_dopc.cntr_value ) 
                   /  CAST( DATEDIFF(ms, prev_dopc. time, dopc. time)  AS FLOAT) ) 
 /* default to only showing non-zero values */ <> 0 
 and ltrim(rtrim(dopc.counter_name)) in (
 'Connection Reset/sec',
'Logins/sec',
'Total Latch Wait Time (ms)',
'Lock Requests/sec',
'Lock Timeouts/sec',
'Lock Wait Time (ms)',
'Lock Waits/sec',
'Lock Requests/sec',
'Errors/sec',
'Batch Requests/sec',
'SQL Compilations/sec',
'Log Bytes Flushed/sec',
'Log Flush Waits/sec',
'Log Flushes/sec',
'Range Scans/sec',
'Index Searches/sec',
'Full Scans/sec'
 )
ORDER BY dopc.instance_name, dopc.counter_name --, dopc.object_name
                    
                    "></asp:SqlDataSource>
                <div class="alert alert-warning" role="alert" id="warnings">
                    <strong>Warning!</strong> 
                    <table id="warning_table"></table>
                </div>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%# Convert.ToString(Eval("counter_name")).Trim() == "Errors/sec" && Convert.ToSingle(Eval("cntr_value")) > 1 ? "<span class='label label-warning'>High Errors/Sec</span>" : "" %>
                                <%# Convert.ToString(Eval("counter_name")).Trim() == "Lock Waits/sec" && Convert.ToSingle(Eval("cntr_value")) > 1 ? "<span class='label label-warning'>Lock Waits/sec</span>" : "" %>
                                <%# Convert.ToString(Eval("counter_name")).Trim() == "Total Latch Wait Time (ms)" && Convert.ToSingle(Eval("cntr_value")) > 1000 ? "<span class='label label-warning'>High Total Latch Wait</span>" : "" %>                                
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>                    
                </asp:GridView>           
                
    </form>
</body>
<script src="js/jquery-1.11.1.min.js"></script>
    <script>
        var refreshtimer = window.setTimeout(function () { window.location.reload(); }, 5000);

        document.ondblclick = function () {
            window.clearTimeout(refreshtimer);
        }

        if ($('span.label-warning').length > 0) {
            $('span.label-warning').parents('tr').appendTo('#warning_table');
            $('#warnings').show();
        }
        else {
            $('#warnings').hide();
        }

        var plot = ["Batch Requests/sec", "Full Scans/sec", "SQL Compilations/sec", "Total Latch Wait Time (ms)"];
        $('td').each(function (i, e) {
            td = $(e);
            if (td.text().trim().length > 0) {
                for (var i = 0; i < plot.length; i ++) {
                    if (plot[i] == td.text().trim()) {
                        if (td.prev().text() == "_Total" || td.prev().text().trim().length == 0) {
                            td.addClass("x-axis");
                            td.next().addClass("y-axis");
                        }
                    }
                }
            }
        })

    </script>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
