<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false" %>
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

SELECT DB_NAME(mf.database_id) AS databaseName , 
    mf.physical_name , 
    divfs.num_of_reads , 
    divfs.num_of_bytes_read , 
    divfs.io_stall_read_ms , 
    divfs.num_of_writes , 
    divfs.num_of_bytes_written , 
    divfs.io_stall_write_ms , 
    divfs.io_stall , 
    size_on_disk_bytes , 
    GETDATE() AS baselineDate 
INTO #baseline 
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs 
    JOIN sys.master_files AS mf ON mf.database_id = divfs.database_id 
          AND mf.file_id = divfs.file_id

waitfor delay '00:00:01'

;WITH currentLine 
     AS ( SELECT DB_NAME(mf.database_id) AS databaseName ,
           mf.physical_name , 
           num_of_reads , 
           num_of_bytes_read , 
           io_stall_read_ms , 
           num_of_writes , 
           num_of_bytes_written , 
           io_stall_write_ms , 
           io_stall , 
           size_on_disk_bytes , 
           GETDATE() AS currentlineDate 
     FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS divfs 
           JOIN sys.master_files AS mf 
              ON mf.database_id = divfs.database_id 
                 AND mf.file_id = divfs.file_id 
     ) 
  SELECT currentLine.databaseName as DB, 
     LEFT(currentLine.physical_name, 1) AS drive ,  
	 reverse(left(reverse(currentLine.physical_name),
                    charindex('\',reverse(currentLine.physical_name),
                              1) - 1)) as [file], 
     --gets the time diference in milliseconds since 
     -- the baseline was taken 
     --DATEDIFF(millisecond,baseLineDate,currentLineDate) AS elapsed_ms,
       cast(round((ROUND((currentLine.num_of_bytes_read - #baseline.num_of_bytes_read + 0.0)/1048576, 2) / ((currentLine.io_stall_read_ms - #baseline.io_stall_read_ms + 0.0)/1000.0+0.0000001)),2) as decimal(8,2)) as [Read MB/s],
       cast(round((ROUND((currentLine.num_of_bytes_written - #baseline.num_of_bytes_written + 0.0)/1048576, 2) / ((currentLine.io_stall_write_ms - #baseline.io_stall_write_ms + 0.0)/1000.0+0.0000001)),2) as decimal(8,2)) as [Write MB/s],
       currentLine.io_stall - #baseline.io_stall AS io_ms ,
       currentLine.io_stall_read_ms - #baseline.io_stall_read_ms 
                                       AS read_ms ,
       currentLine.io_stall_write_ms - #baseline.io_stall_write_ms 
                                       AS write_ms ,
       currentLine.num_of_reads - #baseline.num_of_reads 
                                       AS reads ,
       currentLine.num_of_bytes_read - #baseline.num_of_bytes_read 
                                       AS bytes_read , 
       currentLine.num_of_writes - #baseline.num_of_writes 
                                       AS writes , 
       currentLine.num_of_bytes_written - #baseline.num_of_bytes_written 
                                       AS bytes_written 
  FROM currentLine 
     INNER JOIN #baseline 
        ON #baseLine.databaseName = currentLine.databaseName 
     AND #baseLine.physical_name = currentLine.physical_name 
  --WHERE #baseline.databaseName = 'DatabaseName'
  order by io_ms desc, DB
drop table #baseline

                    
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%# Convert.ToInt32(Eval("io_ms")) > 1000 ? "<span class='label label-warning'>High IO delay</span>" : "" %>                                
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
