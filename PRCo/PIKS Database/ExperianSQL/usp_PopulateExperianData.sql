
create or ALTER     proc  [dbo].[usp_PopulateExperianData] @request_id int, @company_id int,  @audit_record_id int OUTPUT, @debug int = 0
as
begin

-- declare @audit_id int = 0 exec usp_PopulateExperianData 1001 , 1, @audit_id OUTPUT, @debug = 1 select @audit_id as my_audit_record

--exec [usp_BRPopulateExperianData] 1001,1
 --declare @request_id int = 1000, @company_id int = 1

begin try

declare @Experian_exit_code char(1) = 'N' -- this goes into a PRExperianData record

declare @bin varchar(50) -- using a string so it's easier to work with when crafting requests

select @bin = prcex_BIN, @Experian_exit_code = 'R' from PRCompanyExperian where prcex_CompanyID = @company_id

---if @debug = 1  --select @bin as bin, @Experian_exit_code as exit_code   --- this breaks SSRS field population

declare @web_endpoint_auth varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_auth')

declare @web_endpoint_bankruptcies varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_bankruptcies')
declare @web_endpoint_business_facts varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_business_facts')
declare @web_endpoint_judgements varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_judgements')
declare @web_endpoint_liens varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_liens')
declare @web_endpoint_trades varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_trades')
declare @web_endpoint_collections varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'web_endpoint_collections')

declare @Client_id varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'Client_id')
declare @Client_secret varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'Client_secret')
declare @username varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'username')
declare @password varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'password')
declare @subcode varchar(1024) = (select Capt_US from custom_captions where capt_family = 'ExperianIntegration' and capt_code = 'subcode')

if(@debug = 1) select @username, @password

declare @HasPaymentFilingsSummary nchar(1) = 'N',
@HasTaxLienDetails  nchar(1) = 'N',
@HasJudgementDetails nchar(1) = 'N',
@HasTradeContinuous nchar(1) = 'N',
@HasTradeNew nchar(1) = 'N',
@HasTradeAdditional nchar(1) = 'N',
@HasTradeDetails nchar(1) = 'N',
@HasBusinessFacts nchar(1) = 'N'



declare @auth_web_request_body varchar(2000)= '{ "username": "' + @username + '", "password": "' + @password + '"}'
declare @auth_web_request_headers varchar(2000)  = 'Client_id='+ @Client_id + ';Client_secret=' + @Client_secret

--get an authorization token

declare @auth_response varchar(8000)
select @auth_response = dbo.HTTPS_POST_JSON_UTF8(@web_endpoint_auth,@auth_web_request_body,@auth_web_request_headers)

if(isjson(@auth_response)<>1) throw  60000,'JSON PROBLEM WITH AUTH_REPSONSE',1

if @debug = 1
select @auth_response as auth_resp

declare @access_token varchar(1024) = json_value(@auth_response,'$.access_token')

if @debug = 1
select @access_token as access_token

declare @auth_token_header varchar(1024)  = 'Authorization= Bearer ' + @access_token


--pull Business Facts

declare @web_endpoint_business_facts_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_business_facts,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '"}',
	@auth_token_header
	) as json1
	into #business_facts_results

end try
begin catch
	set @web_endpoint_business_facts_success = 0
end catch




if @debug = 1 
select * from #business_facts_results 

select @HasBusinessFacts = 'Y', @Experian_exit_code = 'R'  from #business_facts_results




--pull Judgements

declare @web_endpoint_judgements_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_judgements,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,  "judgmentSummary":true,  "judgmentDetail":true}',
	@auth_token_header
	) as json1
	into #judgements_results

end try
begin catch
	set @web_endpoint_judgements_success = 0
end catch

select @Experian_exit_code = 'R' from #judgements_results 

if @debug = 1
select * from #judgements_results 




--pull Liens

declare @web_endpoint_liens_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_liens,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,    "lienSummary":true,    "lienDetail":true}',
	@auth_token_header
	) as json1
	into #liens_results

end try
begin catch
	set @web_endpoint_liens_success = 0
end catch

if @debug = 1
select * from #liens_results 

select @HasTaxLienDetails = 'Y' , @Experian_exit_code = 'R'  from #liens_results




--pull Trades

declare @web_endpoint_trades_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_trades,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,     "tradePaymentSummary":true,  "tradePaymentTotals":true,  "tradePaymentExperiences":true,  "tradePaymentTrends":true}',
	@auth_token_header
	) as json1
	into #trades_results

end try
begin catch
	set @web_endpoint_trades_success = 0
