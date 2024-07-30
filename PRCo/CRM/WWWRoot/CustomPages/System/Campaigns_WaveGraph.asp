<!-- #include file ="../eware.js" -->
<!-- #include file ="CampaignGraph.js" -->
<LINK REL="stylesheet" HREF="../../../eware.css">

<HTML>

  <BODY>

  <%= eWare.GetTabs() %>

  <BR>


<%
/* Get context info gets the current context info thats relevant*/

  var Id=eWare.GetContextInfo('Waves','Wave_WaveId');

  if (Id=='') {
     ContentBlock = eWare.GetBlock('content');
     ContentBlock.Contents = '<TABLE CLASS=CONTENT><TR><TD CLASS=VIEWBOX>'+
     	eWare.GetTrans('GenCaptions','No Campaign Wave')+'</TD></TR></TABLE>';
     Response.Write(ContentBlock.Execute());
     Response.End;
  }

  s=DrawCampaignGraphs('Wave_WaveId='+Id);

  Response.Write(s);


  %>

<br>
</BODY>
</HTML>








