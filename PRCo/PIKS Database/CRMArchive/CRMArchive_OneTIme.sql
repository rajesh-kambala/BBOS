USE CRM

INSERT INTO CRMArchive.dbo.PRFile SELECT * FROM CRM.dbo.PRFile;
INSERT INTO CRMArchive.dbo.PRFilePayment SELECT * FROM CRM.dbo.PRFilePayment;
INSERT INTO CRMArchive.dbo.PRServiceAlaCarte SELECT * FROM CRM.dbo.PRServiceAlaCarte;
INSERT INTO CRMArchive.dbo.PRAUS SELECT * FROM CRM.dbo.PRAUS;

EXEC CRM.dbo.usp_AccpacDropTable 'PRFile';
EXEC CRM.dbo.usp_AccpacDropTable 'PRFilePayment';
EXEC CRM.dbo.usp_AccpacDropTable 'PRServiceAlaCarte';
EXEC CRM.dbo.usp_AccpacDropTable 'PRBBOSUserAudit';
EXEC CRM.dbo.usp_AccpacDropTable 'PRDeal';
EXEC CRM.dbo.usp_AccpacDropTable 'PRDealCommodity';
EXEC CRM.dbo.usp_AccpacDropTable 'PRDealTerritory';
EXEC CRM.dbo.usp_AccpacDropTable 'PRGeneralInformation';;
EXEC CRM.dbo.usp_AccpacDropTable 'PROwnership';
EXEC CRM.dbo.usp_AccpacDropTable 'PRRole';
EXEC CRM.dbo.usp_AccpacDropTable 'PRAUS';