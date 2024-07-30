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
    [Microsoft.SqlServer.Server.SqlFunction(FillRowMethodName = "FillPACAPrincipal",
        TableDefinition = "[LicenseNumber] nvarchar(max),[LastName] nvarchar(max), [FirstName] nvarchar(max),[MiddleInitial] nvarchar(max),[Title] nvarchar(max),[City] nvarchar(max),[State] nvarchar(max),[PACARunDate] datetime")]
    public static IEnumerable PACAPrincipalFile(SqlString sDirectory, SqlString sFileDate)
    {
        return ReadPacaPrincipalFile(sDirectory, sFileDate);
    }

    private static List<PacaPrincipal> ReadPacaPrincipalFile(SqlString sDirectory, SqlString sFileDate)
    {
        List<PacaPrincipal> principals = new List<PacaPrincipal>();
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
            string sFullFilePath = sDirectory.ToString() + sFileDate.ToString() + "principal.csv";
            if (!File.Exists(sFullFilePath))
                return principals;

            using (StreamReader sr = new StreamReader(sFullFilePath))
            {
                string sLine = null;
                while ((sLine = sr.ReadLine()) != null)
                {
                    string[] sSplit = sLine.Split(',');
                    PacaPrincipal row = new PacaPrincipal();

                    row.LicenseNumber = new SqlString(sSplit[0]);
                    row.LastName = new SqlString(sSplit[1]);
                    row.FirstName = new SqlString(sSplit[2]);
                    row.MiddleInitial = new SqlString(sSplit[3]);
                    row.Title = new SqlString(sSplit[4]);
                    row.City = new SqlString(sSplit[5]);
                    row.State = new SqlString(sSplit[6]);
                    row.PACARunDate = getSQLDateForPACAFileDate(sSplit[7]);

                    principals.Add(row);
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
        return principals;

    }

    public static void FillPACAPrincipal(object data,
		out SqlString LicenseNumber,
		out SqlString LastName,
		out SqlString FirstName,
		out SqlString MiddleInitial,
		out SqlString Title,
		out SqlString City,
		out SqlString State,
		out SqlDateTime PACARunDate
    )
    {
        PacaPrincipal p = (PacaPrincipal)data;

        LicenseNumber = p.LicenseNumber;
        LastName = p.LastName;
        FirstName = p.FirstName;
        MiddleInitial = p.MiddleInitial;
        Title = p.Title;
        City = p.City;
        State = p.State;
        PACARunDate = p.PACARunDate;
    }


    internal class PacaPrincipal
    {
		public SqlString LicenseNumber;//license number
		public SqlString LastName;//lastname
		public SqlString FirstName;//firstname
		public SqlString MiddleInitial;//middle initial
		public SqlString Title;//position
		public SqlString City;//city
		public SqlString State;//state
		public SqlDateTime PACARunDate;//run date

        public PacaPrincipal()
        {

        }

    }
};

