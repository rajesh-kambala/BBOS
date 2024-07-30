<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="QA.aspx.cs" Inherits="PRCo.BBOS.UI.Web.QA" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin panels_box">
        <asp:Panel CssClass="col-sm-6 col-xs-12" runat="server">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%=Resources.Global.SecuritySettings %></h4>
                </div>
                <div class="row panel-body nomargin pad10">
                    <div class="form-group">
                        <label class="col-sm-12 clr_blu" for="ddlIndustryType"><%=Resources.Global.IndustryType %>:</label>
                        <div class="col-sm-6">
                            <asp:DropDownList CssClass="form-control" ID="ddlIndustryType" runat="server" />
                        </div>
                    </div>

                    <div class="form-group mar_top_10">
                        <label class="col-sm-12 clr_blu" for="ddlAccessLevel"><%=Resources.Global.AccessLevel %>:</label>
                        <div class="col-sm-6">
                            <asp:DropDownList CssClass="form-control col-sm-6" ID="ddlAccessLevel" runat="server" />
                        </div>
                    </div>

                    <div class="clearfix"></div>

                    <div class="form-group">
                        <div class="col-md-6 col-sm-12">
                            <asp:LinkButton runat="server" CssClass="btn gray_btn" OnClick="btnSetAccessOnClick">                  
                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<%=Resources.Global.SetAccessLevel %>
                            </asp:LinkButton>

                            <asp:LinkButton runat="server" CssClass="btn gray_btn" OnClick="btnRestoreAccessOnClick">                  
                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<%=Resources.Global.RestoreAccessLevel%>
                            </asp:LinkButton>

                            <asp:LinkButton runat="server" CssClass="btn gray_btn" OnClick="btnCHWTest" Visible="false">                  
                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;CHW Test
                            </asp:LinkButton>


                            <br /><br />
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlSysAdmin" CssClass="col-sm-6 col-xs-12" runat="server">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="blu_tab"><%=Resources.Global.Impersonation %></h4>
                </div>

                <div class="row panel-body nomargin pad10">
                    <asp:Label ID="litImpersonation" runat="server" Font-Italic="true" />

                    <div class="form-group">
                        <label class="col-sm-12 clr_blu" for="txtHQID"><%=Resources.Global.HQID %>:</label>
                        <div class="col-sm-6">
                            <asp:TextBox ID="txtHQID" runat="server" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="col-sm-12 clr_blu" for="txtEmail">- OR -</label>
                    </div>

                    <div class="form-group">
                        <label class="col-sm-12 clr_blu" for="txtEmail"><%=Resources.Global.Email %>:</label>
                        <div class="col-sm-6">
                            <asp:TextBox ID="txtEmail" runat="server" />
                        </div>
                    </div>

                    <div class="clearfix"></div>

                    <div class="form-group">
                        <div>
                            <div class="col-md-6 col-sm-12">
                                <asp:LinkButton runat="server" CssClass="btn gray_btn" OnClick="btnImpersonateOnClick" ID="btnImpersonate">                  
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<%=Resources.Global.Impersonate %>
                                </asp:LinkButton>

                                <asp:LinkButton runat="server" CssClass="btn gray_btn" OnClick="btnRevertOnClick" ID="btnRevert">                  
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<%=Resources.Global.StopImpersonating %>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
</asp:Content>