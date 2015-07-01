<%@ Page Language="C#" EnableViewState="false"%>
<%@ OutputCache NoStore="true" Location="None" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Summary</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />
    <script src="js/jquery-1.11.1.min.js"></script>
    <style>
        table.table_noborder {
            border: none;            
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">               
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="

SELECT 'Block' as Name, (select 
   nvl(sum(seconds_in_wait),0)
from 
   v$session
where 
   blocking_session is not NULL) as Value from Dual

union all

select 'Locks' as Name, (select	count(1)
from 	v$session sn, 
	v$lock m	
where 	
 	((sn.SID = m.SID and m.REQUEST != 0) 
or 	(sn.SID = m.SID and m.REQUEST = 0 and LMODE != 4 and (ID1, ID2) in
        (select s.ID1, s.ID2 
         from 	v$lock S 
         where 	REQUEST != 0 
         and 	s.ID1 = m.ID1 
         and 	s.ID2 = m.ID2)))) as Value FROM Dual

union all

select 'Waits' as Name, (select count(1) FROM v$session_wait w, v$session s, dba_objects o WHERE  s.sid = w.sid AND w.p2 = o.object_id) as Value from Dual

union all

select 'Long op (sec rem)' as Name, (SELECT 
       nvl(sum(time_remaining),0) 
  FROM v$session_longops sl
INNER JOIN v$session s ON sl.SID = s.SID AND sl.SERIAL# = s.SERIAL#
WHERE time_remaining > 0) as Value FROM Dual

union all

select 'CPU' as Name, (
    with AASSTAT as (
      select
      decode(n.wait_class,'User I/O','User I/O',
      'Commit','Commit',
      'Wait') CLASS,
      sum(round(m.time_waited/m.INTSIZE_CSEC,3)) AAS,
      BEGIN_TIME ,
      END_TIME
      from v$waitclassmetric m,
      v$system_wait_class n
      where m.wait_class_id=n.wait_class_id
      and n.wait_class != 'Idle'
      group by decode(n.wait_class,'User I/O','User I/O', 'Commit','Commit', 'Wait'), BEGIN_TIME, END_TIME
      union
      select 'CPU_ORA_CONSUMED' CLASS,
      round(value/100,3) AAS,
      BEGIN_TIME ,
      END_TIME
      from v$sysmetric
      where metric_name='CPU Usage Per Sec'
      and group_id=2
      union
      select 'CPU_OS' CLASS ,
      round((prcnt.busy*parameter.cpu_count)/100,3) AAS,
      BEGIN_TIME ,
      END_TIME
      from
      ( select value busy, BEGIN_TIME,END_TIME from v$sysmetric where metric_name='Host CPU Utilization (%)' and group_id=2 ) prcnt,
      ( select value cpu_count from v$parameter where name='cpu_count' ) parameter
      union
      select
      'CPU_ORA_DEMAND' CLASS,
      nvl(round( sum(decode(session_state,'ON CPU',1,0))/60,2),0) AAS,
      cast(min(SAMPLE_TIME) as date) BEGIN_TIME ,
      cast(max(SAMPLE_TIME) as date) END_TIME
      from v$active_session_history ash
      where SAMPLE_TIME >= (select BEGIN_TIME from v$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2 )
      and SAMPLE_TIME < (select END_TIME from v$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2 )
    )
    select
      round(
        decode(sign(CPU_OS-CPU_ORA_CONSUMED), -1, 0, (CPU_OS - CPU_ORA_CONSUMED )) +
        CPU_ORA_CONSUMED +
        decode(sign(CPU_ORA_DEMAND-CPU_ORA_CONSUMED), -1, 0, (CPU_ORA_DEMAND - CPU_ORA_CONSUMED )) +
        COMMIT +
        READIO +
        WAIT
      , 2)   
      CPU_TOTAL
    from (
    select
      min(BEGIN_TIME) BEGIN_TIME,
      max(END_TIME) END_TIME,
      sum(decode(CLASS,'CPU_ORA_CONSUMED',AAS,0)) CPU_ORA_CONSUMED,
      sum(decode(CLASS,'CPU_ORA_DEMAND' ,AAS,0)) CPU_ORA_DEMAND,
      sum(decode(CLASS,'CPU_OS' ,AAS,0)) CPU_OS,
      sum(decode(CLASS,'Commit' ,AAS,0)) COMMIT,
      sum(decode(CLASS,'User I/O' ,AAS,0)) READIO,
      sum(decode(CLASS,'Wait' ,AAS,0)) WAIT
    from AASSTAT)

)
as Value FROM Dual

UNION ALL
select 'Space' as Name, (
  select count(1) FROM (
  SELECT df.tablespace_name,
         df.file_name,
         df.size_mb,
         f.free_mb,
         df.max_size_mb,
         f.free_mb + (df.max_size_mb - df.size_mb) AS max_free_mb,
         ROUND((df.max_size_mb-(f.free_mb + (df.max_size_mb - df.size_mb)))/max_size_mb,0) AS used_pct
  FROM   (SELECT file_id,
                 file_name,
                 tablespace_name,
                 TRUNC(bytes/1024/1024) AS size_mb,
                 TRUNC(GREATEST(bytes,maxbytes)/1024/1024) AS max_size_mb
          FROM   dba_data_files) df,
         (SELECT TRUNC(SUM(bytes)/1024/1024) AS free_mb,
                 file_id
          FROM dba_free_space
          GROUP BY file_id) f
  WHERE  df.file_id = f.file_id (+)
  ORDER BY df.tablespace_name,
           df.file_name
  ) where USED_PCT > 85) as Value from Dual
  
UNION ALL
  
select 'Invalid Objects' as Name, (SELECT count(1)
FROM   dba_objects
WHERE  status = 'INVALID') as Value FROM Dual
                                        "></asp:SqlDataSource>
            <asp:DataList ID="DataList1" runat="server" RepeatColumns="2" DataSourceID="sqlDataSource" >
                <ItemTemplate>
                    <div style="width:130px; padding-right: 10px">
                        <%# Indicator(Convert.ToString(Eval("Name")), HandleDbNull(Eval("Value"))) %>
                        <span style="margin-left: 5px; padding-right: 5px"><%# Eval("Name") %></span>                        
                        <span style="float:right"><%# Eval("Value") %></span>                        
                    </div>
                </ItemTemplate>
            </asp:DataList>
                <%--<asp:GridView CssClass="table_noborder" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True" BorderStyle="None" ShowHeader="false" CellPadding="4" CellSpacing="0" BorderWidth="0" GridLines="None">
                    <EmptyDataTemplate>
                        No Summary data found.
                    </EmptyDataTemplate>               
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%# Convert.ToString(Eval("Name")) == "CPU" && value) > 80 ? Warning(" ") : Success("") %>
                                <%# Convert.ToString(Eval("Name")) == "Block" && value) > 0 ? Warning(" ") : Success("") %>
                                <%# Convert.ToString(Eval("Name")) == "Locks" && value) > 0 ? Warning(" ") : Success("") %>
                                <%# Convert.ToString(Eval("Name")) == "Long op" && value) > 0 ? Warning(" ") : Success("") %>
                                <%# Convert.ToString(Eval("Name")) == "Space" && value) > 0 ? Warning(" ") : Success("") %>
                                <%# Convert.ToString(Eval("Name")) == "Invalid Objects" && value) > 0 ? Warning(" ") : Success("") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>            --%>
    </form>
</body>
    <script src="js/ScriptsForWidgets.js"></script>
    <script>
        refreshEvery(5000);
    </script>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
        protected float HandleDbNull(object o)
        {
            return Convert.IsDBNull(o) ? 0 : Convert.ToSingle(o);
        }
        protected string Warning(string m)
        {
            return "<span class='label label-warning'>" + m + "</span>";
        }
        protected string Danger(string m)
        {
            return "<span class='label label-danger'>" + m + "</span>";
        }
        protected string Success(string m)
        {
            return "<span class='label label-success'>" + m + "</span>";
        }
        protected string Indicator(string name, float value)
        {
            switch (Convert.ToString(Eval("Name")))
            {
                case "CPU":
                    if (value > 80)
                        return Danger(" ");
                    else if (value > 60)
                        return Warning(" ");
                    else
                        return Success(" ");                    
                case "Block":
                    if (value > 10)
                        return Danger(" ");
                    else if (value > 1)
                        return Warning(" ");                        
                    else
                        return Success(" ");                    
                case "Locks":
                    if (value > 10)
                        return Danger(" ");
                    else if (value > 0)
                        return Warning(" ");
                    else
                        return Success(" ");
                case "Long op (sec rem)":
                    if (value > 30)
                        return Danger(" ");
                    else if (value > 0)
                        return Warning(" ");
                    else
                        return Success(" ");
                    
                case "Space":
                    if (value > 0)
                        return Warning(" ");
                    else
                        return Success(" ");
                    
                case "Invalid Objects":
                    if (value > 0)
                        return Warning(" ");
                    else
                        return Success(" ");                    
            }
            return Success(" ");
        }
    </script>
</html>
