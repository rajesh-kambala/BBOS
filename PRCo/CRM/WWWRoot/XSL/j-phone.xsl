<?xml version='1.0' encoding='utf-8' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <HTML>
  <BODY width="30" leftmargin="5" topmargin="5">
    <FORM  METHOD="POST"  NAME="EntryForm">
    	<xsl:attribute name="ACTION">
    	    <xsl:value-of select="PAGE/@href"/>
    	</xsl:attribute>

	<INPUT type="hidden" >
	<xsl:attribute name="type"><xsl:value-of select="PAGE/CONTAINERBLOCK/@inputtype" /></xsl:attribute>
	<xsl:attribute name="name"><xsl:value-of select="PAGE/CONTAINERBLOCK/@name" /></xsl:attribute>
      	<xsl:attribute name="value"><xsl:value-of select="PAGE/CONTAINERBLOCK/@value" /></xsl:attribute>
	</INPUT>
	<INPUT type="hidden" >
	<xsl:attribute name="type"><xsl:value-of select="PAGE/BLOCK/@inputtype" /></xsl:attribute>
	<xsl:attribute name="name"><xsl:value-of select="PAGE/BLOCK/@name" /></xsl:attribute>
      	<xsl:attribute name="value"><xsl:value-of select="PAGE/BLOCK/@value" /></xsl:attribute>     
	</INPUT>
	
      <!-- QUERYSTRING ARGUMENTS AS HIDDEN FIELDS for GET FORMS -->
      <xsl:for-each select="PAGE/HIDDENQUERY">
           <xsl:for-each select="QUERYFIELD">
                <INPUT type="hidden" >
                     <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>
                     <xsl:attribute name="value"><xsl:value-of select="@value" /></xsl:attribute>
                </INPUT>
           </xsl:for-each>
      </xsl:for-each>


      <xsl:for-each select="PAGE/CONTAINERBLOCK/BLOCK/ENTRYGROUP">
        <INPUT type="hidden" >
          <xsl:attribute name="name"><xsl:value-of select="@idField" /></xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="@id" /></xsl:attribute>     
        </INPUT>
      </xsl:for-each>
      
      <!--xsl:for-each select="PAGE">
          <IMG border="0" width="60" height="25" align="left">
          <xsl:attribute name="SRC"><xsl:value-of select="@logo"/></xsl:attribute></IMG>
          <br/><br/>
      </xsl:for-each-->
      
      <!-- DO THE MAIN MENU DROP DOWN -->
      <div align="center">|<xsl:for-each select="PAGE/TABGROUP">
         <xsl:if test="@menu[.='y']">
            <xsl:for-each select="TAB">
            <xsl:if test="@class[.='TABOFF']">
               <xsl:if test="@caption[.!='']">
                       <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute>
                       <xsl:value-of select="@caption"/></A>|</xsl:if>
            </xsl:if>
            </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
      <br/>
      
      <!-- DO THE CURRENTLY SELECTED OPTION CAPTION BELOW IT -->
      <xsl:for-each select="PAGE/TABGROUP">
           <xsl:if test="@menu[.='y']">
              <xsl:for-each select="TAB">
                 <xsl:if test="@class[.='TABON']"><b><xsl:value-of select="@caption"/></b>  </xsl:if>
              </xsl:for-each>
           </xsl:if>
           <xsl:if test="@menu[.='n']">
              <xsl:for-each select="TAB">
                 <xsl:if test="@class[.='TABON']"><xsl:value-of select="@caption"/></xsl:if>
              </xsl:for-each>
           </xsl:if>
      </xsl:for-each>
      <br/>
      
      <!-- SHOW CURRENT MAIN ENTITY CONTEXT -->
      <xsl:for-each select="PAGE/CONTEXT/ENTRYGROUP/ENTRY">
         <B><xsl:value-of select="@value"/></B><br/>
      </xsl:for-each>
      
      <!-- SHOW TABS/MENU BUTTONS IF ANY TO SEE -->
      <xsl:for-each select="PAGE/TABGROUP">
         <xsl:if test="@menu[.='n']">
               |<xsl:apply-templates select="TAB"/>
               <br/>
         </xsl:if>
      </xsl:for-each>
      </div>
      
      <hr/>
      <!-- RENDER ANY BLOCKS THAT HAVE BEEN RETURNED IN THE XML -->
      <xsl:for-each select="PAGE">
         <xsl:apply-templates select="CALENDARBLOCK"/>
      </xsl:for-each>
      <xsl:for-each select="PAGE/CALENDARBLOCK">
           <xsl:apply-templates select="CALENDAR"/>
           <!-- CALENDAR FILTER -->
           <!--xsl:apply-templates select="FILTER"/-->
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
                  <B><xsl:value-of select="@errorstring" /></B>
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
      <!-- REPEAT BUTTONS SO ON TOP AND BOTTOM OF FORM -->
      <xsl:for-each select="PAGE/CONTAINERBLOCK">
           <xsl:apply-templates select="BUTTONS"/>
      </xsl:for-each>
      <xsl:for-each select="PAGE/BLOCK">
           <xsl:apply-templates select="BUTTONS"/>
      </xsl:for-each>
    </FORM>
    <hr/>
  </BODY>
  </HTML>
