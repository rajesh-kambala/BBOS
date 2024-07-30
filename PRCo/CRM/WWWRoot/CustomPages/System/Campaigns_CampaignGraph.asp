<!-- #include file ="..\eware.js" -->
<!-- #include file ="CampaignGraph.js" -->
<LINK REL="stylesheet" HREF="../../../eware.css">

<HTML>

  <BODY>

  <%= eWare.GetTabs() %>

  <BR>


<%

  var Id=eWare.GetContextInfo('Campaigns','Camp_CampaignId');

  if (Id=='') {
     ContentBlock = eWare.GetBlock('content');
     ContentBlock.Contents = '<TABLE CLASS=CONTENT><TR><TD CLASS=VIEWBOX>'+
         eWare.GetTrans('GenCaptions','No Campaign')+'</TD></TR></TABLE>';
     Response.Write(ContentBlock.Execute());
     Response.End;
  }

  s=DrawCampaignGraphs('Camp_CampaignId='+Id);

  Response.Write(s);


  %>

<br>
</BODY>
</HTML>