end catch

select @Experian_exit_code = 'R'  from #trades_results 

if @debug = 1
select * from #trades_results 


--pull Bankruptcies

declare @web_endpoint_bankruptcies_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_bankruptcies,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,  "bankruptcySummary":true,  "bankruptcyDetail":true}',
	@auth_token_header
	) as json1
	into #bankruptcies_results

end try
begin catch
	set @web_endpoint_bankruptcies_success = 0
end catch

select @Experian_exit_code = 'R'  from #bankruptcies_results 

if @debug = 1
select * from #bankruptcies_results 


--pull Collections

declare @web_endpoint_collections_success int = 1

begin try
	select dbo.HTTPS_POST_JSON_UTF8(
	@web_endpoint_collections,
	'{"bin":"' + @bin + '",  "subcode":"' + @subcode + '" ,  "collectionsSummary":true,  "collectionsDetail":true}',
	@auth_token_header
	) as json1
	into #collections_results

end try
begin catch
	set @web_endpoint_collections_success = 0
end catch

select @Experian_exit_code = 'R'   from #collections_results 

if @debug = 1
select * from #collections_results 






--preclean to be able to rerun tests
delete from PRExperianBusinessCode where prexbc_CompanyID = @company_id and prexbc_RequestID = @request_id
delete from PRExperianData where prexd_CompanyID = @company_id and prexd_RequestID = @request_id
delete from PRExperianLegalFiling where prexlf_CompanyID = @company_id and prexlf_RequestID = @request_id
delete from PRExperianTradePaymentSummary where prextps_CompanyID = @company_id and prextps_RequestID = @request_id
delete from PRExperianTradePaymentDetail where prextpd_CompanyID = @company_id and prextpd_RequestID = @request_id


-- start parsing the JSON and loading it into the tables
declare @json1 varchar(max) = ''

select top 1 @json1 = json1 from #business_facts_results

if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH BUSINESS_FACTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table


insert into dbo.PRExperianBusinessCode(prexbc_TimeStamp,prexbc_RequestID,prexbc_CompanyID,prexbc_TypeCode,prexbc_Code,prexbc_Description)
	select getdate(),@request_id,@company_id,'SIC',* from openjson(json_query(@json1,'$.results.sicCodes'))
	with (
	sicCode varchar(255)  '$.code',
	sicCodeDef varchar(255)  '$.definition'
	)

insert into dbo.PRExperianBusinessCode(prexbc_TimeStamp,prexbc_RequestID,prexbc_CompanyID,prexbc_TypeCode,prexbc_Code,prexbc_Description)
	select getdate(),@request_id,@company_id,'NAICS',* from openjson(json_query(@json1,'$.results.naicsCodes'))
	with (
	naicsCode varchar(255)  '$.code',
	naicsCodeDef varchar(255)  '$.definition'
	)

 set @json1 = ''
select top 1 @json1 = json1 from #liens_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH LIENS_RESULTS',1 

if @debug = 1
select @json1 as json_from_table

insert into dbo.PRExperianLegalFiling(prexlf_TimeStamp,prexlf_RequestID, prexlf_CompanyID,prexlf_TypeCode, prexlf_Date,prexlf_LegalType,prexlf_LegalAction,prexlf_DocumentNumber,prexlf_FilingLocation,prexlf_Owner,prexlf_LiabilityAmount)
select getdate(), @request_id,@company_id,'TaxLien',* from openjson(json_query(@json1,'$.results.lienDetail'))
with (
dateFiled varchar(255)  '$.dateFiled',
legalType varchar(255)  '$.legalType',
legalAction varchar(255)  '$.legalAction',
documentNumber varchar(255)  '$.documentNumber',
filingLocation varchar(255)  '$.filingLocation',
owner varchar(255)  '$.owner',
liabilityAmount varchar(255)  '$.liabilityAmount'
)

select @HasTaxLienDetails = 'Y' from openjson(json_query(@json1,'$.results.lienDetail'))


set @json1 = ''
select top 1 @json1 = json1 from #judgements_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH JUDGEMENTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

insert into dbo.PRExperianLegalFiling(prexlf_TimeStamp, prexlf_RequestID, prexlf_CompanyID,prexlf_TypeCode, prexlf_Date,prexlf_LegalType,prexlf_LegalAction,prexlf_DocumentNumber,prexlf_FilingLocation,prexlf_PlaintiffName,prexlf_LiabilityAmount)
select getdate(), @request_id, @company_id, 'Judgement',* from openjson(json_query(@json1,'$.results.judgmentDetail'))
with (
dateFiled varchar(255)  '$.dateFiled',
legalType varchar(255)  '$.legalType',
legalAction varchar(255)  '$.legalAction',
documentNumber varchar(255)  '$.documentNumber',
filingLocation varchar(255)  '$.filingLocation',
plaintiffName varchar(255)  '$.plaintiffName',
liabilityAmount varchar(255)  '$.liabilityAmount'
)

