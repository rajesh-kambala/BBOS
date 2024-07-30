<?xml version='1.0' encoding='utf-8' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<HTML>
<HEAD>
<TITLE>eWare Page From XML</TITLE>
</HEAD>
<META http-equiv="Content-Type" content="text/html; charset=utf-8" />

<BODY width="30" bgcolor="#FFFFFF" leftmargin="0" topmargin="0" link="#6699CC" >

<FORM  METHOD="POST"  NAME="EntryForm2" >
<xsl:attribute name="ACTION"><xsl:value-of select="PAGE/BLOCK/BUTTONS/BUTTON/BUTTONITEM/@href" /></xsl:attribute>

<INPUT type="hidden" >
<xsl:attribute name="name"><xsl:value-of select="PAGE/CONTAINERBLOCK/@name" /></xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PAGE/CONTAINERBLOCK/@value" /></xsl:attribute>
</INPUT>

<INPUT type="hidden" >
<xsl:attribute name="name"><xsl:value-of select="PAGE/BLOCK/@name" /></xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/@value" /></xsl:attribute>
</INPUT>

<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENSCROLLMODE</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/GRID/@hiddenscrollmode" /></xsl:attribute>     
</INPUT>

<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENORDERBY</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/GRID/@hiddenorderby" /></xsl:attribute>
</INPUT>

<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENORDERBYDESC</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/GRID/@hiddenorderbydesc" /></xsl:attribute>
</INPUT>

</FORM>
<FORM  METHOD="POST"  NAME="EntryForm" >
      <xsl:attribute name="ACTION"><xsl:value-of select="PAGE/@fullhref"/></xsl:attribute>

<INPUT type="hidden" >
<xsl:attribute name="name"><xsl:value-of select="PAGE/CONTAINERBLOCK/@name" /></xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PAGE/CONTAINERBLOCK/@value" /></xsl:attribute>
</INPUT>
<INPUT type="hidden" >
<xsl:attribute name="name"><xsl:value-of select="PAGE/BLOCK/@name" /></xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/@value" /></xsl:attribute>
</INPUT>

<xsl:for-each select="PAGE/CONTAINERBLOCK/BLOCK/ENTRYGROUP">
<INPUT type="hidden" >
     <xsl:attribute name="name"><xsl:value-of select="@idField" /></xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="@id" /></xsl:attribute>     
</INPUT>
</xsl:for-each>

<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENSCROLLMODE</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/GRID/@hiddenscrollmode" /></xsl:attribute>     
</INPUT>
<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENORDERBY</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/GRID/@hiddenorderby" /></xsl:attribute>     
</INPUT>
<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENORDERBYDESC</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/GRID/@hiddenorderbydesc" /></xsl:attribute>     
</INPUT>
<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENCALSCROLLMODE</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/CALENDARBLOCK/CALENDAR/@hiddencalscrollmode" /></xsl:attribute>     
</INPUT>
<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENCALENDARMODE</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/CALENDARBLOCK/CALENDAR/@hiddencalendarmode" /></xsl:attribute>     
</INPUT>
<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENCALSCROLLDATE</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/CALENDARBLOCK/CALENDAR/@hiddencalscrolldate" /></xsl:attribute>
</INPUT>
<INPUT type="hidden" >
     <xsl:attribute name="name">HIDDENREPORTMODE</xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/CONTAINERBLOCK/@hiddenreportmode" /></xsl:attribute>     
</INPUT>
<INPUT type="hidden" >
  <xsl:attribute name="name">HIDDENPAGENUMBER</xsl:attribute>
  <xsl:attribute name="value">
    <xsl:value-of select="PAGE/BLOCK/GRID/@hiddenpagenumber"/>
  </xsl:attribute>
</INPUT>

<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#336699">

<xsl:for-each select="PAGE">
  <td valign="middle" height="35">
    <div align="LEFT">
    <font face="Verdana, Arial" size="1">
    <IMG border="0" width="60" height="25"><xsl:attribute name="SRC"><xsl:value-of select="@logo"/></xsl:attribute></IMG>
    </font>
    </div>
</td>
</xsl:for-each>

<TD width="70%" valign="middle" align="right">
	<xsl:for-each select="PAGE/TABGROUP">
	<xsl:if test="@menu[.='y']">
	<xsl:apply-templates select="TAB"/>
	</xsl:if>
	</xsl:for-each>
</TD>
</table>

