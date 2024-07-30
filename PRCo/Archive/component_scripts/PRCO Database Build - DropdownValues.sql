SET NOCOUNT ON

-- This file creates all the drop down values for selction items within the system
-- Remove unwanted standard accpac values from comm_action custom captions
delete from custom_captions where capt_family='Comm_Action' and capt_Code in ('Demo', 'Meeting', 'Vacation');

-- Remove unwanted standard accpac value from comm_type custom caption
delete from custom_captions where capt_family='Comm_Type' and capt_Code = 'Appointment';

-- Remove unwanted accpac value from comm_status
delete from custom_captions where capt_family='Comm_Status' and capt_Code='InProgress';

-- remove the standard accpac comp_source custom captions
delete from custom_captions where capt_family = 'comp_source';

-- remove the standard accpac oppo_Type custom captions (Consulting, License, Mix, Service)
delete from custom_captions where capt_family = 'oppo_Type';

-- remove the standard accpac oppo_source values
delete from custom_captions where capt_family = 'oppo_Type';

-- change the caption to reflect a Category
update custom_captions set capt_US = 'Category' where capt_Code = 'oppo_Type' and capt_Family = 'ColNames';

-- remove all the current values
delete from custom_captions where capt_component='PRDropdownValues' and capt_family != 'CRMBuildNumber';

-- Status_OpenClosed can be used anywhere an open/closed dropdown is needed
exec usp_AccpacCreateDropdownValue 'Status_OpenClosed', 'Open', 1, 'Open'         /**/
exec usp_AccpacCreateDropdownValue 'Status_OpenClosed', 'Closed', 2, 'Closed'         /**/

exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', '7', 1, 'Association'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'C', 2, 'Corporation'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'D', 3, 'Debtor In Possession'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'E', 4, 'Estate'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'I', 5, 'Individual'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'L', 6, 'Limited Partnership'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'M', 7, 'Limited Liability Company'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'P', 8, 'Partnership'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'T', 9, 'Trust'         /*pril_OwnCode, prpa_OwnCode*/
exec usp_AccpacCreateDropdownValue 'OwnershipTypeCode', 'U', 10, 'Unlimited Liability Company'         /*pril_OwnCode, prpa_OwnCode*/

exec usp_AccpacCreateDropdownValue 'ProfCode', '0', 1, 'Food Service'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', 'C', 10, 'Grower-Shipper'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', 'D', 11, 'Shipper'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', 'G', 12, 'Grocery Wholesaler'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', '4', 2, 'Wholesale Dealer'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', '5', 3, 'Commission Merchant'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', '6', 4, 'Broker'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', '7', 5, 'Retailer'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', '8', 6, 'Processor'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', '9', 7, 'Trucker'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', 'A', 8, 'Grower'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'ProfCode', 'B', 9, 'Grower-Agent'         /*pril_ProfCode, prpa_ProfCode*/
exec usp_AccpacCreateDropdownValue 'TypeFruitVeg', '1', 1, 'Fresh Fruits & Vegs'         /*pril_TypeFruitVeg, prpa_TypeFruitVeg*/
exec usp_AccpacCreateDropdownValue 'TypeFruitVeg', '2', 2, 'Frozen Fruits & Vegs'         /*pril_TypeFruitVeg, prpa_TypeFruitVeg*/
exec usp_AccpacCreateDropdownValue 'TypeFruitVeg', '3', 3, 'Both Fresh & Frozen'         /*pril_TypeFruitVeg, prpa_TypeFruitVeg*/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '1', 1, ''         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '2', 2, '2'         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '3', 3, '3'         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '4', 4, '4'         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '5', 5, '5'         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '6', 6, '6'         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '7', 7, '7'         /**/
exec usp_AccpacCreateDropdownValue 'addr_PRZone', '8', 8, '8'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'M', 1, 'Mailing'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'PH', 2, 'Physical'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'I', 3, 'Invoice'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'W', 4, 'Warehouse'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'S', 5, 'Shipping'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'T', 6, 'Tax'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'PS', 7, 'Prco Ship'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'PM', 8, 'Prco Mail'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypeCompany', 'O', 9, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypePerson', 'H', 1, 'Home'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypePerson', 'B', 2, 'Business'         /**/
exec usp_AccpacCreateDropdownValue 'adli_TypePerson', 'O', 3, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'IR', 1, 'Industry ratios'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'IA', 2, 'Info on another industry'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'NE', 3, 'New electronic publication'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'NI', 4, 'New industry data element'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'NP', 5, 'New Print Publication'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'O',  6, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRServiceOffering', 'S',  7, 'Seminars'         /**/

exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'U',     1, 'Unknown'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WXPPE', 5, 'Windows XP Professional Edition'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WXPHE', 10, 'Windows XP Home Edition'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WXPU',  15, 'Windows XP (Edition Unknown)'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WXPV',  20, 'Windows Vista (Edition Unknown)'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'W00PE', 25, 'Windows 2000 Professional Edition'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'W00S',  30, 'Windows 2000 Server'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'W00U',  35, 'Windows 2000 (Edition Unknown)'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WS3S',  40, 'Windows Server 2003 Standard'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WS3E',  45, 'Windows Server 2003 Enterprise'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WS3M',  50, 'Windows Server 2003 Media Edition'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WS3U',  55, 'Windows (Edition Unknown)'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'W98',   60, 'Windows 98'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'WME',   65, 'Windows Me'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'W95',   70, 'Windows 95'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'MAC',   75, 'Macintosh'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'LNX',   80, 'Linux'         /**/
exec usp_AccpacCreateDropdownValue 'case_PROperatingSystem', 'O',     85, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'case_PREBBNetworkStatus', 'U',     5, 'Unknown'         /**/
exec usp_AccpacCreateDropdownValue 'case_PREBBNetworkStatus', 'S',     10, 'Stand-alone'         /**/
exec usp_AccpacCreateDropdownValue 'case_PREBBNetworkStatus', 'L',     15, 'Local Area Network (LAN)'         /**/
exec usp_AccpacCreateDropdownValue 'case_PREBBNetworkStatus', 'W',     20, 'Wide Area Network (WAN)'         /**/

exec usp_AccpacCreateDropdownValue 'case_PRResearchingReason', 'CR',  5, 'Waiting on customer response/feedback'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRResearchingReason', 'IR', 10, 'Waiting on internal research/analysis'         /**/

exec usp_AccpacCreateDropdownValue 'case_PRClosedReason', 'R',   5, 'Customer issue resolved'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRClosedReason', 'S',  10, 'Closed without resolution / customer satisfied'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRClosedReason', 'NS', 15, 'Closed without resolution / customer not satisfied'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRClosedReason', 'CR', 20, 'Closed - referred back for customer to resolve'         /**/

exec usp_AccpacCreateDropdownValue 'case_PRPriority', '1', 5, 'Callback to be made'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRPriority', '2', 10, 'Completed by e-mail'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRPriority', '3', 15, 'Completed by Fax'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRPriority', '4', 20, 'Completed first call'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRPriority', '5', 25, 'Member will call back if needed'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRPriority', '12',60, 'Refer to another associate'         /**/

delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'case_ProductArea'
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'EBB', 5, 'EBB Support'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'BBO', 15, 'BB Online Support'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'PBB', 25, 'Pocket BB Support'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'STE', 35, 'Service Tutorial Explanation'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'BE', 45, 'Billing Explanation'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'AR', 55, 'PRCo A/R Collection'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'WC', 65, 'Welcome Call'         /**/
exec usp_AccpacCreateDropdownValue 'case_ProductArea', 'O', 75, 'Other'         /**/

delete from custom_captions where capt_familytype = 'Choices' and capt_family = 'case_ProblemType'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '1', 5, 'Blob Error'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '2', 10, 'CD Install'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '3', 15, 'CD Install-Expired'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '4', 20, 'Copy Failed'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '5', 25, 'Corrupt File Other Than Header'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '6', 30, 'Data Not Compatible With Software'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '7', 35, 'DataDir Invalid or Not Defined'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '8', 40, 'Date/Time Issue'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '9', 45, 'Directory Controlled By Another.net File'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '10', 50, 'Does not contain EBB data'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '11', 55, 'Error Message'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '12', 60, 'Error Message 432'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '13', 65, 'Index Out Of Date'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '14', 70, 'Net Dir Issue'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '15', 75, 'Network Initialization Failed'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '16', 80, 'Network Issue'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '17', 85, 'Notes Issue'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '18', 90, 'PDOXUSRE.net Error'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '19', 95, 'PDOXUSRS.LCK error'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '20', 100, 'Problem Reading Database Registration File'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '21', 105, 'Range Check Error'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '22', 110, 'Rights Issue'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '23', 115, 'Software Not Compatible'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '24', 120, 'Update File Corrupt'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '25', 125, 'Updates Issue'
exec usp_AccpacCreateDropdownValue 'case_ProblemType',  '26', 130, 'Viewing Issue'


exec usp_AccpacCreateDropdownValue 'case_PRStage', 'Logged', 5, 'Logged'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRStage', 'Researching', 10, 'Researching'         /**/
exec usp_AccpacCreateDropdownValue 'case_PRStage', 'Closed', 15, 'Closed'         /**/

exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'A', 1, 'Primary'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'X', 10, 'No Sell'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'CC', 11, 'Credit Card Or COD Only'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'B', 2, 'Secondary'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'C', 3, 'Tertiary'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'F', 4, 'New M (First Contact)'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'K', 5, 'Key'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'N', 6, 'Not A Prospect'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'P', 7, 'Prospect (Hq)'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'Q', 8, 'Prospect (Branch)'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRAccountTier', 'T', 9, 'Team'         /**/
exec usp_AccpacCreateDropdownValue 'Comp_PRAdministrativeUsage', '1', 1, 'Handles its own administration and buying/ selling/ transporting.'         /**/
exec usp_AccpacCreateDropdownValue 'Comp_PRAdministrativeUsage', '2', 2, 'Administrative office only'         /**/
exec usp_AccpacCreateDropdownValue 'Comp_PRAdministrativeUsage', '3', 3, 'Does not handle its own administration (only buying/ selling/ transporting.)'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRDataQualityTier', 'C', 1, 'Critical'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRDataQualityTier', 'H', 2, 'High'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRDataQualityTier', 'M', 3, 'Medium'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRDataQualityTier', 'L', 4, 'Low'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'L', 1, 'Listed'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'H', 2, 'Hold'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'N1', 3, 'Not Listed - Service Only'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'N2', 4, 'Not Listed - Listing Membership Prospect'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'N3', 5, 'Not Listed (Previously Listed-Reported Closed/Inactive/Not A Factor)'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'N4', 6, 'Not Listed (Previously Listing/Membership Prospect)'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRListingStatus', 'D', 7, 'Deleted Before Migration'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRType', 'H', 1, 'Headquarter'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRType', 'B', 2, 'Branch'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRCommunicationLanguage', 'E', 1, 'English'          
exec usp_AccpacCreateDropdownValue 'comp_PRCommunicationLanguage', 'S', 2, 'Spanish'          
exec usp_AccpacCreateDropdownValue 'comp_PRInvMethodGroup', 'A', 1, 'A'          
exec usp_AccpacCreateDropdownValue 'comp_PRInvMethodGroup', 'B', 1, 'B'          
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'P', 1, 'Phone'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'F', 2, 'Fax'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'E', 3, 'E-Mail'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'M', 4, 'Mail'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'W', 5, 'Web'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'PV', 6, 'Personal Visit'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'CV', 7, 'Convention Visit'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'CL', 8, 'Connection List'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'PD', 9, 'PACA Database'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRMethodSourceReceived', 'O', 10, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRIndustryType', 'P', 1, 'Produce'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRIndustryType', 'T', 1, 'Transportation'         /**/
exec usp_AccpacCreateDropdownValue 'comp_PRIndustryType', 'S', 1, 'Supply and Service'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'REF', 1, 'Referral/Word-of-Mouth'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'USER',2, 'Current or former BBS User'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'CA',  3, 'Convention/Association'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'AD',  4, 'PRCo Ad'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'N',   5,'Newspaper'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'WEB', 6, 'PRCo Web Site'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'DM',  7, 'PRCo Direct Mail Piece'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'PACA',8, 'PACA Database'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'P',   9, 'Third Party'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'RBCS',10, 'RBCS'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'CL',  11, 'Connection List'         /**/
exec usp_AccpacCreateDropdownValue 'comp_Source', 'O',   12,'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_Type', 'NEWM', 1, 'New Membership'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_Type', 'UPG', 1, 'Membership Upgrade'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_Type', 'BP', 1, 'Blueprints Advertising'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRLostReason', 'C', 1, 'Competition'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRLostReason', 'P', 2, 'Price'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRLostReason', 'S', 3, 'Seasonality of produce'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRLostReason', 'F', 4, 'Frequency of Publication'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRLostReason', 'A', 5, 'Wrong target audience'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRLostReason', 'O', 6, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'C',  1, 'Competitive Offerings'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'R',  2, 'RBCS'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'P',  3, 'Price'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'CB', 4, 'Cost/Benefit'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'CP', 5, 'Cost Prohibitive/not BB related'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'SP', 6, 'Operations too small/future service prospect'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'N',  7, 'New start-up/not ready yet'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_MembershipLostReason', 'O',  8, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_UpgradeLostReason', 'C',  1, 'Cost/benefit'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_UpgradeLostReason', 'P',  2, 'Prefers print book'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_UpgradeLostReason', 'T',  3, 'Technology not available'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_UpgradeLostReason', 'O',  4, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PersonRole', 'I', 1, 'Influencer'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PersonRole', 'D', 2, 'Decision Maker'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PersonRole', 'G', 3, 'Gatekeeper'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PersonRole', 'O', 4, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRAdRun', 'Y',    1, 'Year Round'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdRun', 'S',    2, 'Single'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdRun', 'R',    3, 'Renewal'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdRun', 'O',    4, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'PN',    1, 'Produce News'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'PK',    2, 'The Packer'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'PB',    3, 'Produce Business'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'SN',    4, 'Supermarket News'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'RB',    5, 'Any RBCS publication'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'WG',    6, 'WGA publication'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRAdvertiseIn', 'O',    7, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRStage', 'Initial',		5, 'Initial'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRStage', 'Qualified',		15, 'Qualified'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRStage', 'Proposal Submitted', 25, 'Proposal Submitted'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRStage', 'Negotiating',	35, 'Negotiating'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRStage', 'Sale Closed',	45, 'Sale Closed'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRStage', 'Deal Lost',		55, 'Deal Lost'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRTargetIssue', '1', 1, 'October 2006'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTargetIssue', '2', 2, 'January 2007'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTargetIssue', '3', 3, 'April 2007'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTargetIssue', '4', 4, 'July 2007'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTargetIssue', '5', 5, 'October 2007'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTargetIssue', '6', 6, 'Special Edition 2007'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRTeam', 'ISC',    1, 'ISC'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTeam', 'Field',  1, 'Field'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRTeam', 'Team',   1, 'Team'         /**/

