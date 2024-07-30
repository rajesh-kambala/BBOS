<!-- #include file="PRCompany/CompanyTopContent.asp" -->
<!-- #include file="PRPerson/PersonTopContent.asp" -->

<%
    var topContent = null;

    if (sTopContentUrl.lastIndexOf("CompanyTopContent.asp", 0) === 0) {
        topContent = GenerateCompanyTopContent();
    }

    if (sTopContentUrl.lastIndexOf("PersonTopContent.asp", 0) === 0) {
        topContent = GeneratePersonTopContent();
    } 


    if (topContent != null) {    
%>


    <div class="TOPBODY" id="BBSITopContent" style="display:none;" >
    <% =topContent %>
    </div>
 
    <script type="text/javascript">

        crm.ready(function () {
            $("#EWARE_TOP").html($("#BBSITopContent").html());
            $("#BBSITopContent").html("");
        })
    </script>

<% } %>