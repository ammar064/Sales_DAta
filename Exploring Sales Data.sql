
-----Inspecting Data--------
use [Sales2];


Select* from [dbo].[sales_data_sample];

-----checking unique values------

Select distinct STATUS from [dbo].[sales_data_sample];---usefull to dashbord
Select distinct YEAR_ID  from [dbo].[sales_data_sample];---usefull to dashbord
Select distinct  PRODUCTLINE from  [dbo].[sales_data_sample];---usefull to dashbord
Select distinct COUNTRY from [dbo].[sales_data_sample];---usefull to dashbord
Select distinct DEALSIZE STATUS from [dbo].[sales_data_sample];---usefull to dashbord
Select distinct TERRITORY STATUS from [dbo].[sales_data_sample];---usefull to dashbord



------Analysis
-----1.grouping by Sales by PRODUCTLINE

Select PRODUCTLINE,ROUND(SUM(SALES),0)  as Revenue
from [dbo].[sales_data_sample]
Group by PRODUCTLINE 
order by 2 desc;



-----2.grouping by Sales by Year

Select YEAR_ID,ROUND(SUM(SALES),0) as Revenue
from [dbo].[sales_data_sample]
Group by YEAR_ID 
order by 2 desc;


-----3.grouping by Sales by DEALSIZE

Select DEALSIZE,ROUND(SUM(SALES),0) as Revenue
from [dbo].[sales_data_sample]
Group by DEALSIZE 
order by 2 desc;

-----4.grouping by Sales by COUNTRY

Select COUNTRY,ROUND(SUM(SALES),0) as Revenue
from [dbo].[sales_data_sample]
Group by COUNTRY 
order by 2 desc;


----5.which month we have  the best of Sales 

Select YEAR_ID, MONTH_ID,ROUND(SUM(SALES),0) as Revenue,COUNT(ORDERLINENUMBER) as NumberOfOrder 
from [dbo].[sales_data_sample]
Group by YEAR_ID , MONTH_ID
order by 3 desc;


-----6.what is the most product selling in November ?

Select YEAR_ID, MONTH_ID,PRODUCTLINE,ROUND(SUM(SALES),0) as Revenue,COUNT(PRODUCTLINE) as NumberOfOrder 
from [dbo].[sales_data_sample]
where MONTH_ID =11
Group by YEAR_ID , MONTH_ID ,PRODUCTLINE
order by 4 desc;

-------Who is the best Customer ?


----creat tem table

Drop table if EXISTS #rfm

;with rfm as 
(
	Select CUSTOMERNAME,
		   ROUND(SUM(SALES),0)as MonetaryValue,
		   ROUND(avg(SALES),0) as SalesAvrage,
		   COUNT(ORDERLINENUMBER)as NumberOFOrder ,
		   MAX(ORDERDATE) as LastOrder,
		   (select max(ORDERDATE)from [dbo].[sales_data_sample] ) as MaxDate,
		   DATEDIFF (DD,MAX(ORDERDATE),(select max(ORDERDATE)from [dbo].[sales_data_sample] )) Receny


	From [dbo].[sales_data_sample]
	group by CUSTOMERNAME

),
rfm_calc as
(
	select r.*,
		NTILE (4) Over (order by Receny desc) as rfm_Receny,
		NTILE (4) Over ( order by MonetaryValue)as rfm_MonetaryValue,
		NTILE (4) Over ( order by NumberOFOrder) as rfm_NumberOFOrder
	from rfm r
)
Select c.*,rfm_Receny+rfm_MonetaryValue+rfm_NumberOFOrder as rfm_call,
	cast (rfm_Receny as varchar)+cast(rfm_MonetaryValue as varchar)+cast(rfm_NumberOFOrder as varchar) as rfm_call_string
	into #rfm
 from rfm_calc as c




 Select *
 from #rfm


----Now we can create Category to Custmer

select CUSTOMERNAME,rfm_Receny,rfm_MonetaryValue,rfm_NumberOFOrder,rfm_call_string , 
	case 
		when rfm_call_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_call_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) 
		when rfm_call_string in (311, 411, 331) then 'new customers'
		when rfm_call_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_call_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often  but at low price points)
		when rfm_call_string in (433, 434, 443, 444) then 'loyal'
	end rfm_Category

from #rfm

