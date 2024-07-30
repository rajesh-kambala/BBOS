using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using Microsoft.SqlServer.Server;
using System.Security.Principal;

public partial class UserDefinedFunctions
{

    internal static SqlDateTime getSQLDateForPACAFileDate(string sDate)
    {
        if (sDate.Length == 0)
            return SqlDateTime.Null;

        if (sDate.Length == 7)
            sDate = "0" + sDate;
        //SqlDateTime sqlDt = new SqlDateTime(2007, 02, 20);
        SqlDateTime sqlDt = new SqlDateTime(Int32.Parse(sDate.Substring(4, 4)), Int32.Parse(sDate.Substring(0, 2)), Int32.Parse(sDate.Substring(2, 2)));
        return sqlDt;
    }


    [Microsoft.SqlServer.Server.SqlFunction (FillRowMethodName="FillPACALicense", 
        TableDefinition = "[LicenseNumber] nvarchar(max),[ExpirationDate] datetime, [PrimaryTradeName] nvarchar(max), [CompanyName] nvarchar(max),[CustomerFirstName] nvarchar(max),[CustomerMiddleInitial] nvarchar(max),[City] nvarchar(max),[State] nvarchar(max),[Address1] nvarchar(max),[Address2] nvarchar(max),[PostCode] nvarchar(max),[TypeFruitVeg] nvarchar(max),[ProfCode] nvarchar(max),[OwnCode] nvarchar(max),[IncState] nvarchar(max),[IncDate] datetime,[MailAddress1] nvarchar(max),[MailAddress2] nvarchar(max),[MailCity] nvarchar(max),[MailState] nvarchar(max),[MailPostCode] nvarchar(max),[AreaCode] nvarchar(max),[Exchange] nvarchar(max),[Telephone] nvarchar(max),[TerminateDate] datetime,[TerminateCode] nvarchar(max),[PACARunDate] datetime")]
    public static IEnumerable PACALicenseFile(SqlString sDirectory, SqlString sFileDate)
    {
        return ReadPacaLicenseFile(sDirectory, sFileDate);
    }

