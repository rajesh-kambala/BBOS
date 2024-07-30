USE CRM

SELECT MAX(adli_AddressLinkID) FROM Address_Link
SELECT * FROM SQL_Identity where ID_TableID IN (SELECT bord_tableID FROM Custom_Tables WHERE bord_name='Address_Link');

EXEC usp_DTSPostExecute 'Address_Link', 'adli_AddressLinkID'

SELECT MAX(adli_AddressLinkID) FROM Address_Link
SELECT * FROM SQL_Identity where ID_TableID IN (SELECT bord_tableID FROM Custom_Tables WHERE bord_name='Address_Link');
