<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">
<xsl:template match="/">
<meta NAME="HandheldFriendly" CONTENT="True"/>
<HTML>
<HEAD>
<TITLE>eWare Page From XML</TITLE>
</HEAD>
<BODY width="30" bgcolor="#FFFFFF" leftmargin="0" topmargin="0">

<FORM  METHOD="POST"  NAME="EntryForm2">
<xsl:attribute name="ACTION"><xsl:value-of select="PAGE/BLOCK/BUTTONS/BUTTON/BUTTONITEM/@href" /></xsl:attribute>
<INPUT type="hidden" ><xsl:attribute name="name"><xsl:value-of select="PAGE/BLOCK/@name" /></xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/@value" /></xsl:attribute>
</INPUT>
<INPUT type="hidden" ><xsl:attribute name="name"><xsl:value-of select="PAGE/CONTAINERBLOCK/@name" /></xsl:attribute>
    <xsl:attribute name="value"><xsl:value-of select="PAGE/CONTAINERBLOCK/@value" /></xsl:attribute>
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
<FORM  METHOD="POST"  NAME="EntryForm" ACTION="#" >
<INPUT type="hidden" ><xsl:attribute name="name"><xsl:value-of select="PAGE/CONTAINERBLOCK/@name" /></xsl:attribute>
     <xsl:attribute name="value"><xsl:value-of select="PAGE/CONTAINERBLOCK/@value" /></xsl:attribute> 
</INPUT>
<INPUT type="hidden" ><xsl:attribute name="name"><xsl:value-of select="PAGE/BLOCK/@name" /></xsl:attribute>
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
<table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#000063">


<xsl:for-each select="PAGE">
<TR><td><font face="Verdana, Arial" size="1">
       <div align="center"><IMG border="0"><xsl:attribute name="SRC"><xsl:value-of select="@logo"/></xsl:attribute></IMG>
  </div></font></td></TR>
</xsl:for-each>

<TR><td>
<xsl:for-each select="PAGE/TABGROUP">
    <xsl:if test="@menu[.='y']">
               <xsl:for-each select="TAB">
               <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute><B><xsl:value-of select="@caption"/></B></A>
          </xsl:for-each>
     </xsl:if>
</xsl:for-each>
</td></TR>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#000063">
<TR>
<xsl:for-each select="PAGE/TABGROUP">
     <xsl:if test="@menu[.='n']">
          <TD width="50%" valign="bottom"><div align="right">
               <xsl:apply-templates select="TAB"/>
          </div> </TD>
     </xsl:if>
</xsl:for-each>
</TR>
<TR>
<TD width="50%"  valign="bottom"><div align="left">
<xsl:for-each select="PAGE/TABGROUP">
     <xsl:if test="@menu[.='y']">
          <xsl:for-each select="TAB">
               <xsl:if test="@class[.='TABON']">
                    <font color="#FFFFFF"><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/> - </font></font>
               </xsl:if>
          </xsl:for-each>
     </xsl:if>
     <xsl:if test="@menu[.='n']">
          <xsl:for-each select="TAB">
               <xsl:if test="@class[.='TABON']">
                    <font color="#FFFFFF"><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></font>
               </xsl:if>
          </xsl:for-each>
     </xsl:if>
</xsl:for-each>
</div>
</TD>
</TR>

<TR>
     <TD><div align="lelft">
          <xsl:for-each select="PAGE/CONTEXT/ENTRYGROUP/ENTRY">
          <B><font color="#FFFFFF"><font face="Verdana, Arial" size="2"><xsl:value-of select="@value"/></font></font></B>
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

<xsl:for-each select="PAGE/CONTAINERBLOCK">
     <xsl:apply-templates select="BUTTONS"/>
</xsl:for-each>

<xsl:for-each select="PAGE">
     <xsl:apply-templates select="CONTAINERBLOCK"/>
</xsl:for-each>

<xsl:for-each select="PAGE/BLOCK">
     <xsl:apply-templates select="BUTTONS"/>
     <xsl:choose>
          <xsl:when test="@errorstring[.='']"></xsl:when>
          <xsl:otherwise> 
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000">
                    <font face="Verdana, Arial" size="1"><B><xsl:value-of select="@errorstring" /></B></font>
               </TABLE>
          </xsl:otherwise>
     </xsl:choose>
</xsl:for-each>

<xsl:for-each select="PAGE/CONTAINERBLOCK">
     <xsl:apply-templates select="BLOCK"/>
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
<TABLE width="100%" cellspacing="0" cellpadding="0">
<xsl:for-each select="BLOCK/ENTRYGROUP">
          <xsl:for-each select="ENTRY">
<TR>
                    <TD><xsl:value-of select="@caption" /></TD>
                    <TD><SELECT>
                      <xsl:attribute name="NAME"><xsl:value-of select="@name" /></xsl:attribute>
                      <xsl:apply-templates select="OPTIONS"/>
                   </SELECT>
                   </TD>
                   <input type="hidden">
                        <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>
                        <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
                   </input>
          </TR>
          </xsl:for-each>
 </xsl:for-each>
