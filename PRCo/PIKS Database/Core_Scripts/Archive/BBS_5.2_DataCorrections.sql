DECLARE @Table table (
	ndx int identity(1,1),
	ClassificationID int
)

INSERT INTO @Table SELECT prcl_ClassificationID FROM PRClassification ORDER BY prcl_ClassificationID;

UPDATE PRClassification
   SET prcl_DisplayOrder = (ndx * 10)
  FROM @Table
 WHERE prcl_ClassificationID =  ClassificationID;
Go


ALTER TABLE Company DISABLE TRIGGER ALL
UPDATE Company 
   SET comp_PRConfidentialFS = '1'
 WHERE comp_PRConfidentialFS = 'Y';
ALTER TABLE Company ENABLE TRIGGER ALL
Go

UPDATE PRExternalNewsAuditTrail
   SET prenat_SecondarySource = pren_SecondarySourceName
  FROM PRExternalNews
 WHERE pren_URL = prenat_URL
   AND prenat_PrimarySource = 'DowJones'
Go


