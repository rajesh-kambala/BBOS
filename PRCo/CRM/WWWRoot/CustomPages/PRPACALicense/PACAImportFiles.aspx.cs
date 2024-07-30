using System;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Specialized;

namespace PRCo.BBS.CRM
{
	/// <summary>
	/// Summary description for PACAImportFiles.
	/// </summary>
	public partial class PACAImportFiles : PageBase
	{
		private const int LICENSE_FILE_TYPE = 0;
		private const int PRINCIPAL_FILE_TYPE = 1;
		private const int TRADE_FILE_TYPE = 2;
        private const int COMPLAINT_FILE_TYPE = 3;

        private const int LICENSE_FILE_COLUMN_COUNT = 32;
		private const int PRINCIPAL_FILE_COLUMN_COUNT = 8;
		private const int TRADE_FILE_COLUMN_COUNT = 5;
        private const int COMPLAINT_FILE_COLUMN_COUNT = 7;

        private class DBParam 
		{
			public string SPParamName;
			public SqlDbType Type;
			public string ParamValue;

			public DBParam(string SPParamName, SqlDbType Type)  
			{
				this.SPParamName = SPParamName;
				this.Type = Type;
			}

			public DBParam(string SPParamName, SqlDbType Type, string ParamValue)  
			{
				this.SPParamName = SPParamName;
				this.Type = Type;
				this.ParamValue = ParamValue;
			}
		}

		private ArrayList alLicenseParams  = null;
		private ArrayList alPrincipalParams  = null;
		private ArrayList alTradeParams  = null;
        private ArrayList alComplaintParams = null;

        protected String sSID = "";
        protected string sAppName;

        protected override void Page_Load(object sender, System.EventArgs e)
		{
            //base.Page_Load(sender, e);

            NameValueCollection appSettings =
               ConfigurationManager.AppSettings;
            this.sAppName = appSettings["AppName"];
			this.sSID = Request.Params.Get("SID");
			hidSID.Text = this.sSID;
			// Upload link
			lnkUpload.NavigateUrl="javascript:upload();";
			this.lnkUpload.Text = "Upload PACA Files";
			this.lnkUploadImage.NavigateUrl="javascript:upload();";
			this.lnkUploadImage.ImageUrl = "/" + this.sAppName + "/img/Buttons/Attachment.gif";
			this.lnkUploadImage.Text = "Upload";
			
			// Upload link
			this.lnkContinue.NavigateUrl="javascript:pageContinue();";
			this.lnkContinue.Text = "Continue";
			this.lnkContinueImage.NavigateUrl="javascript:pageContinue();";
			this.lnkContinueImage.ImageUrl = "/" + this.sAppName + "/img/Buttons/Continue.gif";
			this.lnkContinueImage.Text = "Continue";
			//this.lblMessage.Text = "Loading Page!";

			// Set the results panels to invisible until we are sure there is something to show
			pnlLicenseStats.Visible = false;
			pnlPrincipalStats.Visible = false;
			pnlTradeStats.Visible = false;
            pnlComplaintStats.Visible = false;

            lblLicenseSuccess.Text = "";
			lblLicenseFailed.Text = "";
			lblLicenseWrongFormat.Text = "";
			lblPrincipalSuccess.Text = "";
			lblPrincipalFailed.Text = "";
			lblPrincipalWrongFormat.Text = "";
			lblTradeSuccess.Text = "";
			lblTradeFailed.Text = "";
			lblTradeWrongFormat.Text = "";
            lblComplaintSuccess.Text = "";
            lblComplaintFailed.Text = "";
            lblComplaintWrongFormat.Text = "";

            // Check for form submission
            if ( Page.IsPostBack)
			{
				ProcessPACAFiles();
			}
		}