-- Full list of type values for the view and filtering
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'S50',  1, 'Series 50'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'S100', 2, 'Series 100'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'S150', 3, 'Series 150'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'S200', 4, 'Series 200'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'S300', 5, 'Series 300'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'O',    6, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'BB',   5, 'Additional Blue Book(s)'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'EBB',  6, 'Additional EBB(s)'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'UNITS',7, 'Additional Units'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'LOGO', 8, 'LOGO'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'SPOT', 9, 'EBB Spotlight'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'UNK',  1, 'Ad (size unknown)'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'PRM',  2, 'Premium ad placement'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'FULL', 3, 'Full page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'HALF', 4, 'Half page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'THIRD',5, 'One third page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'SIXTH',6, 'One sixth page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType', 'EB',   7, 'EB ad'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRType_Mem', 'S50',  1, 'Series 50'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Mem', 'S100', 2, 'Series 100'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Mem', 'S150', 3, 'Series 150'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Mem', 'S200', 4, 'Series 200'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Mem', 'S300', 5, 'Series 300'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Mem', 'O',    6, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'S100', 1, 'Series 100'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'S150', 2, 'Series 150'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'S200', 3, 'Series 200'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'S300', 4, 'Series 300'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'BB',   5, 'Additional Blue Book(s)'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'EBB',  6, 'Additional EBB(s)'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'UNITS',7, 'Additional Units'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'LOGO', 8, 'LOGO'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'SPOT', 9, 'EBB Spotlight'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Upg', 'O',    10,'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'UNK',  1, 'Ad (size unknown)'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'PRM',  2, 'Premium ad placement'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'FULL', 3, 'Full page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_Bp', 'HALF', 4, 'Half page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'THIRD',5, 'One third page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'SIXTH',6, 'One sixth page ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'EB',   7, 'EB ad'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'OC',   8, 'One Color'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'FC',   9, 'Four Color'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_PRType_BP', 'O',    10, 'Other'         /**/

exec usp_AccpacCreateDropdownValue 'oppo_Source', 'FM',  1, 'Customer initiated, former member'         /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'SMC', 2, 'Customer initiated, originated through Sales/Marketing/Customer Service Group' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'SSD', 3, 'Customer initiated, originated through Special Services Division' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'RG',  4, 'Customer initiated, originated through Rating Group' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'CG',  5, 'Customer initiated, originated through Content Group' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'CO',  6, 'Customer initiated, other' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'INT', 7, 'PRCo initiated internal databse/list' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'EXT', 8, 'PRCo initiated external list' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'PIP', 9, 'PRCo initiated upgrade pipeline' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'PO',  10, 'PRCo initiated -- other' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'TRD', 11, 'Tradeshow' /**/
exec usp_AccpacCreateDropdownValue 'oppo_Source', 'O',   12, 'Other' /**/

exec usp_AccpacCreateDropdownValue 'oppo_SourceBP', 'AD',  1, 'PRCo initiated from ad in another publication' /**/
exec usp_AccpacCreateDropdownValue 'oppo_SourceBP', 'BP',  2, 'PRCo initiated based upon timing of BP content' /**/
exec usp_AccpacCreateDropdownValue 'oppo_SourceBP', 'PO',  3, 'PRCo initiated -- other' /**/
exec usp_AccpacCreateDropdownValue 'oppo_SourceBP', 'CEI', 4, 'Customer Experience Interest' /**/
exec usp_AccpacCreateDropdownValue 'oppo_SourceBP', 'NIB', 5, 'New in Blue' /**/
exec usp_AccpacCreateDropdownValue 'oppo_SourceBP', 'O',   6, 'Other' /**/

exec usp_AccpacCreateDropdownValue 'peli_PRAUSChangePreference', '1', 1, 'Key'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRAUSChangePreference', '2', 2, 'All'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRAUSReceiveMethod', '1', 1, 'Fax'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRAUSReceiveMethod', '2', 2, 'Email'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRAUSReceiveMethod', '3', 3, 'Web Only'         /**/
exec usp_AccpacCreateDropdownValue 'pers_PRLanguageSpoken', 'E', 1, 'English'         /**/
exec usp_AccpacCreateDropdownValue 'pers_PRLanguageSpoken', 'S', 2, 'Spanish'         /**/
exec usp_AccpacCreateDropdownValue 'pers_PRLanguageSpoken', 'F', 3, 'French'         /**/
exec usp_AccpacCreateDropdownValue 'pers_PRLanguageSpoken', 'G', 4, 'German'         /**/
exec usp_AccpacCreateDropdownValue 'pers_PRLanguageSpoken', 'P', 5, 'Portuguese'         /**/
exec usp_AccpacCreateDropdownValue 'pers_PRLanguageSpoken', 'O', 6, 'Other'         /**/

-- remove the accpac native Title codes from the list
Update Custom_Captions SET Capt_Deleted = 1 
 where capt_familytype = 'Choices' and capt_family = 'pers_titlecode' and capt_Component is null
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'PRES', 1, 'President'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'VP', 2, 'Vice President'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'SEC', 3, 'Secretary'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'PROP', 4, 'Proprietor'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'DIR', 5, 'Director'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'COO', 6, 'COO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'PAR', 7, 'Partner'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'GM', 8, 'General Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'MEM', 9, 'Member'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'SHR', 10, 'Shareholder'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'TRE', 11, 'Treasurer'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'CEO', 12, 'CEO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'TRU', 13, 'Trustee'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'MM', 14, 'Managing Member'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'CHR', 15, 'Chairman'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'CFO', 16, 'CFO'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'SVP', 17, 'Sr./Executive VP'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'BRK', 18, 'Broker'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'ACC', 19, 'Accounting'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'BUY', 20, 'Buying & Sales'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'TRN', 21, 'Transportation'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'QC', 22, 'Quality Control'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'OWN', 23, 'Owner'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'MDIR', 24, 'Managing Director'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'OPER', 25, 'Operations'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'DIRO', 26, 'Director of Operations'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'CS', 27, 'Customer Service'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'MRK', 28, 'Marketing'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'SALE', 29, 'Sales'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'DISP', 30, 'Dispatch'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'BUYR', 31, 'Buyer'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'MGR', 32, 'Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'CRED', 33, 'Credit Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'SMGR', 34, 'Sales Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'OMGR', 35, 'Office Manager'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'CTRL', 36, 'Controller'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'pers_TitleCode', 'OTHR', 37, 'Other'         /*Populates the peli_PRTitleCode Field.*/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'D', 1, 'Deceased'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'F', 2, 'Fired'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'R', 3, 'Retired'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'Q', 4, 'Quit'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'O', 5, 'Other/Unknown'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'T', 6, 'Transferred'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRExitReason', 'S', 7, 'Still With Company (Requested Removal From Contact List)'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'E', 1, 'Executive'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'K', 2, 'Marketing'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'S', 3, 'Sales'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'B', 4, 'Buying/Purchasing'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'C', 5, 'Credit'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'T', 6, 'Transportation/Dispatch'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'O', 7, 'Operations'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'F', 8, 'Finance'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'A', 9, 'Administration'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'M', 10, 'Manager'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'I', 11, 'IT'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HE', 12, 'Head Executive'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HM', 13, 'Head of Marketing'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HS', 14, 'Head of Sales'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HB', 15, 'Head of Buying'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HC', 16, 'Head of Credit'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HT', 17, 'Head of Transportation'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HO', 18, 'Head of Operations'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HF', 19, 'Head of Finance'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRole', 'HI', 20, 'Head of IT'         /**/
-- removing these from peli_PRRole to show in their own dropdown
exec usp_AccpacCreateDropdownValue 'peli_PROwnershipRole', 'RCO', 21, 'Owner (Responsibly Connected)'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PROwnershipRole', 'RCN', 22, 'Non-owner (Responsibly Connected)'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PROwnershipRole', 'RCU', 23, 'Undisclosed (Responsibly Connected)'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PROwnershipRole', 'RCR', 24, 'None (Not Responsibly Connected)'         /**/
-- removing these from peli_PRRole to show in their own listing
exec usp_AccpacCreateDropdownValue 'peli_PRRecipientRole', 'RCVTES', 25, 'Receives TES Forms'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRecipientRole', 'RCVJEP', 26, 'Receives Jeopardy Letters'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRecipientRole', 'RCVBILL', 27, 'Billing Attention Line'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRRecipientRole', 'RCVLIST', 28, 'Listing Attention Line'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRStatus', '1', 1, 'Active'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRStatus', '2', 2, 'Inactive'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRStatus', '3', 3, 'No Longer Connected'         /**/
exec usp_AccpacCreateDropdownValue 'peli_PRStatus', '4', 4, 'Removed by Company'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'P', 1, 'Phone'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'F', 2, 'Fax'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'PF', 3, 'Phone or Fax'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'PA', 4, 'Pager'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'S', 5, 'Sales Phone'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'SF', 6, 'Sales Fax'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'TF', 7, 'Toll Free'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'TP', 8, 'Trucker Phone'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypeCompany', 'C', 9, 'Cell'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'C', 1, 'Cell'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'G', 2, 'Pager'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'R', 3, 'Residence'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'E', 4, 'Company Extension'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'P', 5, 'Direct Office Phone'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'F', 6, 'Direct Office Fax'         /**/
exec usp_AccpacCreateDropdownValue 'Phon_TypePerson', 'O', 7, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'praa_AccountingSystem', '1', 1, 'Kpg (Kirkey)'         /**/
exec usp_AccpacCreateDropdownValue 'praa_DateSelectionCriteria', 'DUE', 1, 'Due'         /**/
exec usp_AccpacCreateDropdownValue 'praa_DateSelectionCriteria', 'INV', 2, 'Inv'         /**/
exec usp_AccpacCreateDropdownValue 'praa_DateSelectionCriteria', 'SHP', 3, 'Shp'         /**/
exec usp_AccpacCreateDropdownValue 'praa_DateSelectionCriteria', 'DIS', 4, 'Dis'         /**/
exec usp_AccpacCreateDropdownValue 'prat_Type', 'CO', 0, 'Country Of Origin'         /**/
exec usp_AccpacCreateDropdownValue 'prat_Type', 'SO', 1, 'State Of Origin'         /**/
exec usp_AccpacCreateDropdownValue 'prat_Type', 'SG', 2, 'Size Group'         /**/
exec usp_AccpacCreateDropdownValue 'prat_Type', 'TR', 3, 'Treatment'         /**/
exec usp_AccpacCreateDropdownValue 'prat_Type', 'GM', 4, 'Growing Method'         /**/
exec usp_AccpacCreateDropdownValue 'prat_Type', 'ST', 5, 'Style'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_AcquisitionType', '1', 1, 'capital stock'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_AcquisitionType', '2', 2, 'certain assets'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_AcquisitionType', '3', 3, 'certain assets & certain liabilities'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_AcquisitionType', '4', 4, 'all assets'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_AcquisitionType', '5', 5, 'all assets and all liabilities'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_AcquisitionType', '6', 6, 'other'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_AgreementCategory', '1', 1, 'buy'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_AgreementCategory', '2', 2, 'sell'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessClosureType', '1', 1, '88'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessClosureType', '2', 2, '108'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessClosureType', '3', 3, '113'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessClosureType', '4', 4, 'inactive'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '1', 1, 'acquisition'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '2', 2, 'agreement in principle'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '3', 3, 'assignment for the benefit of creditors:  (8)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '4', 4, 'bankruptcy events'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '5', 5, 'U.S. Bankruptcy Filing (17, 18, 19)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '6', 6, 'Canadian Bankruptcy Filing'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '7', 7, 'Business closed: (88, 108, 113, Inactive)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '8', 8, 'Business entity change'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '9', 9, 'Business started:  (87)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '10', 10, 'Ownership sale from one individual to another'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '11', 11, 'Divestiture/Sale of business/assets'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '12', 12, 'DRC issue:  (155-158)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '13', 13, 'Extension/Compromise (1, 2, 3, 4, 5, 7)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '14', 14, 'Financial Events'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '15', 15, 'Indictment (11)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '16', 16, 'Indictment closed  (12)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '17', 17, 'Injunctions'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '18', 18, 'Judgment :  (13)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '19', 19, 'Letter of intent'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '20', 20, 'Lien:  (13)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '21', 21, 'Location Change'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '22', 22, 'Merger'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '23', 23, 'Natural Disaster:  (105)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '24', 24, 'No longer handling fresh produce'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '25', 25, 'Other legal actions'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '26', 26, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '27', 27, 'Other PACA Event'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '28', 28, 'PACA License Suspended (152)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '29', 29, 'PACA License Reinstated (151)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '30', 30, 'PACA Trust Procedure'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '31', 31, 'Partnership  Dissolution: (96)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '32', 32, 'Receivership applied for (14)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '33', 33, 'Receivership appointed (15)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '34', 34, 'SEC Actions'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '35', 35, 'Public Stock Event'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '36', 36, 'Treasury Stock'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '37', 37, 'TRO (Temporary Restraining Order):  (6)'       exec usp_AccpacCreateDropdownValue 'prbe_BusinessEventType', '38', 38, 'Ownership Change (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_CanBankruptcyType', '1', 1, 'An assignment In bankruptcy made under the Bankruptcy and Insolvency Act'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_CanBankruptcyType', '2', 2, 'A notice Of intention to make a proposal under the Bankruptcy and Insolvency Act'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_CanBankruptcyType', '3', 3, 'A formal plan Of compromise Or arrangement under the companies Creditors Arrangement Act'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterImpact', '1', 1, 'Loss'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterImpact', '2', 2, 'Business Interruption'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterImpact', '3', 3, 'Loss And Business Interruption'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '1', 1, 'Fire'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '2', 2, 'Flood'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '3', 3, 'Tornado'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '4', 4, 'Hurricane'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '5', 5, 'Freeze'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '6', 6, 'Drought'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DisasterType', '7', 7, 'Other'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DRCType', '2', 2, '(156)'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DRCType', '3', 3, '(157)'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DRCType', '4', 4, '(158)'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_DRCType', '1', 1, '(155)'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '1', 1, '1'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '2', 2, '2'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '3', 3, '3'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '4', 4, '4'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '5', 5, '5'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '6', 6, '6'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_ExtensionType', '7', 7, '7'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '1', 1, 'C Corporation'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '2', 2, 'Sub Chapter S Corporation'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '3', 3, 'Corporation'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '4', 4, 'Limited Liability Company'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '5', 5, 'Partnership'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '6', 6, 'Limited Partnership'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '7', 7, 'Limited Liability Partnership'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_NewEntityType', '8', 8, 'Sole Proprietorship'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_OtherPACAType', '1', 1, '(153)'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_OtherPACAType', '2', 2, 'Administrative Action'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_OtherPACAType', '3', 3, 'Bond Posted'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_OtherPACAType', '4', 4, 'Other'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_PACASuspensionType', '1', 1, 'No Barred Until Date'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_PACASuspensionType', '2', 2, 'Has Barred Until Date'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_SaleType', '1', 1, 'Capital Stock'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_SaleType', '2', 2, 'Ownership Interest'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_SaleType', '3', 3, 'Partnership Interest'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_SpecifiedCSNumeral', '1', 1, '17'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_SpecifiedCSNumeral', '2', 2, '18'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_SpecifiedCSNumeral', '3', 3, '19'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_StockEventType', 'O', 1, 'Public Offering'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_StockEventType', 'P', 2, 'Going Private'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_StockEventType', 'D', 3, 'Delisting'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_StockEventType', 'C', 4, 'Symbol Change Or Exchange Change'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '1', 1, 'Alabama Middle Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '2', 2, 'Alabama Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '3', 3, 'Alabama Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '4', 4, 'Alaska Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '5', 5, 'Arizona Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '6', 6, 'Arkansas Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '7', 7, 'Arkansas Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '8', 8, 'California Central Bankruptcy – Los Angeles.  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '9', 9, 'California Central Bankruptcy – Northern Div.  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '10', 10, 'California Central Bankruptcy - Riverside  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '11', 11, 'California Central Bankruptcy – San Fernando Valley  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '12', 12, 'California Central Bankruptcy – Santa Ana  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '13', 13, 'California Eastern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '14', 14, 'California Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '15', 15, 'California Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '16', 16, 'Colorado Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '17', 17, 'Connecticut Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '18', 18, 'Delaware Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '19', 19, 'District Of Columbia Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '20', 20, 'Florida Middle Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '21', 21, 'Florida Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '22', 22, 'Florida Southern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '23', 23, 'Georgia Middle Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '24', 24, 'Georgia Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '25', 25, 'Georgia Southern Bankruptcy Court-Savannah  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '26', 26, 'Guam Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '27', 27, 'Hawaii Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '28', 28, 'Idaho Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '29', 29, 'Illinois Central Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '30', 30, 'Illinois Northern Bankruptcy - Chicago  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '31', 31, 'Illinois Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '32', 32, 'Indiana Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '33', 33, 'Indiana Southern Bankruptcy  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '34', 34, 'Iowa Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '35', 35, 'Iowa Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '36', 36, 'Kansas Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '37', 37, 'Kentucky Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '38', 38, 'Kentucky Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '39', 39, 'Louisiana Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '40', 40, 'Louisiana Middle Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '41', 41, 'Louisiana Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '42', 42, 'Maine Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '43', 43, 'Maryland Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '44', 44, 'Massachusetts Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '45', 45, 'Michigan Eastern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '46', 46, 'Michigan Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '47', 47, 'Mississippi Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '48', 48, 'Mississippi Southern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '49', 49, 'Missouri Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '50', 50, 'Missouri Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '51', 51, 'Montana Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '52', 52, 'Nebraska Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '53', 53, 'Nevada Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '54', 54, 'New Hampshire Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '55', 55, 'New Jersey Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '56', 56, 'New Mexico Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '57', 57, 'New York Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '58', 58, 'New York Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '59', 59, 'New York Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '60', 60, 'New York Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '61', 61, 'North Carolina Eastern Bankruptcy  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '62', 62, 'North Carolina Middle Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '63', 63, 'North Carolina Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '64', 64, 'North Dakota Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '65', 65, 'Ohio Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '66', 66, 'Ohio Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '67', 67, 'Oklahoma Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '68', 68, 'Oklahoma Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '69', 69, 'Oregon Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '70', 70, 'Pennsylvania Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '71', 71, 'Pennsylvania Middle Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '72', 72, 'Pennsylvania Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '73', 73, 'Puerto Rico Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '74', 74, 'Rhode Island Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '75', 75, 'South Carolina Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '76', 76, 'South Dakota Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '77', 77, 'Tennessee Eastern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '78', 78, 'Tennessee Middle Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '79', 79, 'Tennessee Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '80', 80, 'Texas Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '81', 81, 'Texas Northern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '82', 82, 'Texas Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '83', 83, 'Texas Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '84', 84, 'Utah Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '85', 85, 'Vermont Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '86', 86, 'Virginia Eastern Bankruptcy  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '87', 87, 'Virginia Western Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '88', 88, 'Washington Eastern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '89', 89, 'Washington Western Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '90', 90, 'West Virginia Northern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '91', 91, 'West Virginia Southern Bankruptcy Court  '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '92', 92, 'Wisconsin Eastern Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '93', 93, 'Wisconsin Western Bankruptcy Court '         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyCourt', '94', 94, 'Wyoming Bankruptcy Court'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyEntity ', '1', 1, 'Business (Default)'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyEntity ', '2', 2, 'Personal'         /**/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyType', '1', 1, '7'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyType', '2', 2, '11'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyType', '3', 3, '12'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbe_USBankruptcyType', '4', 4, '13'         /*Used to populate prbe_DetailType*/
exec usp_AccpacCreateDropdownValue 'prbt_Name', '1', 1, 'Acquisition'         /**/
exec usp_AccpacCreateDropdownValue 'prbt_Name', '2', 2, 'Agreement In Principle'         /**/
exec usp_AccpacCreateDropdownValue 'prbt_Name', '3', 3, 'Etc.'         /**/

