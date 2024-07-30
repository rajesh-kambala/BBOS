<!-- #include file ="..\eware.js" -->
<!-- #include file ="CampaignGraph.js" -->
<LINK REL="stylesheet" HREF="../../../eware.css">
 
<HTML>

  <BODY>
 
  <%= eWare.GetTabs() %>
 
  <BR>
  
 
<%
/* Get context info gets the current context info thats relevant*/

  var Id=eWare.GetContextInfo('WaveItems','WaIt_WaveItemId'); 

  s=DrawCampaignGraphs2("WaIt_WaveItemId="+Id);

  Response.Write(s); 

 
  %>

<br> 
</BODY>
</HTML>