		private void ProcessPACAFiles()
		{
			try
			{
                bool bProcessImportedRecords = false;
                // Check to see if a license file was uploaded
				if( fileLicenseUpload.PostedFile != null 
					&& fileLicenseUpload.PostedFile.FileName != null
					&& fileLicenseUpload.PostedFile.FileName.Length > 0)
				{
					// create an array list of the expected license file input fields
					if ( alLicenseParams  == null || alLicenseParams.Count == 0)
					{
						InitializeParamList(LICENSE_FILE_TYPE);
					}

					// PRocess the file
					ProcessFile(fileLicenseUpload.PostedFile, 
						"usp_CreateImportPACALicense",
						alLicenseParams, 
						LICENSE_FILE_COLUMN_COUNT, 
						LICENSE_FILE_TYPE);
					//this.lblError.Text += "<br>Filename:[" + fileLicenseUpload.PostedFile.FileName + "]";
					pnlLicenseStats.Visible = true;
                    bProcessImportedRecords = true;
				}	
				// Check to see if a principal file was uploaded
				if( filePrincipalUpload.PostedFile != null 
					&& filePrincipalUpload.PostedFile.FileName != null
					&& filePrincipalUpload.PostedFile.FileName.Length > 0)
				{
					// create an array list of the expected principal file input fields
					if ( alPrincipalParams  == null || alPrincipalParams.Count == 0)
					{
						InitializeParamList(PRINCIPAL_FILE_TYPE);
					}

					// PRocess the file
					ProcessFile(filePrincipalUpload.PostedFile, 
						"usp_CreateImportPACAPrincipal",
						alPrincipalParams, 
						PRINCIPAL_FILE_COLUMN_COUNT, 
						PRINCIPAL_FILE_TYPE);
					pnlPrincipalStats.Visible = true;
				}	
				// Check to see if a trade file was uploaded
				if( fileTradeUpload.PostedFile != null 
					&& fileTradeUpload.PostedFile.FileName != null
					&& fileTradeUpload.PostedFile.FileName.Length > 0)
				{
					// create an array list of the expected Trade file input fields
					if ( alTradeParams  == null || alTradeParams.Count == 0)
					{
						InitializeParamList(TRADE_FILE_TYPE);
					}

					// PRocess the file
					ProcessFile(fileTradeUpload.PostedFile, 
						"usp_CreateImportPACATrade",
						alTradeParams, 
						TRADE_FILE_COLUMN_COUNT, 
						TRADE_FILE_TYPE);
					pnlTradeStats.Visible = true;
				}
                // Check to see if a complaint file was uploaded
                if (fileComplaintUpload.PostedFile != null
                    && fileComplaintUpload.PostedFile.FileName != null
                    && fileComplaintUpload.PostedFile.FileName.Length > 0)
                {
                    // create an array list of the expected Complaint file input fields
                    if (alComplaintParams == null || alComplaintParams.Count == 0)
                    {
                        InitializeParamList(COMPLAINT_FILE_TYPE);
                    }

                    // Process the file
                    ProcessFile(fileComplaintUpload.PostedFile,
                        "usp_CreateImportPACAComplaint",
                        alComplaintParams,
                        COMPLAINT_FILE_COLUMN_COUNT,
                        COMPLAINT_FILE_TYPE);
                    pnlComplaintStats.Visible = true;
                }

                if (bProcessImportedRecords)
                {
                    SqlConnection conCRM = null;
                    SqlCommand cmdCreate = null;
                    SqlParameter parm = null;
                    int iReturn;
                    // invoke the sp that processes the imported records
                    conCRM = OpenDBConnection();
                    cmdCreate = new SqlCommand("usp_PACAProcessImports", conCRM);
                    cmdCreate.CommandType = CommandType.StoredProcedure;
                    // clear all stored procedure parameters
                    cmdCreate.Parameters.Clear();

                    // create the return parameter
                    parm = cmdCreate.Parameters.Add("ReturnValue", SqlDbType.Int);
                    parm.Direction = ParameterDirection.ReturnValue;
                    cmdCreate.ExecuteNonQuery();
                    iReturn = Convert.ToInt32(cmdCreate.Parameters["ReturnValue"].Value);
                    lblLicenseMatched.Text = String.Format("License Numbers Matched:&nbsp;{0}", iReturn);

                    //Process Complaints (3.1.2.5)
                    SqlCommand cmdProcessComplaints = null;

                    cmdProcessComplaints = new SqlCommand("usp_PACAProcessComplaints", conCRM);
                    cmdProcessComplaints.CommandType = CommandType.StoredProcedure;
                    cmdProcessComplaints.ExecuteNonQuery();
                }
 
            }  
			catch (Exception e)
			{
				this.lblError.Text += "<br>" + e.Message;
			}
		}

