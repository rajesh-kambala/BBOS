UPDATE NewProduct
   SET prod_IndustryTypeCode = ',P,T,S,L,'
 WHERE prod_code = 'TRLLIC';
Go

UPDATE PRPublicationArticle
   SET prpbar_CategoryCode = 'VT'
 WHERE prpbar_PublicationCode = 'TRN'
   AND prpbar_MediaTypeCode = 'Video';
Go   
   
UPDATE PRPublicationArticle
   SET prpbar_CategoryCode = 'BT'
 WHERE prpbar_PublicationCode = 'TRN'
   AND prpbar_MediaTypeCode = 'Doc';   
Go   