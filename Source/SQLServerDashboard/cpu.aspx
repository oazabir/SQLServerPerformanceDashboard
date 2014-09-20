<%@ Page Language="C#" EnableViewState="false" %>
<%@ OutputCache NoStore="true" Location="None" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>CPU</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <link href="css/basic.css" rel="stylesheet" />
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/jquery.flot.js"></script>   
    <script src="js/jquery.flot.time.min.js"></script>
    <style>
        .demo-container {
            box-sizing: border-box;
            width: 100%;
            height: 200px;
            /*padding: 20px 15px 15px 15px;
            margin: 15px auto 30px auto;*/
            border: 1px solid #ddd;
            background: #fff;
            background: linear-gradient(#f6f6f6 0, #fff 50px);
            background: -o-linear-gradient(#f6f6f6 0, #fff 50px);
            background: -ms-linear-gradient(#f6f6f6 0, #fff 50px);
            background: -moz-linear-gradient(#f6f6f6 0, #fff 50px);
            background: -webkit-linear-gradient(#f6f6f6 0, #fff 50px);
            box-shadow: 0 3px 10px rgba(0,0,0,0.15);
            -o-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
            -ms-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
            -moz-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
            -webkit-box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }

        .demo-placeholder {
            width: 100%;
            height: 100%;
            font-size: 14px;
            line-height: 1.2em;
        }
    </style>
</head>
<body>
     <div class="demo-container">
        <div id="placeholder" class="demo-placeholder"></div>
    </div>
    <form id="form1" runat="server">        
                      
    </form>
</body>
    <script src="js/ScriptsForWidgets.js"></script>
    <script type = "text/javascript">
        var datasets = {
            "Others": {
                label: "User time",
                data: [],
                color: "rgb(200, 100, 100)"
            },
            "SQLServer": {
                label: "Total time",
                data: [],
                color: "rgb(50, 50, 50)"
            }
        };

        function initData(count) {
            var data = [];
            for (var i = 0; i < count; i++)
                data.push(0);
            return data;
        }

        function updatePlot() {
            var index = 0;
            var options = {
                series: {
                    //shadowSize: 0	// Drawing is faster without shadows                    
                },
                lines: { show: true, fill: true},
                grid: {
                    hoverable: true,
                    clickable: true
                },
                yaxis: {
                    min: 0,
                    max: 100
                },
                xaxis: {
                    show: true,
                    mode: "time",
                    timeformat: "%H:%M"
                }
            };

            var data = [];
            $.each(datasets, function (key, val) {
                var items = [];
                for (var i = 0; i < val.data.length; i++)
                    items.push([val.data[i][0], val.data[i][1]]);

                data.push({ label: key, color: val.color, data: items });

                ++index;
            });

            plot = $.plot("#placeholder", data, options);

            $("#placeholder").bind("plothover", function (event, pos, item) {
                var str = "(" + pos.y.toFixed(2) + ")";
                $("#hoverdata").text(str);

                if (item) {
                    var x = item.datapoint[0].toFixed(2),
                        y = item.datapoint[1].toFixed(2);

                    $("#tooltip").html(                        
                        item.series.label + " = " + y)
                        .css({ top: item.pageY + 5, left: item.pageX + 5 })
                        .fadeIn(200);
                } else {
                    $("#tooltip").hide();
                }

            });

            plot.draw();
        }

        function updateChart() {
            $.ajax({
                type: "GET",
                url: "CPU.ashx?c=<%= Request["c"] %>",                
                contentType: "application/json; charset=utf-8",
                dataType: "text",
                success: OnSuccess,
                failure: function (response) {
                    alert(response);
                }
            });
        }

        function OnSuccess(response) {            
            var rows = eval(response);
            //var data = data.data;
            if (rows) {
                for (var set in datasets) {
                    if (datasets[set].data)
                        datasets[set].data = [];
                }
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    var date = row["EventTime"];
                    for (var col in row) {
                        var set = datasets[col];
                        if (set) {
                            set.data.push([date, row[col]]);
                        }
                    }
                }
            }
            //alert(JSON.stringify(datasets, null, 4));
            updatePlot();

            refreshtimer = window.setTimeout(function () {
                updateChart();
            }, 60000);
        }

        $(document).ready(function () {
            $("<div id='tooltip'></div>").css({
                position: "absolute",
                display: "none",
                border: "1px solid #fdd",
                padding: "2px",
                "background-color": "#fee",
                opacity: 0.80
            }).appendTo("body");
        });
</script>
    <script>
        $(document).ready(updateChart);

        document.ondblclick = function () {
            window.clearTimeout(refreshtimer);
        }
    </script>
    <script runat="server">
        [System.Web.Services.WebMethod]
        public static string GetCurrentTime(string name)
        {
            return "Hello " + name + Environment.NewLine + "The Current Time is: "
                + DateTime.Now.ToString();
        }

        [System.Web.Services.WebMethod]
        public static string GetCPUStats(string connectionName)
        {
            connectionName = "InboundQueue";
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[connectionName].ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"
declare @ts_now bigint 
select @ts_now = ms_ticks from sys.dm_os_sys_info 

select top 30 record_id, 
	dateadd (ms, (y.[timestamp] -@ts_now), GETDATE()) as EventTime,
SQLProcessUtilization as SQLServer, 
--SystemIdle, 
100 - SystemIdle - SQLProcessUtilization as Others 
from ( 
select 
record.value('(./Record/@id)[1]', 'int') as record_id,  
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')  
as SystemIdle,  
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]',  
'int') as SQLProcessUtilization,  
timestamp  
from (  
select timestamp, convert(xml, record) as record  
from sys.dm_os_ring_buffers  
where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'  
and record like '%<SystemHealth>%') as x  
) as y  
order by record_id desc

";
                    cmd.CommandType = System.Data.CommandType.Text;

                    StringBuilder buf = new StringBuilder();
                    //using (OracleDataReader dr = cmd.ExecuteReader())
                    //    WriteDataReader(buf, dr);
                    using (SqlDataReader dr1 = cmd.ExecuteReader())
                    {
                        buf.Append("([");
                        while (dr1.Read())
                        {
                            double sqlServer = Convert.ToDouble(dr1["SQLServer"]);
                            double others = Convert.ToDouble(dr1["Others"]);
                            double total = sqlServer + others;
                            buf.Append(string.Format(
                                "{{'Total time':{0}, 'SQLServer': {1}, 'Others': {2}}},",
                                    Convert.ToString(total),
                                    Convert.ToString(sqlServer),
                                    Convert.ToString(others)));    
                        }
                        if (buf[buf.Length - 1] == ',')
                            buf.Remove(buf.Length - 1, 1);
                        buf.Append("])");
                    }                    
                    
                    return buf.ToString();
                }
            }
        }

        private static void WriteDataReader(StringBuilder sb, System.Data.IDataReader reader)
        {
            if (reader == null || reader.FieldCount == 0)
            {
                sb.Append("null");
                return;
            }

            int dataCount = 0;

            sb.Append("({\"data\":[");
            sb.Append(Environment.NewLine);

            while (reader.Read())
            {
                sb.Append("{");

                for (int i = 0; i < reader.FieldCount; i++)
                {
                    sb.Append("\"" + reader.GetName(i) + "\":");
                    //WriteValue(sb, reader[i]);
                    object val = reader[i];
                    double d;
                    DateTime dt;
                    if (val == null || Convert.IsDBNull(val))
                        sb.Append("null");
                    else if (Double.TryParse(Convert.ToString(val), System.Globalization.NumberStyles.Any, System.Globalization.NumberFormatInfo.InvariantInfo, out d))
                        sb.Append(Convert.ToString(val));
                    //else if (DateTime.TryParse(Convert.ToString(val), System.Globalization.DateTimeFormatInfo.InvariantInfo, System.Globalization.DateTimeStyles.None, out dt))
                    //    sb.Append("/Date(" + dt.Ticks.ToString() + "/");
                    else
                        sb.Append("\"" + Convert.ToString(val) + "\"");
                    
                    sb.Append(",");
                    sb.Append(Environment.NewLine);
                }
                // strip off trailing comma
                if (reader.FieldCount > 0)
                    if (sb[sb.Length - 1 - Environment.NewLine.Length] == ',')
                        sb.Remove(sb.Length - 1 - Environment.NewLine.Length, 1);

                sb.Append("},");
                sb.Append(Environment.NewLine);

                dataCount++;
            }

            // remove trailing comma
            if (dataCount > 0)
                if (sb[sb.Length - 1 - Environment.NewLine.Length] == ',')
                    sb.Remove(sb.Length - 1 - Environment.NewLine.Length, 1);

            sb.Append("]})");
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            //sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
