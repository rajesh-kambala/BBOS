<%
  var Userlang=eWare.GetContextInfo('user','User_language');
%>

<% 
  if (Userlang=="JP") {
%>
  <!-- #include file="CampaignRes_strings_jp.inc" -->
<% } else { %>
  <!-- #include file="CampaignRes_strings.inc" -->
<% } %>


<%


function getchart1sql(FilterSql)
{

  if (Userlang=="JP") {

         var chartsql1= "select count(*) as a, "+
         		 " Capt_JP as comm_status "+
	         	 " from vCampaignCommunications , Custom_Captions "+
         		 " where "+
	        	 FilterSql+
		         " and Comm_CommunicationId is not null "+
        		 " and Capt_family = N'comm_status' "+
	        	 " and Capt_Code = comm_status "+
		         " group by Capt_JP order by Capt_JP ";

  }else{

         var chartsql1 = "select count(*) as a, comm_status from vCampaignCommunications"+ 
                         " where "+
          	       	 FilterSql+
                         " and Comm_CommunicationId is not null"+
                         " group by comm_status order by comm_status";


  }

  return(chartsql1);

}

function getchart2sql(FilterSql)
{

  if (Userlang=="JP") {

	var chartsql2 = " select count(*) as a, "+
		" Capt_JP as oppo_stage "+
	 	" from vCampaignOpportunities ,Custom_captions "+
	 	" where "+
	 	FilterSql+
	 	" and Oppo_OpportunityId is not null  "+
 	 	" and Oppo_Stage is not null "+
	 	" and Capt_family = N'oppo_stage' "+
	 	" and Capt_Code = oppo_stage "+
	 	" group by Capt_JP "+
	 	" order by Capt_JP "

 
  }else{

	var chartsql2 = "select count(*) as a, oppo_stage from vCampaignOpportunities"+ 
	       " where "+
               FilterSql+
               " and Oppo_OpportunityId is not null "+
               " and Oppo_Stage is not null"+
	       " group by oppo_stage order by oppo_stage";



  }
  return(chartsql2);

}


function getchart3sql(FilterSql)
{

  if (Userlang=="JP") {

	var chartsql2 = "select count(*) as a, "+
		 " Capt_JP as comm_status "+
		 " from vCampaignCommunications , Custom_Captions "+
		 " where "+
		 FilterSql+
		 " and Comm_CommunicationId is not null "+
		 " and Capt_family = N'comm_status' "+
		 " and Capt_Code = comm_status "+
		 " group by Capt_JP order by Capt_JP ";      

 
  }else{

	var chartsql2 = "select count(*) as a, comm_status from vCampaignCommunications"+ 
               " where "+
	      	 FilterSql+
               " and Comm_CommunicationId is not null"+
	       " group by comm_status order by comm_status";


  }
  return(chartsql2);

}

function getchart4sql(FilterSql)
{

  if (Userlang=="JP") {

	var chartsql2 = " select count(*) as a, "+
		" Capt_JP as oppo_stage "+
	 	" from vCampaignOpportunities ,Custom_captions "+
	 	" where "+
	 	FilterSql+
	 	" and Oppo_OpportunityId is not null  "+
 	 	" and Oppo_Stage is not null "+
	 	" and Capt_family = N'oppo_stage' "+
	 	" and Capt_Code = oppo_stage "+
	 	" group by Capt_JP "+
	 	" order by Capt_JP ";

 
  }else{

	var chartsql2 = "select count(*) as a, oppo_stage from vCampaignOpportunities"+ 
	       " where "+
               FilterSql+
               " and Oppo_OpportunityId is not null "+
               " and Oppo_Stage is not null"+
	       " group by oppo_stage order by oppo_stage";


  }
  return(chartsql2);

}


function getchart5sql(FilterSql)
{

  if (Userlang=="JP") {

	var chartsql2 = "select count(*) as a, Capt_JP from vCampaignCommunicationsResp"+ 
              " where "+
	      	 FilterSql+
               " and Comm_CommunicationId is not null "+
               " and upper(rtrim(Comm_Status))=N'COMPLETE'"+
	       " group by capt_jp order by capt_jp";

 
  }else{

	var chartsql2 = "select count(*) as a, Capt_US from vCampaignCommunicationsResp"+ 
              " where "+
	      	 FilterSql+
               " and Comm_CommunicationId is not null "+
               " and upper(rtrim(Comm_Status))=N'COMPLETE'"+
	       " group by capt_us order by capt_us";


  }
  return(chartsql2);

}





%>