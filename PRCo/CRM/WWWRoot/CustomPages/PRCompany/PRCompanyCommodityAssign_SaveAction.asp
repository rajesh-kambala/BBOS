<%
	// all the values are submitted in the form "hdnComm_<comm id>_GM_<gm id>_Attr_<attrId>_PGM"
	// any part of the commodity value except <comm id> can be left empty

    // this string will keep track of the submitted values that have been processed
    var sProcessedNames = ","
    // create a list of all submitted names
    var sSubmittedNames = ",";
    var sPublishedNames = ","
    for (x=1; x<=Request.Form.count(); x++) {
        sKey = Request.Form.Key(x);
        if (sKey.substring(0, 8) == "hdnComm_"  && sKey.indexOf("_Listing") == -1)
        {
            sSubmittedNames += sKey + ",";
            if (Request.Form.Item(x) != -1)
            {
                sPublishedNames +=  sKey + ",";
            }
        }
    }
    
    // DumpFormValues();
    Response.Write("<br>Submitted: "  + sSubmittedNames);
    Response.Write("<br>Published: "  + sPublishedNames);
    var arrPublishedNames = sPublishedNames.substring(1, sPublishedNames.length-1).split(",");
    // start by determining which records were deleted or updated
    var nType = 0;
    while (!recCCs.eof) 
    {
	    var nCCAId = recCCs("CompanyCommodityAttributeId");
	    var nCommodityId = recCCs("CommodityId");
	    var nGrowingMethodId = recCCs("GrowingMethodId");
	    var nAttributeId = recCCs("AttributeId");

	    var nSequence = recCCs("SequenceNumber");
        if (isEmpty(nSequence))
            nSequence = "-1";
	    var sPublishWithGM = recCCs("PublishWithGM");
        if (isEmpty(sPublishWithGM))
            sPublishWithGM = "";
	    var sPublishedDisplay = recCCs("PublishedDisplay");
        if (isEmpty(sPublishedDisplay))
            sPublishedDisplay = "";

	    if (!isEmpty(nGrowingMethodId) && isEmpty(nAttributeId))
	        nType = 1;
	    else if (isEmpty(nGrowingMethodId) && !isEmpty(nAttributeId))
	        nType = 2;
	    else if (!isEmpty(nGrowingMethodId) && !isEmpty(nAttributeId))
	    {
            if (isEmpty(sPublishWithGM))
	            nType = 3;
	        else
	            nType = 4;
	    }
    	
	    // create a unique name to describe the commodity/growing method/attribute combo
	    sHdnName = "hdnComm_" + nCommodityId;
	    if (!isEmpty(nGrowingMethodId))
	        sHdnName += "_GM_" + nGrowingMethodId;
	    if (!isEmpty(nAttributeId))
	        sHdnName += "_Attr_" + nAttributeId;
	    if (sPublishWithGM != "")
	        sHdnName += "_PGM";
    	    
        // now check if the same value has been submitted
        sValue = new String(Request.Form.Item(sHdnName));
        if (isEmpty(sValue))
        {
            // the record has been removed; remove it for real
            sSQL = "Delete from PRCompanyCommodityAttribute Where prcca_CompanyCommodityAttributeId=" + nCCAId;
	        qryUpdate = eWare.CreateQueryObj(sSQL);
	        qryUpdate.ExecSQL();
        }
        else
        {
            //get the current record
            var recPRCCA = eWare.FindRecord("PRCompanyCommodityAttribute", "prcca_CompanyCommodityAttributeId=" + nCCAId);
            
            // otherwise check the published and sequence values for 
            // (0)Commodity, (1)Comm w/GM, (2)Comm w/ Attr, (3)Comm w/GM & Attr (published with GM), and
            // (4)Comm w/GM & Attr (published with GM)
            sSQL = "";
            var nCurrSequence = -1;
            if (sValue != -1)
            {
                // it's published now;  get the real sequence #
                for (var ndx=1; ndx <= arrPublishedNames.length; ndx++)
                {
                    if (sHdnName == arrPublishedNames[ndx-1])
                    {
                        nCurrSequence = ndx;
                        break;
                    }
                }
            }
            
            // set the Published Display value; this only gets updated if other values are saved
            hdnDisplayValue = new String(Request.Form.Item(sHdnName+"_Listing"));
            Response.Write("<br>:Looking for hdnDisplayValue: " + sHdnName+"_Listing");
            if (!isEmpty(hdnDisplayValue))
            {
                Response.Write(" Found: " + hdnDisplayValue);
                recPRCCA.prcca_PublishedDisplay = hdnDisplayValue;
            }
            // wasn't published and now it is
            if (nCurrSequence != -1 && nSequence == -1)
            {
                recPRCCA.prcca_Sequence =  nCurrSequence;
                if (nType == 4)
                    recPRCCA.prcca_PublishWithGM = "Y"; 
                else
                    recPRCCA.prcca_Publish = "Y";
                recPRCCA.SaveChanges(); 
            }
            else if (nCurrSequence == -1 && nSequence != -1)
            {
                Response.Write("<br/>prcca_CompanyCommodityAttributeId=" + nCCAId);
                Response.Write("<br/> ** Setting Everthing to NULL");
                recPRCCA.prcca_Sequence =  null;
                recPRCCA.prcca_PublishWithGM = "";
                recPRCCA.prcca_Publish = "";
                recPRCCA.SaveChanges(); 
            }
            else if (nCurrSequence != nSequence )
            {
                recPRCCA.prcca_Sequence =  nCurrSequence;
                recPRCCA.SaveChanges(); 
            }
            // add this value to the list of submitted values that have been processed
            sProcessedNames += sHdnName + ","
        }

        recCCs.NextRecord();
    }

    Response.Write("<br>Processed: "  + sProcessedNames);

    // now handle inserts; go through the submitted list again and determine any records 
    // that have not been processed
    for (x=1; x <= Request.Form.count(); x++)
    {
        sKey = Request.Form.Key(x); 
        if (sKey.substring(0, 8) == "hdnComm_"  && sKey.indexOf("_Listing") == -1)
        {
            if (sProcessedNames.indexOf("," + sKey + ",") == -1)
            {
                // this is an insert; use accpac to help with this process
                recNew = eWare.CreateRecord("PRCompanyCommodityAttribute");
                recNew.prcca_CompanyId = comp_companyid;
                
                // decompose the values from the name
                var sName = sKey;
                var nCommId = -1;
                var nAttrId = -1;
                var nGMId = -1;
                var bPGM = false;
                var ndxAttr = sName.indexOf("_Attr_") ;
                var ndxGM = sName.indexOf("_GM_") ;
                
                if ( ndxAttr > -1)
                {
                    //if this is an attribute, determine if this record is for PublishWithGM
                    var sAttr = sName.substring(ndxAttr + "_Attr_".length);
                    var ndxPGM = sAttr.indexOf("_PGM"); // publish with GM tag
                    if (ndxPGM > -1)
                    {
                        nAttrId = sAttr.substring(0, ndxPGM);
                        bPGM = true;
                    }
                    else
                        nAttrId = sAttr;
                    sName = sName.substring(0, ndxAttr);
                }
                if (ndxGM > -1 )
                {
                    nGMId = sName.substring(ndxGM + "_GM_".length);
                    sName = sName.substring(0, ndxGM);
                }
                nCommId = sName.substring(sName.lastIndexOf("_")+1);
                
                //set the records values
                recNew.prcca_CommodityId = nCommId;
                if (nGMId > -1)
                    recNew.prcca_GrowingMethodId = nGMId;
                if (nAttrId > -1)
                    recNew.prcca_AttributeId = nAttrId;
                
                // check the sequence value            
                nCurrSequence = 0;
                sValue = new String(Request.Form.Item(sKey));
                if (sValue != -1)
                {
                    if (bPGM)
                        recNew.prcca_PublishWithGm = "Y";
                    else
                        recNew.prcca_Publish = "Y";
                    // get the real sequence #
                    for (var ndx=1; ndx <= arrPublishedNames.length; ndx++)
                    {
                        if (sKey == arrPublishedNames[ndx-1])
                        {
                            recNew.prcca_Sequence = ndx;
                            break;
                        }
                    }
                }
                // set the Published Display value
                hdnDisplayValue = new String(Request.Form.Item(sKey+"_Listing"));
                if (!isEmpty(hdnDisplayValue))
                    recNew.prcca_PublishedDisplay = hdnDisplayValue;
                // save the record
                recNew.SaveChanges();
            }    
        }
    }
       Response.Redirect(sCancelAction);
%>