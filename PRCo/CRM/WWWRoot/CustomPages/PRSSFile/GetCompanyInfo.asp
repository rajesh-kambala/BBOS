<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
doPage();
function doPage()
{
    Response.Expires=0 
    Response.ExpiresAbsolute="July 9,1998 17:30:00"

    var prssc_ssfileid = Request("SSFileId");
    var prssc_companyid = Request("CompanyID");
    var sSetOptions = "";
    sSetOptions += "eCurrentPersonId.options[eCurrentPersonId.options.length] = new Option(\"-- Use Contact ATTN --\", \"\");\n" ;
    var sql = "select peli_Personid, dbo.ufn_FormatPersonById(peli_Personid) as FullName " +
          " from Person_Link " +
          " where peli_PRStatus = 1 and peli_CompanyId = " +Request("CompanyID") + 
          " order by FullName ";
    qryPersons = eWare.CreateQueryObj(sql);
    qryPersons.SelectSql();
    re = new RegExp("'", "g");
    while (!qryPersons.eof)
    {
		sFullName = new String(qryPersons("FullName"));
		sFullName = sFullName.replace(re, "\\'");
		sSetOptions += "eCurrentPersonId.options[eCurrentPersonId.options.length] = new Option('" + sFullName + "'," + qryPersons("peli_PersonId") + ");\n" ;
        qryPersons.NextRecord();
    }
    
	sBuffer = "eCurrentPersonId.options.length = 0;\n";	
	sBuffer = sBuffer + sSetOptions;

    // now create statements for setting the address, email, and phone values
    sql = "select " +
        "DefaultPhone = dbo.ufn_FormatPhone(phone.phon_CountryCode, phone.phon_AreaCode, phone.phon_Number, phone.phon_PRExtension), " + 
        "DefaultFax= dbo.ufn_FormatPhone(fax.phon_CountryCode, fax.phon_AreaCode, fax.phon_Number, fax.phon_PRExtension), " + 
        "addr_Address1, addr_Address2, addr_Address3, prci_city, prst_Abbreviation, addr_PostCode " + 
        "FROM vPRAddress " +
             "LEFT OUTER JOIN vPRCompanyPhone fax WITH (NOLOCK) ON adli_CompanyID = fax.plink_RecordID AND fax.phon_PRIsFax = 'Y' AND fax.phon_PRPreferredInternal = 'Y' " +
             "LEFT OUTER JOIN vPRCompanyPhone phone WITH (NOLOCK) ON adli_CompanyID = phone.plink_RecordID AND  phone.phon_PRIsPhone = 'Y' AND phone.phon_PRPreferredInternal = 'Y' " +
        "where adli_PRDefaultMailing = 'Y' and adli_CompanyId = " + Request("CompanyID") ;
    qryAddress = eWare.CreateQueryObj(sql);
    qryAddress.SelectSql();
    if (!qryAddress.eof)
    {
		sAddress1 = new String(qryAddress("addr_Address1"));
		if (isEmpty(sAddress1)) sAddress1 = "";
		sAddress2 = new String(qryAddress("addr_Address2"));
		if (isEmpty(sAddress2)) sAddress2 = "";
		sAddress3 = new String(qryAddress("addr_Address3"));
		if (isEmpty(sAddress3)) sAddress3 = "";
		sCity = new String(qryAddress("prci_City"));
		if (isEmpty(sCity)) sCity = "";
		sState = new String(qryAddress("prst_Abbreviation"));
		if (isEmpty(sState)) sState = "";
		sZip = new String(qryAddress("addr_PostCode"));
		if (isEmpty(sZip)) sZip = "";
		sCSZ = sCity + ", " + sState + " " + sZip;
		sDefaultPhone = new String(qryAddress("DefaultPhone"));
		if (isEmpty(sDefaultPhone)) sDefaultPhone = "";
		sDefaultFax = new String(qryAddress("DefaultFax"));
		if (isEmpty(sDefaultFax)) sDefaultFax = "";
		sBuffer += "document.EntryForm.prssc_address1.value = '" + sAddress1 + "';\n" ;
		sBuffer += "document.EntryForm.prssc_address2.value = '" + sAddress2 + "';\n" ;
		sBuffer += "document.EntryForm.prssc_address3.value = '" + sAddress3 + "';\n" ;
		sBuffer += "document.EntryForm.prssc_citystatezip.value = '" + sCSZ + "';\n" ;
		sBuffer += "document.EntryForm.prssc_telephone.value = '" + sDefaultPhone + "';\n" ;
		sBuffer += "document.EntryForm.prssc_fax.value = '" + sDefaultFax + "';\n" ;
		//sBuffer += "document.EntryForm.prssc_email.value = '" + qryAddress("DefaultEmail") + "';\n" ;
    }
    
	// check the contacts for the selected company and see if the IsPrimary flag needs to be set
    sql = "select prssc_IsPrimary from PRSSContact WHERE " +
            "prssc_SSFileId = " + prssc_ssfileid + " and prssc_CompanyId = " + Request("CompanyID") ;
    qryPrimary = eWare.CreateQueryObj(sql);
    qryPrimary.SelectSql();
    if (qryPrimary.eof)
    {
		sBuffer += "document.EntryForm.prssc_isprimary.checked = true;\n" ;
		sBuffer += "document.EntryForm.prssc_isprimary.disabled = true;\n" ;
		sBuffer += "document.EntryForm._HIDDENprssc_isprimary.value = 'Y';\n" ;
	}	

	Response.Write(sBuffer);
}
%>