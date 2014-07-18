<%@ Page Language="C#"  %>
<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SQL Server Health Monitor</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <link href="css/basic.css" rel="stylesheet" />
    <link href="css/dashboard.css" rel="Stylesheet" />
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.simplemodal.js"></script>
    <script src="js/jquery.flot.js"></script>    
    <script type="text/javascript" src="js/Dashboard.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="navbar navbar-inverse" role="navigation">
            <div class="container">
                <div class="navbar-collapse collapse">
                    <ul class="nav navbar-nav">
                        <li class="active"><a href="#">SQL Server Performance Dashboard</a></li>
                        <li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown">Servers <span class="caret"></span></a>
                            <ul class="dropdown-menu" role="menu">                                
                                <asp:Repeater ID="ConnectionStrings" runat="server">
                                    <ItemTemplate>
                                        <li><a href="?c=<%# Eval("Name") %>"><%# Eval("Name") %></a></li>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ul>
                        </li>
                    </ul>
                </div>                
            </div>
        </div>

        <div class="container">
            <h1><%= ConnectionString %></h1>

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
                        <div class="panel-body panel-body-height" >
                            <div class="demo-container">
                                <div id="placeholder2" class="demo-placeholder"></div>
                            </div>
                        </div>   
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="panel panel-success">
                        <div class="panel-heading">SQL Compilations/sec</div>
                        <div class="panel-body panel-body-height" >
                            <div class="demo-container">
                                <div id="placeholder3" class="demo-placeholder"></div>
                            </div>
                        </div>   
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="panel panel-success">
                        <div class="panel-heading">Total Latch Wait Time (ms)</div>
                        <div class="panel-body panel-body-height" >
                            <div class="demo-container">
                                <div id="placeholder4" class="demo-placeholder"></div>
                            </div>
                        </div>   
                    </div>
                </div>
            </div>


            <div class="row">
                <div class="panel panel-success">
                    <div class="panel-heading"><a href="WhoIsActive.aspx?c=<%= ConnectionString %>">What's going on</a></div>
                    <div class="panel-body panel-body-height" id="WhoIsActive">
                        <div class="progress">
                            <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                        </div>
                    </div>
                    <iframe class="content_loader" onload="setContent(this, 'WhoIsActive')" src="WhoIsActive.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
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
                        <div class="panel-heading"><a href="Sessions.aspx?c=<%= ConnectionString %>">Sessions</a></div>
                        <div class="panel-body panel-body-height" id="Sessions">
                            <div class="progress">
                                <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                            </div>
                        </div>
                        <iframe class="content_loader" onload="setContent(this, 'Sessions')" src="Sessions.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="panel panel-success">
                        <div class="panel-heading"><a href="Blocks.aspx?c=<%= ConnectionString %>">Blocks</a></div>
                        <div class="panel-body panel-body-height" id="Blocks">
                            <div class="progress">
                                <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                            </div>
                        </div>
                        <iframe class="content_loader" onload="setContent(this, 'Blocks')" src="Blocks.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-success">
                        <div class="panel-heading"><a href="ExpensiveQueries.aspx?c=<%= ConnectionString %>">Most Expensive Queries</a></div>
                        <div class="panel-body panel-body-height" id="ExpensiveQueries">
                            <div class="progress">
                                <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                            </div>
                        </div>
                        <iframe class="content_loader" onload="setContent(this, 'ExpensiveQueries')" src="ExpensiveQueries.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="panel panel-success">
                        <div class="panel-heading"><a href="ExpensiveStoredProc.aspx?c=<%= ConnectionString %>">Expensive Stored Proc</a></div>
                        <div class="panel-body panel-body-height" id="ExpensiveStoredProc">
                            <div class="progress">
                                <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                            </div>
                        </div>
                        <iframe class="content_loader" onload="setContent(this, 'ExpensiveStoredProc')" src="ExpensiveStoredProc.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-success">
                        <div class="panel-heading"><a href="DatabaseFiles.aspx?c=<%= ConnectionString %>">Database files</a></div>
                        <div class="panel-body panel-body-height" id="DatabaseFiles">
                            <div class="progress">
                                <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                            </div>
                        </div>
                        <iframe class="content_loader" onload="setContent(this, 'DatabaseFiles')" src="DatabaseFiles.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
                    </div>
                </div>

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

            <div class="row">
                
                <div class="col-md-6">
                    <div class="panel panel-success">
                        <div class="panel-heading"><a href="InactiveSessions.aspx?c=<%= ConnectionString %>">Inactive Sessions</a></div>
                        <div class="panel-body panel-body-height" id="InactiveSessions">
                            <iframe src="InactiveSessions.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none;" frameborder="0"></iframe>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </form>

    <div id="basic-modal-content">
        <pre id="content_text" >

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
        protected void Page_Load(object sender, EventArgs e)
        {
            ConnectionStrings.DataSource = ConfigurationManager.ConnectionStrings;
            ConnectionStrings.DataBind();          
        }
    </script>

    

</body>
</html>