<xsl:for-each select="PAGE/TABGROUP">
<xsl:if test="@menu[.='y']">
<xsl:choose> 
<xsl:when test="@reportMenu[.='y']">
     <table width="100%" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
     <TD>
     <xsl:for-each select="/PAGE/CONTAINERBLOCK"> 
      		<xsl:apply-templates select="BUTTONS"/>
     </xsl:for-each>

      <xsl:for-each select="/PAGE/BLOCK">
      		<xsl:apply-templates select="BUTTONS"/>
      </xsl:for-each>
      </TD>
</table>

     </xsl:when> 
     <xsl:otherwise>

<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
	<TD height="35" valign="middle" ><div align="left">
 		<xsl:for-each select="/PAGE/TABGROUP">
			<xsl:if test="@menu[.='y']">
             			<xsl:choose>
                			<xsl:when test="@menuselected[.='y']">
                     				<xsl:for-each select="TAB">
                          			<xsl:if test="@class[.='TABON']">
                               			<font ><font face="Verdana, Arial" size="4">&#160;<xsl:value-of select="@caption"/></font></font>
                          			</xsl:if>
                     				</xsl:for-each>
                			</xsl:when>
                			<xsl:otherwise>
                     			<xsl:for-each select="/PAGE/TABGROUP">
                          			<xsl:if test="@menu[.='n']">
                               				<font >&#160;<font face="Verdana, Arial" size="4"><xsl:value-of select="@name"/></font></font>
                          			</xsl:if>
                     			</xsl:for-each>
                			</xsl:otherwise>
		             	</xsl:choose>
      			</xsl:if>     
 		</xsl:for-each> 
		<xsl:for-each select="/PAGE/TABGROUP">
     		<xsl:if test="@menu[.='n']">
			<font ><font face="Verdana, Arial" size="4">&#160;<xsl:value-of select="@caption"/>&#160;</font></font>
                		<SELECT name="MainMenu" onChange="document.location=value;" valign="bottom">
                		<xsl:for-each select="TAB">
                			<OPTION><xsl:attribute name="value"><xsl:value-of select="@url"/></xsl:attribute>
                  			<xsl:if test="@class[.='TABON']">
                        		<xsl:attribute name="SELECTED"></xsl:attribute>
                  			</xsl:if>
                       			<xsl:value-of select="@caption"/>
                  			</OPTION>
            			</xsl:for-each>
           			</SELECT>
     		</xsl:if>
		</xsl:for-each>
	</div></TD>
	<TD>
      		<xsl:for-each select="/PAGE/CONTAINERBLOCK"> 
           		<xsl:apply-templates select="BUTTONS"/>
       		</xsl:for-each>

	        <xsl:for-each select="/PAGE/BLOCK">
        		<xsl:apply-templates select="BUTTONS"/>
      		</xsl:for-each>
	</TD>
</table>


</xsl:otherwise>
</xsl:choose>
</xsl:if>  
</xsl:for-each>




<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
    <!--======================================================================================-->
    <!--====================           TOP CONTENT TO BE DISPLAYED    ========================-->
    <!--======================================================================================-->


<TR><TD width="100%" ><div align="left">
    <xsl:for-each select="PAGE/CONTEXT/ENTRYGROUP/ENTRY"> 
          <B><font><font face="Verdana, Arial" size="3" color="#6699CC">&#160;<xsl:value-of    
            select="@value"/></font></font></B>
    </xsl:for-each>

</div>
</TD> 
</TR>
</table>

<xsl:for-each select="PAGE">
     <xsl:apply-templates select="CALENDARBLOCK"/>
</xsl:for-each>

<xsl:for-each select="PAGE/CALENDARBLOCK">
     <xsl:apply-templates select="CALENDAR"/>
     <xsl:apply-templates select="FILTER"/>
 </xsl:for-each>

<xsl:for-each select="PAGE">
     <xsl:apply-templates select="CONTAINERBLOCK"/>
</xsl:for-each>

<xsl:for-each select="PAGE/BLOCK">
    <xsl:choose>
<xsl:when test="@errorstring[.='']"></xsl:when>
          <xsl:otherwise>
         <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="red">
              <TD><font face="Verdana, Arial" size="2"><B><xsl:value-of select="@errorstring" /></B></font></TD>
         </TABLE>
       </xsl:otherwise>
    </xsl:choose>
 <xsl:value-of select="ASP" disable-output-escaping="yes"/>

</xsl:for-each>

