<% 
    // If this is for a lumber company, then reset the Trade Activity tab to point
    // to a different page.
    if (recCompany("comp_PRIndustryType") == "L") { 
        var lumberTradeActivityURL = eWare.URL("PRCompany/PRCompanyARAgingOnListing.asp");
%>
        <script type="text/javascript">
            var colTDS = document.getElementsByTagName("TD");
            for (var ndx = 0; ndx < colTDS.length; ndx++) {
                if ((colTDS[ndx].innerText == "Trade Activity") &&
                    (colTDS[ndx].className == "TABOFF")) {
                    colTDS[ndx].onMouseOver = "window.status='<% =lumberTradeActivityURL %>';return true;";
                    colTDS[ndx].onclick = lumberRedirect;
                    break;
                }
            }

            function lumberRedirect(e) {
                document.location.href = "<% =lumberTradeActivityURL %>";
            }

        </script>

<% } %>



<!-- #include file="CompanyTopContent.asp" -->

    <div class="TOPBODY" id="BBSITopContent" style="display:none;" >
    <% =GenerateCompanyTopContent() %>
    </div>
 
    <script type="text/javascript">

        crm.ready(function () {

            if ($("#BBSITopContent").html() != "") {
               $("#EWARE_TOP").html($("#BBSITopContent").html());
                $("#BBSITopContent").html("");
           }

        })

   </script>


<!-- #include file="../PRCoPageFooter.asp" -->
