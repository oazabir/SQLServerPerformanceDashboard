<%@ Page Language="C#" %>

<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>CPU Monitor</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <link href="css/basic.css" rel="stylesheet" />
    <link href="css/dashboard.css" rel="Stylesheet" />
    <script>
        function setContent() { }
    </script>
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.simplemodal.js"></script>
    <script src="js/jquery.flot.js"></script>
    <script src="js/jquery.flot.baseline.js"></script>
    <script type="text/javascript" src="js/Dashboard.js"></script>
    <style>
        body {
            padding: 10px;
        }
    </style>
    <script type="text/javascript">
        var datasets = {
            "Batch Requests/sec": {
                label: "Batch Requests/sec",
                data: initData(30),
                color: 0,
                ymax: 1000
            },
            "Full Scans/sec": {
                label: "Full Scans/sec",
                data: initData(30),
                color: 1,
                ymax: 100
            },
            "SQL Compilations/sec": {
                label: "SQL Compilations/sec",
                data: initData(30),
                color: 2,
                ymax: 100
            },
            "Total Latch Wait Time (ms)": {
                label: "Total Latch Wait Time (ms)",
                data: initData(30),
                color: 3,
                ymax: 3000
            },
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">

        <div class="row">
            <div class="col-md-3">
                <div class="panel panel-success">
                    <div class="panel-heading">Batch Requests/sec</div>
                    <div class="panel-body panel-body-height">
                        <div class="demo-container">
                            <div id="placeholder1" class="demo-placeholder"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="panel panel-success">
                    <div class="panel-heading">Full Scans/sec</div>
                    <div class="panel-body panel-body-height">
                        <div class="demo-container">
                            <div id="placeholder2" class="demo-placeholder"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="panel panel-success">
                    <div class="panel-heading">SQL Compilations/sec</div>
                    <div class="panel-body panel-body-height">
                        <div class="demo-container">
                            <div id="placeholder3" class="demo-placeholder"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="panel panel-success">
                    <div class="panel-heading">Total Latch Wait Time (ms)</div>
                    <div class="panel-body panel-body-height">
                        <div class="demo-container">
                            <div id="placeholder4" class="demo-placeholder"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <div class="row">
            <div class="panel panel-success">
                <div class="panel-heading"><a href="CurrentSessions.aspx?c=<%= ConnectionString %>">What's going on</a></div>
                <div class="panel-body panel-body-height" id="WhoIsActive">
                    <div class="progress">
                        <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                    </div>
                </div>
                <iframe class="content_loader" onload="setContent(this, 'WhoIsActive')" src="CurrentSessions.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
            </div>
        </div>

        <div class="row">
            <div class="panel panel-success">
                <div class="panel-heading"><a href="Processes.aspx?c=<%= ConnectionString %>">Processes</a></div>
                <div class="panel-body panel-body-height" id="Processes">
                    <div class="progress">
                        <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                    </div>
                </div>
                <iframe class="content_loader" onload="setContent(this, 'Processes')" src="Processes.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
            </div>
        </div>


        <div class="row">
            <div class="col-md-6">
                <div class="panel panel-success">
                    <div class="panel-heading"><a href="PerformanceCounters.aspx?c=<%= ConnectionString %>">Performance Counters</a></div>
                    <div class="panel-body panel-body-height" id="PerformanceCounters">
                        <div class="progress">
                            <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                        </div>
                    </div>
                    <iframe class="content_loader" onload="setContent(this, 'PerformanceCounters')" src="PerformanceCounters.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
                </div>
            </div>
        </div>
    </form>

    <div id="basic-modal-content">
        <pre id="content_text">

        </pre>
    </div>

    <script runat="server">
        protected string ConnectionString
        {
            get
            {
                return Request["c"] ?? ConfigurationManager.ConnectionStrings[0].Name;
            }
        }       
    </script>



</body>
</html>