</xsl:template>
	
<!-- END MAIN PAGE -->
			
<xsl:template match="FILTER">
     <xsl:for-each select="FILTERBUTTON">
     	<input type="submit">
	<xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute>
	</input>
	<br/>
     </xsl:for-each>
    <xsl:for-each select="BLOCK/ENTRYGROUP">
	  <xsl:for-each select="ENTRY">
                    <SELECT>
                       <xsl:attribute name="name"><xsl:value-of select="@name" /></xsl:attribute>    
                       <xsl:apply-templates select="OPTIONS"/>
                    </SELECT>
                    <b><xsl:value-of select="@caption" /></b><br/>
                    <input type="hidden">
                         <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
                         <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>     
                    </input>
          </xsl:for-each>
     </xsl:for-each>
     <xsl:for-each select="FILTERBUTTON">
     	<input type="submit">
	<xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute>
	</input>
	<br/>
     </xsl:for-each>
</xsl:template>

<xsl:template match="CALENDARBLOCK">
    <input type="hidden">
       <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
       <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </input>
</xsl:template>

<xsl:template match="CALENDAR">
     <div align="center">
         <!-- SHOW CURRENT DATE CAPTION -->
         <b><xsl:value-of select="@heading"/></b><br/>
     	 <!-- PREVIOUS DAY -->
     	 <xsl:for-each select="NAVBAR">
           <A><xsl:attribute name="HREF"><xsl:value-of select="@prevhref"/></xsl:attribute>&lt;&lt;</A>
         </xsl:for-each>
         <!-- TODAY -->
 	 <A><xsl:attribute name="href"><xsl:value-of select="@todayaction"/></xsl:attribute><xsl:value-of select="@todaycaption"/></A>
     	 <!-- NEXT DAY -->
     	 <xsl:for-each select="NAVBAR">
	   <A><xsl:attribute name="HREF"><xsl:value-of select="@nexthref"/></xsl:attribute>&gt;&gt;</A><br/>
         </xsl:for-each>
     </div>
     <!-- SHOW APPOINTMENTS AND TASKS UNDER IT (DAY MODE ONLY)-->
     <xsl:if test="@mode[.='1']">
     	  <HR/>		
          <xsl:apply-templates select="APPOINTMENTS"/>
          <HR/>
          <xsl:apply-templates select="TASKS"/>
     </xsl:if>
</xsl:template>

<xsl:template match="APPOINTMENTS">
          <b><u><xsl:value-of select="@heading2"/></u></b>
          <br/>
          <!-- SHOW ALL APPOINTMENTS FOR THIS DAY -->
          <xsl:for-each select="TIMESLOT">
              <xsl:if test="@hasapps[.='y']">
                   <xsl:apply-templates select="APPOINTMENT"/>
              </xsl:if>
          </xsl:for-each>
          
          <!-- NEW APPOINTMENT URL -->
          <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@caption"/></A>
</xsl:template>

<xsl:template match="APPOINTMENT">
     <xsl:apply-templates select="DETAILS"/><BR/>
</xsl:template>

<xsl:template match="TASKS">
          <b><u><xsl:value-of select="@heading2"/></u></b>
          <br/>
          <xsl:apply-templates select="TASK"/>
          <!-- NEW TASK URL -->
          <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@caption"/></A>
</xsl:template>

<xsl:template match="TASK">
    <xsl:apply-templates select="DETAILS"/><br/>
</xsl:template>

<xsl:template match="DETAILS">
     <!--xsl:value-of select="@timecaption" />
     <xsl:value-of select="@timevalue" />
     <xsl:value-of select="@usercaption" />
     <xsl:value-of select="@uservalue" />
     <xsl:value-of select="@notecaption" /-->
     <A>
     <xsl:for-each select="../ICON">
     	<xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute>
     </xsl:for-each>
     <xsl:value-of select="@timevalue" /></A> : <xsl:value-of select="@notevalue" />
</xsl:template>

<xsl:template match="ICON">
     <A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute>
     <IMG border="0"><xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG></A>
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
             <B><xsl:value-of select="@errorstring" /></B><br/>
         </xsl:otherwise>
    </xsl:choose>

</xsl:template>

<xsl:template match="BLOCK">
     <xsl:for-each select="ENTRYGROUP">
         <xsl:apply-templates select="ENTRY"/><br/>
     </xsl:for-each>
     <xsl:apply-templates select="CHART"/>
     <xsl:apply-templates select="GRID"/>
</xsl:template>

