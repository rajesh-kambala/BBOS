<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyContacts.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyContacts" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>

<%@ Register TagPrefix="bbos" TagName="Sidebar" Src="UserControls/Sidebar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHero" Src="UserControls/CompanyHero.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyBio" Src="UserControls/CompanyBio.ascx" %>

<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
  <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
  <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />

  <%--Record Count--%>
  <asp:HiddenField ID="hidSelectedCount" runat="server" Value="0" />
  <asp:HiddenField ID="hidExportsMax" runat="server" Value="0" />
  <asp:HiddenField ID="hidExportsUsed" runat="server" Value="0" />
  <asp:HiddenField ID="hidExportsPeriod" runat="server" Value="M" />
  
  <asp:HiddenField ID="hidPersonIDs_HCO" runat="server" Value="" />
  <asp:HiddenField ID="hidPersonIDs_AC" runat="server" Value="" />
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
  <!-- Left nav bar  -->
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="2" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, Contacts %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
    <p class="page-heading"><%= Resources.Global.Contacts %></p>
    <section class="company-bio">
      <div id="pAll">
        <%--Export modal--%>
        <div class="modal fade" id="ContactDataExportModal" tabindex="-1" aria-labelledby="ContactDataExportModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header">
                <h1 class="modal-title fs-5" id="ContactDataExportModalLabel"><%=Resources.Global.ContactDataExport %></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <asp:Panel ID="fsContactExportSettings" runat="server">
                  <div class="form-group form-inline">
                    <label for="<%= rbExportHCO.ClientID %>" class="col-md-3 col-sm-2"><%= Resources.Global.ExportType %>:</label>
                    <div class="input-group col-md-9 col-sm-10">
                      <div style="width: 100%">
                        <asp:RadioButton ID="rbExportHCO" GroupName="rbExport" Text="<%$ Resources:Global, ContactExportCompanyHeadExecutive %>" Checked="true" runat="server" CssClass="space" />&nbsp;
                                            <a id="WhatIsContactExportCHE" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                              <img src="images/info_sm.png" />
                                            </a>
                      </div>
                      <div style="width: 100%">
                        <asp:RadioButton ID="rbExportAC" GroupName="rbExport" Text="<%$ Resources:Global, ContactExportAllContacts %>" runat="server" CssClass="space" />&nbsp;
                                            <a id="WhatIsContactExportAll" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                              <img src="images/info_sm.png" />
                                            </a>
                      </div>
                    </div>
                  </div>
                  <br />
                  <div class="form-group form-inline">
                    <label for="<%= ddlContactExportFormat.ClientID %>" class="col-md-3"><%= Resources.Global.ExportFormat %>:</label>
                    <div class="input-group col-md-3 col-sm-3">
                      <asp:DropDownList ID="ddlContactExportFormat" runat="server" CssClass="form-control" />
                    </div>
                  </div>

                </asp:Panel>

              </div>
              <div class="modal-footer">
                <button type="button" class="bbsButton bbsButton-secondary filled" data-bs-dismiss="modal">
                  <span class="msicon notranslate">close</span>
                  <span>
                    <asp:Literal runat="server" Text="<%$Resources:Global, Cancel%>" /></span>
                </button>
                <asp:LinkButton CssClass="bbsButton bbsButton-primary" ID="btnGenerateExport" OnClick="btnGenerateExportOnClick" OnClientClick="if(!ValidateExportsCount()) return false;" runat="server" type="button">
                    <span class="msicon notranslate">download</span>
                    <span> <asp:Literal runat="server" Text="<%$Resources:Global, btnGenerateExportFile%>" /></span>
                </asp:LinkButton>
              </div>
            </div>
          </div>
        </div>
        <%--Export modal end--%>

        <div class="bbs-card-bordered">
          <div class="bbs-card-header tw-flex tw-justify-between">
            <span><%= Resources.Global.BBOSContacts %></span>
            <button type="button" class="bbsButton bbsButton-secondary filled small" data-bs-toggle="modal" data-bs-target="#ContactDataExportModal">
              <span class="msicon notranslate">download</span>
              <span>
                <asp:Literal runat="server" Text="<%$Resources:Global, Download%>" /></span>
            </button>
          </div>
          <div class="bbs-card-body no-padding overflow-auto">
            <div class="table-responsive">
              <asp:GridView ID="gvContacts"
                runat="server"
                AllowSorting="true"
                AutoGenerateColumns="false"
                CssClass="table table-hover"
                GridLines="None"
                OnSorting="GridView_Sorting"
                OnRowDataBound="GridView_RowDataBound"
                HeaderStyle-CssClass="vertical-align-top">

                <Columns>
                  <asp:BoundField HeaderText="Seq" HeaderStyle-CssClass="tw-font-semibold text-nowrap vertical-align-top" ItemStyle-CssClass="text-center" DataField="DefaultSequence" SortExpression="DefaultSequence" />

                  <asp:TemplateField HeaderText="<%$ Resources:Global, vCard %>" ItemStyle-CssClass="text-center hidden-p" HeaderStyle-CssClass="tw-font-semibold text-center vertical-align-top hidden-p">
                    <ItemTemplate>
                      <asp:ImageButton ImageUrl='<%# UIUtils.GetImageURL("icon-vcard.gif") %>' ToolTip="<%$ Resources:Global, DownloadVCard %>" value='<%# Eval("pers_PersonID") %>' OnClick="btnVCardOnClick" runat="server" />
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderStyle-CssClass="tw-font-semibold vertical-align-top" HeaderText="<%$ Resources:Global, PersonName %>" SortExpression="pers_LastName">
                    <ItemTemplate>
                      <%# GetPersonDataForCell((int)Eval("pers_PersonID"), (string)Eval("PersonName"), UIUtils.GetBool(Eval("HasNote"))) %>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:BoundField HeaderText="<%$ Resources:Global, Title %>" HeaderStyle-CssClass="tw-font-semibold vertical-align-top" ItemStyle-CssClass="text-start" DataField="peli_PRTitle" SortExpression="peli_PRTitle" />

                  <asp:TemplateField HeaderText="<%$ Resources:Global, EmailAddress %>" HeaderStyle-CssClass="tw-font-semibold vertical-align-top" ItemStyle-CssClass="text-start">
                    <ItemTemplate>
                      <a href='mailto:<%#Eval("Email")%>' class='explicitlink'><%#Eval("Email")%></a>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" HeaderStyle-CssClass="tw-font-semibold vertical-align-top" ItemStyle-CssClass="text-start" DataField="Phone" />
                </Columns>
              </asp:GridView>
            </div>
          </div>
        </div>
      </div>
      <br />
    </section>
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <script language="javascript" type="text/javascript">
      $("input[name='ctl00$contentLeftSidebar$rbExport']").change(function () {
        if ($("input[name='ctl00$contentLeftSidebar$rbExport']:checked").val() == "rbExportHCO")
            $("#contentMain_hidSelectedCount").val($("#<%=hidPersonIDs_HCO.ClientID%>").val().split(',').length);
          else
            $("#contentMain_hidSelectedCount").val($("#<%=hidPersonIDs_AC.ClientID%>").val().split(',').length);
      });
  </script>
</asp:Content>