<xsl:for-each select="PAGE/CONTAINERBLOCK">
   <xsl:for-each select="BLOCK">
       <xsl:value-of select="ASP" disable-output-escaping="yes"/>
   </xsl:for-each>
   <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699">
       <xsl:for-each select="BLOCK">
          <xsl:for-each select="ENTRYGROUP">
               <xsl:apply-templates select="ENTRY"/>
          </xsl:for-each>
        </xsl:for-each>
     <xsl:apply-templates select="CHART"/>
     <xsl:apply-templates select="GRID"/>
   </TABLE>

</xsl:for-each>

<xsl:for-each select="PAGE">
    <xsl:apply-templates select="BLOCK"/>
</xsl:for-each>

<xsl:for-each select="PAGE/BLOCK">
     <xsl:apply-templates select="FILTER"/>
 </xsl:for-each>
     
</FORM>

</BODY>
</HTML>

</xsl:template>

<xsl:template match="FILTER">
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="CCCCCC" >
<xsl:for-each select="BLOCK/ENTRYGROUP">
     <TR>
          <xsl:for-each select="ENTRY">
               <TD valign="bottom" align="left"><div align="left">
                    <font face="Verdana, Arial" size="1" color="#6699CC"><b><xsl:value-of select="@caption" /></b></font></div>
               </TD>
               <TD valign="bottom" align="left"><div align="left">
                    <SELECT>
                            <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>    
                            <xsl:apply-templates select="OPTIONS"/>
                    </SELECT>
               </div>
               </TD>
          </xsl:for-each>
     </TR>
 </xsl:for-each>
<TR><TD>
<xsl:for-each select="FILTERBUTTON">
<A><xsl:attribute name="href"><xsl:value-of select="@ahref" /></xsl:attribute><IMG border="0" width="20" height="20" ><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG></A>
</xsl:for-each>
</TD></TR>
</TABLE>

<xsl:for-each select="BLOCK/ENTRYGROUP">
    <xsl:for-each select="ENTRY">
    <input type="hidden">
         <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </input>
    </xsl:for-each>
</xsl:for-each>

</xsl:template>

<xsl:template match="CALENDARBLOCK">
    <input type="hidden">
       <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
       <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </input>
</xsl:template>

<xsl:template match="CALENDAR">
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#336699" bgcolor="#CCCCCC">

     <TD width="85" align="left"><div align="left"><b>
     <font face="Verdana, Arial" size="1" color="#6699CC"><xsl:value-of select="@heading"/></font></b></div></TD>
