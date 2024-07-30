USE [msdb]
GO

/****** Object:  Operator [SQL Support Notifications]    Script Date: 5/24/2022 6:17:00 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'SQL Support Notifications', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'noc@bluebookservices.com', 
		@category_name=N'[Uncategorized]'
GO

