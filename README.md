![Logo](http://qaapps.bluebookservices.com/ProjectSite/images/BBSSeal.gif)

# Blue Book Services Systems Overview
Blue Book Services (BBSI) is a credit rating agency and directory service for the Produce and Lumber industry.  They also create various publications, offer trading assistance and dispute resolution services.  BBSI maintains extensive data on subject companies.

*Note: Blue Book Services used to be named Produce Report Company and the product used to be named the Electronic Blue Book.  This is why the system still has components named "PRCo" or "EBB".*

## Production vs. QA
The BBSI application environment spans three servers.  There is a public facing applications server for customer facing applications, and internal application server for CRM and accounting, and an internal database server supporting both application servers.  The QA environment mirrors this. The descriptions below are for production.

The suite of BBSI applications is built upon Sage CRM.  BBSI uses Sage CRM as their core system and all the custom applications on components leverage the CRM database.  This has resulted in a database heavy architecture.

## Sage CRM Web Application
- https://crm.bluebookservices.local/crm/
- D:\Applications\CRM\WWWRoot\
- This is a third party CRM product from Sage that has been extensively customized using both classic ASP and some ASP.NET.
- The field, screen block, and screen definitions are are defined in meta-data tables (custom_[*]) that CRM reads from when rendering pages.
- This is an internal application only accessible when on the VPN.

## BBOS Web Application
- https://apps.bluebookservices.com
- D:\Applications\Apps\BBOS
- This is a customer facing web application hosted by IIS used by members to access real-time information on either produce or lumber companies.  Members can search and view company details, export data, download reports, and purchase Business Reports which is contains more detailed data on subject companies including data from third-party sources.
- The application has eCommerce functionality integrating with PayFlowPro.
- The application sends email via SMTP.
- Emails with the error details are also sent to supportbbos@bluebookservices.com.
- This web application connects to the CRM database on SQL Server via ADO.NET native SQL functionality.   A single shared SQL Server login account is used by the application to connect to the database.
- It can be stopped started via its IIS application pool or by recycling IIS itself.
- Design and built by Travant Solutions.

## BBOS Web Service
- https://apps.bluebookservices.com/BBWebServices/
- D:\Applications\Apps\BBWebServices
- This is a web service hosted by IIS used by the customers to integrate BBSI data into third-party systems.
- Emails with the error details are also sent to supportbbos@bluebookservices.com.
- The web service connects to the CRM database on SQL Server via ADO.NET native SQL functionality.   A single shared SQL Server login account is used by the application to connect to the database.
- The web service can be stopped started via its IIS application pool or by recycling IIS itself.
- Design and built by Travant Solutions.

## BBOS Monitor
- D:\Applications\BBSMonitor
- This in installed on the production Sage MAS Server and database server.  The Sage MAS server instance executes the events to synchronize data between CRM and MAS.  All other events execute on the database server instance.
- This is a Windows Service used to execute numerous periodic tasks.  
- The application sends email via SMTP.
- Emails with the error details are also sent to supportbbos@bluebookservices.com.
- The Windows service connects to the CRM database on SQL Server via ADO.NET native SQL functionality.   A single shared SQL Server login account is used by the application to connect to the database.
- The Windows service can be stopped started via the Windows Services Management Console.
- Design and built by Travant Solutions.

## BBOS Public Profiles
- https://www.producebluebook.com
- D:\Applications\Apps\ProducePublicProfiles
- https://www.lumberbluebook.com
- D:\Applications\Apps\LumberPublicProfiles
- This is a customer facing web application hosted by IIS integrated with two WordPress marketing sites.  This application displays basic company information in the marketing site and allows users to purchase memberships or business reports via eCommerce.
- The application has eCommerce functionality integrating with PayFlowPro.
- The application sends email via SMTP.
- Emails with the error details are also sent to supportbbos@bluebookservices.com.
- This web application connects to the CRM database on SQL Server via ADO.NET native SQL functionality.   A single shared SQL Server login account is used by the application to connect to the database.
- It can be stopped started via its IIS application pool or by recycling IIS itself.
- Design and built by Travant Solutions.

## BBOS Widgets
- D:\Applications\Apps\BBOSWidgets
- This is a customer facing web application that provides widget functionality that can be embedded in third-party, i.e. customer, web sites.  This includes TM/FM Seal validation, QuickFind Company Lookup, and advertising that is used on the BBOS marketing sites.
- The application sends email via SMTP.
- Emails with the error details are also sent to supportbbos@bluebookservices.com.
- This web application connects to the CRM database on SQL Server via ADO.NET native SQL functionality.   A single shared SQL Server login account is used by the application to connect to the database.
- It can be stopped started via its IIS application pool or by recycling IIS itself.
- Design and built by Travant Solutions.

## BBOS Mobile App
- This is a Xamarin Forms application compiled to both iOS and Android to provide mobile access to the BBOS system.
- There are two flavors of the application: one for produce and one for lumber. 
- This is a web service hosted by IIS used by the customers to integrate BBSI data into third-party systems.
- The mobile apps connect to the BBOS Mobile App Services to retrieve data and process requests.
- Design and built by Travant Solutions.

## BBOS Mobile Web Serivice
- https://apps.bluebookservices.com/BBMobileServices/
- D:\Applications\Apps\BBOSMobileServices
- This is a web service hosted by IIS used by the iOS and Android mobile app to retreive data and process requests.
- Emails with the error details are also sent to supportbbos@bluebookservices.com.
- The web service connects to the CRM database on SQL Server via ADO.NET native SQL functionality.   A single shared SQL Server login account is used by the application to connect to the database.
- The web service can be stopped started via its IIS application pool or by recycling IIS itself.
- Design and built by Travant Solutions.

## WordPress
- BBSI maintains three marketing sites within a multi-network configuration of WordPress.
- WordPress connects to the WordPress database on SQL Server via a customized abstraction layer in PHP.  A single shared SQL Server login account is used by the application to connect to the database.
- Both the produce and lumber sites embed the BBOS Public Profile application.


## SQL Server Database Server
- The BBOS web application, web service, mobile web service and Windows service all connect to the CRM SQL Server database using a shared SQL Server login account.

## SQL Server Reporting Services
- https://reports.bluebookservices.local/reports
- This is a SQL Server add-on component that provides reporting capabilities to SQL Server.
- Windows security is used to manage the user accounts.
- BBSI personnel log in to manually execute reports.
- The BBOS and CRM applications programmatically connects to execute reports.


# Servers
- The Microsoft Azure VPN client is required to access the BBSI network.
- **apps.bluebookservices.com** - The public application server hosting BBOS, the web services, widgets, and marketing web sites.
- **crm.bluebookservices.local** - The internal application server hosting Sage CRM, MAS, an instance of the BBS Monitor and some internal utility web applications.
- **az-nc-sage-p2.bluebookprco.local** - The internal application server hosting MAS and an instance of the BBS Monitor.
- **sql.bluebookservices.local** - The database server hosting SQL Server, an instance of the BBS Monitor, and SSRS.
- **qaapps.bluebookservices.com** - The QA public application server hosting BBOS, the web services, widgets, and marketing web sites.  This is also the build server.
- **qacrm.bluebookservices.local** - The QA internal application server hosting Sage CRM and an instance of the BBS Monitor.
- **az-nc-sage-q2.bluebookprco.local** - The QA internal application server hosting MAS and an instance of the BBS Monitor.
- **qasql.bluebookservices.local** - The QA database server hosting SQL Server, an instance of the BBS Monitor, and SSRS.


# Source Code

## BBOSMobile Visual Studio Solution
- **BBOSMobile** – The Xamarin mobile application project.
- **BBOSMobile.Core** - The mobile application business object layer
- **BBOSMobile.ServiceModels** - The library of request and response objects used to transmit data with the BBOS Mobile web service.

## BBOSMobileServices Visual Studio Solution
- **BBOSMobileServices** – REST API web service used to support the BBOS Mobile application.  Leverages the BBOSMobile.ServiceModels project.

## EBB Visual Studio Solution
- **BBOS** – The current BBOS web application used by members to access real-time information on either produce or lumber companies.
- **BBOSPublicProfiles** - Web application used to provide enhanced functionality in the produce and lumber WordPress marketing web sites.
- **BBOSWebService** – An public web service used by customers to integrate Blue Book Data in their internal systems.
- **BBOSWidgets** – An public web application used to provide Blue Book functionality in third-party web sites.
- **EBBBusinessObjects** – Business object layer

## BBSComponents Visual Studio Solution
- **BBSMonitor** – Windows service used to execute periodic tasks.  This includes sending faxes, daily delivery of product reports to customers, and keeping disparate data in sync.
- **BBSReportInterface** – Code library used to programmatically generate  SSRS reports.
- **EmailInterface** - Code library used to provide programatic access to Exchange365 to retrieve email.
- **ExternalNews** - Code library used to consume third-party web services for news providers such as Dow Jones.
- **FaxInterace** - Code library used to interface with cloud-based fax service providers to send faxes and retrieve fax status.

## CRM Visual Studio Solution
- **Database** - Contains the CRM modification SQL scripts in the Core_Scripts folder.
- **WWWRoot** - Web application with some .NET code but mostly Classic ASP scripts for CRM custom pages.

## BBSReporting Visual Studio Solution
Most of the report folders are self-explanatory.  Only a sub-set are listed here.
- **BBOSMemberReprots** - Reports available to members via BBOS.
- **BBSReporting** - General reports that are not easily categorized or used by multiple groups.
- **BusinessReport** - Contains the main BusinessReport and all the sub-reports that comprise the Business Report.

## PRCoUtils Visual Studio Solution
This solution contains numerous utilities that were used for one-time imports or may be still used for periodic imports.

# Build / Deployment Process

## Build
- Project Site: http://qaapps.bluebookservices.com/ProjectSite
- Slack Channel: https://travant.slack.com/messages/CBU9B4PE1
- Build Script: D:\Applications\Build\Build.bat – Note: Run as an administrator.

## QA Deployment
- BBSI has their own build server on qa.apps.bluebookservices.com.  The build script builds the QA environment.
- Reports are deployed by the build script. *Note: New reports may have to be manually configured for data sources, etc.*

## Production Deployment
- Run the AnyConnect to connect to the BBSI network.
- RDC to each production server and execute the backup script.
  - apps.bluebookservices.com: D:\Backup\BBOSBackup.bat
  - crm.bluebookservices.local: D:\Backup\CRMBackup.bat
  - sql.bluebookservices.local: D:\Backup\SQLBackup.bat
- RDC to sql.bluebookservices.local and via SQL Management Studio execute the D:\Applications\Backup for Release.sql script.
- RDC to qaapps.bluebookservices.com to execute the deployment scripts.  In D:\Applications\Deploy, the deployment is broken up into multiple scripts that can be executed in parallel.
  - DeployDatabase.bat
  - DeployToBBOS.bat
  - DeployToCRM.bat
  - DeployToSQL.bat
  - DeployReports.bat *Note: New reports may have to be manually configured for data sources, etc.*


# Common Production Issues

## Remove AR Aging Data ##
There are various reasons why previously imported AR Aging data needs to be removed.  Often times it is the customer that notifies BBSI that the data is incorrect.

Use the [Delete AR Aging.sql](https://www.travant.com/info/bbsi/Delete%20AR%20Aging.txt) file to handle this issue. The users will provide the company ID (BB ID) and the AR aging date (not created/imported date) of the file.  Edit the SQL Script putting these values in place of @PutCompanyIDHere and @PutARAgingDateHere.  Execute the script with the @ForCommit = 0 to first verify the data.  If the output looks correct, change the @ForCommit to 1 and execute to apply the changes.

## Weekly Credit Sheet Process Crash & Restart ##
Restart the Weekly Credit Sheet Process.
The process is restartable in that if the process executes multiple times on the same day, recipients that previously received the email will be excluded.  We need to manually reset the batch status to that it gets processed again.  The process is set to execute hourly at the top of the hour.  That can be changed via the BBSMonitor config file on the production database server.

Steps
- Correct whatever data caused the process to crash.  Most likely a missing or invalid email address.
- Query for the aborted credit sheet batch:
```T-SQL
SELECT *
  FROM PRCreditSheetBatch
WHERE prcsb_TypeCode = 'CSUPD'
  AND prcsb_StatusCode = 'A'
```
- Change the status to Pending:
```T-SQL
UPDATE PRCreditSheetBatch
   SET prcsb_StatusCode='P'
 WHERE prcsb_TypeCode = 'CSUPD'
   AND prcsb_StatusCode = 'A'
```

  
  
## Duplicate BBOS User ##

## BBOS User Email Address In Use ##
