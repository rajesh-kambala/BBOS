

<!-- #include file ="LangRes_Campaign.inc" -->

<%

function DrawCampaignGraphs(FilterSql)
{
  var chart1;
  chart1=eWare.GetBlock('chart');
  
  
    with(chart1)
    {
       Stylename('Bar');
       newline=false;
       Title='Communications';
       Description='Campaign Analysis';
       ApplyBarStyle('RectGradient');
       Differentcolors=true;
       Resize(400,400);
       showlegend(true);
       movelegend('top');
       showmarks(true);
       make3d('40');
       labelx=CommunicationStatusTitle;
       labely=QuantityTitle;
       backimage('5'); 
       xlprop="comm_status";
       yprop="a"; 
       SQLText=getchart1sql(FilterSql);

   }	 	

  var chart2;
  chart2=eWare.GetBlock('chart');
  
  
    with(chart2)
    {
       Stylename('Bar');
       newline=false;
       Title='Opportunities';
       Description='Opportunities status';
       ApplyBarStyle('RectGradient');
       Differentcolors=true;
       Resize(400,400);
       showlegend(true);
       movelegend('top');
       showmarks(true);
       make3d('40');
       labelx=OpportunityStatusTitle;
       labely=QuantityTitle;
       backimage('5'); 
       xlprop="oppo_stage";
       yprop="a"; 
       SQLText=getchart2sql(FilterSql)
    }	 	
  
  var container; 
  container=eWare.GetBlock('container');
  with (container)
  {
    addblock(chart1);  
    addblock(chart2);
    displaybutton(Button_Default)=false;
  }

  return container.execute();
 }

function DrawCampaignGraphs2(FilterSql)
{
  var chart1;
  chart1=eWare.GetBlock('chart');
  
  
    with(chart1)
    {
       Stylename('Bar');
       newline=false;
       Title='Communications';
       Description='Campaign Analysis';
       ApplyBarStyle('RectGradient');
       Differentcolors=true;
       Resize(400,400);
       showlegend(true);
       movelegend('top');
       showmarks(true);
       make3d('40');
       labelx=CommunicationStatusTitle;
       labely=QuantityTitle;
       backimage('5'); 
       xlprop="comm_status";
       yprop="a"; 
       SQLText=getchart3sql(FilterSql);
    }	 	

  var chart2;
  chart2=eWare.GetBlock('chart');
  
  
    with(chart2)
    {
       Stylename('Bar');
       newline=false;
       Title='Opportunities';
       Description='Opportunities status';
       ApplyBarStyle('RectGradient');
       Differentcolors=true;
       Resize(400,400);
       showlegend(true);
       movelegend('top');
       showmarks(true);
       make3d('40');
       labelx=OpportunityStatusTitle;
       labely=QuantityTitle;
       backimage('5'); 
       xlprop="oppo_stage";
       yprop="a"; 
       SQLText=getchart4sql(FilterSql);
    }	 	

  chart3 = eWare.GetBlock('chart');
  with(chart3)
    {
       Stylename('Bar');
       newline=false;
       Title='Wave Activity Response So Far';
       Description='Campaign Analysis';
       ApplyBarStyle('RectGradient');
       Differentcolors=true;
       Resize(400,400);
       showlegend(true);
       movelegend('top');
       showmarks(true);
       make3d('40');
       labelx=ResponsesToCompletedCommunications;
       labely=QuantityTitle;
       backimage('5'); 
       xlprop="cmli_comm_waveresponse";
       xlprop="Capt_US";
       yprop="a"; 
       SQLText=getchart5sql(FilterSql);    }	 	

  
  var container; 
  container=eWare.GetBlock('container');
  with (container)
  {
    addblock(chart1);  
    addblock(chart3);

    chart2.NewLine = true;
    addblock(chart2);
    displaybutton(Button_Default)=false;
  }

  return container.execute();
 }

%>


