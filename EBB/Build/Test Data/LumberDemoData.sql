/*
 * Copyright (c) 2002-2008 Travant Solutions, Inc.
 * Created by Travant Excel SQL Export MACROs
 * SQL Inserts created from LumberDemoData.xls
 * on 7/24/2008 9:41:05 AM
 *
 */

Set NoCount On
Select getdate() as "Start Date/Time";
Begin Transaction;
DELETE FROM PRPublicationArticle WHERE prpbar_CreatedBy = -500




/*  Begin PRPublicationArticle Inserts */

Select 'Begin PRPublicationArticle Inserts';
Insert Into PRPublicationArticle
(prpbar_PublicationArticleID,prpbar_PublicationCode,prpbar_PublishDate,prpbar_ExpirationDate,prpbar_CategoryCode,prpbar_RSS,prpbar_News,prpbar_MembersOnly,prpbar_Sequence,prpbar_Name,prpbar_Abstract,prpbar_Body,prpbar_CreatedBy,prpbar_CreatedDate,prpbar_UpdatedBy,prpbar_UpdatedDate,prpbar_TimeStamp)
Values (50000,'BBN','7/1/2008 00:00','12/31/2008 00:00','Industry','Y','Y','Y',1,'Jones Lumber Co. Intends to Acquire Chicago Building Enterprises, Inc.',NULL,'Jones Lumber Co. announced July 31, 2008 its intention to acquire Chicago Building Enterprises, Inc., a distribution yard established in 1956 serving consumer and contractor lumber yards, hardware stores and floor covering retailers.
<p>
“The potential acquisition of Chicago Building Enterprises fits perfectly into our strategy to develop our presence in the midwest,” said Tom Jones, President, Jones Lumber Co.
<p>
The acquisition is expected to be completed by January 15, 2009.
',-500,GETDATE(),1,GETDATE(),GETDATE());

Insert Into PRPublicationArticle
(prpbar_PublicationArticleID,prpbar_PublicationCode,prpbar_PublishDate,prpbar_ExpirationDate,prpbar_CategoryCode,prpbar_RSS,prpbar_News,prpbar_MembersOnly,prpbar_Sequence,prpbar_Name,prpbar_Abstract,prpbar_Body,prpbar_CreatedBy,prpbar_CreatedDate,prpbar_UpdatedBy,prpbar_UpdatedDate,prpbar_TimeStamp)
Values (50001,'BBN','7/1/2008 00:00','12/31/2008 00:00','PRCo','Y','Y','Y',1,'Lumber Listing Prototype',NULL,'As company data is collected and analyzed, Lumber Blue Book Listings would be published and available through a web-based application.  A Lumber Blue Book Listing could look something like this:
<p><pre>
CHICAGO, IL
   BB #1012345
XYZ Lumber, Inc.
   P.O. Box 1234. (60012-1234)
   123 Main St.
   Phone 312 946-8329
   FAX 312-946-8463
   E-Mail: xyz@xyzlumber.com
   Web Site: www.xyzlumber.com
   Keith Nelson, Sales
   Nelson cell 312-946-0000
   Nelson E-Mail: knelson@xyzlumber.com
   Specialize in Fire Retardant Lumber
Products: 2x2s, Ballusters, Boards, Borate, 
Bridging, CCA, Commons, Copper Azole, 
Decking, Dimension, Fingerjoint Studs, 
Fire Retardant Lumber, 
Fire Retardant Plywood, Framing Lumber, 
Furring, I-Joists, Lumber, MSR, OSB, 
Pallet Stock, Panels, Pattern Stock, 
Plywood, Posts, Pre-cut Dimension, 
Pressure Treated Stock, Rim Board, 
Shelving, Shorts, Special Cuttings, 
Studs, Timbers, Treated Lumber,
Species: Douglas Fir, Eastern Spruce, 
Engelmann Spruce, ESLP, Euro Spruce, 
Hem Fir, Lodgepole Pine, Red Pine,
Southern Pine, Southern Yellow Pine,
Spruce-Pine-Fir, White Fir
Facilities: Bar Coding, 
Distribution Yard(s), Inside Storage, 
Packaging, Paper Wrap Capability, 
PET Trimmers
       Rating …………………….250M XXX B
</pre>',-500,GETDATE(),1,GETDATE(),GETDATE());

Insert Into PRPublicationArticle
(prpbar_PublicationArticleID,prpbar_PublicationCode,prpbar_PublishDate,prpbar_ExpirationDate,prpbar_CategoryCode,prpbar_RSS,prpbar_News,prpbar_MembersOnly,prpbar_Sequence,prpbar_Name,prpbar_Abstract,prpbar_Body,prpbar_CreatedBy,prpbar_CreatedDate,prpbar_UpdatedBy,prpbar_UpdatedDate,prpbar_TimeStamp)
Values (50002,'BBN','7/1/2008 00:00','12/31/2008 00:00','BBS','Y','Y','Y',2,'About the BBOS Lumber Prototype',NULL,'This prototype was developed specifically for presentation purposes to the NAWLA task force evaluating a suitable replacement for Lumbermen’s Red Book.  
<p>
The foundation of this prototype is our current Blue Book Online Services (BBOS) application for the fresh fruit and vegetable industry.  Thus, most of the functionality and data uses real data for the produce industry.  We believe this is important, because it demonstrates that we not only can produce mock-up screen shots, but already have the technical infrastructure in place that can quickly and easily be extended to serve the lumber industry.
<p>
The Company Search screens (accessed by selecting Quick Search > Search Companies) have been modified to provide an illustration of how the current BBOS application could be modified and extended for the lumber industry.  By selecting Industry Type = Lumber, the “Commodity” and “Classification” search screens display a non-functioning mock-up for how BBOS could be modified for the lumber industry.  We understand that the values presented on these mock-up screens will need to be refined as we work with the industry to finalize and categorize the data elements needed to make a lumber version of BBOS a value-added tool.
',-500,GETDATE(),1,GETDATE(),GETDATE());


/*  3 PRPublicationArticle Insert Statements Created */






Commit Transaction;
Select getdate() as "End Date/Time";
Set NoCount Off
