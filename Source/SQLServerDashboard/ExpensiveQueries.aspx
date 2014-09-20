<%@ Page Language="C#" EnableViewState="false" %>
<%@ OutputCache NoStore="true" Location="None" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE9" />
    <title>Expensive Queries</title>
    <link href="css/bootstrap.min.css" rel="stylesheet" />
    <link href="css/bootstrap-theme.min.css" rel="stylesheet" />    
    <style>
        td.large-cell {
            padding: 0px;
            margin: 0px;
            table-layout:fixed;
        }

        td.large-cell div {
            height: 80px;
            overflow-y: auto;
            cursor: hand;
            cursor: pointer                
        }
    </style>

</head>
<body>
        <form id="form1" runat="server">        
                <asp:SqlDataSource ID="sqlDataSource" runat="server"  ProviderName="System.Data.SqlClient" SelectCommand="
/*
SELECT TOP 5 
 total_worker_time , 
 execution_count , 
 total_worker_time / execution_count AS [Avg CPU Time] , 
                    deqs.last_logical_reads as [Logical Read],
                    deqs.last_physical_reads as [Physical Read],                                        
 CASE WHEN deqs.statement_start_offset = 0 
 AND deqs.statement_end_offset = -1 
 THEN '-- see objectText column--' 
 ELSE --'-- query --' + CHAR(13) + CHAR(10) +
  
                    SUBSTRING(execText.text, deqs.statement_start_offset / 2, 
 ( ( CASE WHEN deqs.statement_end_offset = -1 
 THEN DATALENGTH(execText.text) 
 ELSE deqs.statement_end_offset 
 END ) - deqs.statement_start_offset ) / 2) 
 END AS queryText,
                    deqs.last_logical_reads, deqs.min_logical_reads, deqs.max_logical_reads,
                    deqs.last_logical_writes, deqs.min_logical_writes, deqs.max_logical_writes,
                    deqs.last_physical_reads, deqs.min_physical_reads, deqs.max_physical_reads,
                    deqs.total_elapsed_time, deqs.last_elapsed_time, deqs.min_elapsed_time, 
                    deqs.max_elapsed_time
FROM sys.dm_exec_query_stats deqs 
                    
 CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText 
ORDER BY deqs.total_worker_time DESC ; 
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;

declare @result table 
(
		--QueryPlan xml,
		ExpensivePredicate nvarchar(max),			
		EstimateCPU nvarchar(30),				
		EstimatedRows float,
		PhysicalOp nvarchar(30),
		LogicalOp nvarchar(30),
		EstimateIO nvarchar(30),		
        PlanHandle varbinary(100),
        [Statement] nvarchar(max),
        OptimizationLevel nvarchar(30),
        SubTreeCost float,
        UseCounts int, 
        SizeInBytes int
);

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
core AS (
        SELECT
                --eqp.query_plan AS [QueryPlan],				
                ecp.plan_handle [PlanHandle],
                q.[Text] AS [Statement],				
				t.value('(@ScalarString)[1]', 'nvarchar(1024)') ExpensivePredicate,
				ISNULL(CAST(r.value('(@EstimateRows)[1]', 'VARCHAR(128)') as float),0) as EstimatedRows,				
				r.value('(@PhysicalOp)[1]', 'nvarchar(30)') PhysicalOp,
				r.value('(@LogicalOp)[1]', 'nvarchar(30)') LogicalOp,
				r.value('(@EstimateIO)[1]', 'nvarchar(30)') EstimateIO,
				r.value('(@EstimateCPU)[1]', 'nvarchar(30)') EstimateCPU,
				n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS OptimizationLevel ,
                ISNULL(CAST(n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') as float),0) AS SubTreeCost ,
                ecp.usecounts [UseCounts],
                ecp.size_in_bytes [SizeInBytes]
        FROM
                sys.dm_exec_cached_plans AS ecp
                CROSS APPLY sys.dm_exec_query_plan(ecp.plan_handle) AS eqp
                CROSS APPLY sys.dm_exec_sql_text(ecp.plan_handle) AS q
                CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn ( n )
				CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan//RelOp[@PhysicalOp=&quot;Table Scan&quot;]/TableScan/Predicate/ScalarOperator') AS qt ( t )
				CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan//RelOp[@EstimateCPU = max(/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan//RelOp/@EstimateCPU)]') AS qr ( r )
		WHERE 
			UseCounts > 10
)
insert @result
SELECT TOP 50        
		--QueryPlan,
		ExpensivePredicate,			
		EstimateCPU,				
		EstimatedRows,
		PhysicalOp,
		LogicalOp,
		EstimateIO,		
        PlanHandle,
        [Statement],
        OptimizationLevel,
        SubTreeCost,
        UseCounts,        
        SizeInBytes
FROM
        core
WHERE SubTreeCost > 1
order by EstimatedRows DESC

SELECT 
		ExpensivePredicate,			
		max(EstimateCPU) as EstimateCPU,				
		max(EstimatedRows) as EstimatedRows,
		max(PhysicalOp) as PhysicalOp,
		max(LogicalOp) as LogicalOp,
		max(EstimateIO) as EstimateIO,		
        max(PlanHandle) as PlanHandle,
        max([Statement]) as [Statement],
        max(OptimizationLevel) as OptimizationLevel,
        max(SubTreeCost) as SubTreeCost,
        max(UseCounts) as UseCounts,
        round(max(SubTreeCost) * max(UseCounts),3) [GrossCost],
        max(SizeInBytes) as SizeInBytes
	FROM @result
	group by ExpensivePredicate
	order by EstimatedRows DESC


                                       
                    "></asp:SqlDataSource>
                <asp:GridView CssClass="table table-striped" ID="GridView1" runat="server" DataSourceID="sqlDataSource" EnableModelValidation="True">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%--<%# Convert.ToInt32(Eval("Avg CPU Time")) > 5000 ? "<span class='label label-warning'>High CPU</span>" : "" %>                                
                                <%# Convert.ToInt32(Eval("max_logical_reads")) > 5000 ? "<span class='label label-warning'>High Logical Read</span>" : "" %>                                
                                <%# Convert.ToInt32(Eval("max_physical_reads")) > 1000 ? "<span class='label label-warning'>High Physical Read</span>" : "" %>                                
                                <%# Convert.ToInt32(Eval("max_logical_writes")) > 5000 ? "<span class='label label-warning'>High Logical Write</span>" : "" %>                                                                
                                --%>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>              
                    <EmptyDataTemplate>
                        No data found.
                    </EmptyDataTemplate>
                          
                </asp:GridView>            
    </form>
</body>
    <script src="js/jquery-1.11.1.min.js"></script>
    <script>
        
        $('tr').each(function (i, tr) {
            var td = $('td:eq(7)', tr);
            td.html('<div>' + td.html() + '</div>');
            td.addClass('large-cell');
            td.find('div').click(function () {
                alert($(this).text())
            });
        });
        
    </script>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            sqlDataSource.ConnectionString = ConfigurationManager.ConnectionStrings[Request["c"]].ConnectionString;
        }
    </script>
</html>