		private void ProcessFile(HttpPostedFile hpfFile,
										string sStoredProc,
										ArrayList alParams, 
										int iExpectedCount, 
										int iFileType)
		{
			// Get size of uploaded file
			int nFileLen = hpfFile.ContentLength; 

			// make sure the size of the file is > 0
			if( nFileLen > 0 )
			{
				// Create a name for the file to store
				string sFilename = Path.GetFileName(hpfFile.FileName);
				// Make all date references one consistent time
				DateTime dtNow = DateTime.Now;

				// Prepare to open the file
				StreamReader stmReader = null;
				
				// Prepare for a connection to the DB
				SqlConnection conCRM = null;
				SqlCommand cmdCreate = null;
				SqlParameter parm = null;
				int iReturn;

				//create some variables for statistics
				int iWrongCount = 0;
				int iFailedLoad = 0;
				int iSuccessLoad = 0;
				string [] sSplit = null;
				try
				{
                    conCRM = OpenDBConnection();
                    cmdCreate = new SqlCommand( sStoredProc, conCRM );
					cmdCreate.CommandType = CommandType.StoredProcedure;

					// Read the file
					stmReader = new StreamReader(hpfFile.InputStream);

					// Process each line of input
					int iSequence = 0; //used by Principal
					string sLine = null;
					while ((sLine = stmReader.ReadLine()) != null)
					{
						sSplit = sLine.Split(',');
						// Cursory validation of this line says that it 
						// should have <iExpectedCount> fields
						// If it doesn't we cannot process it.
						if (sSplit.Length != iExpectedCount)
						{
							iWrongCount++;
							continue;
						}
						// this record may have a fighting chance at being processed
						for (int i=0; i<sSplit.Length; i++)
						{
							// if the value is empty, set our string value property to null
							if (sSplit[i].Length == 0)
								((DBParam)alParams [i]).ParamValue = null;
							else
								((DBParam)alParams [i]).ParamValue = sSplit[i];
						}
						try
						{

							// clear all stored procedure parameters
							cmdCreate.Parameters.Clear();

							// create the return parameter
							parm = cmdCreate.Parameters.Add( "ReturnValue", SqlDbType.Int );
							parm.Direction = ParameterDirection.ReturnValue;
									
							// Load the stored procedure based upon file type
							if (iFileType == LICENSE_FILE_TYPE)
							{
								// load sp parameters common for each call
								parm = cmdCreate.Parameters.AddWithValue( "@pril_FileName", sFilename);
                                parm = cmdCreate.Parameters.AddWithValue("@pril_ImportDate", dtNow);
								// now load the License input file parameters
								LoadLicenseParameters(cmdCreate);
							}
							else if (iFileType == PRINCIPAL_FILE_TYPE)
							{
								// load sp parameters common for each call
                                parm = cmdCreate.Parameters.AddWithValue("@prip_FileName", sFilename);
                                parm = cmdCreate.Parameters.AddWithValue("@prip_ImportDate", dtNow);
								// load the sequence
                                parm = cmdCreate.Parameters.AddWithValue("@prip_Sequence", iSequence);
								// now load the License input file parameters
								LoadPrincipalParameters(cmdCreate);
								iSequence++;
							}
							else if (iFileType == TRADE_FILE_TYPE)
							{
								// load sp parameters common for each call
                                parm = cmdCreate.Parameters.AddWithValue("@prit_FileName", sFilename);
                                parm = cmdCreate.Parameters.AddWithValue("@prit_ImportDate", dtNow);
								// now load the License input file parameters
								LoadTradeParameters(cmdCreate);
							}
                            else if (iFileType == COMPLAINT_FILE_TYPE)
                            {
                                // load sp parameters common for each call
                                parm = cmdCreate.Parameters.AddWithValue("@pripc_FileName", sFilename);
                                parm = cmdCreate.Parameters.AddWithValue("@pripc_ImportDate", dtNow);
                                // now load the License input file parameters
                                LoadComplaintParameters(cmdCreate);
                            }

                            cmdCreate.ExecuteNonQuery();
							// This return value is the ID of the record inserted
							// We don't use it here.
							iReturn = Convert.ToInt32(cmdCreate.Parameters[ "ReturnValue" ].Value);
							iSuccessLoad++;
						}
						catch (Exception e)
						{
							if (sSplit != null && sSplit.Length > 1)
								this.lblError.Text += "<br>" + e.Message + " Record: [" + sSplit[0] + "]" ;
							else
								this.lblError.Text += "<br>" + e.Message ;
								
							iFailedLoad++;
						}
					}
				}
				finally
				{	
					// close the database connection
                    if (conCRM != null)
                        CloseDBConnection(conCRM);
                    if (iFileType == LICENSE_FILE_TYPE)
					{
                        lblLicenseSuccess.Text = String.Format("Successfully Loaded:&nbsp;{0}", iSuccessLoad);
                        lblLicenseFailed.Text = String.Format("Failed Records:&nbsp;{0}", iFailedLoad);
                        lblLicenseWrongFormat.Text = String.Format("Wrong Format:&nbsp;{0}", iWrongCount);
					}
					else if (iFileType == PRINCIPAL_FILE_TYPE)
					{
						lblPrincipalSuccess.Text = String.Format("{0}",iSuccessLoad);
						lblPrincipalFailed.Text = String.Format("{0}",iFailedLoad);
						lblPrincipalWrongFormat.Text = String.Format("{0}",iWrongCount);
					}
					else if (iFileType == TRADE_FILE_TYPE)
					{
						lblTradeSuccess.Text = String.Format("{0}",iSuccessLoad);
						lblTradeFailed.Text = String.Format("{0}",iFailedLoad);
						lblTradeWrongFormat.Text = String.Format("{0}",iWrongCount);
					}
                    else if (iFileType == COMPLAINT_FILE_TYPE)
                    {
                        lblComplaintSuccess.Text = String.Format("{0}", iSuccessLoad);
                        lblComplaintFailed.Text = String.Format("{0}", iFailedLoad);
                        lblComplaintWrongFormat.Text = String.Format("{0}", iWrongCount);
                    }
                    if (stmReader != null)
						stmReader.Close();
				}
			}
		}

