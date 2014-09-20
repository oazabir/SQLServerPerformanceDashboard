using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web;

namespace SQLServerDashboard
{
    /// <summary>
    /// Summary description for CPU
    /// </summary>
    public class CPU : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            string connectionName = context.Request["c"];
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
                                "{{'Total time':{0}, 'SQLServer': {1}, 'Others': {2}, 'EventTime': {3}}},",
                                    Convert.ToString(total),
                                    Convert.ToString(sqlServer),
                                    Convert.ToString(others),
                                    Convert.ToDateTime(dr1["EventTime"]).Ticks/10000));
                        }
                        if (buf[buf.Length - 1] == ',')
                            buf.Remove(buf.Length - 1, 1);
                        buf.Append("])");
                    }

                    context.Response.ContentType = "application/json";
                    context.Response.Write(buf.ToString());
                }
            }
            
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}