<!--          <TD align="right"> <A><xsl:attribute name="HREF"><xsl:value-of select="@todayaction"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@todaycaption"/></font></b></font></A></TD>  -->
          <xsl:for-each select="NAVBAR">
               <TD><A><xsl:attribute name="HREF"><xsl:value-of select="@prevhref"/></xsl:attribute><IMG border="0" width="20" height="20" ><xsl:attribute name="SRC"><xsl:value-of select="@previmage" /></xsl:attribute></IMG></A></TD>
                   <TD valign="bottom">
                        <xsl:for-each select="SELECTCALENDARMODE">
                        <SELECT valign="bottom"><xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute><xsl:attribute name="OnChange"><xsl:value-of select="@onchange"/></xsl:attribute>
                             <xsl:for-each select="OPTIONS/OPTION">
                                  <OPTION><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
                                       <xsl:if test="@selected[.='y']">
                                            <xsl:attribute name="SELECTED"></xsl:attribute>
                                       </xsl:if>
                                       <xsl:value-of select="@display"/>
                                  </OPTION>
                             </xsl:for-each>
                           </SELECT>
                        </xsl:for-each>
                   </TD>
                  <TD><A><xsl:attribute name="HREF"><xsl:value-of select="@nexthref"/></xsl:attribute><IMG border="0" width="20" height="20" ><xsl:attribute name="SRC"><xsl:value-of select="@nextimage" /></xsl:attribute></IMG></A></TD>
          </xsl:for-each>
          <TD align="right"> <A><xsl:attribute name="HREF"><xsl:value-of select="@todayaction"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@todaycaption"/></font></b></font></A></TD>
     </TABLE>
     <xsl:if test="@mode[.='1']">
          <xsl:apply-templates select="APPOINTMENTS"/>
          <xsl:apply-templates select="TASKS"/>
     </xsl:if>
     <xsl:if test="@mode[.='2']">
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699" >
          <xsl:for-each select="APPOINTMENTS">
                    <TR bgcolor="#003D72">
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading1"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading2"/></font></b></font></TD>          
                    </TR>
                    <xsl:for-each select="TIMESLOT">
                         <TR bgcolor="#FFFFFF">
                              <TD> <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@date"/></font></A></TD>
                                   <xsl:if test="@hascomm[.='y']">
                                        <xsl:if test="@now[.='y']">
                                             <TD bgcolor="#CCCCCC"><font face="Verdana, Arial" size="1">
                                                  <xsl:for-each select="APPOINTMENT">
                                                       <xsl:apply-templates select="ICON"/>
                                                       <xsl:for-each select="DETAILS">
                                                            <xsl:value-of select="@timevalue" />
                                                       </xsl:for-each>
                                                  </xsl:for-each>
                                             </font></TD>
                                        </xsl:if>
                                        <xsl:if test="@now[.='n']">
                                             <TD><font face="Verdana, Arial" size="1">
                                                  <xsl:for-each select="APPOINTMENT">
                                                       <xsl:apply-templates select="ICON"/>
                                                       <xsl:for-each select="DETAILS">
                                                            <xsl:value-of select="@timevalue" />
                                                       </xsl:for-each>
                                                  </xsl:for-each>
                                             </font></TD>
                                        </xsl:if>
                                   </xsl:if>
                                   <xsl:if test="@hascomm[.='n']">
                                        <TD>&#160;</TD>
                                   </xsl:if>
                         </TR>
                    </xsl:for-each>

          </xsl:for-each> <!-- END OF THE APPOINTMENTS FOR WEEK MODE -->
          <xsl:for-each select="TASKS">

                    <TR bgcolor="#003D72">
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading1"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading2"/></font></b></font></TD>          
                    </TR>
                    <xsl:for-each select="TIMESLOT">
                         <TR bgcolor="#FFFFFF">
                              <TD> <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@date"/></font></A></TD>
                                   <xsl:if test="@hascomm[.='y']">
                                        <xsl:if test="@now[.='y']">
                                             <TD bgcolor="#CCCCCC"><font face="Verdana, Arial" size="1">
                                                  <xsl:for-each select="TASK">
                                                       <xsl:apply-templates select="ICON"/>
                                                       <xsl:for-each select="DETAILS">
                                                           <xsl:value-of select="@timevalue" />
                                                      </xsl:for-each>
                                                  </xsl:for-each>
                                             </font></TD>
                                        </xsl:if>
                                        <xsl:if test="@now[.='n']">
                                             <TD><font face="Verdana, Arial" size="1">
                                                  <xsl:for-each select="TASK">
                                                       <xsl:apply-templates select="ICON"/>
                                                       <xsl:for-each select="DETAILS">
                                                           <xsl:value-of select="@timevalue" />
                                                      </xsl:for-each>
                                                  </xsl:for-each>
                                             </font></TD>
                                        </xsl:if>
                                   </xsl:if>
                                   <xsl:if test="@hascomm[.='n']">
                                        <TD>&#160;</TD>
                                   </xsl:if>
                         </TR>
                    </xsl:for-each>

          </xsl:for-each> <!-- END OF THE TASKS FOR WEEK MODE -->
               </TABLE>
     </xsl:if>
     <xsl:if test="@mode[.='3']">
          <xsl:for-each select="TASKSANDAPPOINTMENTS"> <!-- Shows day headings in monthly view-->
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699" >
                    <TR bgcolor="#003D72">
                    <TD>&#160;</TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading1"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading2"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading3"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading4"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading5"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading6"/></font></b></font></TD>
                         <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading7"/></font></b></font></TD>
                    </TR>
                    <xsl:for-each select="TIMESLOT">
                         <TR bgcolor="#FFFFFF">
                              <TD> <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></A></TD>
                                   <xsl:if test="@indent[.>0]">
                                          <xsl:apply-templates select="BLANK"/>
                                   </xsl:if>
                              <xsl:apply-templates select="DAY"/>
                         </TR>
                    </xsl:for-each>
               </TABLE>
          </xsl:for-each> <!-- END OF THE MONTH MODE -->
         </xsl:if>
         <xsl:if test="@mode[.='4']">
          <xsl:for-each select="TASKSANDAPPOINTMENTS">
           <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699" >

           <xsl:for-each select="QUATER">
                <xsl:if test="@white[.='y']">
                     <TR bgcolor="#FFFFFF">           
                          <xsl:for-each select="MONTH">
                               <TD height="20" align="center">
                                    <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute>
                                    <font color="#FFFFFF" ><font face="Verdana, Arial" size="3"><b><xsl:value-of select="@caption"/></b></font></font>
                                    </A>
                               </TD>
                          </xsl:for-each>
                     </TR>
                </xsl:if>
                <xsl:if test="@white[.='n']">
                     <TR bgcolor="#003D72">
                          <xsl:for-each select="MONTH">                     
                               <TD width="100%" height="20" align="center">
                                     <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute>
                                     <font color="#FFFFFF"><font face="Verdana, Arial" size="3"><b><xsl:value-of select="@caption"/></b></font></font>
                                     </A>
                                </TD>
                          </xsl:for-each>
                     </TR>
                </xsl:if>
           </xsl:for-each>
           </TABLE> 
          </xsl:for-each> <!-- END OF THE YEAR MODE -->
         </xsl:if>