select @HasJudgementDetails = 'Y' from openjson(json_query(@json1,'$.results.judgmentDetail'))


--load trade payment summary records

set @json1 = ''
select top 1 @json1 = json1 from #trades_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH TRADES_RESULTS',1 

if @debug = 1
select @json1 as json_from_table


insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Total',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.tradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Combined',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.combinedTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)





insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Continuous', *  from openjson(json_query(@json1,'$.results.tradePaymentTotals.continuouslyReportedTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	select @HasTradeContinuous = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentTotals.continuouslyReportedTradelines1'))

	if @debug = 1
	select @HasTradeContinuous as '@HasTradeContinuous1'


insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'New',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.newlyReportedTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	select @HasTradeNew = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentTotals.newlyReportedTradelines'))


insert into dbo.PRExperianTradePaymentSummary(prextps_TimeStamp,prextps_RequestID,prextps_CompanyID,
	prextps_TypeCode, prextps_TradeLineCount,prextps_CurrentDBT,prextps_TotalHighCreditAmount,prextps_TotalAccountBalance,prextps_CurrentPercentage,prextps_DBT30, prextps_DBT60,prextps_DBT90,prextps_DBT91Plus)

	select getdate(), @request_id, @company_id, 'Additional',*  from openjson(json_query(@json1,'$.results.tradePaymentTotals.additionalTradelines'))
	with (
	tradelineCount varchar(255)  '$.tradelineCount',
	currentDbt varchar(255)  '$.currentDbt',
	totalHighCreditAmount varchar(255)  '$.totalHighCreditAmount.amount',
	totalAccountBalance varchar(255)  '$.totalAccountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus'
	)

	select @HasTradeAdditional = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentTotals.additionalTradelines'))

	if 'y' in (@HasTradeContinuous,@HasTradeNew,@HasTradeAdditional) set @HasPaymentFilingsSummary = 'Y'


set @json1 = ''
--declare @json1 varchar(max), @request_id int = 1000, @company_id int = 1
select top 1 @json1 = json1 from #trades_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH TRADES_RESULTS',1

if @debug = 1
select @json1 as json_from_table

insert into dbo.PRExperianTradePaymentDetail(prextpd_TimeStamp,prextpd_RequestID,prextpd_CompanyID,
	prextpd_BusinessCategory,prextpd_DateReported,prextpd_DateLastActivity,prextpd_Terms,prextpd_RecentHighCredit,prextpd_AccountBalance,prextpd_CurrentPercentage,prextpd_DBT30,prextpd_DBT60,prextpd_DBT90,prextpd_DBT91Plus,prextpd_NewlyReported,prextpd_TypeCode)

	select getdate(), @request_id, @company_id,
	
	businessCategory,
	dateReported,
	dateLastActivity,
	terms,
	recentHighCredit,
	accountBalance,
	currentPercentage,
	dbt30,
	dbt60,
	dbt90,
	dbt91Plus,
	case newlyReportedIndicator when 'true' then 'Y' else 'N' end as newlyReportedIndicator,
	'NewContinuous'
	
	 from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeNewAndContinuous'))
	with (
	businessCategory varchar(255)  '$.businessCategory',
	dateReported varchar(255)  '$.dateReported',
	dateLastActivity varchar(255)  '$.dateLastActivity',
	terms varchar(255)  '$.terms',
	recentHighCredit varchar(255)  '$.recentHighCredit.amount',
	accountBalance varchar(255)  '$.accountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus',
	newlyReportedIndicator varchar(255)  '$.newlyReportedIndicator'--,customerDisputeIndicator varchar(255)  '$.customerDisputeIndicator',
	
	)

	select @HasTradeDetails = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeNewAndContinuous'))

