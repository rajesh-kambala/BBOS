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
    [Microsoft.SqlServer.Server.SqlFunction(FillRowMethodName = "FillPACATrade",
       TableDefinition = "[LicenseNumber] nvarchar(max),[AdditionalTradeName] nvarchar(max),[City] nvarchar(max),[State] nvarchar(max),[PACARunDate] datetime")]
    public static IEnumerable PACATradeFile(SqlString sDirectory, SqlString sFileDate)
    {
        return ReadPacaTradeFile(sDirectory, sFileDate);
    }

    private static List<PacaTrade> ReadPacaTradeFile(SqlString sDirectory, SqlString sFileDate)
    {
        List<PacaTrade> Trades = new List<PacaTrade>();
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
            string sFullFilePath = sDirectory.ToString() + sFileDate.ToString() + "Trade.csv";
            if (!File.Exists(sFullFilePath))
                return Trades;

            using (StreamReader sr = new StreamReader(sFullFilePath))
            {
                string sLine = null;
                while ((sLine = sr.ReadLine()) != null)
                {
                    string[] sSplit = sLine.Split(',');
                    PacaTrade row = new PacaTrade();

                    row.LicenseNumber = new SqlString(sSplit[0]);
                    row.AdditionalTradeName = new SqlString(sSplit[1]);
                    row.City = new SqlString(sSplit[2]);
                    row.State = new SqlString(sSplit[3]);
                    row.PACARunDate = getSQLDateForPACAFileDate(sSplit[4]);

                    Trades.Add(row);
                }
            }

        } finally
        {
            //Revert the impersonation context; note that impersonation is needed only            
            //when opening the file.             
            //SQL Server will raise an exception if the impersonation is not undone             
            // before returning from the function.            
            if (OriginalContext != null)
                OriginalContext.Undo();
        }
        return Trades;

    }

    public static void FillPACATrade(object data,
		out SqlString LicenseNumber,
        out SqlString AdditionalTradeName,
		out SqlString City,
		out SqlString State,
		out SqlDateTime PACARunDate
    )
    {
        PacaTrade p = (PacaTrade)data;

        LicenseNumber = p.LicenseNumber;
        AdditionalTradeName = p.AdditionalTradeName;
        City = p.City;
        State = p.State;
        PACARunDate = p.PACARunDate;
    }


    internal class PacaTrade
    {
		public SqlString LicenseNumber;//license number
        public SqlString AdditionalTradeName;//additional trade name
		public SqlString City;//city
		public SqlString State;//state
		public SqlDateTime PACARunDate;//run date

        public PacaTrade()
        {

        }

    }
};