-- Notice that these codes correspond to the prsuu_UsageType values
exec usp_AccpacCreateDropdownValue 'prbr_MethodSent', 'EBR', 2, 'Email'         /**/
exec usp_AccpacCreateDropdownValue 'prbr_MethodSent', 'FBR', 3, 'Fax'         /**/
exec usp_AccpacCreateDropdownValue 'prbr_MethodSent', 'VBR', 4, 'Verbal'         /**/
exec usp_AccpacCreateDropdownValue 'prbr_MethodSent', 'OBR', 5, 'Online'         /**/

exec usp_AccpacCreateDropdownValue 'prcl_BookSection', '0', 1, '0 (For Produce)'         /**/
exec usp_AccpacCreateDropdownValue 'prcl_BookSection', '1', 2, '1 (For Transportation)'         /**/
exec usp_AccpacCreateDropdownValue 'prcl_BookSection', '2', 3, '2 (For Supply)'         /**/
exec usp_AccpacCreateDropdownValue 'prcl_Name', '1', 1, 'Seller'         /**/
exec usp_AccpacCreateDropdownValue 'prcl_Name', '2', 2, 'Broker'         /**/
exec usp_AccpacCreateDropdownValue 'prcl_Name', '3', 3, 'Buying Office'         /**/
exec usp_AccpacCreateDropdownValue 'prcl_Name', '4', 4, 'Procurement Office'         /**/
exec usp_AccpacCreateDropdownValue 'prc3_Brand', '1', 1, 'Dole'         /**/
exec usp_AccpacCreateDropdownValue 'prc3_Brand', '2', 2, 'Chiquita'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '0', 0, '0'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '1', 1, '1-4'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '10', 10, '3000+'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '2', 2, '5-9'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '3', 3, '10-19'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '4', 4, '20-49'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '5', 5, '50-99'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '6', 6, '100-249'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '7', 7, '250-499'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '8', 8, '500-999'         /**/
exec usp_AccpacCreateDropdownValue 'prc2_StoreCount', '9', 9, '1000-2999'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '0', 0, 'Accpac'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '1', 1, 'Agware (Franwell Inc.)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '10', 10, 'Oracle'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '11', 11, 'Peachtree'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '12', 12, 'Peoplesoft'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '13', 13, 'Propack (Integrated Knowledge Group)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '14', 14, 'Prosun Produce System (Unisun)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '15', 15, 'Produce Magic'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '16', 16, 'Produce Pro'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '17', 17, 'Prophet Software'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '18', 18, 'Quickbooks'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '19', 19, 'Simplified Software (Shipper Advantage, Broker Advantage, Distributor Advantage)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '2', 2, 'Cancom'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '20', 20, 'Visual Produce (Silver Creek Software)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '21', 21, 'Custom-Developed Software'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '3', 3, 'Datatech Software'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '4', 4, 'Dproduceman'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '5', 5, 'Edible Software (Solid Software Solutions)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '6', 6, 'Famous Software'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '7', 7, 'Great Plains (Microsoft)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '8', 8, 'Kirkey'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AccountingSoftware', '9', 9, 'Mas90'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_AmountSpent', '0', 0, '$0-$500'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_AccpacCreateDropdownValue 'prc5_AmountSpent', '1', 1, '$501-$1000'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_AccpacCreateDropdownValue 'prc5_AmountSpent', '2', 2, '$1001-$2500'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_AccpacCreateDropdownValue 'prc5_AmountSpent', '3', 3, '$2501-$5000'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_AccpacCreateDropdownValue 'prc5_AmountSpent', '4', 4, '$5001+'         /*prc5_BBAmountSpent, prc5_RBCSAmountSpent, prc5_DBAmountSpent, prc5_ExperianAmountSpent, prc5_CompunetAmountSpent*/
exec usp_AccpacCreateDropdownValue 'prc5_Approver', '0', 0, 'Credit Mgr./Dept.'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_AccpacCreateDropdownValue 'prc5_Approver', '1', 1, 'Sales Mgr.'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_AccpacCreateDropdownValue 'prc5_Approver', '2', 2, 'Sales Person'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_AccpacCreateDropdownValue 'prc5_Approver', '3', 3, 'Owner/Principal'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_AccpacCreateDropdownValue 'prc5_Approver', '4', 4, 'Other'         /*prc5_NewSaleCreditApprover, prc5_CreditIncreaseApprover, prc5_CreditCutoffApprover, prc5_NoPayApprover*/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '0', 0, 'Quality Of Ratings'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '1', 1, 'EBB'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '2', 2, 'Timeliness Of Updates (Cs)'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '3', 3, 'Comprehensive Brs'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '4', 4, 'T/A'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '5', 5, 'Collection Assistance'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '6', 6, 'Pocket Bb'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '7', 7, 'Watchdog Capabilities'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '8', 8, 'Quantity Of Reported Changes'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_BBServiceBenefits', '9', 9, 'Relationship'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_CompunetServiceBenefits', '0', 0, 'Quality Of Business Reports'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_CompunetServiceBenefits', '1', 1, 'Pricing'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_CompunetServiceBenefits', '2', 2, 'Transportation-Focused Services'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_CompunetServiceBenefits', '3', 3, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_DBServiceBenefits', '0', 0, 'Predictive Credit Scores'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_DBServiceBenefits', '1', 1, 'Paydex #'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_DBServiceBenefits', '2', 2, 'Price'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_DBServiceBenefits', '3', 3, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_ExperianServiceBenefits', '0', 0, 'Predictive Credit Scores'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_ExperianServiceBenefits', '1', 1, 'Commercial And Small Business Intelliscores'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_ExperianServiceBenefits', '2', 2, 'Price'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_ExperianServiceBenefits', '3', 3, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RankingUsage', '0', 0, 'First'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_AccpacCreateDropdownValue 'prc5_RankingUsage', '1', 1, 'Second'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_AccpacCreateDropdownValue 'prc5_RankingUsage', '2', 2, 'Third'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_AccpacCreateDropdownValue 'prc5_RankingUsage', '3', 3, 'Fourth'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_AccpacCreateDropdownValue 'prc5_RankingUsage', '4', 4, 'Fifth'         /*prc5_BBRankingUsage, prc5_RBCSRankingUsage, prc5_DBRankingUsage, prc5_ExperianRankingUsage, prc5_CompunetRankingUsage*/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '0', 0, 'Picc'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '1', 1, 'Online Services'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '2', 2, 'Electronic Submissions Of Aging Reports'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '3', 3, 'Business Reports'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '4', 4, 'Quantity Of Listings'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '5', 5, 'Price'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '6', 6, 'Other Vance Publications'         /**/
exec usp_AccpacCreateDropdownValue 'prc5_RBCSServiceBenefits', '7', 7, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_BkrReceive', '2', 2, 'Shipper'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_BkrReceive', '3', 3, 'Buyer'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_BkrReceive', '4', 4, 'Shipper and Buyer'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'PROP', 1, 'Sole Proprietorship'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'COOP', 2, 'Cooperative'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'CORP', 3, 'Corporation'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'LLC', 4, 'Limited Liability Company'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'ULC', 5, 'Unlimited Liability Company'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'LLP', 6, 'Limited Liability Partnership'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'LPART', 7, 'Limited Partnership'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_CorporateStructure', 'PART', 8, 'Partnership'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '0', 0, 'AFSII American Food Safety Institute (Chippewa Falls, WI)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '1', 1, 'Baystate Organic Certifiers (Winchendon, MA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '2', 2, 'Bio Latina -- U.S. Office (Washington, DC)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '3', 3, 'Canadian Organic Certification Cooperative Ltd. (Canada)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '4', 4, 'CCIA California Crop Improvement Association (Davis, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '5', 5, 'CCOF CCOF Certification Services (Santa Cruz, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '6', 6, 'Certified Organic, Inc. (Keosauqua, IA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '7', 7, 'COFA California Organic Farmers Association (Kerman, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '8', 8, 'Colorado Department of Agriculture (Lakewood, CO)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '9', 9, 'CSI Canadian Seed Institute (Canada)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '10', 10, 'D. Grosser and Associates, Ltd. -- U.S. Office of Consorzio Per II Controllo Dei Prodotti Biologici (New York, NY)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '11', 11, 'Fertilizer and Seed Certification Services (Pendleton, SC)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '12', 12, 'Global Culture (Crescent City, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '13', 13, 'Global Organic Alliance, Inc. (Bellefontaine, OH)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '14', 14, 'GOCA Guaranteed Organic Certification Agency (Fallbrook, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '15', 15, 'HOFA Hawaii Organic Farmers Association (Hilo, HI)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '16', 16, 'ICS International Certification Services, Inc. -- dba, Farm Verified Organic and ICS-US (Medina, ND)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '17', 17, 'Idaho State Department of Agriculture (Boise, ID)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '18', 18, 'Indiana Certified Organic (Clayton, IN)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '19', 19, 'Integrity Certified International (Bellevue, NE)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '20', 20, 'Iowa Department of Agriculture (Des Moines, IA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '21', 21, 'Louisiana Department of Agriculture and Forestry (Baton Rouge, LA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '22', 22, 'Marin County (Novato, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '23', 23, 'Maryland Department of Agriculture (Annapolis, MD)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '24', 24, 'MDAC Mississippi Department of Agriculture and Commerce (Jackson, MS)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '25', 25, 'Missouri Department of Agriculture (Jefferson City, MO)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '26', 26, 'MNCIA Minnesota Crop Improvement Association (St. Paul, MN)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '27', 27, 'MOFGA MOFGA Certification Services, LLC (Unity, ME)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '28', 28, 'Montana Department of Agriculture (Helena, MT)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '29', 29, 'Monterey County Certified Organic (Salinas, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '30', 30, 'MOSA Midwest Organic Services Association (Viroqua, WI)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '31', 31, 'MVOAI Maharishi Vedic Organic Agriculture Institute (Fairfield, IA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '32', 32, 'NATFCERT Natural Food Certifiers (Scarsdale, NY)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '33', 33, 'NCCIA North Carolina Crop Improvement Association (Raleigh, NC)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '34', 34, 'Nevada State Department of Agriculture (Reno, NV)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '35', 35, 'New Hampshire Dept. of Agriculture, Markets, & Food (Concord, NH)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '36', 36, 'New Mexico Organic Commodity Commission (Albuquerque, NM)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '37', 37, 'NOAFVT Vermont Organic Farmers, LLC (Richmond, VT)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '38', 38, 'NOFA -- New Jersey (Pennington, NJ)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '39', 39, 'NOFA -- New York, LLC (Binghamton, NY)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '40', 40, 'OCIA Organic Crop Improvement Association (Lincoln, NE)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '41', 41, 'OCPP OCPP/Pro-Cert Canada, Inc. (Canada)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '42', 42, 'ODA Oklahoma Department of Agriculture (Oklahoma City, OK)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '43', 43, 'OEFFA Ohio Ecological Food and Farm Administration (West Salem, OH)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '44', 44, 'OGM Organic Growers of Michigan (Grand Rapids, MI)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '45', 45, 'OPAM Organic Producers Association of Manitoba Cooperative, Inc. (Canada)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '46', 46, 'Oregon Tilth (Salem, OR)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '47', 47, 'Organic Certifiers, Inc. (Ventura, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '48', 48, 'Organic Forum International (Paynesville, MN)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '49', 49, 'Organic National and International Certifiers (Los Angeles, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '50', 50, 'Pennsylvania Certified Organic (Centre Hall, PA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '51', 51, 'QAI Quality Assurance International (San Diego, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '52', 52, 'QCS Quality Certification Services -- Formerly FOG (Gainesville, FL)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '53', 53, 'QMI QMI Organics, Inc. -- formerly QCB Organic, Inc. (Canada)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '54', 54, 'Rhode Island Department of Environmental Management (Providence, RI)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '55', 55, 'Saskatchewan Organic Certification Association, Inc. (Canada)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '56', 56, 'SCS Nutriclean -- Formerly Scientific Certification Systems (Emeryville, CA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '57', 57, 'Stellar Certification Services, Inc. (Junction City, OR)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '58', 58, 'Texas Department of Agriculture (Austin, TX)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '59', 59, 'Utah Department of Agriculture (Salt Lake City, Utah)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '60', 60, 'VDACS Virginia Department of Agriculture (Richmond, VA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_OrganicCertifiedBy', '61', 61, 'Washington State Department of Agriculture (Olympia, WA)'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_SellDomesticAccountTypes', 'F', 1, 'Food Wholesalers' /* PRCompanyProfile */
exec usp_AccpacCreateDropdownValue 'prcp_SellDomesticAccountTypes', 'G', 2, 'Retail Grocers'   /* PRCompanyProfile */
exec usp_AccpacCreateDropdownValue 'prcp_SellDomesticAccountTypes', 'I', 3, 'Institutions'     /* PRCompanyProfile */
exec usp_AccpacCreateDropdownValue 'prcp_SellDomesticAccountTypes', 'R', 4, 'Restaurants'      /* PRCompanyProfile */
exec usp_AccpacCreateDropdownValue 'prcp_SellDomesticAccountTypes', 'M', 5, 'Military'         /* PRCompanyProfile */
exec usp_AccpacCreateDropdownValue 'prcp_SellDomesticAccountTypes', 'D', 6, 'Distributors'     /* PRCompanyProfile */
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '1', 1, '1-49,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '2', 2, '50,000-99,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '3', 3, '100,000-249,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '4', 4, '250,000-499,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '5', 5, '500,000-749,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '6', 6, '750,000-999,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageBushel', '7', 7, '1,000,000 or more'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '1', 1, '1-24'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '2', 2, '25-49'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '3', 3, '50-74'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '4', 4, '75-99'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '5', 5, '100-199'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '6', 6, '200-499'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '7', 7, '500-999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCarlots', '8', 8, '1000 or more'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCF', '1', 1, '1-49,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCF', '2', 2, '50,000-99,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCF', '3', 3, '100,000-499,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCF', '4', 4, '500,000-999,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageCF', '5', 5, '1,000,000 or more'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageSF', '1', 1, '1-9,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageSF', '2', 2, '10,000-24,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageSF', '3', 3, '25,000-49,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageSF', '4', 4, '50,000-99,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageSF', '5', 5, '100,000-249,999'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_StorageSF', '6', 6, '250,000 or more'         /**/
exec usp_AccpacCreateDropdownValue 'TruckEquip', '1', 1, '1-5'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_AccpacCreateDropdownValue 'TruckEquip', '2', 2, '6-10'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_AccpacCreateDropdownValue 'TruckEquip', '3', 3, '11-24'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_AccpacCreateDropdownValue 'TruckEquip', '4', 4, '25-49'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_AccpacCreateDropdownValue 'TruckEquip', '5', 5, '50-99'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_AccpacCreateDropdownValue 'TruckEquip', '6', 6, '100 or more'         /*prcp_TrkrContainer, prcp_TrkrDryVan, prcp_TrkrFlatbed, prcp_TrkrOther, prcp_TrkrPiggyback, prcp_TrkrPowerUnits, prcp_TrkrReefer, prcp_TrkrTanker, prcp_TrkrTrailersLeased, prcp_TrkrTrailersOwned, prcp_TrkrTrucksLeased, prcp_TrkrTrucksOwned*/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '01', 1, '5'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '02', 2, '10'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '03', 3, '15'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '04', 4, '20'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '05', 5, '25'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '06', 6, '40'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '07', 7, '50'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '08', 8, '75'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '09', 9, '100'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '10', 10, '150'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '11', 11, '200'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '12', 12, '250'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '13', 13, '300'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '14', 14, '350'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '15', 15, '400'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '16', 16, '500'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '17', 17, '600'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '18', 18, '700'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '19', 19, '750'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '20', 20, '800'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '21', 21, '900'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '22', 22, '1000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '23', 23, '1250'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '24', 24, '1500'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '25', 25, '1750'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '26', 26, '2000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '27', 27, '2500'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '28', 28, '3000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '29', 29, '4000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '30', 30, '5000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '31', 31, '6000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '32', 32, '7000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '33', 33, '8000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '34', 34, '10000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '35', 35, '15000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '36', 36, '20000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '37', 37, '30000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '38', 38, '40000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '39', 39, '50000'         /**/
exec usp_AccpacCreateDropdownValue 'prcp_Volume', '40', 40, '65000'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_OwnershipDescription ', '1', 1, 'Parent'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_OwnershipDescription ', '2', 2, 'Owner'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_OwnershipDescription ', '3', 3, 'Partner'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_OwnershipDescription ', '4', 4, 'Limited Partner'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_OwnershipDescription ', '5', 5, 'Managing Partner'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_Source', 'A', 4, 'A/R Aging'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_Source', 'TR', 4, 'Trading Assistance'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_Source', 'C', 0, 'Connection List'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_Source', 'T', 1, 'Trade Experience Survey'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_Source', 'P', 2, 'Phone'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_Source', 'E', 3, 'Email'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TransactionFrequency', 'W', 0, 'Weekly'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TransactionFrequency', 'M', 1, 'Monthly'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TransactionFrequency', 'S', 2, 'Seasonally'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TransactionVolume', 'H', 0, 'High'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TransactionVolume', 'M', 1, 'Medium'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TransactionVolume', 'L', 2, 'Low'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_Status', 'N', 1, 'New'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_Status', 'M', 2, 'Modified'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_Status', 'A', 3, 'Approved'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_Status', 'D', 4, 'Do Not Publish'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_Status', 'P', 5, 'Publishable'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_Status', 'K', 6, 'Killed'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_SourceType', 'TX', 1, 'Transaction'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_SourceType', 'PE', 2, 'Person Event'         /**/
exec usp_AccpacCreateDropdownValue 'prcs_SourceType', 'BE', 3, 'Business Event'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '1', 1, '1'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '2', 2, '2'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '3', 3, '3'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '4', 4, '4'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '5', 5, '5'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '6', 6, '6'         /**/
exec usp_AccpacCreateDropdownValue 'prcw_Order', '7', 7, '7'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_BusinessType', '1', 1, 'Wholesaler'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_BusinessType', '2', 2, 'Grower/Shipper'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_LicenseStatus', '1', 1, 'A'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_LicenseStatus', '2', 2, 'E'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_Salutation', '1', 1, 'Mr.'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_Salutation', '2', 2, 'M.'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_Salutation', '3', 3, 'Ms.'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_Salutation', '4', 4, 'Mme.'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_Salutation', '5', 5, 'Sr.'         /**/
exec usp_AccpacCreateDropdownValue 'prdr_Salutation', '6', 6, 'Sra.'         /**/
exec usp_AccpacCreateDropdownValue 'preq_Status', 'O', 1, 'Open'         /**/
exec usp_AccpacCreateDropdownValue 'preq_Status', 'C', 2, 'Closed'         /**/
exec usp_AccpacCreateDropdownValue 'preq_Type', 'TES', 1, 'TES'         /**/
exec usp_AccpacCreateDropdownValue 'preq_Type', 'AR', 2, 'AR'         /**/
exec usp_AccpacCreateDropdownValue 'preq_Type', 'BBScore', 3, 'Bluebook Score'         /**/

exec usp_AccpacCreateDropdownValue 'prfi_AwardClaimantPayer', '1', 1, 'Respondent #1'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_AwardClaimantPayer', '2', 2, 'Repondent #2'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_AwardRespondentPayer', '1', 1, 'Claimant'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_AwardRespondentPayer', '2', 2, 'Respondent #1'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_AwardRespondentPayer', '3', 3, 'Repondent #2'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_CollectionSubCategory', '1', 1, 'Not contested by debtor'
exec usp_AccpacCreateDropdownValue 'prfi_CollectionSubCategory', '2', 2, 'Contested by debtor'
exec usp_AccpacCreateDropdownValue 'prfi_Company1Role', '1', 1, 'Creditor'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Company1Role', '2', 2, 'Debtor'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Company1Role', '3', 3, 'Claimant'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Company1Role', '4', 4, 'Respondent'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_CurrencyType', '1', 1, 'Us Dollars'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_CurrencyType', '2', 2, 'Canadian Dollars'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_CurrencyType', '3', 3, 'Pesos'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_CurrencyType', '4', 4, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_CreditorCollectedReason', 'PF', 1, 'Paid In Full'
exec usp_AccpacCreateDropdownValue 'prfi_CreditorCollectedReason', 'PC', 2, 'Partially Collected'
exec usp_AccpacCreateDropdownValue 'prfi_CreditorCollectedReason', 'C', 3, 'Creditor Mistake/Error'
exec usp_AccpacCreateDropdownValue 'prfi_CreditorCollectedReason', 'O', 4, 'Other'
exec usp_AccpacCreateDropdownValue 'prfi_DocArbitratorShipMethod', '1', 1, 'Fedex (Default)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DocArbitratorShipMethod', '2', 2, 'UPS'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DocArbitratorShipMethod', '3', 3, 'DHL'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DocArbitratorShipMethod', '4', 4, 'Global Priority'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DocArbitratorShipMethod', '5', 5, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DRCArbitrationType', '1', 1, 'Expedited'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DRCArbitrationType', '2', 2, 'Formal'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_DRCArbitrationType', '3', 3, 'Hybrid'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_IssueCategory', '1', 1, 'Dispute (Default)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_IssueCategory', '2', 2, 'Non-Payment'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_IssueCategory', '3', 3, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Language', '1', 1, 'English (Default)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Language', '2', 2, 'Spanish Or French'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_PaperworkLocation', '1', 1, 'All In System'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_PaperworkLocation', '2', 2, 'In Folder'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_PaperworkLocation', '3', 3, 'In Suspense'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_PLANPartnerUsed', '1', 1, 'American Financial Management'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Subtype', '1', 1, 'M File'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Subtype', '2', 2, 'Opinion Letter'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Subtype', '3', 3, 'Dispute'         /**/

exec usp_AccpacCreateDropdownValue 'prfi_Topic', '1', 1, 'Transportation Issue'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '2', 2, 'Commodity Info'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '3', 3, 'USDA Inspection Interpretation'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '4', 4, 'CFIA Inspection Interpretation'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '5', 5, 'Other Inspection Interpretation'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '6', 6, 'USDA Interpretation'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '7', 7, 'Pay Issue'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '8', 8, 'Contractual Disagreement'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Topic', '9', 9, 'Other Produce Issue/Advice'         /**/

exec usp_AccpacCreateDropdownValue 'prfi_Type', 'C', 2, 'Claim'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Type', 'A', 3, 'Advice'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Type', 'M', 4, 'Misc.'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Type', 'O', 4, 'Opinion'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Type', 'D', 4, 'Dispute'         /**/

exec usp_AccpacCreateDropdownValue 'prfi_Status', 'O', 1, 'Open'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_Status', 'C', 2, 'Closed'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '1', 1, 'Pending (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '2', 2, 'Re-opened (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '3', 3, 'Collected (in part), referred out (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '4', 4, 'Invoiced (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '5', 5, 'Not billable (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '6', 6, 'Uncollected/unsettled (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '7', 7, 'Settled (BBS Migration)'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReason', '8', 8, 'Uncollected, referred out (BBS Migration)'         /**/
-- Closing reasons for a collection file.
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'PC', 1, 'PRCo Collected'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'PA', 2, 'Went to PACA'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'MC', 3, 'Mistake by Creditor'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'PL', 4, 'PLAN Partner Collected'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'PU', 5, 'PLAN Partner Could Not Collect'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'PI', 6, 'PRCo Impasse'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'CT', 7, 'Went to Court'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'O',  8, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_ClosingReasonCollection', 'SA', 9, 'Don''t Sign Authorization'         /**/

exec usp_AccpacCreateDropdownValue 'prfi_InquirySource', 'P', 1, 'Phone'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySource', 'F', 2, 'Fax'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySource', 'M', 3, 'Mail'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySource', 'E', 4, 'E-Mail'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySource', 'W', 5, 'Web'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySource', 'O', 5, 'Other'         /**/
-- these values are used by prfi_InquirySource for collection files
exec usp_AccpacCreateDropdownValue 'prfi_InquirySourceCollection', 'AD', 1, 'PRCo Advertisement'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySourceCollection', 'PROMO', 2, 'PRCo Direct Mail Promo'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySourceCollection', 'PAST', 3, 'Used Collections in Past'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySourceCollection', 'BB', 4, 'Referred by BB Member'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySourceCollection', 'PACA', 5, 'Referred by PACA'         /**/
exec usp_AccpacCreateDropdownValue 'prfi_InquirySourceCollection', 'O', 6, 'Other'         /**/


exec usp_AccpacCreateDropdownValue 'prfs_Currency', '1', 1, 'US Dollars'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_Currency', '2', 2, 'Canadian Dollars'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_Currency', '3', 3, 'Pesos'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_EntryStatus', 'N', 1, 'None'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_EntryStatus', 'P', 2, 'Partial'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_EntryStatus', 'F', 3, 'Full'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '1', 1, '1 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '2', 2, '2 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '3', 3, '3 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '4', 4, '4 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '5', 5, '5 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '6', 6, '6 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '7', 7, '7 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '8', 8, '8 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '9', 9, '9 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '10', 10, '10 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_InterimMonth', '11', 11, '11 Month'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_PreparationMethod', 'I', 1, 'Internally Prepared'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_PreparationMethod', 'A', 2, 'Accountant Audited'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_PreparationMethod', 'R', 3, 'Accountant Reviewed'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_PreparationMethod', 'C', 4, 'Accountant Compilation'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_PreparationMethod', 'S', 5, 'SEC Filing'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_PreparationMethod', 'T', 6, 'Income Tax Return'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_Type', 'Y', 1, 'Year-End'         /**/
exec usp_AccpacCreateDropdownValue 'prfs_Type', 'I', 2, 'Interim'         /**/
exec usp_AccpacCreateDropdownValue 'pril_LicenseStatus', '1', 1, 'A'         /**/
exec usp_AccpacCreateDropdownValue 'pril_LicenseStatus', '2', 2, 'E'         /**/
exec usp_AccpacCreateDropdownValue 'prli_Type', 'MC', 1, 'MC'         /**/
exec usp_AccpacCreateDropdownValue 'prli_Type', 'FF', 2, 'FF'         /**/
exec usp_AccpacCreateDropdownValue 'prli_Type', 'CFIA', 3, 'CFIA'         /**/
exec usp_AccpacCreateDropdownValue 'prli_Type', 'DOT', 4, 'DOT'         /**/
exec usp_AccpacCreateDropdownValue 'prli_Type', 'PACA', 5, 'PACA'         /**/
exec usp_AccpacCreateDropdownValue 'prpa_LicenseStatus', 'A', 1, 'Active'         /**/
exec usp_AccpacCreateDropdownValue 'prpa_LicenseStatus', 'E', 2, 'Expired'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_BankruptcyType', '1', 1, 'Chapter 7'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_BankruptcyType', '2', 2, 'Chapter 11'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_BankruptcyType', '3', 3, 'Chapter 12'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_BankruptcyType', '4', 4, 'Chapter 13'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_DischargeType', '1', 1, 'Dismissed'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_DischargeType', '2', 2, 'Discharged'         /**/
exec usp_AccpacCreateDropdownValue 'prpe_DischargeType', '3', 3, 'Closed'         /**/
exec usp_AccpacCreateDropdownValue 'prpt_Name', '1', 1, 'Acquisition'         /**/
exec usp_AccpacCreateDropdownValue 'prpt_Name', '2', 2, 'Agreement In Principle'         /**/
exec usp_AccpacCreateDropdownValue 'prpr_Source', '1', 1, 'Phone'         /**/
exec usp_AccpacCreateDropdownValue 'prpr_Source', '2', 2, 'Email'         /**/
exec usp_AccpacCreateDropdownValue 'prrn_Type', 'L', 0, 'Legal Status and Payment Practice'         /**/
exec usp_AccpacCreateDropdownValue 'prrn_Type', 'A', 1, 'Affliation / Business Relationship'         /**/
exec usp_AccpacCreateDropdownValue 'prrn_Type', 'T', 2, 'Trading Experience'         /**/
exec usp_AccpacCreateDropdownValue 'prrn_Type', 'R', 3, 'Rating, Listing, Licensing, and Operating Status'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'CT', 0, 'Confirmed Trading Activity'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'IT', 1, 'Inferred Trading Activity'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'CR', 2, 'Company Relationship'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'PR', 3, 'Person Relationship'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'SA', 4, 'Strategic Alliance'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'LI', 5, 'Litigation'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Category', 'UN', 6, 'Unknown'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Name', '1', 1, 'Buyer'         /**/
exec usp_AccpacCreateDropdownValue 'prrt_Name', '2', 2, 'Freight Provider'         /**/
exec usp_AccpacCreateDropdownValue 'prex_Name', '2', 2, 'NASDAQ'         /**/
exec usp_AccpacCreateDropdownValue 'prex_Name', '3', 3, 'TSE'         /**/
exec usp_AccpacCreateDropdownValue 'prex_Name', '4', 4, 'AMEX'         /**/
exec usp_AccpacCreateDropdownValue 'prex_Name', '5', 5, 'OTCBB'         /**/
exec usp_AccpacCreateDropdownValue 'prex_Name', '1', 1, 'NYSE'         /**/
exec usp_AccpacCreateDropdownValue 'prte_CustomTESRequest', '1', 1, 'Select all companies that have reported a pay description of D, E or F'         /**/
exec usp_AccpacCreateDropdownValue 'prte_CustomTESRequest', '2', 2, 'Randomly select companies on connection list '         /**/
exec usp_AccpacCreateDropdownValue 'prte_CustomTESRequest', '3', 3, 'Randomly select companies that submitted trade reports'         /**/
exec usp_AccpacCreateDropdownValue 'prte_CustomTESRequest', '4', 4, 'Select companies that have not received survey in last 60 days'         /**/
exec usp_AccpacCreateDropdownValue 'prte_CustomTESRequest', '5', 5, 'Select specific companies with relationship '         /**/
exec usp_AccpacCreateDropdownValue 'prtr_AmountPastDue', 'A', 1, 'None'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_AmountPastDue', 'B', 2, 'Less Than 25M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_AmountPastDue', 'C', 3, '25M To 100M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_AmountPastDue', 'D', 4, 'Over 100M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_CreditTerms', 'A', 1, '10 Days'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_CreditTerms', 'B', 2, '21 Days'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_CreditTerms', 'C', 3, '30 Days'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_CreditTerms', 'D', 4, 'Beyond 30 Days'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_HighCredit', 'A', 1, '5-10M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_HighCredit', 'B', 2, '10-50M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_HighCredit', 'C', 3, '50-75M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_HighCredit', 'D', 4, '75-100M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_HighCredit', 'E', 5, '100-250M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_HighCredit', 'F', 6, 'Over 250M'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LastDealtDate', 'A', 1, '1-6 Months'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LastDealtDate', 'B', 2, '7-12 Months'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LastDealtDate', 'C', 3, 'Over 1 Year'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LoadsPerYear', 'A', 1, '1-24'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LoadsPerYear', 'B', 2, '25-50'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LoadsPerYear', 'C', 3, '50-100'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_LoadsPerYear', 'D', 4, 'Over 100'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_OverallTrend', 'I', 1, 'Improving'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_OverallTrend', 'U', 2, 'Unchanged'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_OverallTrend', 'D', 3, 'Declining'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Pack', 'S', 1, 'Superior'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Pack', 'A', 2, 'Average'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Pack', 'G', 3, 'Good'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Pack', 'F', 4, 'Fair'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipLength', 'B', 1, 'Under 1 Year'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipLength', 'C', 2, '1-10 Years'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipLength', 'D', 3, '10+ Years'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'SH', 1, 'Shipper'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'BR', 2, 'Broker'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'DR', 3, 'Distributor/Receiver'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'CS', 4, 'Chain Store'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'IM', 5, 'Importer/Exporter'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'CA', 6, 'Carrier'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'TB', 7, 'Transporation Broker'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'FC', 8, 'Freight Contractor'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_RelationshipType', 'FF', 9, 'Freight Forwarder'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Terms', '1', 1, 'COD'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Terms', '2', 2, 'Firm Price'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Terms', '3', 3, 'Consignment'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_Terms', '4', 4, 'FOB'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_ResponseSource', 'T', 1, 'TES Form'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_ResponseSource', 'W', 2, 'Web Site Submission'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_ResponseSource', 'E', 3, 'EBB Submission'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_ResponseSource', 'A', 4, 'A/R Aging'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_ResponseSource', 'R', 5, 'Relationship Entry'         /**/
exec usp_AccpacCreateDropdownValue 'prtr_ResponseSource', 'M', 6, 'Manual Entry'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '0', 0, 'PRCo Initiated'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '1', 1, 'Responded To LRL'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '2', 2, 'Responded To Custom PRCo Communication'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '3', 3, 'Responded To Promotion'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '4', 4, 'Unsolicited'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '5', 5, 'Responded To DL Statement'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '6', 6, 'Responded To BBS Invoice/Statement'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '7', 7, 'Result Of New Sale/Membership'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationStimulus', '8', 8, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'P', 1, 'Phone'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'F', 2, 'Fax'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'E', 3, 'E-Mail'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'M', 4, 'Mail'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'PV', 5, 'Personal Visit'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'CV', 6, 'Convention Visit'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_NotificationType', 'O', 7, 'Other'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_Status', 'O', 0, 'Open'         /**/
exec usp_AccpacCreateDropdownValue 'prtx_Status', 'C', 1, 'Closed'         /**/
exec usp_AccpacCreateDropdownValue 'prtd_ColumnType', 'T', 1, 'Text'         /**/
exec usp_AccpacCreateDropdownValue 'prtd_ColumnType', 'D', 2, 'Date'         /**/
exec usp_AccpacCreateDropdownValue 'prtd_ColumnType', 'I', 3, 'Integer'         /**/
exec usp_AccpacCreateDropdownValue 'prtd_ColumnType', 'N', 4, 'Numeric'         /**/
exec usp_AccpacCreateDropdownValue 'prtd_ColumnType', 'B', 5, 'Boolean'         /**/
exec usp_AccpacCreateDropdownValue '_DisputeInvolvedSelect', 'Y', 1, 'Yes'         /*Supports Filtering on Trade Report Screen*/
exec usp_AccpacCreateDropdownValue '_DisputeInvolvedSelect', 'N', 2, 'No'         /*Supports Filtering on Trade Report Screen*/
exec usp_AccpacCreateDropdownValue '_ExceptionSelect', 'Y', 1, 'Yes'         /*Supports Filtering on Trade Report Screen*/
exec usp_AccpacCreateDropdownValue '_ExceptionSelect', 'N', 2, 'No'         /*Supports Filtering on Trade Report Screen*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '1', 1, 'Mexico'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '10', 10, 'Caribbean'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '2', 2, 'Central America'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '3', 3, 'South America'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '4', 4, 'Europe'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '5', 5, 'Asia'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '6', 6, 'Middle East'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '7', 7, 'Africa'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '8', 8, 'Australia/ New Zealand'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'ExporterRegion', '9', 9, 'Pacific Rim'         /*prcp_SellExportersRegion, prcp_SrcBuyExportersRegion*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '1', 1, '1-4'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '2', 2, '5-9'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '3', 3, '10-19'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '4', 4, '20-49'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '5', 5, '50-99'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '6', 6, '100-249'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '7', 7, '250-499'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '8', 8, '500-999'         /*prcp_FTEmployees, prcp_PTEmployees*/
exec usp_AccpacCreateDropdownValue 'NumEmployees', '9', 9, '1000+'         /*prcp_FTEmployees, prcp_PTEmployees*/

-- used to provide a dropdown allowing the user to filter on which side of the relationship is reporting
exec usp_AccpacCreateDropdownValue 'prcr_ReportingCompanyType', '1', 2, 'Subject Company'
exec usp_AccpacCreateDropdownValue 'prcr_ReportingCompanyType', '2', 3, 'Related Company'

--Used in the Company Relationship Summary Filter panel for type
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '01', 1, '01-- Company X reports trade experience with Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '04', 2, '04-- Company X reports AR Aging data on Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '05', 3, '05-- Company X reports dispute with Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '07', 4, '07-- Company X reports collection with Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '09', 5, '09-- Company X reports buying produce from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '10', 6, '10-- Company X reports providing freight service for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '11', 7, '11-- Company X reports receiving freight service from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '12', 8, '12-- Company X reports buying supplies from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '13', 9, '13-- Company X reports selling produce to Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '14', 10, '14-- Company X reports providing brokerage services for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '16', 12, '16-- Company X reports receiving brokerage services from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '15', 11, '15-- Company X reports generic trading relationship with Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '23', 13, '23-- Company X requests AUS/Watchdog services on Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '25', 14, '25-- Company X requests business report on Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '27', 15, '27-- Company X has 100% ownership in Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '28', 16, '28-- Company X has 1-99% ownership in Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '29', 17, '29-- Company X shares individual ownership with Company Y (affiliation)'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '30', 18, '30-- Company X handles sales for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '31', 19, '31-- Company X handles buying for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '32', 20, '32-- Company X provides warehouse/cold storage services for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '33', 21, '33-- Company X filed PACA Action against Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '34', 22, '34-- Company X filed non-PACA lawsuit against Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeFilter', '35', 23, '35-- Company X has unknown relationship with Company Y'         /**/

-- Used in the New Company Relationship-- Trx Open Screen
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '09', 1, '09-- Company X reports buying produce from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '10', 2, '10-- Company X reports providing freight service for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '11', 3, '11-- Company X reports receiving freight service from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '12', 4, '12-- Company X reports buying supplies from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '13', 5, '13-- Company X reports selling produce to Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '14', 6, '14-- Company X reports providing brokerage services for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '16', 8, '16-- Company X reports receiving brokerage services from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '15', 7, '15-- Company X reports generic trading relationship with Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '23', 9, '23-- Company X requests AUS/Watchdog services on Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '25', 10, '25-- Company X requests business report on Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '27', 11, '27-- Company X has 100% ownership in Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '28', 12, '28-- Company X has 1-99% ownership in Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '30', 13, '30-- Company X handles sales for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '31', 14, '31-- Company X handles buying for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '32', 15, '32-- Company X provides warehouse/cold storage services for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeOpenTrans', '35', 16, '35-- Company X has unknown relationship with Company Y'         /**/

--  Used in the Company Relationship Summary Filter Panel for Category
exec usp_AccpacCreateDropdownValue 'prcr_CategoryType', '1', 1, 'Confirmed Trading Relationship'
exec usp_AccpacCreateDropdownValue 'prcr_CategoryType', '2', 2, 'Connection List'
exec usp_AccpacCreateDropdownValue 'prcr_CategoryType', '3', 3, 'Blue Book Reports'
exec usp_AccpacCreateDropdownValue 'prcr_CategoryType', '4', 4, 'Ownership'
exec usp_AccpacCreateDropdownValue 'prcr_CategoryType', '5', 5, 'Strategic Alliance'
exec usp_AccpacCreateDropdownValue 'prcr_CategoryType', '6', 6, 'Litigation'

-- Used in the New Company Relationship-- NO OPEN TRANSACTION
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '09', 1, '09-- Company X reports buying produce from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '10', 2, '10-- Company X reports providing freight service for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '11', 3, '11-- Company X reports receiving freight service from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '12', 4, '12-- Company X reports buying supplies from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '13', 5, '13-- Company X reports selling produce to Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '14', 6, '14-- Company X reports providing brokerage services for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '16', 8, '16-- Company X reports receiving brokerage services from Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '15', 7, '15-- Company X reports generic trading relationship with Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '30', 9, '30-- Company X handles sales for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '31', 10, '31-- Company X handles buying for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '32', 11, '32-- Company X provides warehouse/cold storage services for Company Y'         /**/
exec usp_AccpacCreateDropdownValue 'prcr_TypeNoTrans', '35', 12, '35-- Company X has unknown relationship with Company Y'         /**/

exec usp_AccpacCreateDropdownValue 'prd2_Type', 'D', 1, 'Domestic'         /* PRRegion */
exec usp_AccpacCreateDropdownValue 'prd2_Type', 'I', 2, 'International'    /* PRRegion */

exec usp_AccpacCreateDropdownValue 'emai_Type', 'E', 1, 'E-Mail'    /* Email */
exec usp_AccpacCreateDropdownValue 'emai_Type', 'W', 2, 'Web Site' /* Email */

exec usp_AccpacCreateDropdownValue 'prsp_Activity', 'A', 1, 'Adjustment' /* PRServicePayment */
exec usp_AccpacCreateDropdownValue 'prsp_Activity', 'C', 2, 'Credit' /* PRServicePayment */
exec usp_AccpacCreateDropdownValue 'prsp_Activity', 'I', 3, 'Invoice' /* PRServicePayment */
exec usp_AccpacCreateDropdownValue 'prsp_Activity', 'P', 4, 'Payment' /* PRServicePayment */
exec usp_AccpacCreateDropdownValue 'prsp_Activity', 'X', 5, 'Prepayment' /* PRServicePayment */

exec usp_AccpacCreateDropdownValue 'prse_DeliveryMethod', 'M', 1, 'Mail' /* PRService */
exec usp_AccpacCreateDropdownValue 'prse_DeliveryMethod', 'S', 2, 'Ship' /* PRService */

exec usp_AccpacCreateDropdownValue 'comm_Action', 'MT', 51, 'Meeting' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_Action', 'OT', 52, 'Other' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_Action', 'M', 53, 'Mail (BBS Migration)' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_Action', 'P', 54, 'Phone (BBS Migration)' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_Action', 'E', 55, 'E-Mail (BBS Migration)' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_Action', 'F', 56, 'Fax (BBS Migration)' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_Action', 'O', 57, 'Other (BBS Migration)' /* Communication */

exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'R', 1, 'Rating' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'C', 2, 'Content' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'P', 3, 'Publishing' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'SM', 4, 'Sales & Marketing' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'FS', 5, 'Field Sales' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'BD', 6, 'Business Development' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'CS', 7, 'Customer Service' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'SS', 8, 'Special Services' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRCategory', 'O', 9, 'Other' /* Communication */

exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'CI', 1, 'Custom Investigation' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'UF', 2, 'Updated Financials' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'RR', 3, 'Rating Review' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'TMR', 4, 'Trading Member Review' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'JL1', 5, 'Jeopardy Letter 1' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'JL2', 6, 'Jeopardy Letter 2' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'JL3', 7, 'Jeopardy Letter 3' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'AUS', 8, 'AUS Report' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'CSS', 9, 'Customer Service Survey' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'SSL', 10, 'Special Services Letter' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'VI', 11, 'Verbal Investigation' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'O', 12, 'Other' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'SSN', 13, 'Special Services Notes (BBS Migration)' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'RD', 14, 'Recent Developments (BBS Migration)' /* Communication */
exec usp_AccpacCreateDropdownValue 'comm_PRSubCategory', 'HN', 15, 'Hot Notes (BBS Migration)' /* Communication */

exec usp_AccpacCreateDropdownValue 'prun_SourceType', 'C', 1, 'CSR' /* PRServiceUnitAllocation */
exec usp_AccpacCreateDropdownValue 'prun_SourceType', 'O', 2, 'Online' /* PRServiceUnitAllocation */

exec usp_AccpacCreateDropdownValue 'prun_AllocationType', 'M', 1, 'Membership' /* PRServiceUnitAllocation */
exec usp_AccpacCreateDropdownValue 'prun_AllocationType', 'A', 2, 'Additional Unit Pack' /* PRServiceUnitAllocation */
exec usp_AccpacCreateDropdownValue 'prun_AllocationType', 'P', 3, 'Promotion' /* PRServiceUnitAllocation */

exec usp_AccpacCreateDropdownValue 'prsuu_SourceCode', 'C', 1, 'CSR' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_SourceCode', 'O', 2, 'Online' /* PRServiceUnitUsage */

exec usp_AccpacCreateDropdownValue 'prsuu_TransactionTypeCode', 'U', 1, 'Usage' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_TransactionTypeCode', 'R', 2, 'Reversal' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_TransactionTypeCode', 'C', 3, 'Cancelled' /* PRServiceUnitUsage */

exec usp_AccpacCreateDropdownValue 'prsuu_ReversalReasonCode', 'D', 1, 'Duplicate' /* prsuu_ReversalReason */
exec usp_AccpacCreateDropdownValue 'prsuu_ReversalReasonCode', 'E', 2, 'Customer Error' /* prsuu_ReversalReason */
exec usp_AccpacCreateDropdownValue 'prsuu_ReversalReasonCode', 'O', 2, 'Other' /* prsuu_ReversalReason */

exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'VBR', 1, 'Verbal Business Report' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'FBR', 2, 'Fax Business Report' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'EBR', 3, 'E-Mail Business Report' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'MBR', 4, 'Mail Business Report' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'OBR', 5, 'Online Business Report' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'OML', 6, 'Online Marketing List' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'OS', 7, 'Online Search' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_UsageTypeCode', 'C', 8, 'Cancelled' /* PRServiceUnitUsage */

exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'VBR', 1, '0' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'FBR', 2, '20' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'EBR', 3, '20' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'MBR', 4, '20' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'OBR', 5, '20' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'OML', 6, '0' /* PRServiceUnitUsage */
exec usp_AccpacCreateDropdownValue 'prsuu_Units', 'OS', 7, '0' /* PRServiceUnitUsage */

exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'AB/SK', 1, 'Alberta/Saskatchewan' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'AK', 2, 'Alaska' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'AL', 3, 'Alabama' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'AR', 4, 'Arkansas' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'ATLANTIC', 5, 'New Brunswick/Nova Scotia/PEI/Newfoundland' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'AZ', 6, 'Arizona' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'BC', 7, 'British Columbia' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-H1', 8, 'Stockton, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-H2', 9, 'Sebastopol, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-H3', 10, 'Sacramento/San Francisco, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L1', 11, 'Oxnard, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L10', 12, 'Orange County, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L11', 13, 'Los Angeles, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L2', 14, 'Santa Maria, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L3', 15, 'Imperial Valley, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L4', 16, 'Coachella, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L5', 17, 'Salinas, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L6', 18, 'San Joaquin, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L7', 19, 'Riverside/San Bernardino, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L8', 20, 'Delano, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CA-L9', 21, 'Bakersfield/San Diego, CA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CO', 22, 'Colorado' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'CT', 23, 'Connecticut' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'DC/RI', 24, 'Washington, D.C./Rhode Island' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'DE', 25, 'Delaware' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-1', 26, 'Pompano Beach/Ruskin/Sarasota, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-10', 27, 'Belle Glade/Homestead, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-11', 28, 'Fort Myers/Immokalee, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-2', 29, 'Orlando, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-3', 30, 'Hastings/Jacksonville, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-4', 31, 'Pensacola/Tallahassee, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-5', 32, 'Tampa, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-6', 33, 'Miami, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-7', 34, 'Fort Pierce/Vero Beach, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-8', 35, 'Lake Wales/Ocala, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FL-9', 36, 'Lakeland/Plant City, FL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'FOREIGN', 37, 'Other than US/Canada/Mexico/Puerto Rico' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'GA', 38, 'Georgia' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'HI', 39, 'Hawaii' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'IA', 40, 'Iowa' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'ID', 41, 'Idaho' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'IL', 42, 'Illinois' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'IN', 43, 'Indiana' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'KS', 44, 'Kansas' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'KY', 45, 'Kentucky' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'LA', 46, 'Louisiana' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MA', 47, 'Massachusetts' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MB', 48, 'Manitoba' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MD', 49, 'Maryland' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'ME', 50, 'Maine' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MI', 51, 'Michigan' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MN', 52, 'Minnesota' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MO', 53, 'Missouri' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MS', 54, 'Mississippi' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MT', 55, 'Montana' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MX-1', 56, 'Mexico 1' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MX-2', 57, 'Mexico 2' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MX-3', 58, 'Mexico 3' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MX-4', 59, 'Mexico 4' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'MX-5', 60, 'Mexico 5' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NC', 61, 'North Carolina' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'ND/SD', 62, 'North Dakota/South Dakota' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NE', 63, 'Nebraska' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NH', 64, 'New Hampshire' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NJ', 65, 'New Jersey' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NM', 66, 'New Mexico' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NV', 67, 'Nevada' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NW TERR', 68, 'Northwest Territory (Canadian Province)' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'NY', 69, 'New York' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'OH', 70, 'Ohio' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'OK', 71, 'Oklahoma' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'ON', 72, 'Ontario' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'OR', 73, 'Oregon' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'PA', 74, 'Pennsylvania' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'PR', 75, 'Puerto Rico' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'QC', 76, 'Quebec' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'SC', 77, 'South Carolina' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'TN', 78, 'Tennessee' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'TX-1', 79, 'Dallas/Fort Worth, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'TX-3', 80, 'San Antonio/Amarillo/El Paso, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'TX-4', 81, 'Laredo/Northeast, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'TX-5', 82, 'Houston, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'TX/RIO-2', 83, 'Rio Grande Valley, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'UT', 84, 'Utah' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'VA', 85, 'Virginia' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'VT', 86, 'Vermont' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'WA', 87, 'Washington state' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'WI', 88, 'Wisconsin' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'WV', 89, 'West Virginia' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_RatingTerritory', 'WY', 90, 'Wyoming' /* PRCity */

exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-51-01', 1, 'NORTH WEST MEXICO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-51-02', 2, 'NORTH CENTRAL MEXICO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-51-03', 3, 'CENTRAL MEXICO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-51-04', 4, 'SOUTH CENTRAL MEXICO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-51-05', 5, 'SOUTH MEXICO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-52-01', 6, 'CENTRAL AMERICA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-53-01', 7, 'SOUTH AMERICA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-54-01', 8, 'ENGLAND' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-55-01', 9, 'EUROPE' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-56-01', 10, 'PACIFIC RIM' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-57-01', 11, 'CARRIBEAN' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'IN-58-01', 12, 'AFRICA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-01-01', 13, 'SOUTHWEST ILLINOIS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-02-01', 14, 'N. MO & N.E. KS: ST. LOUIS & KANSAS CITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-03-01', 15, 'N. KY & OH' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-04-01', 16, 'NEBRASKA & IOWA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-05-01', 17, 'S.W. T/MKT; CHICAGO & METRO AREA; GARY & M.W. IN' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-06-01', 18, 'DETROIT RECEIVERS & S.E. MI GROWERS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-07-01', 19, 'W. MI: SHIPPING & LTD. RECEIVING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-08-01', 20, 'CENTRAL WI & U.P., MI - POTATO SHIPP REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-09-01', 21, 'MINNEAPOLIS/ST. PAUL, MN & W. WI' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-10-01', 22, 'NORTHERN ILLINOIS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-11-01', 23, 'RED RIVER ; ND, SD, ID, MB: POTATO SHIP' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-12-01', 24, 'S.E. WI (MILWAUKEE)' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-13-01', 25, 'INDIANA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-14-01', 26, 'KENTUCKY (LOUISVILLE)' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'MW-15-01', 27, 'S.E. ILLINOIS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-01-01', 28, 'NEW YORK - BUFFALO/ROCHESTER AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-02-01', 29, 'BROOKLYN MARKETS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-03-01', 30, 'BOSTON/NEW HAMPSHIRE/RHODE ISLAND/VERMONT' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-04-01', 31, 'NEW JERSEY - MARKETS SOUTH & SHIPPING WEST' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-05-01', 32, 'NEW JERSEY - SOUTH JERSEY SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-06-01', 33, 'ONTARIO - TORONTO AREA/HAMILTON AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-07-01', 34, 'PENNSYLVANIA - WEST #2 (PITTSBURG)' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-08-01', 35, 'NEW YORK - HUDSON VALLEY AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-09-01', 36, 'PENNSYLVANIA - WEST #1 (ERIE)' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-10-01', 37, 'NEW YORK - WESTERN NEW YORK SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-11-01', 38, 'NEW YORK - BINGHAMTON/ELMIRA AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-12-01', 39, 'NEW YORK - POTATO & DRIED BEAN AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-13-01', 40, 'ONTARIO SHIPPING - BRANTFORD AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-14-01', 41, 'ONTARIO SHIPPING - BRADFORD AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-15-01', 42, 'ONTARIO SHIPPING - LONDON AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-16-01', 43, 'ONTARIO SHIPPING - LEAMINGTON AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-17-01', 44, 'NEW YORK CITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-17-02', 45, 'NEW YORK CITY - NY VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-18-01', 46, 'NEW YORK - LONG ISLAND/SUFFOLK CTY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-19-01', 47, 'NEW YORK - ORANGE COUNTY AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-20-01', 48, 'NEW JERSEY - MARKET- NORTH SECTION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-21-01', 49, 'ONTARIO - OTTAWA AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-22-01', 50, 'PENSYLVANIA - EAST #1 & #2' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-23-01', 51, 'QUEBEC AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-24-01', 52, 'QUEBEC - MONTREAL AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-25-01', 53, 'NEW YORK - SYRACUSE AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-26-01', 54, 'NEW YORK - UTICA AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-27-01', 55, 'CONNECTICUT/WEST MASSACHUSETTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-28-01', 56, 'NEW YORK - ALBANY AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-29-01', 57, 'MAINE' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-30-01', 58, 'ATLANTIC PROVIDENCES' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-31-01', 59, 'PENNSYLVANIA - EAST #5 & #6' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-32-01', 60, 'NEW YORK CITY VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'NE-33-01', 61, 'PENNSYLVANIA - EAST #3 & #4' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-01-01', 62, 'AK' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-02-01', 63, 'DC, MD, VA - PRIMARY RECEIVING MARKETS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-03-01', 64, 'WV & WESTERN VA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-04-01', 65, 'SHENANDOAH APPLE SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-05-01', 66, 'DE SHIPPING & NORFOLK, VA RECEIVING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-06-01', 67, 'WESTERN WV' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-07-01', 68, 'CENTRALl & EASTERN TN' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-08-01', 69, 'HI' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-09-01', 70, 'WY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'OP-10-01', 71, 'EASTERN WV' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-01-01', 72, 'BELLE GLADE, FL: SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-02-01', 73, 'HOMESTEAD, FL: VEG SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-03-01', 74, 'MIAMI, FL: RECEIVING, IMPORT/EXPORT' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-04-01', 75, 'VIDALIA/SAVANNAH, GA: ONION SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-05-01', 76, 'RUSKIN/SARASOTA, FL: POM/PIT SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-06-01', 77, 'THOMASVILLE/MACON, GA: VEG SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-07-01', 78, 'ORLANDO, FL: RECEIVING, LTD. SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-08-01', 79, 'JACKSONVILLE, FL: RECEIVING & HASTINGS, FL: SHIP' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-09-01', 80, 'PENSACOLA/TALLAHASSEE, FL & AL' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-10-01', 81, 'SOUTH CAROLINA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-11-01', 82, 'NORTH CAROLINA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-12-01', 83, 'NORTH, GA (ATLANTA): T/MKT. & METRO RECEIVING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-13-01', 84, 'TAMPA, FL: RECEIVING & LTD. SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-14-01', 85, 'VERO BEACH/FT. PIERCE, FL: CITRUS SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-15-01', 86, 'LAKELAND/PLANT CITY, FL: ST & VEG. SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-16-01', 87, 'LAKE WALES, FL: F & V SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-17-01', 88, 'OCALA, FL: RECEIVING & LTD. BERRY SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-18-01', 89, 'POMPANO BEACH, FL: VEG SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-19-01', 90, 'FORT MYERS/IMMOKALEE, FL: TOM & VEG SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SE-20-01', 91, 'PUERTO RICO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-01-01', 92, 'OKLAHOMA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-02-01', 93, 'MISSISSIPPI' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-03-01', 94, 'LOWER MISSOURI' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-04-01', 95, 'TENNESSEE/KENTUCKY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-05-01', 96, 'ARKANSAS-LITTLE ROCK & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-05-02', 97, 'ARKANSAS-NORTHWEST REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-05-03', 98, 'ARKANSAS-NORTHEAST REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-05-04', 99, 'ARKANSAS-SOUTHWEST REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-05-05', 100, 'ARKANSAS-SOUTHEAST REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-06-01', 101, 'NEW ORLEANS & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-06-02', 102, 'LOUISIANA-NORTHERN REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-06-03', 103, 'LOUISIANA-SOUTHERN REGION' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-07-01', 104, 'FORT WORTH, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-08-01', 105, 'DENVER & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-08-02', 106, 'COLORADO-PUEBLO, COLORADO SP & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-08-03', 107, 'COLORADO-SAN LUIS VALLEY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-08-04', 108, 'COLORADO-GRAND JUNCTION & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-09-01', 109, 'AMARILLO/LUBBOCK, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-10-01', 110, 'SAN ANTONIO, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-11-01', 111, 'DALLAS, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-12-01', 112, 'RIO GRANDE VALLEY, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-13-01', 113, 'LAREDO, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-14-01', 114, 'WACO/AUSTIN/TEMPLE, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-15-01', 115, 'NORTHEAST, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-16-01', 116, 'HOUSTON, TX' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'SW-17-01', 117, 'KANSAS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-01', 118, 'L.A. CTY, CA: BEVERLY HILLS AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-02', 119, 'L.A. CTY, CA: BURBANK AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-03', 120, 'L.A. CTY, CA: SHERMAN OAKS AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-04', 121, 'L.A. CTY, CA: LONG BEACH AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-05', 122, 'L.A. CTY, CA: VERNON AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-06', 123, 'L.A. CTY, CA: LAWNDALE AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-07', 124, 'L.A. CTY, CA: COMPTON AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-08', 125, 'L.A. CTY, CA: SOUTH PAZADENA AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-09', 126, 'L.A. CTY, CA: CITY OF INDUSTRY AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-10', 127, 'L.A. CTY, CA: EL MONTE AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-11', 128, 'L.A. CTY, CA: CITY OF COMMERCE AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-12', 129, 'L.A. CTY, CA: NORWALK AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-01-13', 130, 'L. A. REVISION & CALL REPORTS (CITY ONLY)' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-02-01', 131, 'SANTA MARIA & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-03-01', 132, 'OXNARD & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-04-01', 133, 'SALINAS & VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-05-01', 134, 'BAKERSFIELD' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-06-01', 135, 'NORTH LOS ANGELES COUNTY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-07-01', 136, 'COACHELLA VALLEY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-08-01', 137, 'DELANO/PORTERVILLE' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-09-01', 138, 'RIVERSIDE & SAN BERNARDINO COUNTIES' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-10-01', 139, 'SAN DIEGO, CA & SOUTHERN VICINITY' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-10-02', 140, 'SAN DIEGO, CA: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-11-01', 141, 'PHOENIX, AZ & SURROUNDING AREAS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-12-01', 142, 'CA: ORANGE COUNTY - NORTH' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-12-02', 143, 'CA: ORANGE COUNTY - SOUTH' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-13-01', 144, 'AZ/NM/TX/S.W. CO' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-14-01', 145, 'CA & YUMA, AZ: IMPERIAL VALLEY: SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WC-15-01', 146, 'NOGALES & AREA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-01-01', 147, 'MONTANA - ALBERTA & SASKATACHEWAN' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-02-01', 148, 'NORTH CA (SAN FRAN.): 2 T/MKT. & METRO REC' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-03-01', 149, 'SEBASTOPOL, CA: FRUIT SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-03-02', 150, 'COASTAL NORTHERN CALIFORNIA' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-04-01', 151, 'SACRAMENTO, CA & NV: RECEIVING AREA & LTD' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-05-01', 152, 'UT - SOUTHWEST, NV' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-06-01', 153, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-06-02', 154, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-06-03', 155, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-06-04', 156, 'CA: SAN JOAQUIN VALLEY: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-07-01', 157, 'NW NV/W CENT ID/EASTERN OR' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-08-01', 158, 'STOCKTON, CA: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-09-01', 159, 'CENT & N CENT, WA/CENT BC' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-10-01', 160, 'WESTERN OR/CENT/N. CENT/N.E., OR: SHIPPING' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-11-01', 161, 'E WA/N-WEST. ID/E BC: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-12-01', 162, 'NORTH CENTRAL CA: SHIPPING DISTRICTS' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-13-01', 163, 'WESTERN OR/WESTERN WA/WESTERN BC' /* PRCity */
exec usp_AccpacCreateDropdownValue 'prci_SalesTerritory', 'WD-14-01', 164, 'SOUTH CENTRAL & EASTERN ID' /* PRCity */

exec usp_AccpacCreateDropdownValue 'AssignmentUserID', 'Survey', 0, '1' /*  The UserID of the user to send out surveys. Used by BBSInterface */
exec usp_AccpacCreateDropdownValue 'AssignmentUserID', 'UnknownAlaCarteOrder', 0, '49' /* The UserID of the inside sales rep to use when the region is unknown. Used by BBSInterface */
exec usp_AccpacCreateDropdownValue 'AssignmentUserID', 'DataProcessor', 0, '44' /* */


exec usp_AccpacCreateDropdownValue 'prtf_FormType', 'SE', 1, 'Single English' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_FormType', 'SS', 3, 'Single Spanish' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_FormType', 'SI', 5, 'Single International' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_FormType', 'ME', 2, 'Multiple English' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_FormType', 'MS', 4, 'Multiple Spanish' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_FormType', 'MI', 6, 'Multiple International' /* PRTESForm */

exec usp_AccpacCreateDropdownValue 'prtf_SentMethod', 'F', 0, 'Fax' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_SentMethod', 'M', 1, 'Mail' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_SentMethod', 'E', 2, 'E-Mail' /* PRTESForm */

exec usp_AccpacCreateDropdownValue 'prtf_ReceivedMethod', 'FD', 0, 'Fax through DID line' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_ReceivedMethod', 'M', 1, 'Mail' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_ReceivedMethod', 'W', 2, 'Unknown' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_ReceivedMethod', 'FR', 3, 'Fax through Reception' /* PRTESForm */
exec usp_AccpacCreateDropdownValue 'prtf_ReceivedMethod', 'OL', 4, 'Online' /* PRTESForm */

exec usp_AccpacCreateDropdownValue 'prte_HowSent', 'F', 0, 'Fax' /* PRTES */
exec usp_AccpacCreateDropdownValue 'prte_HowSent', 'M', 1, 'Mail' /* PRTES */

exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'PM', 1, 'Blue Book Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'RM', 2, 'Blue Book Service:150' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'PB', 3, 'Branch Blue Book Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'RB', 4, 'Branch Blue Book Service:150-B' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AM', 5, 'Blue Book Copy' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AW', 6, 'Blue Book Copy plus Updates' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZA', 7, 'Blue Book Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZB', 8, 'Branch Blue Book Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'WO', 9, 'Electronic Blue Book:Base(Additional Copy)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'WZ', 10, 'Electronic Blue Book:Premium(Additional Copy)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '2Z', 11, 'Network User License 7-10 Users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '3Z', 12, 'Network User License 11-20 Users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '4Z', 13, 'Network User License 21+ Users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '5Z', 14, 'Series 300 Unlimited User License' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BA', 15, 'Branch Access License' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'P3', 16, 'Blue Book Service:300' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'PO', 17, 'Blue Book Service:50' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EM', 18, 'Blue Book Service:100(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BO', 19, 'Branch Blue Book Service(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ME', 20, 'Blue Book Service:300(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JS', 21, 'Jump Start Print Blue Book Service' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JR', 22, 'Jump Start Electronic Blue Book on CD-ROM Service' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TM', 23, 'Trading Member Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TR', 24, 'Trading Member Service:Series 150' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TB', 25, 'Branch Trading Membership Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'T5', 26, 'Branch Trading Membership Service:150-B' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FM', 27, 'Transportation Member Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FR', 28, 'Transportation Member Service:Series 150' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FB', 29, 'Branch Transportation Membership Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'F5', 30, 'Branch Transportation Membership Service:150B' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZC', 31, 'Trading Member Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZE', 32, 'Transportation Member Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZF', 33, 'Transportation Branch Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZD', 34, 'Trading Branch Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TP', 35, 'Trading Member Publicity (Bold Listing)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FP', 36, 'Transportation Member Publicity (Bold Listing)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'T3', 37, 'Trading Member Service:300' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'F3', 38, 'Transportation Member Service: 300' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TO', 39, 'Trading Membership Service:50' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FO', 40, 'Transportation Membership Service:50' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EP', 41, 'Trading Member Service:100(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ET', 42, 'Transportation Member Service:100(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TE', 43, 'Trading Member Service:300(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FE', 44, 'Transportation Member Service:300(OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BW', 45, 'Express Update Service by FAX - Gratis' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EW', 46, 'Express Update Service by E-Mail - Gratis' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BX', 47, 'Express Update Service by FAX - 1 Year' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EX', 48, 'Express Update Service by E-Mail - 1 year' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'QS', 49, 'Blueprints Annual Subscription' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'QG', 50, 'Blueprints Annual Subscription-Gratis' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'FD', 51, 'Communications Directory' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'LM', 52, 'Published Logo: HQ' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'LB', 53, 'Published Logo: Branch' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HM', 54, 'Company Spotlight: HQ' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HL', 55, 'Company Spotlight: Branch' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HS', 56, 'Company Spotlight: HQ' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'LG', 57, 'Published Logo: Gratis' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HG', 58, 'Company Spotlight: Gratis' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AD', 59, 'Credit Sheet Updates' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'NC', 60, 'Gratis Service (No Charge)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'UN', 61, 'University BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'UO', 62, 'University EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ZG', 63, 'Gratis Blue Book Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'DG', 64, 'Datasource Daily Updates  - Gratis' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OM', 65, 'Blue Book Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OR', 66, 'Blue Book Service:150 Int''l' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JB', 67, 'Blue Book Service:100-B' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JM', 68, 'Blue Book Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OI', 69, 'Blue Book Service 100 Int''l (OL)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JX', 70, 'Blue Book Branch Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OZ', 71, 'Blue Book Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JZ', 72, 'Blue Book Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JP', 73, 'Blue Book Service:300' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OP', 74, 'Blue Book Service:300' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OA', 75, 'Blue Book Copy- International' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OB', 76, 'Branch Blue Book Service:100' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'O5', 77, 'Branch Blue Book Service:150-B Int''l' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'OQ', 78, 'Branch Blue Book Service:200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JC', 79, 'Electronic Blue Book:Premium Add''l Int''l' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'JO', 80, 'Electronic Blue Book:Base Add''l Int''l' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HP', 81, '($45) Parcel Post Shipping & Handling' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'SB', 82, 'Fed Ex Shipping (C. & S. Amer.) Book / Series 200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'SE', 83, 'Fed Ex Shipping (C. & S. Amer.) EBB 150' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'IB', 84, 'Fed Ex Shipping (Eu/Asia/Africa) Book & Series 200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'IE', 85, 'Fed Ex Shipping (Eu/Asia/Africa) EBB 150' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HB', 86, '($90) FedEx Ship & Handling BB''s and Series 200' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'HE', 87, '($45) FedEx S & H Series 100 EBB & Extra EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AB', 88, 'Arbitration Fee' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BR', 89, 'Business Reports' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'CS', 90, 'Collection Service' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'DL', 91, 'Descriptive Listing Lines' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'DR', 92, 'Contract Service (DRC)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'IR', 93, 'International Business Reports' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'IS', 94, 'Info License Fee' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'KY', 95, 'Know Your Commodity' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'LD', 96, 'Custom Directory' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'QM', 97, 'Quarterly Magazine Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'RA', 98, 'Reference Guide Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'CA', 99, 'Advertising in Annual Communications Directory' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'RG', 100, 'Reference Guide' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'SD', 101, 'Seminars (DRC)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'SR', 102, 'Seminars (PRCo)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'ST', 103, 'Stickers/Seals' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'TA', 104, 'Trading Assistance' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'XB', 105, 'Boxed Border Around Blueprints Directory Listing' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AH', 106, 'BB Online: 100 Units' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AI', 107, 'BB Online: 250 Units' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AJ', 108, 'BB Online: 500 Units' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AK', 109, 'BB Online: 1000 Units' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AF', 110, 'BB Online: 50 Units (Gratis)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AL', 111, 'BB Online: 3000 Units' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'AG', 112, 'BB Online: 100 Units (Gratis)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'MG', 113, 'BB Online: 1000 units (Gratis)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'QR', 114, 'Copies of Reprinted Blueprints Articles' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '1E', 115, '10 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '2E', 116, '25 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '3E', 117, '50 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '4E', 118, '100 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '5E', 119, '250 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '6E', 120, '500 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BF', 121, 'FedEx - BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EF', 122, 'FedEx - EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BN', 123, 'UPS Next Day Air - BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EN', 124, 'UPS Next Day Air - EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BU', 125, 'UPS 2nd Day Air - BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EU', 126, 'UPS 2nd Day Air - EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', '1Z', 127, 'Network User License 4-6 Users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'BT', 128, 'Web Site Beta Tester' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'EB', 129, 'Exchange Bulletin Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'IN', 130, 'International FedEx Shipping' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'PS', 131, 'Custom Design' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceCode', 'PT', 132, 'Design Company Spotlight Template' /*PRService */

exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', '1E-01', 1, '10 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', '2E-01', 2, '25 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', '3E-01', 3, '50 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', '4E-01', 4, '100 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', '5E-01', 5, '250 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', '6E-01', 6, '500 Business Report Package' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'AB-01', 7, 'Arbitration Fee' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BB-01', 8, 'One April and one October Print Blue Book' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BB-02', 9, 'Two April Print Blue Books' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BB-03', 10, 'Two October Print Blue Books' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BB-04', 11, 'University Book - N/C April edition shipped in October' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BB-30', 12, 'BB Jump Start' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BBO-01', 13, 'BB Online Units Only' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BF-01', 14, 'FedEx - BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BN-01', 15, 'UPS Next Day Air - BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BR-01', 16, 'Business Reports' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BU-01', 17, 'UPS 2nd Day Air - BB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'BX-01', 18, 'Express Update Service - FAX' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'CA', 19, 'Advertising in Annual Communications Directory' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'CL-01', 20, 'Collection Service' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'CS-01', 21, 'Credit sheet updates only' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DL-01', 22, 'Descriptive listing facts' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DR-01', 23, 'Contract Service (DRC)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-01', 24, 'One January and one April BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-02', 25, 'One January and one July BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-03', 26, 'One January and one October BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-04', 27, 'One April and one July BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-05', 28, 'One April and one October BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-06', 29, 'One July and one October BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-07', 30, 'Quarterly BB DS on disk' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DS-20', 31, 'BB DS delivered on the EBB CD-ROM' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'DSU-01', 32, 'Datasource Daily Updates' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EB-01', 33, 'Exchange Bulletin Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-01', 34, 'One January and one April EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-02', 35, 'One January and one July EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-03', 36, 'One January and one October EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-04', 37, 'One April and one July EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-05', 38, 'One April and one October EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-06', 39, 'One July and one October EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-07', 40, 'University EBB - One April and one October EBB (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-10', 41, 'EBB Quarterly (Standalone)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-11', 42, 'EBB Quarterly (Network)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-20', 43, 'EBB 4-6 network users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-21', 44, 'EBB 7-10 network users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-22', 45, 'EBB 11-20 network users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-23', 46, 'EBB 21+ network users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-24', 47, 'EBB unlimited network users' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-25', 48, 'EBB branch access license' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-30', 49, 'EBB Jump Start' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EBB-90', 50, 'EBB Export Contact Name beta tester' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EF-01', 51, 'FedEx - EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EN-01', 52, 'UPS Next Day Air - EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EU-01', 53, 'UPS 2nd Day Air - EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'EX-01', 54, 'Express Update Service - E-Mail' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'FD-01', 55, 'Communications Directory' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'HP-01', 56, 'Company Spotlight' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'IN-01', 57, 'International FedEx Shipping' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'IR-01', 58, 'International Business Reports' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'IS-01', 59, 'Info License Fee' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'KY-01', 60, 'Know Your Commodity' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'LB-01', 61, 'Company Logo: Print BB / EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'LD-01', 62, 'Custom Directory' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'LG-01', 63, 'Company Logo: Print BB / EBB' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'NP-01', 64, 'Non-Prospect' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'PO-01', 66, 'Publicity Only (Bold Print for Listing)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'PS-01', 67, 'Custom Design' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'PT-01', 68, 'Design Company Spotlight Template' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'QM-01', 69, 'Quarterly Magazine Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'QR', 70, 'Copies of Reprinted Blueprints Articles' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'QS-01', 71, 'Blueprints Annual Subscription' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'RA-01', 72, 'Reference Guide Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'RG-01', 73, 'Reference Guide' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'SA-01', 74, 'Supplement Advertising' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'SD-01', 75, 'Seminars (DRC)' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'SHIP-1', 76, 'Federal Express or PP Shipping & Handling' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'SR-01', 77, 'Seminars' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'ST-01', 78, 'Stickers/Seals' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'SU-01', 79, 'Satellite Update' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'TA-01', 80, 'Trading Assistance' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-01', 81, 'Beta Test all current On-Line (Web) Services' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-02', 82, 'Beta Test On-Line Database' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-03', 83, 'Beta Test On-Line Business Reports' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-04', 84, 'Beta Test On-Line Credit Sheet' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-05', 85, 'Beta Test On-Line Database and Credit Sheet' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-06', 86, 'Beta Test On-Line Database and Bus. Reports' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'WEB-07', 87, 'Beta Test On-Line Bus. Reports and Credit Sheet' /*PRService */
exec usp_AccpacCreateDropdownValue 'prse_ServiceSubCode', 'XB-01', 88, 'Boxed Border Around Blueprints Directory Listing' /*PRService */


exec usp_AccpacCreateDropdownValue 'praaif_FileFormat', 'DEL', 0, 'Delimited' /* PRARAgingImportFormat */
--exec usp_AccpacCreateDropdownValue 'praaif_FileFormat', 'XML', 1, 'XML' /* PRARAgingImportFormat */

exec usp_AccpacCreateDropdownValue 'praaif_DateFormat', 'MMDDYY', 0, 'MMDDYY' /* PRARAgingImportFormat */
exec usp_AccpacCreateDropdownValue 'praaif_DateFormat', 'MMDDYYYY', 2, 'MMDDYYYY' /* PRARAgingImportFormat */
exec usp_AccpacCreateDropdownValue 'praaif_DateFormat', 'DDMMYY', 3, 'DDMMYY' /* PRARAgingImportFormat */
exec usp_AccpacCreateDropdownValue 'praaif_DateFormat', 'DDMMYYYY', 4, 'DDMMYYYY' /* PRARAgingImportFormat */
exec usp_AccpacCreateDropdownValue 'praaif_DateFormat', 'YYMMDD', 5, 'YYMMDD' /* PRARAgingImportFormat */
exec usp_AccpacCreateDropdownValue 'praaif_DateFormat', 'YYYYMMDD', 6, 'YYYYMMDD' /* PRARAgingImportFormat */


exec usp_AccpacCreateDropdownValue 'prau_LastRunDate', '', 0, 'AUS Last Run Date/Time' /* PRAUS (Not a real column) */
exec usp_AccpacCreateDropdownValue 'EmailOverride', 'Email', 0, 'mrempert@bluebookprco.com' /* Used by usp_CreateEmail to override any specified email address. */
exec usp_AccpacCreateDropdownValue 'FaxOverride', 'Fax', 0, '630 3440343' /* Used by usp_CreateEmail to override any specified fax. */


SET NOCOUNT OFF