<TR><TD>
<xsl:for-each select="FILTERBUTTON">
<INPUT TYPE="button" name ="4" onClick="document.forms[1].submit()">
          <xsl:attribute name="value"><xsl:value-of select="@caption"/></xsl:attribute>
     </INPUT>
</xsl:for-each>
</TD></TR>

</TABLE>
</xsl:template>

<xsl:template match="CALENDARBLOCK">
    <input type="hidden">
       <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
       <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </input>
</xsl:template>

<xsl:template match="CALENDAR">
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" bgcolor="#999999">
     <TD width="50%"><div align="left"><b><font face="Verdana, Arial" size="1" color="#FFFFFF"><xsl:value-of select="@heading"/></font></b></div></TD>
          <TD> <A><xsl:attribute name="HREF"><xsl:value-of select="@todayaction"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@todaycaption"/></font></b></font></A></TD>
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
     </TABLE>
     <xsl:if test="@mode[.='1']">
          <xsl:apply-templates select="APPOINTMENTS"/>
          <xsl:apply-templates select="TASKS"/>
     </xsl:if>
     <xsl:if test="@mode[.='2']">
          <xsl:for-each select="APPOINTMENTS">
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >
                    <TR bgcolor="#999999">
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
               </TABLE>
          </xsl:for-each> <!-- END OF THE APPOINTMENTS FOR WEEK MODE -->
          <xsl:for-each select="TASKS">
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >
                    <TR bgcolor="#999999">
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
               </TABLE>
          </xsl:for-each> <!-- END OF THE TASKS FOR WEEK MODE -->
     </xsl:if>
     <xsl:if test="@mode[.='3']">
          <xsl:for-each select="TASKSANDAPPOINTMENTS">
               <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >
                    <TR bgcolor="#999999">
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
           <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >

           <xsl:for-each select="QUATER">
                <xsl:if test="@white[.='y']">
                     <TR bgcolor="#FFFFFF">           
                          <xsl:for-each select="MONTH">
                               <TD height="20" align="center">
                                    <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute>
                                    <font color="#999999"><font face="Verdana, Arial" size="3"><b><xsl:value-of select="@caption"/></b></font></font>
                                    </A>
                               </TD>
                          </xsl:for-each>
                     </TR>
                </xsl:if>
                <xsl:if test="@white[.='n']">
                     <TR bgcolor="#999999">
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
     <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >
          <TR bgcolor="#999999">
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
     <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >
          <TR bgcolor="#999999">
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
               <TABLE>
                    <TD><xsl:value-of select="@errorstring" /></TD>
               </TABLE>
           </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="BLOCK">
     <xsl:for-each select="ENTRYGROUP">
          <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000">
               <xsl:apply-templates select="ENTRY"/>
          </TABLE>
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
              <TD height="12" width="49%"><font face="Verdana, Arial" size="1"><b><xsl:value-of select="@caption" /></b></font></TD>
               <xsl:choose>
                    <xsl:when test="@image[.='']">
                        <xsl:choose>
                         <xsl:when test="@value[.='']">
                            <TD bgcolor="#CCCCCC" height="12" width="51%">&#160;</TD>
                         </xsl:when>
                          <xsl:otherwise>
                             <TD bgcolor="#CCCCCC" height="12" width="51%"><font face="Verdana, Arial" size="3"><xsl:value-of select="@value"/></font></TD>
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
     <xsl:if test="@inputype[.!='checkbox']">
                <TD height="12" width="49%"><font face="Verdana, Arial" size="1"><b><xsl:value-of select="@caption" /></b></font></TD>
                <TD bgcolor="#CCCCCC" height="12" width="51%"><font face="Verdana, Arial" size="1" >
                     <xsl:choose>
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
                </TD>
                <input type="hidden">
                    <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
                    <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>     
               </input>
</xsl:if>
         </xsl:otherwise>
     </xsl:choose>
     </xsl:when>
     <xsl:otherwise>    <!-- when the mode is view -->
     <xsl:if test="@inputype[.!='checkbox']">

     <TD height="12" width="49%"><font face="Verdana, Arial" size="1"><b><xsl:value-of select="@caption" /></b></font></TD>
     <xsl:choose>
        <xsl:when test="@image[.='']">
         <xsl:choose>
               <xsl:when test="@href[.='']">
                    <xsl:choose>
                         <xsl:when test="@value[.='']">
                              <TD bgcolor="#CCCCCC" height="12" width="51%">&#160;</TD>
                         </xsl:when>
                         <xsl:otherwise>
                              <TD bgcolor="#CCCCCC" height="12" width="51%"><font face="Verdana, Arial" size="1"><xsl:value-of select="@value"/></font></TD>
                         </xsl:otherwise>
                    </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                    <TD bgcolor="#CCCCCC" height="12" width="51%"><font face="Verdana, Arial" size="1"><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@value"/></A></font></TD>
               </xsl:otherwise>
         </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
                  <TD bgcolor="#CCCCCC" height="12" width="51%"><IMG border="0">
                       <xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG>
                  </TD>
        </xsl:otherwise>
    </xsl:choose>