<xsl:template match="ENTRY">
<xsl:choose>                         
     <xsl:when test="@mode[.='edit']">
          <xsl:choose>
          <xsl:when test="@readonly[.='Y']">
               <b><xsl:value-of select="@caption" /></b>
               <xsl:choose>
                    <xsl:when test="@image[.='']">
                        <xsl:choose>
                         <xsl:when test="@value[.='']">
                         </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="@value"/><br/>
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
          <xsl:when test="@readonly[.='N']">
                <b><xsl:value-of select="@caption" /></b><br/>
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
                     <font color="red"><b>?</b></font><!--img border="0" ><xsl:attribute name="src"><xsl:value-of select="@required"/></xsl:attribute></img-->
                 </xsl:otherwise>
                 </xsl:choose>
                 <input type="hidden">
                    <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
                    <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>     
               </input>
         </xsl:when>
     </xsl:choose>
     </xsl:when>
     <xsl:otherwise>    <!-- when the mode is view -->
     <b><xsl:value-of select="@caption" /></b>
     <xsl:choose>
        <xsl:when test="@image[.='']">
         <xsl:choose>
               <xsl:when test="@href[.='']">
                    <xsl:choose>
                         <xsl:when test="@value[.='']">
                              <div></div>
                         </xsl:when>
                         <xsl:otherwise>
                              <div><xsl:value-of select="@value"/></div>
                         </xsl:otherwise>
                    </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                    <div><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@value"/></A></div>
               </xsl:otherwise>
         </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
                  <div><IMG border="0">
                       <xsl:attribute name="SRC"><xsl:value-of select="@image"/></xsl:attribute></IMG>
                  </div>
        </xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
</xsl:choose>
<br/>
</xsl:template>

<xsl:template match="CHART">
     <div align="left">
     	  <b>
          <xsl:value-of select="@caption"/></b>
     </div><br/>
     <IMG border="0">
         <xsl:attribute name="SRC"><xsl:value-of select="@src" /></xsl:attribute>
     </IMG><br/>
</xsl:template>

<xsl:template match="GRID">
     <b><xsl:value-of select="@caption"/></b>
     <xsl:for-each select="NAV">
          <xsl:choose>
              <xsl:when test="@mapame[.='']">
              </xsl:when>
              <xsl:otherwise>        
                  <div align="right">
                     <xsl:for-each select="AREA">
                       <A >
                       <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
                       <xsl:value-of select="@caption"></xsl:value-of>
                       </A>|
                     </xsl:for-each>
                  </div>
              </xsl:otherwise>
          </xsl:choose>
     </xsl:for-each>
     <xsl:for-each select="HEADERS">
          <xsl:apply-templates select="HEADER"/>
     </xsl:for-each>
     <br/>     
     <xsl:for-each select="ROWS/ROW">
          <xsl:if test="@rownumber[.='1']">
               <xsl:apply-templates select="CELL"/>
               <br/>
          </xsl:if>
          <xsl:if test="@rownumber[.='0']">
               <xsl:apply-templates select="CELL"/>
               <br/>
          </xsl:if>
     </xsl:for-each>
</xsl:template>

<xsl:template match="TAB">
     <A><xsl:attribute name="HREF"><xsl:value-of select="@url"/></xsl:attribute>
     <b><xsl:value-of select="@caption"/></b></A>|
</xsl:template>

<xsl:template match="CELL">
     <xsl:choose>
          <xsl:when test="@href[.='']">
               <xsl:choose>
                    <xsl:when test="@caption[.='']">
                       <div></div>
                    </xsl:when>
                    <xsl:otherwise>
                         <div><xsl:value-of select="@caption" /></div>
                    </xsl:otherwise>
               </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
               <xsl:choose>
                    <xsl:when test="@caption[.='']">
                       <div></div>
                    </xsl:when>
                    <xsl:otherwise>
                         <div><A><xsl:attribute name="HREF"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@caption"/></A></div>
                    </xsl:otherwise>
               </xsl:choose>
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
   <div>	
      <xsl:apply-templates select="BUTTON"/>
   </div>
</xsl:template>

<xsl:template match="BUTTON">
     <xsl:apply-templates select="BUTTONITEM" />
</xsl:template>

<xsl:template match="BUTTONITEM">
   <xsl:choose>
      <xsl:when test="@image[.='']">
         <xsl:choose>
            <xsl:when test="@href[.='#']">
               <input type="submit"><xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute></input>
            </xsl:when>
            <xsl:when test="@type[.='EDIT']">
               <input type="submit"><xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute></input>
            </xsl:when>
            <xsl:when test="@type[.='URL']">
               <A><xsl:attribute name="HREF"><xsl:value-of select="@href" /></xsl:attribute>
               <b><xsl:value-of select="@caption" /></b></A>
            </xsl:when>
            <xsl:otherwise>
               <!-- e.g. SEARCH BUTTON -->
               <input type="submit"><xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute></input>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <!-- TAKE OUT NEW BUTTONS ETC. -->
         <!--xsl:choose>
            <xsl:when test="@href[.='#']">
               <input type="submit"><xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute></input>
            </xsl:when>
            <xsl:when test="@type[.='EDIT']">
<input type="submit"><xsl:attribute name="value"><xsl:value-of select="@caption" /></xsl:attribute></input>
            </xsl:when>
            <xsl:when test="@type[.='URL']">
               <A>button here <xsl:attribute name="HREF"><xsl:value-of select="@href" /></xsl:attribute><IMG border="0"><xsl:attribute name="SRC"><xsl:value-of select="@image" /></xsl:attribute></IMG></A>
            </xsl:when>
          </xsl:choose-->
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

</xsl:stylesheet>