<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanyProfileViews.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyProfileViews" MasterPageFile="BBOS.Master" EnableEventValidation="false" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style type="text/css">
        .explicitlink {
            color: rgb(226,232,240) !important;
            text-decoration: underline !important;
            cursor: pointer !important;
        }

        .explicitlink:hover  
        {
            color: rgb(226,232,240) !important;
            text-decoration: none !important;
            cursor: pointer !important;
        }
    </style>
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />

    <!-- Main  -->
    <main class="main-content tw-m-4 tw-flex tw-flex-col tw-gap-y-4">
        <h3><%=Resources.Global.PeopleAreReviewingCompanyProfile %></h3>
        <p><%=Resources.Global.EmployeesFromFollowingRecentlyViewed %></p>
        <div>
            <p class="caption"><asp:Literal id="litRollingList" runat="server" /></p>
        </div>

        <div class="whosviewd" id="divPopulated" runat="server">
            <table class="table table-striped tw-m-0">
                <thead class="table-light">
                    <tr>
                        <th scope="col"></th>
                        <th scope="col"><%=Resources.Global.Company %></th>
                        <th scope="col"><%=Resources.Global.Rating %></th>
                        <th scope="col"><%=Resources.Global.Location %></th>
                        <th scope="col"><%=Resources.Global.BBNumber %></th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="repRows" runat="server" OnItemDataBound="repRows_ItemDataBound">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:Image ID="imgLogo" runat="server" Visible="false" />
                                </td>
                                <td>
                                    <asp:HyperLink ID="hlCompanyDetails" runat="server"><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                </td>
                                <td>
                                    <%# Eval("prra_RatingLine") %>
                                </td>
                                <td>
                                    <%# Eval("CityStateCountryShort") %>
                                </td>
                                <td>
                                    <%# Eval("ViewedByCompanyID") %>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>

        <div class="whosviewd" id="divEmpty" runat="server" visible="false">
            <table class="table table-striped tw-m-0">
                <thead class="table-light">
                    <tr>
                        <th scope="col"></th>
                        <th scope="col"><%=Resources.Global.Company %></th>
                        <th scope="col"><%=Resources.Global.Rating %></th>
                        <th scope="col"><%=Resources.Global.Location %></th>
                        <th scope="col"><%=Resources.Global.BBNumber %></th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
            <div class="emptylist"><%=Resources.Global.NoVisitsToCompanyProfile %></div>
        </div>

          <div class="whosviewedNotEnabled" id="divNotEnabled" runat="server" visible="false">
            <div class="backdrop">
              <div class="container">
                <p>****************************************************************</p>
                <br />
                <p><%=Resources.Global.ContactCustomerSuccess %></p>
                <p>
                    <a href="mailto:CustomerSuccess@bluebookservices.com" class="explicitlink">CustomerSuccess@bluebookservices.com</a> <%=Resources.Global.Or %> 630-668-3500
                </p>
                <br />
                <p>****************************************************************</p>
              </div>
            </div>
          </div>
    </main>
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
    <style>
    .main-content-old {
        width: 100%;
    }
</style>
</asp:Content>
