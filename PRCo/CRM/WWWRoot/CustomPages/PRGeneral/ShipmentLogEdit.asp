<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012-2013

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

    doPage();    

function doPage() {

	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;  

    blkMain=eWare.GetBlock("PRShipmentLogQueue");
    blkMain.Title="Edit Manual Shipment";
    blkMain.GetEntry("ShipmentLogID").ReadOnly = true;
    blkMain.GetEntry("Addressee").ReadOnly = true;
    blkMain.GetEntry("ItemList").ReadOnly = true;
    blkMain.GetEntry("DeliveryAddress").ReadOnly = true;
    blkMain.GetEntry("prshplg_MailRoomComments").ReadOnly = true;
    blkMain.GetEntry("comp_CompanyId").ReadOnly = true;
    blkMain.GetEntry("prshplg_CreatedBy").ReadOnly = true;

    if (eWare.Mode < Edit)
        eWare.Mode = Edit;

    sListingAction = eWare.Url("PRGeneral/ShipmentLogQueue.asp");

    var shipmentLogID = getIdValue("ShipmentLogID");
    recShipmentLog = eWare.FindRecord("vPRShipmentLogQueue", "ShipmentLogID=" + shipmentLogID);

    if (eWare.Mode == Save)
    {
        recShipmentLog.prshplg_CarrierCode = Request.Form.Item("prshplg_CarrierCode");
        recShipmentLog.prshplg_TrackingNumber = Request.Form.Item("prshplg_TrackingNumber");
        recShipmentLog.SaveChanges();
        Response.Redirect(sListingAction);
        return;
	}

	if (eWare.Mode == PreDelete )
	{
		//Perform a physical delete of the record
		sql = "DELETE FROM PRShipmentLogDetail WHERE prshplgd_ShipmentLogID="+ shipmentLogID;
		qryDelete = eWare.CreateQueryObj(sql);
		qryDelete.ExecSql();

		sql = "DELETE FROM PRShipmentLog WHERE prshplg_ShipmentLogID="+ shipmentLogID;
		qryDelete = eWare.CreateQueryObj(sql);
		qryDelete.ExecSql();

        Response.Redirect(sListingAction);
        return;
	}

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);
    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));

	sDeleteUrl = changeKey(sURL, "em", "3");
	//blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='" + sDeleteUrl + "';"));
    blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:if (confirm('Are you sure you want to delete this shipment?')) { location.href='" + sDeleteUrl + "';}"));

    
    eWare.AddContent(blkContainer.Execute(recShipmentLog));
    Response.Write(eWare.GetPage());

    Response.Write("<script type='text/javascript'>");
    Response.Write("    document.getElementById('_Datashipmentlogid').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Dataaddressee').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Datacomp_companyid').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Datacomp_prcorrtradestyle').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Dataitemlist').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Datadeliveryaddress').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Dataprshplg_mailroomcomments').className = 'VIEWBOX';");
    Response.Write("    document.getElementById('_Dataprshplg_createdby').className = 'VIEWBOX';");
    Response.Write("</script>");

}


%>