</xsl:template>

<xsl:template match="DAY">
     <xsl:if test="@now[.='y']">
          <TD VALIGN="TOP" bgcolor="#CCCCCC"><font face="Verdana, Arial" size="1">
               <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></A>
               <BR/>
               <xsl:if test="@hascomm[.='y']">
                    <xsl:for-each select="APPSANDTASKS">
                         <xsl:apply-templates select="ICON"/>
                    </xsl:for-each>
               </xsl:if>
           </font></TD>
      </xsl:if>
      <xsl:if test="@now[.='n']">
           <TD VALIGN="TOP" ><font face="Verdana, Arial" size="1">
                <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></A>
                <BR/>
               <xsl:if test="@hascomm[.='y']">
                    <xsl:for-each select="APPSANDTASKS">
                         <xsl:apply-templates select="ICON"/>
                    </xsl:for-each>
               </xsl:if>
           </font></TD>
       </xsl:if>
</xsl:template>

<xsl:template match="BLANK">
<TD>&#160;</TD>
</xsl:template>

<xsl:template match="APPOINTMENTS">
     <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699" >
          <TR bgcolor="#003D72">
               <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading1"/></font></b></font></TD>
               <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading2"/></font></b></font></TD>
          </TR>
          <xsl:for-each select="TIMESLOT">
               <xsl:if test="@now[.='y']">
                    <TR bgcolor="#CCCCCC">
                         <TD><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@time"/></font></A></TD>
                         <xsl:if test="@hasapps[.='y']">
                              <TD><xsl:apply-templates select="APPOINTMENT"/></TD>
                         </xsl:if>
                         <xsl:if test="@hasapps[.='n']">
                              <TD>&#160;</TD>
                         </xsl:if>
                    </TR>
               </xsl:if>
               <xsl:if test="@now[.='n']">
                    <TR bgcolor="#FFFFFF">
                         <TD><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@time"/></font></A></TD>
                         <xsl:if test="@hasapps[.='y']">
                              <TD><xsl:apply-templates select="APPOINTMENT"/></TD>
                         </xsl:if>
                         <xsl:if test="@hasapps[.='n']">
                              <TD>&#160;</TD>
                         </xsl:if>
                     </TR>
               </xsl:if>
          </xsl:for-each>
     </TABLE>
</xsl:template>

<xsl:template match="APPOINTMENT">
     <xsl:apply-templates select="ICON"/>
     <xsl:apply-templates select="DETAILS"/>
     <BR/>
</xsl:template>

<xsl:template match="TASKS">
     <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699" >
          <TR bgcolor="#003D72">
               <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading1"/></font></b></font></TD>
               <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading2"/></font></b></font></TD>
               <TD><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@heading3"/></font></b></font></TD>
          </TR>
          <TR bgcolor="#FFFFFF">
               <TD></TD>
                    <TD><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></A></TD>
               <TD></TD>
          </TR>
          <xsl:apply-templates select="TASK"/>
     </TABLE>
</xsl:template>

<xsl:template match="TASK">
     <xsl:if test="@now[.='y']">
          <TR bgcolor="#CCCCCC"><font face="Verdana, Arial" size="1">
               <TD><xsl:apply-templates select="ICON"/></TD>
               <TD><font face="Verdana, Arial" size="1"><xsl:apply-templates select="DETAILS"/></font></TD>
               <TD><xsl:apply-templates select="STATUS"/></TD>
          </font></TR>
     </xsl:if>
     <xsl:if test="@now[.='n']">
          <TR><font face="Verdana, Arial" size="1">
               <TD><xsl:apply-templates select="ICON"/></TD>
               <TD><font face="Verdana, Arial" size="1"><xsl:apply-templates select="DETAILS"/></font></TD>
               <TD><xsl:apply-templates select="STATUS"/></TD>
          </font></TR>
     </xsl:if>
</xsl:template>