insert into dbo.PRExperianTradePaymentDetail(prextpd_TimeStamp,prextpd_RequestID,prextpd_CompanyID,
	prextpd_BusinessCategory,prextpd_DateReported,prextpd_DateLastActivity,prextpd_Terms,prextpd_RecentHighCredit,prextpd_AccountBalance,prextpd_CurrentPercentage,prextpd_DBT30,prextpd_DBT60,prextpd_DBT90,prextpd_DBT91Plus,prextpd_NewlyReported,prextpd_TypeCode)

	select getdate(), @request_id, @company_id,
	
	businessCategory,
	dateReported,
	dateLastActivity,
	terms,
	recentHighCredit,
	accountBalance,
	currentPercentage,
	dbt30,
	dbt60,
	dbt90,
	dbt91Plus,
	case newlyReportedIndicator when 'true' then 'Y' else 'N' end as newlyReportedIndicator,
	'Additional'
	
	 from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeAdditional'))
	with (
	businessCategory varchar(255)  '$.businessCategory',
	dateReported varchar(255)  '$.dateReported',
	dateLastActivity varchar(255)  '$.dateLastActivity',
	terms varchar(255)  '$.terms',
	recentHighCredit varchar(255)  '$.recentHighCredit.amount',
	accountBalance varchar(255)  '$.accountBalance.amount',
	currentPercentage varchar(255)  '$.currentPercentage',
	dbt30 varchar(255)  '$.dbt30',
	dbt60 varchar(255)  '$.dbt60',
	dbt90 varchar(255)  '$.dbt90',
	dbt91Plus varchar(255)  '$.dbt91Plus',
	newlyReportedIndicator varchar(255)  '$.newlyReportedIndicator'--,customerDisputeIndicator varchar(255)  '$.customerDisputeIndicator',
	
	)

	select @HasTradeDetails = 'Y' from openjson(json_query(@json1,'$.results.tradePaymentExperiences.tradeNewAndContinuous'))

--declare @json1 varchar(max), @request_id int = 1000, @company_id int = 1
--now pull all the odd pieces together to load PRExperianData 
declare
@employeeSize varchar(512) = null, @salesRevenue varchar(512) = null,
@bankruptcyIndicator varchar(512) = null,
@judgmentCount varchar(512) = null, @judgmentBalance varchar(512) = null

--from Business Facts

set @json1 = ''
select top 1 @json1 = json1 from #business_facts_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH BUSINESS_FACTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @employeeSize = employeeSize, @salesRevenue = salesRevenue from openjson(json_query(@json1,'$.results'))
with (
employeeSize varchar(255)  '$.employeeSize',
salesRevenue varchar(255)  '$.salesRevenue'
)

if @debug = 1
select @employeeSize '@employee_size', @salesRevenue '@sales_revenue'


--From Bankruptcy
set @json1 = ''
select top 1 @json1 = json1 from #bankruptcies_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH BANKRUPTCIES_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @bankruptcyIndicator = bankruptcyIndicator from openjson(json_query(@json1,'$.results'))
with (
bankruptcyIndicator varchar(255)  '$.bankruptcyIndicator'
)

--From Judgements
set @json1 = ''
select top 1 @json1 = json1 from #judgements_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH JUDGEMENTS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @judgmentCount = judgmentCount, @judgmentBalance = judgmentBalance from openjson(json_query(@json1,'$.results.judgmentSummary'))
with (
judgmentCount varchar(255)  '$.judgmentCount',
judgmentBalance varchar(255)  '$.judgmentBalance' -- add this to lien balance
)

--From Trades

declare @currentDbt varchar(512) = null,
@monthlyAverageDbt varchar(512) = null,
@highestDbt6Months varchar(512) = null,
@highestDbt5Quarters varchar(512) = null,
@allTradelineCount varchar(512) = null,
@allTradelineBalance varchar(512) = null,
@continuous_tradelineCount varchar(512) = null,
@continuous_totalAccountBalance varchar(512) = null,
@singleHighCredit varchar(512) = null

set @json1 = ''
select top 1 @json1 = json1 from #trades_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH TRADES_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select 
@currentDbt = currentDbt,
@monthlyAverageDbt = monthlyAverageDbt,
@highestDbt6Months = highestDbt6Months,
@highestDbt5Quarters = highestDbt5Quarters,
@allTradelineCount = allTradelineCount,
@allTradelineBalance = allTradelineBalance,
@continuous_tradelineCount = continuous_tradelineCount,
@continuous_totalAccountBalance = continuous_totalAccountBalance,
@singleHighCredit = singleHighCredit

