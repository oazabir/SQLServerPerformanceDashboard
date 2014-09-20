<%@ Page Language="C#"  %>
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
    <script type="text/javascript" src="js/Dashboard.js"></script>
    
    <style>
        body { padding: 20px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">         
        <!-- Sessions -->
        <div class="row">
            <div class="panel panel-success">
                <div class="panel-heading"><a target="_top" href="Sessions.aspx?c=<%= ConnectionString %>">All Sessions</a></div>
                <div class="panel-body panel-body-height-large" id="Sessions">
                    <div class="progress">
                        <div class="progress-bar progress-bar-striped" style="width: 60%"><span class="sr-only">100% Complete</span></div>
                    </div>
                </div>
                <iframe class="content_loader" onload="setContent(this, 'Sessions')" src="Sessions.aspx?c=<%= ConnectionString %>" style="width: 100%; height: 100%; border: none; display: none" frameborder="0"></iframe>
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
    </script>

    

</body>
</html>
