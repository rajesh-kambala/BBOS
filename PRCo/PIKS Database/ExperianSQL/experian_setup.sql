--delete from Custom_Captions where capt_family = 'ExperianIntegration'

exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'Client_id', 0, 't0ld1NvdBzU687kBFifL7YjubDqERxPG' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'Client_secret', 0, 'o5tO1zoCTGShGgn2' 

exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'username', 0, 'bpiotrowski@travant.com' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'password', 0, 'Bob~1604k2' 

exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'Authorization', 0, 'not_set' 


exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_auth', 0, 'https://sandbox-us-api.experian.com/oauth2/v1/token' 

exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_bankruptcies', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/bankruptcies' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_business_facts', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/facts' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_judgements', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/judgments' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_liens', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/liens' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_trades', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/trades' 
exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'web_endpoint_collections', 0, 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/collections'

exec usp_AccpacCreateDropdownValue 'ExperianIntegration', 'subcode', 0, '0563736' 


--select top 1000 * from Custom_Captions where capt_family = 'ExperianIntegration'