<xsl:template match="DETAILS">
     <xsl:value-of select="@timecaption" />
     <xsl:value-of select="@timevalue" />
     <BR/>
     <xsl:value-of select="@usercaption" />
     <xsl:value-of select="@uservalue" />
     <BR/>
     <xsl:value-of select="@notecaption" />
     <xsl:value-of select="@notevalue" />
</xsl:template>

<xsl:template match="ICON">
     <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><IMG border="0"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG></A>
</xsl:template>

<xsl:template match="STATUS">
     <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><IMG border="0"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG></A>
</xsl:template>

<xsl:template match="CONTAINERBLOCK">
    <input type="hidden">
       <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
       <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>     
    </input>
    <xsl:choose>
         <xsl:when test="@errorstring[.='']"></xsl:when>
         <xsl:otherwise>
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="red" bordercolor="#336699">
<!--                  <TD><font face="Verdana, Arial" size="2"><B>&#160;<xsl:value-of select="@errorstring" /></B></font></TD> -->
                  <TD><xsl:value-of select="@name"/><xsl:value-of select="@value"/><font face="Verdana, Arial" size="2"><B><xsl:value-of select="@errorstring" /></B></font></TD>
               </TABLE>
         </xsl:otherwise>
    </xsl:choose>

</xsl:template>

<xsl:template match="BLOCK">
     <xsl:for-each select="ENTRYGROUP">
          <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699">
               <xsl:apply-templates select="ENTRY"/>
          </TABLE>
     </xsl:for-each>

     <!-- add the hidden input types outside the table or it messes with the borders -->
     <xsl:for-each select="ENTRYGROUP">
          <xsl:for-each select="ENTRY">
	<xsl:choose>
               <xsl:when test="@mode[.='edit']">
                    <input type="hidden">
                    <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
                    <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>     
                    </input>
               </xsl:when>
        </xsl:choose>
     </xsl:for-each>
     </xsl:for-each>

     <xsl:apply-templates select="CHART"/>
     <xsl:apply-templates select="GRID"/>
</xsl:template>

<xsl:template match="ENTRY">
<TR>
<xsl:choose>                         
     <xsl:when test="@mode[.='edit']">
          <xsl:choose>
          <xsl:when test="@readonly[.='Y']">
              <TD height="12" width="49%" nowrap="TRUE" ><font face="Verdana, Arial" size="1" color="#6699CC">&#160;<b><xsl:value-of select="@caption" /></b></font></TD>
               <xsl:choose>
                    <xsl:when test="@image[.='']">
                        <xsl:choose>
                         <xsl:when test="@value[.='']">
                            <TD bgcolor="#FFFFFF" height="12" width="51%">&#160;</TD>
                         </xsl:when>
                          <xsl:otherwise>
                             <TD bgcolor="#FFFFFF" height="12" width="51%" nowrap="TRUE"><font face="Verdana, Arial" size="3">&#160;<xsl:value-of select="@value"/></font></TD>
                         </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>                     
                    <xsl:otherwise>
                       <IMG border="0"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG>
                     </xsl:otherwise>
               </xsl:choose>
                    <input type="hidden">
                        <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>
                             <xsl:choose>
                                  <xsl:when test="@inputype[.='select']">
                                       <xsl:attribute name="value"><xsl:value-of select="@hiddenvalue"/></xsl:attribute>
                                  </xsl:when>
                                  <xsl:otherwise>
                                       <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
                                  </xsl:otherwise>
                             </xsl:choose>
                    </input>
          </xsl:when>
          <xsl:otherwise>
              <TD height="12" width="49%" nowrap="TRUE" ><font face="Verdana, Arial" size="1" color="#6699CC"><b>&#160;<xsl:value-of select="@caption" /></b></font></TD>
        	<TD width="51%" valign="bottom" align="left"><div align="left">
                <font face="Verdana, Arial" size="1" >
                     <xsl:choose>
                     <xsl:when test="@inputype[.='checkbox']">
                          <xsl:choose>
                          <xsl:when test="@value[.='']">
                               <input size="15">
                                    <xsl:attribute name="type"><xsl:value-of select="@inputype" /></xsl:attribute> 
                                    <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>
                               </input>
                          </xsl:when>
                          <xsl:otherwise>
                               <input size="15">
                                    <xsl:attribute name="type"><xsl:value-of select="@inputype" /></xsl:attribute>
                                    <xsl:attribute name="checked"/>
                                    <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>
                               </input>
                          </xsl:otherwise>
                          </xsl:choose>
                     </xsl:when>

                     <xsl:when test="@inputype[.='text']">
                          <input size="15">
                               <xsl:attribute name="type"><xsl:value-of select="@inputype" /></xsl:attribute>    
                               <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>       
                               <xsl:attribute name="value"><xsl:value-of select="@value" /></xsl:attribute>     
                          </input>
                     </xsl:when>
                     <xsl:when test="@inputype[.='select']">
                          <SELECT>
                               <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>    
                               <xsl:apply-templates select="OPTIONS"/>
                          </SELECT>
                     </xsl:when>
                     <xsl:otherwise>
                          <xsl:value-of select="@caption" /><xsl:value-of select="@value"/>
                     </xsl:otherwise>
                  </xsl:choose>
                <xsl:choose>
                <xsl:when test="@required[.='n']"></xsl:when>
                 <xsl:otherwise>
                     <img border="0" ><xsl:attribute name="src"><xsl:value-of select="@required"/></xsl:attribute></img>
                 </xsl:otherwise>
                 </xsl:choose>
                </font>
                        	</div></TD>
         </xsl:otherwise>
     </xsl:choose>
     </xsl:when>
     <xsl:otherwise>    <!-- when the mode is view -->
     <TD height="12" width="49%" nowrap="TRUE" ><font face="Verdana, Arial" size="1" color="#6699CC"><b>&#160;<xsl:value-of select="@caption" /></b></font></TD>
     <xsl:choose>
        <xsl:when test="@image[.='']">
         <xsl:choose>
               <xsl:when test="@href[.='']">
                    <xsl:choose>
                         <xsl:when test="@value[.='']">
                              <TD bgcolor="#FFFFFF" height="12" width="51%">&#160;</TD>
                         </xsl:when>
                         <xsl:otherwise>
                              <TD bgcolor="#FFFFFF" height="12" width="51%"><font face="Verdana, Arial" size="1">&#160;<xsl:value-of select="@value"/></font></TD>
                         </xsl:otherwise>
                    </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                    <TD bgcolor="#FFFFFF" height="12" width="51%"><font face="Verdana, Arial" size="1"><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@value"/></A></font></TD>
               </xsl:otherwise>
         </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
                  <TD bgcolor="#FFFFFF" height="12" width="51%"><IMG border="0">
                       <xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG>
                  </TD>
        </xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