</xsl:if>
   </xsl:otherwise>
</xsl:choose>
</TR>
</xsl:template>

<xsl:template match="CHART">
    <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" bgcolor="#999999">
        <TR><TD width="50%"><div align="left"><b><font face="Verdana, Arial" size="1" color="#FFFFFF">
          <xsl:value-of select="@caption"/></font></b></div></TD></TR></TABLE> 
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" bgcolor="#999999">
         <TR><TD VALIGN="TOP">
             <IMG border="0">
                 <xsl:attribute name="SRC"><xsl:value-of select="@src" /></xsl:attribute>
              </IMG>
          </TD></TR>
     </TABLE>
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" bgcolor="#000063">
         <TR><TD VALIGN="TOP">.
          </TD></TR>
     </TABLE>
</xsl:template>

<xsl:template match="GRID">
     <TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" bgcolor="#999999">
          <TD width="50%"><div align="left"><b><font face="Verdana, Arial" size="1" color="#FFFFFF"><xsl:value-of select="@caption"/></font></b></div></TD>
               <xsl:for-each select="NAV">
                    <xsl:choose>
                         <xsl:when test="@mapame[.='']">
                         </xsl:when>
                         <xsl:otherwise>                    
                              <TD width="50%"><div align="right">
                                        <xsl:for-each select="AREA">
                                            <A >
                                               <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
                                               <IMG align="Right" border="0" ><xsl:attribute name="src"><xsl:value-of select="@image"/></xsl:attribute></IMG>
                                            </A>
                                        </xsl:for-each>
                                     </div>
                               </TD>
                           </xsl:otherwise>
                     </xsl:choose>
               </xsl:for-each>
     </TABLE>
     <TABLE width="100%" border="1" cellspacing="0" cellpadding="0" bordercolor="#000000" >
     <TR bgcolor="#999999">
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
<TABLE width="100%" cellspacing="0" cellpadding="0" bordercolor="#000000" bgcolor="#000063">
  <TR><TD VALIGN="TOP">.
  </TD></TR>
</TABLE>
</xsl:template>

<xsl:template match="TAB">
     <xsl:choose>
          <xsl:when test="@image[.='']">
                 <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></font></A>
          </xsl:when>
          <xsl:otherwise>
                    <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute><IMG border="0" width="19" height="25" hspace="2"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG></A>
          </xsl:otherwise>
     </xsl:choose>          
</xsl:template>

<xsl:template match="HEADER">
  <TD>
     <xsl:choose>
          <xsl:when test="@href[.='']">
               <font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></font>
          </xsl:when>
          <xsl:otherwise>
               <xsl:choose>
                    <xsl:when test="@image[.='']">
                         <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></font></A>
                    </xsl:when>
                    <xsl:otherwise>
                         <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption"/></font></b></font></A>
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
<xsl:choose>
  <xsl:when test="@value[.='']">
  <OPTION value="...---...">
   <xsl:if test="@selected[.='y']"><xsl:attribute name="SELECTED"></xsl:attribute></xsl:if>
   <xsl:value-of select="@display"/>
   </OPTION>
  </xsl:when>
  <xsl:otherwise>
        <OPTION><xsl:attribute name="VALUE"><xsl:value-of select="@value"/></xsl:attribute>
        <xsl:if test="@selected[.='y']"><xsl:attribute name="SELECTED"></xsl:attribute></xsl:if>
        <xsl:value-of select="@display"/>
        </OPTION>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="BUTTONS">
<TABLE width="100%" cellspacing="0" cellpadding="0" bgcolor="#999999" >
           <xsl:apply-templates select="BUTTON"/>
</TABLE>
</xsl:template>

<xsl:template match="BUTTON">
<TD>
     <xsl:apply-templates select="BUTTONITEM" />
</TD>
</xsl:template>

<xsl:template match="BUTTONITEM">
<xsl:if test="@image[.='']">
     <xsl:choose>
          <xsl:when test="@href[.='#']">
               <INPUT TYPE="button" name ="4" onClick="document.forms[0].submit()">
                    <xsl:attribute name="value"><xsl:value-of select="@caption"/></xsl:attribute>
               </INPUT>
          </xsl:when>
          <xsl:when test="@type[.='EDIT']">
               <INPUT TYPE="button" name ="4" onClick="document.forms[0].submit()">
                    <xsl:attribute name="value"><xsl:value-of select="@caption"/></xsl:attribute>
               </INPUT>
          </xsl:when>
          <xsl:when test="@type[.='URL']">
               <A><xsl:attribute name="HREF"><xsl:value-of select="@href" /></xsl:attribute><font color="#FFFFFF"><b><font face="Verdana, Arial" size="1"><xsl:value-of select="@caption" /></font></b></font></A>
          </xsl:when>
          <xsl:otherwise>
               <INPUT TYPE="button" name ="4" onClick="document.forms[1].submit()">
                    <xsl:attribute name="value"><xsl:value-of select="@caption"/></xsl:attribute>
               </INPUT>
          </xsl:otherwise>
     </xsl:choose>
</xsl:if>
</xsl:template>

</xsl:stylesheet>