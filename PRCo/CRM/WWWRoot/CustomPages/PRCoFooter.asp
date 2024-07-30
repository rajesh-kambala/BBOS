<%
}
catch(exception) {
    Session.Contents("prco_exception") = exception;
    Session.Contents("prco_exception_continueurl") = ErrorContinueUrl;
    Response.Redirect(eWare.Url("PRCoErrorPage.asp"));
    //throw exception;
}
%>