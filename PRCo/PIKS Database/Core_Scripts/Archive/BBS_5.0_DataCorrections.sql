UPDATE PRTESRequest
   SET prtesr_TESFormID = NULL   
 WHERE prtesr_SentMethod = 'VI'
   AND prtesr_TESFormID IS NOT NULL;   
Go   