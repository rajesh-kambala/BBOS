<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanySearch.aspx.cs" Inherits="BBOSMobileSales.CompanySearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:HiddenField ID="hidPage" runat="server" Value="1" />
    <asp:HiddenField ID="hidItemsPerPage" runat="server" />

    <div class="card my-3">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Company Search</h5>

            <div class="row">
                <div class="col-6 col-sm-4 col-lg-2 mb-2">
                    <asp:TextBox ID="txtBBNum" runat="server" CssClass="form-control form-control-sm" placeholder="BB #" />
                </div>
            </div>

            <div class="row">
                <div class="col-12 mb-2">
                    <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control form-control-sm" placeholder="Company Name" />
                </div>
            </div>

            <div class="row">
                <div class="col-12 mb-2">
                    <asp:DropDownList ID="ddlListingStatus" runat="server" CssClass="form-control form-control-sm" />
                </div>
            </div>

            <div class="row">
                <div class="col-12 col-sm-3 mb-2">
                    <asp:DropDownList ID="ddlIndustry" runat="server" CssClass="form-control form-control-sm" />
                </div>

                <div class="col-12 col-sm-3 mb-2">
                    <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control form-control-sm" />
                </div>

                <div class="col-12 col-sm-6 mb-2">
                    <asp:DropDownList ID="ddlSalesTerritory" runat="server" CssClass="form-control form-control-sm" />
                </div>
            </div>
        </div>

        <div class="row my-3">
            <div class="col-6 text-center">
                <button class="btn btn-sm btn-bbsi" onclick="search();return false;">Search</button>
            </div>
            <div class="col-6 text-center">
                <a class="btn btn-sm btn-bbsi" href="CompanySearch.aspx">Clear</a>
            </div>
        </div>
    </div>

    <div class="data-list mx-3 d-none" id="searchResults">
        <h5 class="card-title mt-0">Search Results</h5>
        <div id="searchResults2">
        </div>
    </div>

    <div id="spinner" class="text-center d-none">
        <img src="images/spinner.gif" style="width: 50px; height: auto;" />
    </div>

    <div id="scrollContents" class="d-none">
    </div>

    <script>
        var END_OF_RESULTS = '<div style="color:red">--End of Results--</div>';
        var NO_RESULTS_FOUND = '<div style="color:red">--No Results Found--</div>';

        $(document).ready(function () {
            prepDropDownClass('ContentPlaceHolder1_ddlListingStatus');
            prepDropDownClass('ContentPlaceHolder1_ddlIndustry');
            prepDropDownClass('ContentPlaceHolder1_ddlState');
            prepDropDownClass('ContentPlaceHolder1_ddlSalesTerritory');
        });

        function endsWith(str, suffix) {
            return str.indexOf(suffix, str.length - suffix.length) !== -1;
        }

        var searchResultsVisible = false;
        var searchResultsCount = 16;
        function search() {
            if (!validate())
                return;

            CompanySearch();

            $("#searchResults").removeClass("d-none");
            searchResultsVisible = true;
        }

        function validate() {
            if ($("#<%=txtBBNum.ClientID%>").val().length > 0) {
                if (isNaN($("#<%=txtBBNum.ClientID%>").val())) {
                    bootbox.alert("BB# must be numeric.");
                    return false;
                }
            }

            return true;
        }

        function CompanySearch() {
            $("#<%=hidPage.ClientID%>").val("1");

            var jsdata = generateSearchJson();

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AJAXHelper.asmx/CompanySearch",
                data: jsdata,
                dataType: "text",
                success: function (msg) {
                    displayResults(msg);
                },
                error: function (e) {
                }
            });
        }

        function displayResults(msg) {
            var obj = JSON.parse(msg);
            var htm = "";

            $.each(obj, function (i, item) {
                var x = JSON.parse(item);

                if (x.length == 1) {
                    location.href = "CompanyView.aspx?CompanyID=" + x[0].comp_CompanyID;
                }

                $.each(x, function (index, item) {
                    var h = "";
                    h += '<div class="row data-row"><div class="col-12"><a href="CompanyView.aspx?CompanyID={0}">{1}</a><br />{2}<br />{3} {4}<br />{5}</div></div>';
                    h = h.replace("{0}", item.comp_CompanyID);
                    h = h.replace("{1}", item.comp_PRBookTradestyle);
                    h = h.replace("{2}", item.CityStateCountryShort);
                    h = h.replace("{3}", item.comp_prindustrytype);
                    h = h.replace("{4}", item.comp_prType);
                    h = h.replace("{5}", item.comp_prlistingstatus);
                    htm += h;
                });

            });

            if (htm.length > 0)
                $("#searchResults2").html(htm);
            else
                $("#searchResults2").html(NO_RESULTS_FOUND);
        }

        function CompanySearch_Scroll() {
            var value = parseInt($("#<%=hidPage.ClientID%>").val()) + 1;
            $("#<%=hidPage.ClientID%>").val(value);

            var jsdata = generateSearchJson();

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "AJAXHelper.asmx/CompanySearch",
                data: jsdata,
                dataType: "text",
                success: function (msg) {
                    appendResults(msg);
                },
                error: function (e) {
                }
            });
        }

        function generateSearchJson() {
            jsonObj = {};
            jsonObj.BBNum = $("#<%=txtBBNum.ClientID%>").val();
            jsonObj.CompanyName = $("#<%=txtCompanyName.ClientID%>").val();
            jsonObj.ListingStatus = $("#<%=ddlListingStatus.ClientID%>").val();
            jsonObj.Industry = $("#<%=ddlIndustry.ClientID%>").val();
            jsonObj.State = $("#<%=ddlState.ClientID%>").val();
            jsonObj.SalesTerritory = $("#<%=ddlSalesTerritory.ClientID%>").val();
            jsonObj.Page = $("#<%=hidPage.ClientID%>").val();
            jsonObj.ItemsPerPage = $("#<%=hidItemsPerPage.ClientID%>").val();

            var json = JSON.stringify(jsonObj);
            console.log(json);
            return json;
        }

        function getItem(i, v) {
            item = {};
            item["i"] = i;
            item["v"] = v;
            return item;
        }

        console.log("Begin CompanySearch");
        $("#searchResults").scroll(function () {
            console.log("scroll");
        });

        $(window).on('scroll', function () {

            if ($("#searchResults").hasClass("d-none"))
                return;

            if ($(window).scrollTop() >= $('#searchResults').offset().top + $('#searchResults').
                outerHeight() - window.innerHeight) {
                if (querying)
                    return;

                if (endsWith($("#searchResults2").html(), END_OF_RESULTS))
                    return;

                querying = true;
                $("#spinner").removeClass("d-none");
                CompanySearch_Scroll();
            }
        });

        var querying = false;

        function appendResults(msg) {
            var obj = JSON.parse(msg);
            var htm = "";

            $.each(obj, function (i, item) {
                var x = JSON.parse(item);
                $.each(x, function (index, item) {
                    var h = "";
                    h += '<div class="row data-row"><div class="col-12"><a href="CompanyView.aspx?CompanyID={0}">{1}</a><br />{2}<br />{3} {4}<br />{5}</div></div>';
                    h = h.replace("{0}", item.comp_CompanyID);
                    h = h.replace("{1}", item.comp_PRBookTradestyle);
                    h = h.replace("{2}", item.CityStateCountryShort);
                    h = h.replace("{3}", item.comp_prindustrytype);
                    h = h.replace("{4}", item.comp_prType);
                    h = h.replace("{5}", item.comp_prlistingstatus);
                    htm += h;
                });

            });

            $("#spinner").addClass("d-none");

            if (htm.length > 0)
                $("#searchResults2").append(htm); // Append the additional content
            else
                $("#searchResults2").append(END_OF_RESULTS);

            querying = false;
        }
    </script>
</asp:Content>