    private static List<PacaLicense> ReadPacaLicenseFile(SqlString sDirectory, SqlString sFileDate)
    {
        List<PacaLicense> licenses = new List<PacaLicense>();
        // get the file
        WindowsImpersonationContext OriginalContext = null;
        try        
        {
            //Impersonate the current SQL Security context
            WindowsIdentity CallerIdentity = SqlContext.WindowsIdentity;
            //WindowsIdentity might be NULL if calling context is a SQL login
            if (CallerIdentity != null)
            {
                OriginalContext = CallerIdentity.Impersonate();
            }

            string sFullFilePath = sDirectory.ToString() + sFileDate.ToString() + "license.csv";
            if (!File.Exists(sFullFilePath))
                return licenses;

            using (StreamReader sr = new StreamReader(sFullFilePath))
            {
			    string sLine = null;
			    while ((sLine = sr.ReadLine()) != null)
			    {
				    string[] sSplit = sLine.Split(',');
                    PacaLicense row = new PacaLicense();
                    row.LicenseNumber = new SqlString(sSplit[0]);
                    row.ExpirationDate = getSQLDateForPACAFileDate(sSplit[1]);
                    row.PrimaryTradeName = new SqlString(sSplit[2]); 
                    row.CompanyName = new SqlString(sSplit[3]); 
                    row.CustomerFirstName = new SqlString(sSplit[4]); 
                    row.CustomerMiddleInitial = new SqlString(sSplit[5]); 
                    row.City = new SqlString(sSplit[6]); 
                    row.State = new SqlString(sSplit[7]); 
                    row.Address1 = new SqlString(sSplit[8]); 
                    row.Address2 = new SqlString(sSplit[9]); 
                    row.PostCode = new SqlString(sSplit[10]); 
                    row.TypeFruitVeg = new SqlString(sSplit[11]); 
                    row.ProfCode = new SqlString(sSplit[12]); 
                    row.OwnCode = new SqlString(sSplit[13]); 
                    row.IncState = new SqlString(sSplit[14]);
                    row.IncDate = getSQLDateForPACAFileDate(sSplit[15]);
                    row.MailAddress1 = new SqlString(sSplit[16]); 
                    row.MailAddress2 = new SqlString(sSplit[17]); 
                    row.MailCity = new SqlString(sSplit[18]); 
                    row.MailState = new SqlString(sSplit[19]); 
                    row.MailPostCode = new SqlString(sSplit[20]); 
                    row.AreaCode = new SqlString(sSplit[21]); 
                    row.Exchange = new SqlString(sSplit[22]); 
                    row.Telephone = new SqlString(sSplit[23]);
                    row.TerminateDate = getSQLDateForPACAFileDate(sSplit[24]);
                    row.TerminateCode = new SqlString(sSplit[25]);
                    row.PACARunDate = getSQLDateForPACAFileDate(sSplit[26]);

                    licenses.Add(row);
                }
            }

        }finally{
            //Revert the impersonation context; note that impersonation is needed only            
            //when opening the file.             
            //SQL Server will raise an exception if the impersonation is not undone             
            // before returning from the function.            
            if (OriginalContext != null)
                OriginalContext.Undo();
        }            

        return licenses;

    }
    public static void FillPACALicense(object data,
        out SqlString LicenseNumber,
        out SqlDateTime ExpirationDate,
        out SqlString PrimaryTradeName,
        out SqlString CompanyName,
        out SqlString CustomerFirstName,
        out SqlString CustomerMiddleInitial,
        out SqlString City,
        out SqlString State,
        out SqlString Address1,
        out SqlString Address2,
        out SqlString PostCode,
        out SqlString TypeFruitVeg,
        out SqlString ProfCode,
        out SqlString OwnCode,
        out SqlString IncState,
        out SqlDateTime IncDate,
        out SqlString MailAddress1,
        out SqlString MailAddress2,
        out SqlString MailCity,
        out SqlString MailState,
        out SqlString MailPostCode,
        out SqlString AreaCode,
        out SqlString Exchange,
        out SqlString Telephone,
        out SqlDateTime TerminateDate,
        out SqlString TerminateCode,
        out SqlDateTime PACARunDate
    )
    {
        PacaLicense pl = (PacaLicense)data;
        LicenseNumber = pl.LicenseNumber;
        ExpirationDate = pl.ExpirationDate;
        PrimaryTradeName = pl.PrimaryTradeName;
        CompanyName = pl.CompanyName;
        CustomerFirstName = pl.CustomerFirstName;
        CustomerMiddleInitial = pl.CustomerMiddleInitial;
        City = pl.City;
        State = pl.State;
        Address1 = pl.Address1;
        Address2 = pl.Address2;
        PostCode = pl.PostCode;
        TypeFruitVeg = pl.TypeFruitVeg;
        ProfCode = pl.ProfCode;
        OwnCode = pl.OwnCode;
        IncState = pl.IncState;
        IncDate = pl.IncDate;
        MailAddress1 = pl.MailAddress1;
        MailAddress2 = pl.MailAddress2;
        MailCity = pl.MailCity;
        MailState = pl.MailState;
        MailPostCode = pl.MailPostCode;
        AreaCode = pl.AreaCode;
        Exchange = pl.Exchange;
        Telephone = pl.Telephone;
        TerminateDate = pl.TerminateDate;
        TerminateCode = pl.TerminateCode;
        PACARunDate = pl.PACARunDate;
    }


    internal class PacaLicense
    {
		public SqlString LicenseNumber;//license number
		public SqlDateTime ExpirationDate;//Expiration date
		public SqlString PrimaryTradeName;//primary trade name
		public SqlString CompanyName;//customer name
		public SqlString CustomerFirstName;//customer first name
		public SqlString CustomerMiddleInitial;//customer middle initial
		public SqlString City;//city
		public SqlString State;//state
		public SqlString Address1;//address line 1
		public SqlString Address2;//address line 2
		public SqlString PostCode;//zip+4
		public SqlString TypeFruitVeg;//type fruit / veg
		public SqlString ProfCode;//type business code
		public SqlString OwnCode;//ownership
		public SqlString IncState;//state incorporated
		public SqlDateTime IncDate;//date incorporated
		public SqlString MailAddress1;//mailing address line 1
		public SqlString MailAddress2;//mailing address line 2
		public SqlString MailCity;//mailing city
		public SqlString MailState;//mailing state
		public SqlString MailPostCode;//mailing zip+4
		public SqlString AreaCode;//area code
		public SqlString Exchange;//exchange
		public SqlString Telephone;//number
		public SqlDateTime TerminateDate;//termination date
        public SqlString TerminateCode;//termination code
		public SqlDateTime PACARunDate;//run date

        public PacaLicense()
        {

        }

    }
};

