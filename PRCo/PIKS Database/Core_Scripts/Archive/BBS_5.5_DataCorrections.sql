UPDATE PRCreditSheet
   SET prcs_ItemText = dbo.ufn_GetItem(prcs_CreditSheetID, 0, 1, 34)
Go

UPDATE PRTESRequest
   SET prtesr_ReceivedMethod = 'FD'
 WHERE prtesr_ReceivedMethod = 'M'
   AND prtesr_TESFormID IN (
		 SELECT prtf_TESFormID 
		  FROM PRTESForm WITH (NOLOCK)
		 WHERE prtf_ReceivedMethod = 'M'
		   AND CHARINDEX('FS1', prtf_FaxFileName) > 0
  );
  
UPDATE PRTESForm  
   SET prtf_ReceivedMethod = 'FD'
 WHERE prtf_ReceivedMethod = 'M'
   AND CHARINDEX('FS1', prtf_FaxFileName) > 0;
Go   


DELETE FROM Cases WHERE Case_CaseId <= 16;
Go