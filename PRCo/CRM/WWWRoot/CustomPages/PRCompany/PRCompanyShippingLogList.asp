<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    lstMain = eWare.GetBlock("PRShipmentLogGrid");
    lstMain.prevURL = eWare.URL(f_value);
    lstMain.PadBottom = true;
    
   
    blkContainer.AddBlock(lstMain);

    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url("PRCompany/PRCompanyService.asp") + "&T=Company&Capt=Services"));
    eWare.AddContent(blkContainer.Execute("prshplg_CompanyID=" + comp_companyid));

    Response.Write(eWare.GetPage('Company'));
%>

<script type="text/javascript">
    function openTrackingWindow(sCarrier, sTrackingNumber) {

        var url = "";
        if (sCarrier == "FedEx") {
            url = "http://fedex.com/Tracking?action=track&tracknumber_list=" + sTrackingNumber + "&cntry_code=us";
        }
        if ((sCarrier == "USPS") ||
            (sCarrier == "US Postal Service")) {
            url = "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?origTrackNum=" + sTrackingNumber;
        }

        window.open(url,
                    "shipmentTracking",
                    "location=no,menubar=no,status=no,toolbar=yes,scrollbars=yes,resizable=yes,width=800,height=600", true);
    }

    colTD = document.getElementsByTagName("TD");
    for (var i = 0; i < colTD.length; i++) {
        if ((colTD[i].className == "ROW1") ||
            (colTD[i].className == "ROW2")) {
            
            var oTD = colTD[i]

            for (var j = 0; j < oTD.children.length; j++) {
                if (oTD.children[j].tagName == "A") {
                    var sCarrier = colTD[i-1].innerText;
                    var sTrackingNumber = oTD.children[j].innerText;
                    oTD.children[j].href = "javascript:openTrackingWindow('" + sCarrier + "', '" + sTrackingNumber + "');";
                }
            }
        }
    }
//</script>


<!-- #include file="CompanyFooters.asp" -->