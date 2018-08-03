
--/*
DEL_loop:
	
delete top (2000000)  
--select *
from CheckResult_DepositStandard
--where data_date<='20161231'
--group by acc_date order by acc_date


IF @@ROWCOUNT <> 0 
	goto DEL_loop

--*/


