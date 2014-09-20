<%@ Page Language="C#" %>

<%@ OutputCache NoStore="true" Location="None" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Oracle Health Monitor</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <link href="css/basic.css" rel="stylesheet" />
    <link href="css/dashboard.css" rel="Stylesheet" />
    <script src="js/jquery-1.11.1.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/jquery.simplemodal.js"></script>
    <script type="text/javascript" src="js/Dashboard.js"></script>
    <script src="js/jquery.idletimer.js"></script>
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

            <ul id="myTab" class="nav nav-tabs">
                <li class="active"><a id="cpuTab" href="#">Resource</a></li>
                <li><a id="waitsTab" href="#">Waits, Blocks, Locks</a></li>
                <li><a id="historyTab" href="#">Historical</a></li>
            </ul>
            <div class="row">
                <iframe id="cpuIframe" src="CPUTab.aspx?c=<%= ConnectionString %>" class="tab_iframe" scrolling="no" style="visibility:visible"></iframe>
                <iframe id="sessionIframe" src="SessionsTab.aspx?c=<%= ConnectionString %>" class="tab_iframe" scrolling="no"></iframe>
                <iframe id="waitsIframe" src="waitsTab.aspx?c=<%= ConnectionString %>" class="tab_iframe" scrolling="no"></iframe>
                <iframe id="historyIframe" src="HistoryTab.aspx?c=<%= ConnectionString %>" class="tab_iframe" scrolling="no"></iframe>
            </div>     

        </div>
    </form>

    <div id="basic-modal-content">
        <pre id="content_text">

        </pre>
    </div>

    <script type="text/javascript">
        $(document).ready(function () {
            window.setInterval(function () {
                $('iframe.tab_iframe').each(function (i, e) {
                    var frame = $(e);
                    var iframeDoc = e.contentDocument || e.contentWindow.document;

                    // Check if loading is complete
                    if (iframeDoc.readyState == 'complete') {
                        frame.height(frame.contents().height());
                    }
                });
            }, 5000);

            $('#myTab a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
                $(this).blur();
                var id = $(this).attr('id');
                $('iframe.tab_iframe').css('visibility', 'hidden');
                if (id == "cpuTab")
                    $('#cpuIframe').css('visibility', 'visible');
                else if (id == "sessionTab")
                    $('#sessionIframe').css('visibility', 'visible');
                else if (id == "waitsTab")
                    $('#waitsIframe').css('visibility', 'visible');
                else if (id == "historyTab")
                    $('#historyIframe').css('visibility', 'visible');
            });

            $(document).idleTimer(300000);
            $(document).on("idle.idleTimer", function (event, elem, obj) {
                document.location.href = "idle.html";
            });
        });
        
    </script>

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
