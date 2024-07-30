<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Feedback.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Feedback" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <script type="text/javascript">
        function Toggle() {
            document.getElementById("trProblem1").style.display = "none";
            document.getElementById("trProblem2").style.display = "none";
            document.getElementById("trProblem3").style.display = "none";
            document.getElementById("trProblem4").style.display = "none";
            document.getElementById("trProblem5").style.display = "none";

            document.getElementById("trFeature1").style.display = "none";
            document.getElementById("trFeature2").style.display = "none";
            document.getElementById("trFeature3").style.display = "none";

            document.getElementById("trChange1").style.display = "none";
            document.getElementById("trChange2").style.display = "none";
            document.getElementById("trChange3").style.display = "none";

            document.getElementById("trComment").style.display = "none";
            document.getElementById("trQuestion").style.display = "none";

            document.getElementById("trSuggestCompany1").style.display = "none"
            document.getElementById("trSuggestCompany2").style.display = "none";
            document.getElementById("trSuggestCompany3").style.display = "none";
            document.getElementById("trSuggestCompany4").style.display = "none";
            document.getElementById("trSuggestCompany5").style.display = "none";

            ddlFeedbackType = document.getElementById("<% =ddlFeedbackType.ClientID %>");

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "PR") {
                document.getElementById("trProblem1").style.display = "";
                document.getElementById("trProblem2").style.display = "";
                document.getElementById("trProblem3").style.display = "";
                document.getElementById("trProblem4").style.display = "";
                document.getElementById("trProblem5").style.display = "";
            }

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "RF") {
                document.getElementById("trFeature1").style.display = "";
                document.getElementById("trFeature2").style.display = "";
                document.getElementById("trFeature3").style.display = "";
            }

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "CR") {
                document.getElementById("trChange1").style.display = "";
                document.getElementById("trChange2").style.display = "";
                document.getElementById("trChange3").style.display = "";
            }

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "GC") {
                document.getElementById("trComment").style.display = "";
            }

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "SM") {
                document.getElementById("trSuggestCompany1").style.display = "";
                document.getElementById("trSuggestCompany4").style.display = "";
                document.getElementById("trSuggestCompany5").style.display = "";
            }

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "Q") {
                document.getElementById("trQuestion").style.display = "";
            }

            if (ddlFeedbackType[ddlFeedbackType.selectedIndex].value == "RULC") {
                document.getElementById("trSuggestCompany1").style.display = ""
                document.getElementById("trSuggestCompany2").style.display = "";
                document.getElementById("trSuggestCompany3").style.display = "";
                document.getElementById("trSuggestCompany4").style.display = "";
                document.getElementById("trSuggestCompany5").style.display = "";
            }
        }
    </script>
    <style>
        .main-content-old {
            width: 100%;
        }
        .content-container div.row a.gray_btn {
            display: inline;
            width: auto;
            margin-right: 10px;
            margin-bottom: 20px;
        }
    </style>
    <asp:Panel ID="pnlUserInfo" runat="server">
        <div class="row nomargin_lr vertical-align-top">
            <div class="col-md-2 clr_blu">
                <%=Resources.Global.Name_Cap %>:
            </div>
            <div class="col-md-4 col-xs-10">
                <asp:TextBox ID="txtUserName" Columns="50" runat="server" CssClass="form-control" />
            </div>
        </div>
        <div class="row nomargin_lr vertical-align-top">
            <div class="col-md-2 clr_blu">
                <%=Resources.Global.EmailAddress %>:
            </div>
            <div class="col-md-4 col-xs-10">
                <asp:TextBox ID="txtUserEmail" Columns="50" runat="server" CssClass="form-control" />
            </div>
        </div>
    </asp:Panel>

    <div class="row nomargin_lr vertical-align-top">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.FeedbackType %>:
        </div>
        <div class="col-md-4 col-xs-10">
            <asp:DropDownList ID="ddlFeedbackType" runat="server" onchange="Toggle();" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trProblem1">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.PageName %>:
        </div>
        <div class="col-md-4 col-xs-10 form-inline text-nowrap">
            <asp:TextBox ID="txtPageName" runat="server" CssClass="form-control" Width="100%"/>
            <a id="popWhatIsPageName" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                <img src="images/info_sm.png" />
            </a>
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trProblem2">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.ObjectClickedActionTaken %>:
        </div>
        <div class="col-md-4 col-xs-10 form-inline text-nowrap">
            <asp:TextBox ID="txtClicked" runat="server" CssClass="form-control" Width="100%"/>
            <a id="popWhatIsObjectClicked" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                <img src="images/info_sm.png" />
            </a>
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trProblem3">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.DataBeingViewed %>:
        </div>
        <div class="col-md-4 col-xs-10 form-inline text-nowrap">
            <asp:TextBox ID="txtData" runat="server" CssClass="form-control" Width="100%"/>
            <a id="popDataBeingViewed" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                <img src="images/info_sm.png" />
            </a>
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trProblem4">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.Expectations %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtExpectations" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trProblem5">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.ActualBehavior %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtActualBehavior" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trFeature1" style="display:none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.FeatureDescription %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtDescription" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trFeature2" style="display:none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.HowisthisbeneficialNewFeature %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtChangeBenefits" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trFeature3" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.Howoftenwouldyouuseit %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtHowOften" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trChange1" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.CurrentFunctionality %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtCurrentFunctionality" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trChange2" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.ProposedNewFunctionality %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtProposedFunctionality" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trChange3" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.Howwouldthisbenefityou %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtBenefits" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trComment" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.Comment %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtComment" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trQuestion" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.Question %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtQuestion" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trSuggestCompany1" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.CompanyName %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtCompanyName" Width="100%" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trSuggestCompany2" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.CompanyAddresses2 %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtCompanyAddress" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trSuggestCompany3" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.CompanyPhone %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtCompanyPhone" Width="100%" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trSuggestCompany4" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.CompanyWebSites %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtCompanyWeb" Width="100%" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr vertical-align-top" id="trSuggestCompany5" style="display: none;">
        <div class="col-md-2 clr_blu">
            <%=Resources.Global.AdditionalInformation %>:
        </div>
        <div class="col-md-6 col-xs-10">
            <asp:TextBox ID="txtCompanyAddlInfo" TextMode="MultiLine" Width="100%" Rows="6" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin_lr mar_top">
        <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmitOnClick">
		    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Submit %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
		    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
        </asp:LinkButton>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        Toggle();
    </script>
</asp:Content>