		/// <summary>
		/// Create the stored procedure parameters for the loading of a
		/// PACA License Record
		/// </summary>
		/// <param name="cmdCreate"></param>
		private void LoadLicenseParameters(SqlCommand cmdCreate)
		{
			string sParamName = null;
			string sParamValue = null;
			string sTempPhone = "";
			SqlDbType iType = SqlDbType.NVarChar;

			for (int i=0; i<alLicenseParams .Count;i++)
			{
				SqlParameter parm = null;
				sParamName = ((DBParam)alLicenseParams [i]).SPParamName;
				sParamValue = ((DBParam)alLicenseParams [i]).ParamValue;
				iType = ((DBParam)alLicenseParams [i]).Type;
				// Determine what to do with the input value
				if (sParamName == null)
				{
					// shouldn't ever be
					continue;
				}
				else if (sParamName.Equals("unused"))
				{
					// we don't use this field from the input table
					continue;
				}
                else if (sParamName.Equals("AreaCode") ||
                         sParamName.Equals("Exchange") ||
                         sParamName.Equals("FaxAreaCode") ||
                         sParamName.Equals("FaxExchange"))
                {
                    // Save these values until we get to telephone
                    sTempPhone += sParamValue;
                }
                else if (sParamName.Equals("@pril_Telephone") ||
                         sParamName.Equals("@pril_Fax"))
                {
                    // Set the telephone parameter on the sp
                    sTempPhone += sParamValue;
                    parm = cmdCreate.Parameters.AddWithValue(sParamName, sTempPhone);
                    sTempPhone = string.Empty;
                }

				else 
				{
					// determine the type and store the sp parameter 
					if (iType == SqlDbType.NVarChar ) //string
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sParamValue);
					else if (iType == SqlDbType.Int ) //int
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, int.Parse(sParamValue));
					else if (iType == SqlDbType.DateTime ) //date
					{
						DateTime dtReturn = InputToDate(sParamValue);
						// if the date is null, don't add the param; the sp
						// will set the value to null
						if (dtReturn!=DateTime.MinValue)
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, dtReturn);
					}	
				}

			}
		}
		private void LoadPrincipalParameters(SqlCommand cmdCreate)
		{
			string sParamName = null;
			string sParamValue = null;
			SqlDbType iType = SqlDbType.NVarChar;

			for (int i=0; i<alPrincipalParams .Count;i++)
			{
				SqlParameter parm = null;
				sParamName = ((DBParam)alPrincipalParams [i]).SPParamName;
				sParamValue = ((DBParam)alPrincipalParams [i]).ParamValue;
				iType = ((DBParam)alPrincipalParams [i]).Type;
				// Determine what to do with the input value
				if (sParamName == null)
				{
					// shouldn't ever be
					continue;
				}
				else if (sParamName.Equals("unused"))
				{
					// we don't use this field from the input table
					continue;
				}
				else 
				{
					// determine the type and store the sp parameter 
					if (iType == SqlDbType.NVarChar ) //string
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sParamValue);
					else if (iType == SqlDbType.Int ) //int
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, int.Parse(sParamValue));
					else if (iType == SqlDbType.DateTime ) //date
					{
						DateTime dtReturn = InputToDate(sParamValue);
						// if the date is null, don't add the param; the sp
						// will set the value to null
						if (dtReturn!=DateTime.MinValue)
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, dtReturn);
					}	
				}

			}
		}

		private void LoadTradeParameters(SqlCommand cmdCreate)
		{
			string sParamName = null;
			string sParamValue = null;
			SqlDbType iType = SqlDbType.NVarChar;

			for (int i=0; i<alTradeParams .Count;i++)
			{
				SqlParameter parm = null;
				sParamName = ((DBParam)alTradeParams [i]).SPParamName;
				sParamValue = ((DBParam)alTradeParams [i]).ParamValue;
				iType = ((DBParam)alTradeParams [i]).Type;
				// Determine what to do with the input value
				if (sParamName == null)
				{
					// shouldn't ever be
					continue;
				}
				else if (sParamName.Equals("unused"))
				{
					// we don't use this field from the input table
					continue;
				}
				else 
				{
					// determine the type and store the sp parameter 
					if (iType == SqlDbType.NVarChar ) //string
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sParamValue);
					else if (iType == SqlDbType.Int ) //int
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, int.Parse(sParamValue));
					else if (iType == SqlDbType.DateTime ) //date
					{
						DateTime dtReturn = InputToDate(sParamValue);
						// if the date is null, don't add the param; the sp
						// will set the value to null
						if (dtReturn!=DateTime.MinValue)
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, dtReturn);
					}	
				}

			}
		}

        private void LoadComplaintParameters(SqlCommand cmdCreate)
        {
            string sParamName = null;
            string sParamValue = null;
            SqlDbType iType = SqlDbType.NVarChar;

            for (int i = 0; i < alTradeParams.Count; i++)
            {
                SqlParameter parm = null;
                sParamName = ((DBParam)alTradeParams[i]).SPParamName;
                sParamValue = ((DBParam)alTradeParams[i]).ParamValue;
                iType = ((DBParam)alTradeParams[i]).Type;
                // Determine what to do with the input value
                if (sParamName == null)
                {
                    // shouldn't ever be
                    continue;
                }
                else if (sParamName.Equals("unused"))
                {
                    // we don't use this field from the input table
                    continue;
                }
                else
                {
                    // determine the type and store the sp parameter 
                    if (iType == SqlDbType.NVarChar) //string
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, sParamValue);
                    else if (iType == SqlDbType.Int) //int
                        parm = cmdCreate.Parameters.AddWithValue(sParamName, int.Parse(sParamValue));
                    else if (iType == SqlDbType.DateTime) //date
                    {
                        DateTime dtReturn = InputToDate(sParamValue);
                        // if the date is null, don't add the param; the sp
                        // will set the value to null
                        if (dtReturn != DateTime.MinValue)
                            parm = cmdCreate.Parameters.AddWithValue(sParamName, dtReturn);
                    }
                }

            }
        }


        private void InitializeParamList(int intFileType)
		{
			if (intFileType == LICENSE_FILE_TYPE)
			{
				alLicenseParams = new ArrayList(LICENSE_FILE_COLUMN_COUNT);

                alLicenseParams.Add(new DBParam("@pril_LicenseNumber", SqlDbType.NVarChar));//license number
                alLicenseParams.Add(new DBParam("@pril_ExpirationDate", SqlDbType.DateTime));//Expiration date
                alLicenseParams.Add(new DBParam("@pril_PrimaryTradeName", SqlDbType.NVarChar));//primary trade name
                alLicenseParams.Add(new DBParam("@pril_CompanyName", SqlDbType.NVarChar));//customer name
                alLicenseParams.Add(new DBParam("@pril_CustomerFirstName", SqlDbType.NVarChar));//customer first name
                alLicenseParams.Add(new DBParam("@pril_CustomerMiddleInitial", SqlDbType.NVarChar));//customer middle initial
                alLicenseParams.Add(new DBParam("@pril_City", SqlDbType.NVarChar));//city
                alLicenseParams.Add(new DBParam("@pril_State", SqlDbType.NVarChar));//state
                alLicenseParams.Add(new DBParam("@pril_Address1", SqlDbType.NVarChar));//address line 1
                alLicenseParams.Add(new DBParam("@pril_Address2", SqlDbType.NVarChar));//address line 2
                alLicenseParams.Add(new DBParam("@pril_PostCode", SqlDbType.NVarChar));//zip+4
                alLicenseParams.Add(new DBParam("@pril_TypeFruitVeg", SqlDbType.NVarChar));//type fruit / veg
                alLicenseParams.Add(new DBParam("@pril_ProfCode", SqlDbType.NVarChar));//type business code
                alLicenseParams.Add(new DBParam("@pril_OwnCode", SqlDbType.NVarChar));//ownership
                alLicenseParams.Add(new DBParam("@pril_IncState", SqlDbType.NVarChar));//state incorporated
                alLicenseParams.Add(new DBParam("@pril_IncDate", SqlDbType.DateTime));//date incorporated
                alLicenseParams.Add(new DBParam("@pril_MailAddress1", SqlDbType.NVarChar));//mailing address line 1
                alLicenseParams.Add(new DBParam("@pril_MailAddress2", SqlDbType.NVarChar));//mailing address line 2
                alLicenseParams.Add(new DBParam("@pril_MailCity", SqlDbType.NVarChar));//mailing city
                alLicenseParams.Add(new DBParam("@pril_MailState", SqlDbType.NVarChar));//mailing state
                alLicenseParams.Add(new DBParam("@pril_MailPostCode", SqlDbType.NVarChar));//mailing zip+4
                alLicenseParams.Add(new DBParam("AreaCode", SqlDbType.NVarChar));//area code
                alLicenseParams.Add(new DBParam("Exchange", SqlDbType.NVarChar));//exchange
                alLicenseParams.Add(new DBParam("@pril_Telephone", SqlDbType.NVarChar));//number

                alLicenseParams.Add(new DBParam("@pril_Email", SqlDbType.NVarChar));
                alLicenseParams.Add(new DBParam("@pril_WebAddress", SqlDbType.NVarChar));

                alLicenseParams.Add(new DBParam("FaxAreaCode", SqlDbType.NVarChar));//area code
                alLicenseParams.Add(new DBParam("FaxExchange", SqlDbType.NVarChar));//exchange
                alLicenseParams.Add(new DBParam("@pril_Fax", SqlDbType.NVarChar));//number

                alLicenseParams.Add(new DBParam("@pril_TerminateDate", SqlDbType.DateTime));//termination date
                alLicenseParams.Add(new DBParam("@pril_TerminateCode", SqlDbType.NVarChar));//termination code
                alLicenseParams.Add(new DBParam("@pril_PACARunDate", SqlDbType.DateTime));//run date
			}
			else if (intFileType == PRINCIPAL_FILE_TYPE)
			{
				alPrincipalParams = new ArrayList(PRINCIPAL_FILE_COLUMN_COUNT);
			
				alPrincipalParams.Add( new DBParam( "@prip_LicenseNumber", SqlDbType.NVarChar ) );//license number
				alPrincipalParams.Add( new DBParam( "@prip_LastName", SqlDbType.NVarChar ) );//lastname
				alPrincipalParams.Add( new DBParam( "@prip_FirstName", SqlDbType.NVarChar ) );//firstname
				alPrincipalParams.Add( new DBParam( "@prip_MiddleInitial", SqlDbType.NVarChar ) );//middle initial
				alPrincipalParams.Add( new DBParam( "@prip_Title", SqlDbType.NVarChar ) );//position
				alPrincipalParams.Add( new DBParam( "@prip_City", SqlDbType.NVarChar ) );//city
				alPrincipalParams.Add( new DBParam( "@prip_State", SqlDbType.NVarChar ) );//state
				alPrincipalParams.Add( new DBParam( "@prip_PACARunDate", SqlDbType.DateTime ) );//run date
			}
			else if (intFileType == TRADE_FILE_TYPE)
			{
				alTradeParams = new ArrayList(TRADE_FILE_COLUMN_COUNT);
			
				alTradeParams.Add( new DBParam( "@prit_LicenseNumber", SqlDbType.NVarChar ) );//license number
				alTradeParams.Add( new DBParam( "@prit_AdditionalTradeName", SqlDbType.NVarChar ) );//additional trade name
				alTradeParams.Add( new DBParam( "@prit_City", SqlDbType.NVarChar ) );//city
				alTradeParams.Add( new DBParam( "@prit_State", SqlDbType.NVarChar ) );//state
				alTradeParams.Add( new DBParam( "@prit_PACARunDate", SqlDbType.DateTime ) );//run date
			}
            else if (intFileType == COMPLAINT_FILE_TYPE)
            {
                alComplaintParams = new ArrayList(COMPLAINT_FILE_COLUMN_COUNT);

                alComplaintParams.Add(new DBParam("@pripc_BusinessName", SqlDbType.NVarChar));
                alComplaintParams.Add(new DBParam("@pripc_LicenseNumber", SqlDbType.NVarChar));
                alComplaintParams.Add(new DBParam("@pripc_DisInfRepComplaintCount", SqlDbType.Int));
                alComplaintParams.Add(new DBParam("@pripc_InfRepComplaintCount", SqlDbType.Int));
                alComplaintParams.Add(new DBParam("@pripc_DisForRepCompaintCount", SqlDbType.Int));
                alComplaintParams.Add(new DBParam("@pripc_ForRepComplaintCount", SqlDbType.Int));
                alComplaintParams.Add(new DBParam("@pripc_TotalFormalClaimAmt", SqlDbType.Int));
            }
        }
		
		private DateTime InputToDate(string sDate)
		{
			DateTime dtReturn = DateTime.MinValue;
			if (sDate == null || sDate.Trim().Length == 0)
			{
				return dtReturn;
			}

			if (sDate.Length == 7)
			{
				// need to pad an extra zero on the front
				sDate = "0"+sDate;
			}
			try 
			{
				// these values come in the format MMDDYYYY
				int iMonth = int.Parse(sDate.Substring(0,2));
				int iDay = int.Parse(sDate.Substring(2,2));
				int iYear = int.Parse(sDate.Substring(4,4));
				dtReturn = new DateTime(iYear, iMonth, iDay);
			}
			catch (Exception e)
			{
				Response.Write(String.Format("<br>Error converting {0} to DateTime.<br>Error:{1}", sDate, e.Message));
			}
			return dtReturn;
			
		}

	}
}