from openjson(json_query(@json1,'$.results'))
with (
currentDbt varchar(255)  '$.tradePaymentSummary.currentDbt',
monthlyAverageDbt varchar(255)  '$.tradePaymentSummary.monthlyAverageDbt',
highestDbt6Months varchar(255)  '$.tradePaymentSummary.highestDbt6Months',
highestDbt5Quarters varchar(255)  '$.tradePaymentSummary.highestDbt5Quarters',
allTradelineCount varchar(255)  '$.tradePaymentSummary.allTradelineCount',  --this also gets added to total collections
allTradelineBalance varchar(255)  '$.tradePaymentSummary.allTradelineBalance', --this also gets added to total collections
continuous_tradelineCount varchar(255)  '$.tradePaymentTotals.continuouslyReportedTradelines.tradelineCount',  
continuous_totalAccountBalance varchar(255)  '$.tradePaymentTotals.continuouslyReportedTradelines.totalAccountBalance.amount', 
singleHighCredit varchar(255)  '$.tradePaymentSummary.singleHighCredit'
)


--From Liens
declare @lienCount varchar(512) = null,
@lienBalance varchar(512) = null

set @json1 = ''
select top 1 @json1 = json1 from #liens_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH LIENS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @lienCount = lienCount, @lienBalance = lienBalance from openjson(json_query(@json1,'$.results.lienSummary'))
with (
lienCount varchar(255)  '$.lienCount',
lienBalance varchar(255)  '$.lienBalance' -- add this to judgement balance
)

--From Collections
declare @collectionCount varchar(512) = null,
@collectionBalance varchar(512) = null

set @json1 = ''
select top 1 @json1 = json1 from #collections_results
if(isjson(@json1)<>1) throw 60000,'JSON PROBLEM WITH COLLECTIONS_RESULTS',1

if @debug = 1
select @json1 as json_from_table

select @collectionCount = collectionCount, @collectionBalance = collectionBalance from openjson(json_query(@json1,'$.results.collectionsSummary'))
with (
collectionCount varchar(255)  '$.collectionCount',
collectionBalance varchar(255)  '$.collectionBalance' -- add this to lien balance
)

end try
begin catch
set @Experian_exit_code = 'E'
end catch


--Here we go....one big composite record (2.1.1.6)
insert into dbo.PRExperianData(prexd_StatusCode,prexd_TimeStamp,prexd_RequestID,prexd_CompanyID,
prexd_CurrentDBT,
prexd_MonthlyAverageDBT,
prexd_HighestDBT6Months,
prexd_HighestDBT5Quarters,
prexd_TradeCollectionCount,
prexd_TradeCollectionAmount,

prexd_TradelinesCount,
prexd_TradelinesAmount,

prexd_CollectionsCount,
prexd_CollectionsAmount,

prexd_ContiniousTradelinesCount,
prexd_ContiniousTradelinesAmount,

prexd_SingleHighCredit,
prexd_BankruptcyIndicator,
prexd_LienCount,
prexd_LienBalance,
prexd_JudgementCount,
prexd_JudgementBalance,
prexd_EmployeeSize,
prexd_SalesRevenue)

select @Experian_exit_code,getdate(),@request_id,@company_id,

@currentDbt,
@monthlyAverageDbt,
@highestDbt6Months,
@highestDbt5Quarters,

cast(@allTradelineCount as int) + cast(@collectionCount as int),
cast(@allTradelineBalance as money) + cast(@collectionBalance as money),

cast(@allTradelineCount as int),
cast(@allTradelineBalance as money),

cast(@collectionCount as int),
cast(@collectionBalance as money),

cast(@continuous_tradelineCount as int),
cast(@continuous_totalAccountBalance as money),

@singleHighCredit,
case @bankruptcyIndicator when 'true' then 'Y' else 'N' end as bankruptcyIndicator,

cast(@lienCount as int),
cast(@lienBalance as money),
cast(@judgmentCount as int),
cast(@judgmentBalance as money),
cast(@employeeSize as int),
cast(@salesRevenue as money)






--make the mandatory PRExperianAuditLog record for each web request result (2.1.1.7)
insert into dbo.PRExperianAuditLog(prexal_TimeStamp,prexal_RequestID,prexal_SubjectCompanyID,
prexal_HasPaymentFilingsSummary,
prexal_HasTaxLienDetails,
prexal_HasJudgmentDetails,
prexal_HasTradeContinous,
prexal_HasTradeNew,
prexal_HasTradeAdditional,
prexal_HasTradeDetails,
prexal_HasBusinessFacts)

values(
getdate(), @request_id,@company_id,
@HasPaymentFilingsSummary,
@HasTaxLienDetails,
@HasJudgementDetails,
@HasTradeContinuous,
@HasTradeNew,
@HasTradeAdditional,
@HasTradeDetails,
@HasBusinessFacts
)


set @audit_record_id = @@IDENTITY


end