</xsl:choose>
</TR>
</xsl:template>

<xsl:template match="CHART">
    <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#336699" bgcolor="#CCCCCC">
        <TR><TD width="100%"><div align="left"><b><font face="Verdana, Arial" size="1">
          <xsl:value-of select="@caption"/></font></b></div></TD></TR></TABLE> 
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" bgcolor="#CCCCCC">
         <TR><TD VALIGN="TOP">
             <IMG border="0">
                 <xsl:attribute name="SRC"><xsl:value-of select="@src" /></xsl:attribute>
              </IMG>
          </TD></TR>
     </TABLE>
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" bgcolor="#CCCCCC">
         <TR><TD VALIGN="TOP">.
          </TD></TR>
     </TABLE>
</xsl:template>

<xsl:template match="GRID">
  <TABLE width="100%" cellspacing="0" cellpadding="0" bgcolor="#003D72">  <!-- #336699">  -->
  <TR>
    <TD width="76%">
      <DIV align="left">
        <FONT face="Verdana, Arial" size="2" color="#6699CC" >&#160;
          <xsl:value-of select="@caption"/>
        </FONT>
      </DIV>
    </TD>
    <xsl:for-each select="NAV">
      <xsl:choose>
        <xsl:when test="@PageNumber[.='']">
        <TD width="24%"></TD>
        </xsl:when>
        <xsl:otherwise>                    
          <TD width="24%">
            <DIV align="right">
              <FONT FACE="Verdana, Arial" SIZE="2" COLOR="#6699CC">
                <xsl:value-of select="@PageCaption"/>&#160;
              </FONT>
              <INPUT TYPE="TEXT" ID="EnterPageNumber" NAME="EnterPageNumber" MAXLENGTH="5" SIZE="5">
                <xsl:attribute name="VALUE"><xsl:value-of select="@PageNumber"/></xsl:attribute>
              </INPUT>&#160;
              <A>
                <xsl:attribute name="HREF"><xsl:value-of select="@PageScript"/></xsl:attribute>
                <IMG SRC="@SRC" BORDER="0" ALIGN="MIDDLE">
                  <xsl:attribute name="SRC"><xsl:value-of select="@PageButton"/></xsl:attribute>
                </IMG>
              </A>&#160;
              <xsl:for-each select="AREA">
                <A>
                  <xsl:attribute name="href">
                    <xsl:value-of select="@href"/>
                  </xsl:attribute>
                  <IMG border="0">
                    <xsl:attribute name="src">
                      <xsl:value-of select="@image"/>
                    </xsl:attribute>
                  </IMG>
                </A>
              </xsl:for-each>
            </DIV>
          </TD>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </TR>
  </TABLE>
  <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#336699">
    <TR bgcolor="#003D72">
      <xsl:for-each select="HEADERS">
        <xsl:apply-templates select="HEADER"/>
      </xsl:for-each>
    </TR>     
    <xsl:for-each select="ROWS/ROW">
      <xsl:if test="@rownumber[.='1']">
        <TR bgcolor="#FFFFFF">
          <xsl:apply-templates select="CELL"/>
        </TR>
      </xsl:if>
      <xsl:if test="@rownumber[.='0']">
        <TR bgcolor="#CCCCCC">
          <xsl:apply-templates select="CELL"/>
        </TR>
      </xsl:if>
    </xsl:for-each>
  </TABLE>
