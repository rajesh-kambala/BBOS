/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc. 2019-2024

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc. is 
 strictly prohibited.

 Confidential, Unpublished Property of Blue Book Services, Inc.
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: BOR.aspx.cs
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using PRCo.EBB.BusinessObjects;
using PRCo.EBB.Util;
using TSI.BusinessObjects;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web.PublicProfiles
{
    public partial class BOR : MembershipBase
    {
        protected CreditCardPaymentInfo _oCCPayment = null;

        override protected void Page_Load(object sender, EventArgs e)
        {
            base.Page_Load(sender, e);

            Master.SetFormClass("member step-5 listing");

            _oCCPayment = (CreditCardPaymentInfo)Session["oCreditCardPayment"];

            if (_oCCPayment == null)
            {
                Response.Redirect(GetMarketingSiteURL());
            }

            if (!IsPostBack)
            {
                hidRequestType.Text = GetRequestParameter("type").ToUpper();
                lblTotal.Text = GetFormattedCurrency(_oCCPayment.TotalPrice, 0M);

                cddCountry.ServicePath = GetWebServiceURL();
                cddState.ServicePath = GetWebServiceURL();

                cddCountry.ContextKey = GetString(Session[SESSION_COUNTRY]);
                cddState.ContextKey = GetString(Session[SESSION_STATE]);

                SetListDefaultValue(ddlCountry, GetString(Session[SESSION_COUNTRY]));
                SetListDefaultValue(ddlState, GetString(Session[SESSION_STATE]));

                LoadLookupValues();
                PopulateForm();
            }
        }

        /// <summary>
        /// Loads all of the databound controls setting 
        /// thier default values.
        /// </summary>
        protected void LoadLookupValues()
        {
            // Bind Company Type drop-down
            BindLookupValues(ddlTypeofEntity, GetReferenceData("BOR_TypeofEntity", GetCulture()));
            ddlTypeofEntity.Items.Insert(0, new ListItem("", ""));

            BindState("1", ddlIncorporatedState); //US

            BindClassifications(cblProduceBuyer, 0, 1);
            BindClassifications(cblProduceSeller, 0, 2);
            BindClassifications(cblProduceBroker, 0, 3);
            BindClassifications(cblSupplyChainServices, 0, 4);
            BindClassifications(cblTransportation, 1, 5);
            BindClassifications(cblSupply, 2, 6);
        }

        private const string SQL_GET_CLASSIFICATIONS =
            @"SELECT prcl_ClassificationID, {2} prcl_Name, prcl_Level, 
                prcl_BookSection, prcl_ParentID, prcl_CompanyCount, prcl_CompanyCountIncludeLocalSource, prcl_DisplayOrder, 
                prcl_Description
              FROM PRClassification WITH(NOLOCK)
                where prcl_BookSection = {0}
                and prcl_parentid={1}
                order by prcl_displayorder";

        private void BindClassifications(CheckBoxList cbl, int prcl_BookSection, int prcl_parentid)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("Culture", GetCulture()));
            
            string szColName = "prcl_Name";
            if (GetCulture() == SPANISH_CULTURE)
                szColName = szColName + "_es";

                string szSQL = string.Format(SQL_GET_CLASSIFICATIONS, prcl_BookSection, prcl_parentid, szColName);
            cbl.DataSource = GetDBAccess().ExecuteReader(szSQL, null, CommandBehavior.CloseConnection, null);
            cbl.DataBind();
        }

        const string SQL_GET_STATES =
            @"SELECT prst_StateID, prst_State FROM PRState WITH(NOLOCK) WHERE prst_CountryID = @prst_CountryID and prst_State IS NOT NULL ORDER BY prst_State";

        private void BindState(string szCountryID, DropDownList ddl)
        {
            ArrayList oParameters = new ArrayList();
            oParameters.Add(new ObjectParameter("prst_CountryID", szCountryID));
            ddl.DataSource = GetDBAccess().ExecuteReader(SQL_GET_STATES, oParameters, CommandBehavior.CloseConnection, null);
            ddl.DataValueField = "prst_StateID";
            ddl.DataTextField = "prst_State";
            ddl.DataBind();

            ddl.Items.Insert(0, new ListItem("", ""));
        }

        /// <summary>
        /// Populates the form controls.
        /// </summary>
        protected void PopulateForm()
        {
            switch (hidRequestType.Text)
            {
                case "P":
                    pnlProduce0.Visible = true;
                    pnlProduce1.Visible = true;
                    pnlProduce2.Visible = true;

                    pnlBusinessInformation.Visible = true;
                    pnlNameofBank.Visible = true;
                    pnlPrincipals.Visible = true;
                    pnlEntity.Visible = true;

                    break;
                case "T":
                    pnlTransportation0.Visible = true;
                    pnlTransportation1.Visible = true;
                    pnlTransportation2.Visible = true;

                    pnlBusinessInformation.Visible = true;
                    pnlNameofBank.Visible = true;
                    pnlPrincipals.Visible = true;
                    pnlEntity.Visible = true;
                    break;
                case "S":
                    pnlSupply0.Visible = true;
                    pnlSupply1.Visible = true;

                    pnlBusinessInformation.Visible = true;
                    pnlNameofBank.Visible = false;
                    pnlPrincipals.Visible = false;
                    pnlEntity.Visible = false;
                    break;
            }

            membershipHeader.Visible = true;

            txtCompanyName.Text = GetString(Session[SESSION_COMPANYNAME]);
            txtPhone.Text = GetString(Session[SESSION_SUBMITTERPHONE]);

            string szAddress = GetString(Session[SESSION_STREET1]);
            if (GetString(Session[SESSION_STREET2]) != string.Empty)
                szAddress += " " + GetString(Session[SESSION_STREET2]);

            txtMailingAddress.Text = szAddress;
            txtCity.Text = GetString(Session[SESSION_CITY]);

            //SetListDefaultValue(ddlCountry, GetString(Session[SESSION_COUNTRY]));
            //SetListDefaultValue(ddlState, GetString(Session[SESSION_STATE]));

            txtZipCode.Text = GetString(Session[SESSION_ZIP]);

            hlAGTools.NavigateUrl = Utilities.GetConfigValue("AGToolsURL", "https://bluebook.ag.tools/home");
        }

        private void ClearPaymentInfoFromSession()
        {
            //Clear session info we got from payment.aspx page
            Session.Remove(SESSION_COMPANYNAME);
            Session.Remove(SESSION_SUBMITTERPHONE);
            Session.Remove(SESSION_STREET1);
            Session.Remove(SESSION_STREET2);
            Session.Remove(SESSION_CITY);
            Session.Remove(SESSION_STATE);
            Session.Remove(SESSION_ZIP);
            Session.Remove(SESSION_COUNTRY);
        }

        private string GetEmailBody()
        {
            const string I3 = "   ";
            const string I6 = "      ";
            string szIndustry;
            szIndustry = hidRequestType.Text;

            StringBuilder sbMsg = new StringBuilder();
            sbMsg.Append("BOR data received from " + txtCompanyName.Text + Environment.NewLine + Environment.NewLine);

            sbMsg.Append("Business Information" + Environment.NewLine);
            sbMsg.Append(I3 + "Industry: ");
            switch (szIndustry)
            {
                case "P":
                    sbMsg.Append("Produce" + Environment.NewLine);
                    break;
                case "S":
                    sbMsg.Append("Supply" + Environment.NewLine);
                    break;
                case "T":
                    sbMsg.Append("Transportation" + Environment.NewLine);
                    break;
            }

            sbMsg.Append(I3 + "Company Name: " + txtCompanyName.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Mailing Address: " + txtMailingAddress.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Mailing City: " + txtCity.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Mailing State: " + ddlState.SelectedItem.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Mailing Country: " + ddlCountry.SelectedItem.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Mailing Zip (Postal): " + txtZipCode.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Phone: " + txtPhone.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Fax: " + txtFax.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Website: " + txtWebsite.Text + Environment.NewLine);
            sbMsg.Append(I3 + "Company Email Address: " + txtCompanyEmail.Text + Environment.NewLine);

            if(szIndustry != "S")
                sbMsg.Append(I3 + "Name of Bank: " + txtBankName.Text + Environment.NewLine);

            switch (szIndustry)
            {
                case "P":
                    sbMsg.Append(I3 + "PACA # " + txtPACANumber.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "DRC # " + txtDRCNumber.Text + Environment.NewLine);
                    break;
                case "T":
                    sbMsg.Append(I3 + "MC # " + txtMCNumber.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Freight Forwarder # " + txtFreightForwarderNumber.Text + Environment.NewLine);
                    break;
            }

            if (szIndustry != "S")
            {
                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Principal #1" + Environment.NewLine);
                sbMsg.Append(I3 + "Name: " + txtPrincipalName1.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Title: " + txtTitle1.Text + Environment.NewLine);
                sbMsg.Append(I3 + "% of Ownership: " + txtOwnership1.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Year Born: " + txtYearBorn1.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Years in Position: " + txtYearsInPosition1.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Years at Company: " + txtYearsAtCompany1.Text + Environment.NewLine);

                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Principal #2" + Environment.NewLine);
                sbMsg.Append(I3 + "Name: " + txtPrincipalName2.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Title: " + txtTitle2.Text + Environment.NewLine);
                sbMsg.Append(I3 + "% of Ownership: " + txtOwnership2.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Year Born: " + txtYearBorn2.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Years in Position: " + txtYearsInPosition2.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Years at Company: " + txtYearsAtCompany2.Text + Environment.NewLine);

                sbMsg.Append(Environment.NewLine);
                sbMsg.Append("Principal #3" + Environment.NewLine);
                sbMsg.Append(I3 + "Name: " + txtPrincipalName3.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Title: " + txtTitle3.Text + Environment.NewLine);
                sbMsg.Append(I3 + "% of Ownership: " + txtOwnership3.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Year Born: " + txtYearBorn3.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Years in Position: " + txtYearsInPosition3.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Years at Company: " + txtYearsAtCompany3.Text + Environment.NewLine);

                sbMsg.Append(Environment.NewLine);

                sbMsg.Append("Were any of the above principals formerly financially interested in, or managed of, any business which became bankrupt or otherwise failed to pay indebtedness in full? " + rblBankrupt.SelectedItem.Text);

                sbMsg.Append(Environment.NewLine + Environment.NewLine);

                sbMsg.Append("Entity" + Environment.NewLine);
                sbMsg.Append(I3 + "Type of Entity: " + ddlTypeofEntity.SelectedItem.Text + Environment.NewLine);
                if (ddlTypeofEntity.SelectedItem.Text == "Other")
                {
                    sbMsg.Append(I3 + "    Other Type: " + txtOther.Text + Environment.NewLine);
                }
                sbMsg.Append(I3 + "Date Business Established: " + txtDateBusinessEstablished.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Date Incorporated: " + txtDateIncorporated.Text + Environment.NewLine);
                sbMsg.Append(I3 + "Incorporated U.S. State: " + ddlIncorporatedState.SelectedItem.Text + Environment.NewLine);
                sbMsg.Append(I3 + "# of Permanent Employees: " + txtNumPermanentEmployees.Text + Environment.NewLine);
            }

            sbMsg.Append(Environment.NewLine);

            sbMsg.Append("Nature of Business" + Environment.NewLine);

            switch (szIndustry)
            {
                case "P":
                    List<string> selectedProduceBuyer = cblProduceBuyer.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedProduceBuyer.Count > 0)
                    {
                        sbMsg.Append(I3 + "PRODUCE BUYER" + Environment.NewLine);
                        sbMsg.Append(I6 + string.Join(", ", selectedProduceBuyer) + Environment.NewLine);
                    }

                    List<string> selectedProduceSeller = cblProduceSeller.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedProduceSeller.Count > 0)
                    {
                        sbMsg.Append(I3 + "PRODUCE SELLER" + Environment.NewLine);
                        sbMsg.Append(I6 + string.Join(", ", selectedProduceSeller) + Environment.NewLine);
                    }

                    List<string> selectedProduceBroker = cblProduceBroker.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedProduceBroker.Count > 0)
                    {
                        sbMsg.Append(I3 + "PRODUCE BROKER" + Environment.NewLine);
                        sbMsg.Append(I6 + string.Join(", ", selectedProduceBroker) + Environment.NewLine);
                    }

                    List<string> selectedSupplyChainServices = cblSupplyChainServices.Items.Cast<ListItem>()
                      .Where(li => li.Selected)
                      .Select(li => li.Text)
                      .ToList();
                    if (selectedSupplyChainServices.Count > 0)
                    {
                        sbMsg.Append(I3 + "SUPPLY CHAIN SERVICES" + Environment.NewLine);
                        sbMsg.Append(I6 + string.Join(", ", selectedSupplyChainServices) + Environment.NewLine);
                    }

                    sbMsg.Append(Environment.NewLine);

                    sbMsg.Append("Commodities Handled" + Environment.NewLine);
                    sbMsg.Append(I3 + "Top 5 to 10 Fruit & Vegetables Sold/Bought: " + txtCommoditiesHandled.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Annual Trucklot Volume: " + txtAnnualTrucklotVol_P.Text + Environment.NewLine);

                    sbMsg.Append(Environment.NewLine);

                    sbMsg.Append("Produce Info" + Environment.NewLine);

                    List<string> selectedProduceBoughtFrom = cblProduceBuyFrom.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedProduceBoughtFrom.Count > 0)
                    {
                        sbMsg.Append(I3 + "Produce Bought From: ");
                        sbMsg.Append(string.Join(", ", selectedProduceBoughtFrom) + Environment.NewLine);
                    }

                    sbMsg.Append(I6 + "Produce Purchased State: " + txtStatesBuyProduce.Text + Environment.NewLine);
                    sbMsg.Append(I6 + "Produce Purchased Countries: " + txtCountriesBuyProduce.Text + Environment.NewLine);
                    sbMsg.Append(Environment.NewLine);

                    List<string> selectedProduceSoldTo = cblProduceSellTo.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedProduceSoldTo.Count > 0)
                    {
                        sbMsg.Append(I3 + "Produce Sold To: ");
                        sbMsg.Append(string.Join(", ", selectedProduceSoldTo) + Environment.NewLine);
                    }

                    sbMsg.Append(I6 + "Produce Sold State: " + txtStatesSellProduce.Text + Environment.NewLine);
                    sbMsg.Append(I6 + "Produce Sold Countries: " + txtCountriesSellProduce.Text + Environment.NewLine);
                    sbMsg.Append(Environment.NewLine);

                    sbMsg.Append("Brand Names: " + txtBrandNames.Text + Environment.NewLine);
                    break;
                case "T":
                    List<string> selectedTransportation = cblTransportation.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedTransportation.Count > 0)
                    {
                        sbMsg.Append(I6 + string.Join(", ", selectedTransportation) + Environment.NewLine);
                    }

                    sbMsg.Append(Environment.NewLine);

                    sbMsg.Append(I3 + "Geographic Areas Served: " + txtGeographicAreasServed.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Annual Trucklot Volume: " + txtAnnualTrucklotVol_T.Text + Environment.NewLine);

                    List<string> selectedTransportationArrangeWith = cblTransportationArrangeWith.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    sbMsg.Append(I3 + "Arrange Transportation With: ");
                    if (selectedTransportationArrangeWith.Count > 0)
                    {
                        sbMsg.Append(string.Join(", ", selectedTransportationArrangeWith) + Environment.NewLine);
                    }
                    else
                    {
                        sbMsg.Append("None" + Environment.NewLine);
                    }

                    sbMsg.Append(I3 + "Number of Trucks Owned: " + txtNumTrucksOwned.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Number of Trucks Leased: " + txtNumTrucksLeased.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Number of Trailers Owned: " + txtNumTrailersOwned.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Number of Trailers Leased: " + txtNumTrailersLeased.Text + Environment.NewLine);

                    sbMsg.Append(Environment.NewLine);

                    sbMsg.Append("Number of Units" + Environment.NewLine);
                    sbMsg.Append(I3 + "Reefer Trailers: " + txtReeferTrailers.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Dry Van Trailers: " + txtDryVanTrailers.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Piggyback Trailers: " + txtPiggybackTrailers.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Flatbed Trailers: " + txtFlatbedTrailers.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Tankers: " + txtTankers.Text + Environment.NewLine);
                    sbMsg.Append(I3 + "Containers: " + txtContainers.Text + Environment.NewLine);

                    sbMsg.Append(Environment.NewLine);

                    sbMsg.Append("Type of Freight" + Environment.NewLine);
                    sbMsg.Append(I3 + "Produce: " + txtProduce.Text + "%" + Environment.NewLine);
                    sbMsg.Append(I3 + "Non-Produce Refrigerated/Frozen: " + txtNonProduceCold.Text + "%" + Environment.NewLine);
                    sbMsg.Append(I3 + "Non-Produce/Non-Refrigerated: " + txtNonProduceNonCold.Text + "%" + Environment.NewLine);

                    break;

                case "S":
                    List<string> selectedSupply = cblSupply.Items.Cast<ListItem>()
                        .Where(li => li.Selected)
                        .Select(li => li.Text)
                        .ToList();
                    if (selectedSupply.Count > 0)
                    {
                        sbMsg.Append(I6 + string.Join(", ", selectedSupply) + Environment.NewLine);
                    }

                    break;
            }

            sbMsg.Append(Environment.NewLine);
            sbMsg.Append("Descriptive Listing Facts: ");
            if (string.IsNullOrEmpty(txtListingFacts.Text))
                sbMsg.Append("None");
            else
                sbMsg.Append(txtListingFacts.Text);

            return sbMsg.ToString();
        }

        protected void EmailCSR(int UnknownCityUserID, string szEmailSubject, string szEmailBody)
        {
            int iPRCoSpecialistID = GetObjectMgr().GetPRCoSpecialistID(txtCity.Text,
                                                           Convert.ToInt32(ddlState.SelectedValue),
                                                           GeneralDataMgr.PRCO_SPECIALIST_INSIDE_SALES,
                                                           GetIndustryType(),
                                                           null);
            if (iPRCoSpecialistID == 0)
            {
                iPRCoSpecialistID = UnknownCityUserID;
            }

            //Defect 7020, 3768, and 7397 email changes
            GeneralDataMgr oMgr = new GeneralDataMgr(_oLogger, null);
            oMgr.SendEmail(Utilities.GetConfigValue("BORListingEmailRecipients", "JLair@bluebookservices.com;llima@bluebookservices.com;treardon@bluebookservices.com"),
                            EmailUtils.GetFromAddress(),
                            szEmailSubject,
                            szEmailBody,
                            false,
                            null,
                            "BOR.aspx",
                            null);
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            //Email the BOR info to the listing specialist
            string szEmailSubject = string.Format(Utilities.GetConfigValue("BOREmailSubject", "BOR Data for {0}"), txtCompanyName.Text);
            string szEmailBody = GetEmailBody();

            EmailCSR(
                Utilities.GetIntConfigValue("BORListingSpecialistUnknownCityPRCoUserID", 24),
                szEmailSubject,
                szEmailBody);

            //Clear session and redirect to BBOS homepage
            ClearPaymentInfoFromSession();
            string szUrl = "";

            if(LangQueryString().Contains("?"))
                szUrl = string.Format("{0}&url={1}", "BORComplete.aspx" + LangQueryString(), new Custom_CaptionMgr(_oCustom_CaptionMgr).GetMeaning("BBOS", "URL"));
            else
                szUrl = string.Format("{0}?url={1}", "BORComplete.aspx", new Custom_CaptionMgr(_oCustom_CaptionMgr).GetMeaning("BBOS", "URL"));

            Response.Redirect(szUrl);
        }

        private string GetCulture()
        {
            var lang = Request.QueryString["lang"];
            if (!string.IsNullOrEmpty(lang))
            {
                if (lang == SPANISH_CULTURE)
                    return SPANISH_CULTURE;
            }
            return ENGLISH_CULTURE;
        }
    }
}