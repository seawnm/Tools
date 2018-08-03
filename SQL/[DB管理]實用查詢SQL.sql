--可以列出指定的SP內容
sp_helptext 'sp_FTP_Check_Abnormal'

--可以列出目前DB的所有object資訊
sp_help

--可以列出table或view的詳細資料
sp_help 'DataCheck_Items'

--可以列出sp帶入的參數值
sp_help 'sp_FTP_to_Standard_Loan'

--可以列出會用到這張table,view的地方
sp_depends 'FTP_Deposit_Result'

--可以列出這個sp會用到的object名細
sp_depends 'sp_FTP_Pricing_Deposit'