</xsl:template>

<xsl:template match="TAB">
     <xsl:choose>
          <xsl:when test="@image[.='']">
                 <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></font></A>
          </xsl:when>
          <xsl:otherwise>
                    <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute><IMG border="0" width="20" height="20" hspace="2"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG></A>
          </xsl:otherwise>
     </xsl:choose>          
</xsl:template>

<xsl:template match="HEADER">
  <TD>
     <xsl:choose>
          <xsl:when test="@href[.='']">
               <b><font color="#FFFFFF" face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b>
          </xsl:when>
          <xsl:otherwise>
               <xsl:choose>
                    <xsl:when test="@image[.='']">
                         <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></font></A>
                    </xsl:when>
                    <xsl:otherwise>
                         <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><b><font color="#FFFFFF" face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></A>
                         <IMG border="0" width="10" height="10" ><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG>
                    </xsl:otherwise>
               </xsl:choose>
          </xsl:otherwise>
     </xsl:choose>
  </TD>
</xsl:template>

<xsl:template match="CELL">
     <xsl:choose>
          <xsl:when test="@href[.='']">
               <xsl:choose>
                    <xsl:when test="@caption[.='']">
                       <TD>&#160;</TD>
                    </xsl:when>
                    <xsl:otherwise>
                         <TD><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption" /></font></TD>
                    </xsl:otherwise>
               </xsl:choose>
          </xsl:when>
          <xsl:when test="@image[.='']">
               <xsl:choose>
                    <xsl:when test="@caption[.='']">
                       <TD>&#160;</TD>
                    </xsl:when>
                    <xsl:otherwise>
                         <TD><font face="Verdana, Arial" size="1"><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@caption"/></A></font></TD>
                    </xsl:otherwise>
               </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
               <TD><font face="Verdana, Arial" size="1"><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><IMG border="0" width="20" height="20"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG></A></font></TD>
          </xsl:otherwise>
     </xsl:choose>
</xsl:template>

<xsl:template match="OPTIONS">     
          <xsl:apply-templates select="OPTION"/>
</xsl:template>

<xsl:template match="OPTION">
  <OPTION ><xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    <xsl:if test="@selected[.='y']"><xsl:attribute name="SELECTED"></xsl:attribute></xsl:if>
    <xsl:value-of select="@display"/></OPTION></xsl:template>

<xsl:template match="BUTTONS">
      <xsl:apply-templates select="BUTTON"/>
</xsl:template>

<xsl:template match="BUTTON">
     <xsl:apply-templates select="BUTTONITEM" />
</xsl:template>

<xsl:template match="BUTTONITEM">
   <xsl:choose>
   <xsl:when test="@image[.='']">
   </xsl:when>
   <xsl:otherwise>
<TD align="right" valign="middle">
         <xsl:choose>
            <xsl:when test="@href[.='#']">
               <A HREF="javascript:document.forms[0].submit();" ><IMG border="0" width="25" height="25" ><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG></A>
            </xsl:when>
            <xsl:when test="@type[.='EDIT']">
               <A HREF="javascript:document.forms[0].submit();" ><IMG border="0" width="25" height="25" ><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG></A>
            </xsl:when>
            <xsl:when test="@type[.='URL']">
               <A><xsl:attribute name="HREF"><xsl:value-of select="@href" /></xsl:attribute><IMG border="0" width="25" height="25" ><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG></A>
            </xsl:when>
            <xsl:otherwise>
               <A href="javascript:document.forms[1].submit()" ><IMG border="0" width="20" height="20" ><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG></A>
            </xsl:otherwise>
          </xsl:choose>
</TD>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>