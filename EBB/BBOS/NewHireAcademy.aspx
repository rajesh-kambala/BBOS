<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="NewHireAcademy.aspx.cs" Inherits="PRCo.BBOS.UI.Web.NewHireAcademy" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function openVideoWindow(articleID, publicationCode) {
            window.open('VideoPlayer.aspx?PublicationArticleID=' + articleID + '&publicationCode=' + publicationCode, "VideoPlayer", "width=1000, height=650");
            setViewedDate(articleID);
        }

        function setViewedDate(articleID) {
            var today = new Date();
            lastViewed = (today.getMonth() + 1) + '/' + today.getDate() + '/' + today.getFullYear();
            document.getElementById("lastViewed" + articleID).innerHTML = lastViewed;
            document.getElementById("rateVideo" + articleID).disabled = false;
        }

        function openRating(publicationArticleID) {
            window.open("Survey.aspx?Type=NHARating&PublicationArticleID=" + publicationArticleID,
                "NHARating",
                "location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=400,height=250", true);
        }

        function openQuiz() {
            window.open("Survey.aspx?Type=NHA",
                "NHAQuiz",
                "location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=900,height=650", true);
        }

        function enableCertificationQuiz() {
            PRCo.EBB.UI.Web.AJAXHelper.HasRatedAllNHAVideos(enableCertificationQuizOnComplete, enableCertificationQuizOnFailure);
        }

        function enableCertificationQuizOnComplete(result) {
            if (result) {
                document.location.reload(true);
            }
        }

        function enableCertificationQuizOnFailure(result) {
            //alert("Error: " + result.get_message());
        }

        function initPage() {
            if (document.getElementById("contentMain_hidReadArticleIDs").value == "")
                return;

            var readIDs = document.getElementById("contentMain_hidReadArticleIDs").value.split(",");
            for (i = 0; i < readIDs.length; i++) {
                document.getElementById("rateVideo" + readIDs[i]).disabled = false;
            }
        }
    </script>

    <style type="text/css">
        .nhaCell {
            padding-top: 10px;
            padding-bottom: 10px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 vertical-align-top">
            <% =Resources.Global.NHAIntro%>
        </div>
    </div>

    <%--<asp:HyperLink NavigateUrl="~/CompanyDetailsSummary.aspx?CompanyID=118561" ImageUrl="~/en-us/images/NHASponsor.jpg" runat="server" Visible="false" CssClass="explicitlink" />--%>

    <asp:HiddenField ID="hidReadArticleIDs" runat="server" />

    <div class="row nomargin panels_box">
        <div class="col-md-12">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.TrainingSessions %></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div class="row nomargin_lr">
                        <asp:Repeater ID="repTrainingSessions" runat="server">
                            <HeaderTemplate>
                                <table style="width: 100%">
                            </HeaderTemplate>

                            <ItemTemplate>
                                <%# IncrementRepeaterCount() %>
                                <%# GetBeginSeparator(_iRepeaterCount, 3, "33%", false, "nhaCell")%>

                                <span class="nhTitle"><%# _iRepeaterCount%>. <%# Eval("prpbar_Name")  %></span><br />

                                <table width="80%" style="margin-left: 26px; margin-top: 10px; margin-bottom: 15px">
                                    <tr>
                                        <td style="vertical-align: top;">
                                            <a href="#" onclick="openVideoWindow('<%# Eval("prpbar_PublicationArticleID") %>', '<%# Eval("prpbar_PublicationCode") %>')">
                                                <img src="<%# GetThumbnailImage(Eval("prpbar_CoverArtThumbFileName"), "Video") %>" alt="" border="0" style="vertical-align: middle; margin-bottom:4px;">
                                            </a>
                                        </td>

                                        <td align="left" style="vertical-align: top; padding-left: 5px;">
                                            <%# Eval("prpbar_Abstract")%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" align="left" valign="top" style="text-align: center; border-top: thin solid gray;">
                                            <table style="width: 100%">
                                                <tr>
                                                    <td style="width: 50%; margin-top: 5px" align="left"><% =Resources.Global.Duration %>: <%# Eval("prpbar_Length")%></td>
                                                    <td style="width: 50%"><% =Resources.Global.LastViewed %>: <span id="lastViewed<%# Eval("prpbar_PublicationArticleID") %>"><%# GetStringFromDate(Eval("LastReadDate"))%></span></td>
                                                </tr>
                                            </table>

                                            <div class="row nomargin_lr mar_top_5">
                                                <div class="col-md-12 text-left nopadding nomargin">
                                                    <a href="javascript:openRating('<%# Eval("prpbar_PublicationArticleID") %>');" id="rateVideo<%# Eval("prpbar_PublicationArticleID") %>" class="btn gray_btn cursor_pointer" disabled="false">
                                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RateVideo %>" />
                                                    </a>
                                                    &nbsp;
                                                    <a href="<%# PageControlBaseCommon.GetFileDownloadURL((int)Eval("prpbar_PublicationArticleID"), (string)Eval("prpbar_PublicationCode")) %>&CAFN=Y" class="text-nowrap btn gray_btn cursor_pointer" target="_blank">
                                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, DownloadSlides %>" />
                                                    </a>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>

                                <%# GetEndSeparator(_iRepeaterCount, 3) %>
                            </ItemTemplate>

                            <FooterTemplate>
                                </table>
                               
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="col-md-6">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%= Resources.Global.Certification %></h4>
                </div>
                <div class="panel-body nomargin pad10">
                    <div class="row nomargin_lr">
                        <div class="col-md-12">
                            <% =Resources.Global.NHACertificationIntro%>
                        </div>
                    </div>
                    <div class="row nomargin_lr">
                        <div class="col-md-12">
                            <asp:LinkButton ID="btnQuiz" runat="server" CssClass="btn gray_btn">
		                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, TakeCertificationQuiz %>" />
                            </asp:LinkButton>
                            &nbsp; &nbsp;
                                <% =Resources.Global.Lasttaken%>:&nbsp; <asp:Label ID="litLastQuizMsg" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
    </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        initPage();
    </script>
</asp:Content>
