<?xml version='1.0' encoding='utf-8' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <HDML VERSION="3.0" MARKABLE="TRUE" TTL="0">
  
  <!-- INITIALISER -->
  <NODISPLAY>
  <ACTION TYPE="ACCEPT" TASK="GO" DEST="#MAIN">
  <xsl:attribute name="VARS">
  	<xsl:for-each select="/PAGE/BLOCK">
  		<xsl:for-each select="ENTRYGROUP">
  			<xsl:for-each select="ENTRY">
   			     <xsl:if test=".">key_<xsl:value-of select="@name" />=<xsl:value-of select="@encodedhiddenvalue" />&amp;</xsl:if>
   			     <xsl:if test=".">display_<xsl:value-of select="@name" />=<xsl:value-of select="@encodeddisplayvalue" />&amp;</xsl:if>
  			</xsl:for-each>
  		</xsl:for-each>
  	</xsl:for-each>
  	<xsl:for-each select="/PAGE/CONTAINERBLOCK/BLOCK">
		<xsl:for-each select="ENTRYGROUP">
			<xsl:for-each select="ENTRY">
   			     <xsl:if test=".">key_<xsl:value-of select="@name" />=<xsl:value-of select="@encodedhiddenvalue" />&amp;</xsl:if>
   			     <xsl:if test=".">display_<xsl:value-of select="@name" />=<xsl:value-of select="@encodeddisplayvalue" />&amp;</xsl:if>
		  	</xsl:for-each>
	     	</xsl:for-each>
	</xsl:for-each>
  </xsl:attribute>
  </ACTION>
  </NODISPLAY>
  
  <!-- MAIN CARD -->
  <DISPLAY NAME="MAIN">
      <!-- MAIN MENU LINK AND CURRENT CAPTION -->
      Menu<A TASK="GO" DEST="#mainmenucard">
         <xsl:for-each select="PAGE/TABGROUP">
           <xsl:if test="@menu[.='y']">
             <xsl:for-each select="TAB">
               <xsl:if test="@class[.='TABON']">
                 <xsl:if test="@caption[.!='']"><xsl:value-of select="@caption"/></xsl:if>
               </xsl:if>
             </xsl:for-each>
           </xsl:if>
         </xsl:for-each>
       </A><BR />
       
      <!-- SUB MENU LINK AND CURRENT CAPTION -->
      Item<A TASK="GO" DEST="#submenucard">
         <xsl:for-each select="PAGE/TABGROUP">
           <xsl:if test="@menu[.='n']">
             <xsl:for-each select="TAB">
               <xsl:if test="@class[.='TABON']">
                 <xsl:if test="@caption[.!='']"><xsl:value-of select="@caption"/></xsl:if>
               </xsl:if>
             </xsl:for-each>
           </xsl:if>
         </xsl:for-each>
       </A>
       <BR />------------------<BR />

       <!-- SHOW CURRENT MAIN ENTITY CONTEXT -->
       <xsl:for-each select="PAGE/CONTEXT/ENTRYGROUP/ENTRY">
          <xsl:value-of select="@value"/>
       	  <BR />------------------<BR />
       </xsl:for-each>

      <!-- RENDER ANY BLOCKS THAT HAVE BEEN RETURNED IN THE XML -->
      <xsl:for-each select="PAGE/CALENDARBLOCK">
           <xsl:apply-templates select="CALENDAR"/>
      </xsl:for-each>
      <xsl:for-each select="PAGE/CONTAINERBLOCK">
           <xsl:apply-templates select="BUTTONS"/>
	   <xsl:choose>
		<xsl:when test="@errorstring[.='']"></xsl:when>
		<xsl:otherwise>
		   <xsl:value-of select="@errorstring" /><br />
		</xsl:otherwise>
	   </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="PAGE">
           <xsl:apply-templates select="CONTAINERBLOCK"/>
      </xsl:for-each>
      <xsl:for-each select="PAGE/BLOCK">
           <xsl:apply-templates select="BUTTONS"/>
           <xsl:choose>
      	      <xsl:when test="@errorstring[.='']"></xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="@errorstring" />
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
       
  </DISPLAY>
  
  <!-- OTHER CARDS REFERENCED ABOVE OR BELOW -->
  
  <DISPLAY NAME="mainmenucard">
     <xsl:for-each select="PAGE/TABGROUP">
         <xsl:if test="@menu[.='y']">
            <xsl:for-each select="TAB">
            <xsl:if test="@class[.='TABOFF']">
               <xsl:if test="@caption[.!='']">
                   <A TASK="GO" METHOD="POST">
                   <xsl:attribute name="LABEL"><xsl:value-of select="@caption"/></xsl:attribute>
                   <xsl:attribute name="DEST"><xsl:value-of select="@url"/></xsl:attribute>
                   <xsl:value-of select="@caption"/></A>
               </xsl:if>
            </xsl:if>
            </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
  </DISPLAY>
  
  <DISPLAY NAME="submenucard">
     <xsl:for-each select="PAGE/TABGROUP">
         <xsl:if test="@menu[.='n']">
            <xsl:for-each select="TAB">
            <xsl:if test="@class[.='TABOFF']">
               <xsl:if test="@caption[.!='']">
                   <A TASK="GO" METHOD="POST">
                   <xsl:attribute name="LABEL"><xsl:value-of select="@caption"/></xsl:attribute>
                   <xsl:attribute name="DEST"><xsl:value-of select="@url"/></xsl:attribute>
                   <xsl:value-of select="@caption"/></A>
               </xsl:if>
            </xsl:if>
            </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
  </DISPLAY>
  
  <!--========================== ENTRY CARDS ==================================-->
  
  <xsl:for-each select="PAGE/BLOCK">
  	<xsl:for-each select="ENTRYGROUP">
	    <xsl:for-each select="ENTRY">
		<xsl:choose>                         
		     <xsl:when test="@mode[.='edit']">
		     <xsl:choose>
			  <xsl:when test="@readonly[.='N']">
			       <xsl:choose>
				   <xsl:when test="@inputype[.='checkbox']">
				      <CHOICE MARKABLE="FALSE">
				      <xsl:attribute name="NAME">card_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="KEY">key_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:value-of select="@caption" />
				      <CE TASK="RETURN" RETVALS="Y;Yes" VALUE="Y">Yes</CE>
				      <CE TASK="RETURN" RETVALS=";No" VALUE="">No</CE>
				      </CHOICE>
				   </xsl:when>
				   <xsl:when test="@inputype[.='select']">
				      <CHOICE MARKABLE="FALSE">
				      <xsl:attribute name="NAME">card_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="KEY">key_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:value-of select="@caption" />
				      <xsl:apply-templates select="OPTIONS"/>
				      </CHOICE>
				   </xsl:when>
				   <xsl:otherwise>
				      <ENTRY MARKABLE="FALSE">
				      <xsl:attribute name="NAME">card_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="KEY">key_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="FORMAT">250M</xsl:attribute>    
				      <xsl:value-of select="@caption" />
				      </ENTRY>
				   </xsl:otherwise>
				</xsl:choose>
			 </xsl:when>
		     </xsl:choose>
		     </xsl:when>
		</xsl:choose>
	    </xsl:for-each>
	</xsl:for-each>
  </xsl:for-each>
  
  <xsl:for-each select="PAGE/CONTAINERBLOCK/BLOCK">
  	<xsl:for-each select="ENTRYGROUP">
	    <xsl:for-each select="ENTRY">
		<xsl:choose>                         
		     <xsl:when test="@mode[.='edit']">
		     <xsl:choose>
			  <xsl:when test="@readonly[.='N']">
			       <xsl:choose>
				   <xsl:when test="@inputype[.='checkbox']">
				      <CHOICE MARKABLE="FALSE">
				      <xsl:attribute name="NAME">card_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="KEY">key_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:value-of select="@caption" />
				      <CE TASK="RETURN" RETVALS="Y;Yes" VALUE="Y">Yes</CE>
				      <CE TASK="RETURN" RETVALS="N;No" VALUE="N">No</CE>
				      </CHOICE>
				   </xsl:when>
				   <xsl:when test="@inputype[.='select']">
				      <CHOICE MARKABLE="FALSE">
				      <xsl:attribute name="NAME">card_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="KEY">key_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:value-of select="@caption" />
				      <xsl:apply-templates select="OPTIONS"/>
				      </CHOICE>
				   </xsl:when>
				   <xsl:otherwise>
				      <ENTRY MARKABLE="FALSE">
				      <xsl:attribute name="NAME">card_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="KEY">key_<xsl:value-of select="@name" /></xsl:attribute>    
				      <xsl:attribute name="FORMAT">250M</xsl:attribute>    
				      <xsl:value-of select="@caption" />
				      </ENTRY>
				   </xsl:otherwise>
				</xsl:choose>
			 </xsl:when>
		     </xsl:choose>
		     </xsl:when>
		</xsl:choose>
	    </xsl:for-each>
	</xsl:for-each>
  </xsl:for-each>

</HDML>
</xsl:template>


<!--============================= END MAIN PAGE ===================================-->

<!-- NOTE : we may need something here for ezweb
<xsl:template match="CALENDARBLOCK">
    <input type="hidden">
       <xsl:attribute name="name">_hidden<xsl:value-of select="@name"/></xsl:attribute>       
       <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
    </input>
</xsl:template>
-->

<!--======================= CALENDAR STUFF ======================================-->

<xsl:template match="CALENDAR">
     <!-- SHOW CURRENT DATE CAPTION -->
     
     <B><xsl:value-of select="@heading"/></B><BR />
      
     <!-- PREVIOUS DAY -->
     <xsl:for-each select="NAVBAR">
       <A TASK="GO" METHOD="POST"><xsl:attribute name="DEST"><xsl:value-of select="@prevhref"/></xsl:attribute>&lt;&lt;</A>
     </xsl:for-each>
     
     <!-- TODAY -->
     <A TASK="GO" METHOD="POST"><xsl:attribute name="DEST"><xsl:value-of select="@todayaction"/></xsl:attribute><xsl:value-of select="@todaycaption"/></A>
         
     <!-- NEXT DAY -->
     <xsl:for-each select="NAVBAR">
       <A TASK="GO" METHOD="POST"><xsl:attribute name="DEST"><xsl:value-of select="@nexthref"/></xsl:attribute>&gt;&gt;</A>
     </xsl:for-each>

     <BR />------------------<BR />
          
     <!-- SHOW APPOINTMENTS AND TASKS UNDER IT (DAY MODE ONLY)-->
     <xsl:if test="@mode[.='1']">
          <xsl:apply-templates select="APPOINTMENTS"/><BR />------------------<BR />
          <xsl:apply-templates select="TASKS"/>
     </xsl:if>
</xsl:template>

<xsl:template match="APPOINTMENTS">
          <BR />
          <B><xsl:value-of select="@heading2"/></B>
          <BR />
          
          <!-- SHOW ALL APPOINTMENTS FOR THIS DAY -->
          <xsl:for-each select="TIMESLOT">
              <xsl:if test="@hasapps[.='y']">
                   <xsl:apply-templates select="APPOINTMENT"/>
              </xsl:if>
          </xsl:for-each>
          <BR />
          
          <!-- NEW APPOINTMENT URL -->
          <A TASK="GO"><xsl:attribute name="DEST"><xsl:value-of select="@href"/>&amp;refresh=newappt</xsl:attribute><xsl:value-of select="@caption"/></A>
</xsl:template>

<xsl:template match="APPOINTMENT">
     <xsl:apply-templates select="DETAILS"/>
</xsl:template>

<xsl:template match="TASKS">
          <BR />
          <B><xsl:value-of select="@heading2"/></B>
          <BR />
          
          <!-- SHOW ALL TASKS THIS DAY -->
          <xsl:apply-templates select="TASK"/>
          <BR />
          
          <!-- NEW TASK URL -->
          <A TASK="GO"><xsl:attribute name="DEST"><xsl:value-of select="@href"/>&amp;refresh=newtask</xsl:attribute><xsl:value-of select="@caption"/></A>
</xsl:template>

<xsl:template match="TASK">
    <xsl:apply-templates select="DETAILS"/>
</xsl:template>

<xsl:template match="DETAILS">
     <A TASK="GO" METHOD="POST">
     <xsl:for-each select="../ICON">
     <xsl:attribute name="DEST"><xsl:value-of select="@href"/></xsl:attribute>
     </xsl:for-each>
     <xsl:value-of select="@timevalue" /></A> : <xsl:value-of select="@notevalue" />
     <BR />
</xsl:template>


<!--======================= BLOCK STUFF ======================================-->

<xsl:template match="BLOCK">
     <xsl:for-each select="ENTRYGROUP">
         <xsl:apply-templates select="ENTRY"/>
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
                            <xsl:value-of select="@value"/>
                         </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>                     
               </xsl:choose>
          </xsl:when>
          <xsl:when test="@readonly[.='N']">
                <b><xsl:value-of select="@caption" /></b>
                
		<A>
		<xsl:attribute name="DEST">#card_<xsl:value-of select="@name" />
		</xsl:attribute>
		
	        <xsl:choose>
		   <xsl:when test="@inputype[.='checkbox']">
			<xsl:attribute name="TASK">GOSUB</xsl:attribute>
			<xsl:attribute name="RECEIVE">
			<xsl:if test=".">key_<xsl:value-of select="@name" />;</xsl:if>
			<xsl:if test=".">display_<xsl:value-of select="@name" /></xsl:if>
			</xsl:attribute>		
			<xsl:if test=".">$display_<xsl:value-of select="@name" /></xsl:if>
		   </xsl:when>
		   <xsl:when test="@inputype[.='select']">
			<xsl:attribute name="TASK">GOSUB</xsl:attribute>
			<xsl:attribute name="RECEIVE">
			<xsl:if test=".">key_<xsl:value-of select="@name" />;</xsl:if>
			<xsl:if test=".">display_<xsl:value-of select="@name" /></xsl:if>
			</xsl:attribute>		
			<xsl:if test=".">$display_<xsl:value-of select="@name" /></xsl:if>
		   </xsl:when>
		   <xsl:otherwise>
			<xsl:attribute name="TASK">GO</xsl:attribute>
			<xsl:if test=".">$key_<xsl:value-of select="@name" /></xsl:if>
		   </xsl:otherwise>
		</xsl:choose>
		
		</A>
		
                <xsl:choose>
                   <xsl:when test="@required[.='n']"></xsl:when>
                    <xsl:otherwise>
                     <b>?</b>
                    </xsl:otherwise>
                </xsl:choose>
         </xsl:when>
       </xsl:choose>
     </xsl:when>
     <xsl:otherwise>    <!-- when the mode is view -->
       <b><xsl:value-of select="@caption" /></b>
            <xsl:choose>
               <xsl:when test="@href[.='']">
                    <xsl:choose>
                         <xsl:when test="@value[.='']">
                         </xsl:when>
                         <xsl:otherwise>
                              <xsl:value-of select="@value"/>
                         </xsl:otherwise>
                    </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                    <A TASK="GO">
                    <xsl:attribute name="DEST"><xsl:value-of select="@href"/></xsl:attribute>
                    <xsl:attribute name="POSTDATA">
                    	<!-- context info for block to be included -->
		        <xsl:for-each select="/PAGE/BLOCK">
		             <xsl:if test="."><xsl:value-of select="@name" />=<xsl:value-of select="@value" />&amp;</xsl:if>
		        </xsl:for-each>
                    </xsl:attribute><xsl:value-of select="@value"/></A>
               </xsl:otherwise>
            </xsl:choose>
     </xsl:otherwise>
</xsl:choose>
<BR />
</xsl:template>

<xsl:template match="OPTIONS">     
          <xsl:apply-templates select="OPTION"/>
</xsl:template>

<xsl:template match="OPTION">      
  <CE TASK="RETURN">
  <xsl:attribute name="RETVALS">
  <xsl:if test="."><xsl:value-of select="@value"/>;</xsl:if>
  <xsl:if test="."><xsl:value-of select="@display"/></xsl:if>
  </xsl:attribute>
  <xsl:attribute name="VALUE"><xsl:value-of select="@value"/></xsl:attribute>
  <xsl:value-of select="@display"/>
  </CE>
</xsl:template>

<!--======================= BUTTONS STUFF ======================================-->
<!-- NOTE : Any and all hidden values that are normally on form fields MUST be 
     added here as part of the POSTDATA to the button below.
     i.e. HDML does not have hidden inputs, only has vars and postdata. We want
     to always use postdata (no max and more secure), so always have to tag all
     hidden fields to button url						-->
     
<xsl:template match="BUTTONS">
    <xsl:apply-templates select="BUTTON"/>
</xsl:template>

<xsl:template match="BUTTON">
     <xsl:apply-templates select="BUTTONITEM" />
</xsl:template>

<xsl:template match="BUTTONITEM">
   <xsl:choose>
      <xsl:when test="@image[.='']">
         <xsl:choose>
              <xsl:when test="@type[.='URL']">
                   <A TASK="GO">
                   <xsl:attribute name="DEST"><xsl:value-of select="@href" /></xsl:attribute>
                   <b><xsl:value-of select="@caption" /></b></A>
              </xsl:when>
              <!-- e.g. SEARCH/SAVE/NEW BUTTONS etc. -->
              <xsl:otherwise>
                   <A TASK="GO" METHOD="POST">
                   <xsl:attribute name="DEST"><xsl:value-of select="@href" /></xsl:attribute>
                   <xsl:attribute name="POSTDATA">

			<!-- hidden query context strings first, current block etc. -->
			
		        <xsl:for-each select="/PAGE/HIDDENQUERY">
			     <xsl:for-each select="QUERYFIELD">
		                  <xsl:if test="."><xsl:value-of select="@name" />=<xsl:value-of select="@value" />&amp;</xsl:if>
			     </xsl:for-each>
		        </xsl:for-each>
						
			<!-- now blocks and container blocks -->
		        
		        <xsl:for-each select="/PAGE/BLOCK">
		             <!-- id field -->
		             <xsl:if test="."><xsl:value-of select="@idField" />=<xsl:value-of select="@id" />&amp;</xsl:if>
		             
		             <!-- block mode etc. -->
		             <xsl:if test="."><xsl:value-of select="@name" />=<xsl:value-of select="@value" />&amp;</xsl:if>
		             
		             <!-- hidden and actual value for every entry -->
		             <xsl:for-each select="ENTRYGROUP">
		                  <xsl:for-each select="ENTRY">
		                       <xsl:if test="."><xsl:value-of select="@name" />_hidden=<xsl:value-of select="@encodedhiddenvalue" />&amp;</xsl:if>
		                       <xsl:if test="@mode[.='edit']">
			                    <xsl:if test="@readonly[.='N']"><xsl:value-of select="@name" />=$key_<xsl:value-of select="@name" />&amp;</xsl:if>
				       </xsl:if>
				  </xsl:for-each>
			     </xsl:for-each>
		        </xsl:for-each>
		        
		        <!-- repeat for container blocks -->
		        
		        <xsl:for-each select="/PAGE/CONTAINERBLOCK/BLOCK">
		             <!-- id field -->
		             <xsl:if test="."><xsl:value-of select="@idField" />=<xsl:value-of select="@id" />&amp;</xsl:if>
		             
		             <!-- block mode etc. -->
		             <xsl:if test="."><xsl:value-of select="@name" />=<xsl:value-of select="@value" />&amp;</xsl:if>
		             
		             <!-- hidden and actual value for every entry -->
		             <xsl:for-each select="ENTRYGROUP">
		                  <xsl:for-each select="ENTRY">
		                       <xsl:if test="."><xsl:value-of select="@name" />_hidden=<xsl:value-of select="@encodedhiddenvalue" />&amp;</xsl:if>
		                       <xsl:if test="@mode[.='edit']">
                                            <xsl:if test="@readonly[.='N']"><xsl:value-of select="@name" />=$key_<xsl:value-of select="@name" />&amp;</xsl:if>
                                            <xsl:if test="@readonly[.='Y']"><xsl:value-of select="@name" />=<xsl:value-of select="@value" />&amp;</xsl:if>
				       </xsl:if>
				  </xsl:for-each>
			     </xsl:for-each>
		        </xsl:for-each>
		        
		        <!-- if container, need hidden value of block mode -->
		        
		        <xsl:for-each select="/PAGE/CONTAINERBLOCK">
		             <xsl:if test="."><xsl:value-of select="@name" />_hidden=<xsl:value-of select="@value" />&amp;</xsl:if>
		        </xsl:for-each>
		        
		        <!-- same if calendar block -->
		        
		        <xsl:for-each select="/PAGE/CALENDARBLOCK">
		             <xsl:if test="."><xsl:value-of select="@name" />_hidden=<xsl:value-of select="@value" />&amp;</xsl:if>
		        </xsl:for-each>
		        
                   </xsl:attribute> <!-- end POSTDATA -->
                   <b><xsl:value-of select="@caption" /></b>
                   </A><BR />
              </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
   </xsl:choose>
</xsl:template>

<!--======================= GRID STUFF ======================================-->

<xsl:template match="GRID">
     <b><xsl:value-of select="@caption"/></b><BR />
     ------------------<BR />
     <xsl:for-each select="ROWS/ROW">
          <xsl:if test="@rownumber[.='1']">
               <xsl:apply-templates select="CELL"/>
          </xsl:if>
          <xsl:if test="@rownumber[.='0']">
               <xsl:apply-templates select="CELL"/>
          </xsl:if>
       	  ------------------<BR />
     </xsl:for-each>
     <xsl:for-each select="NAV">
          <xsl:choose>
              <xsl:when test="@mapame[.='']">
              </xsl:when>
              <xsl:otherwise>        
                     <xsl:for-each select="AREA">
                       <A TASK="GO">
                       <xsl:attribute name="DEST"><xsl:value-of select="@href"/></xsl:attribute>
                       <xsl:value-of select="@caption"></xsl:value-of>
                       </A>
                     </xsl:for-each>
              </xsl:otherwise>
          </xsl:choose>
     </xsl:for-each>
</xsl:template>

<xsl:template match="CELL">
     <xsl:choose>
          <xsl:when test="@href[.='']">
               <xsl:choose>
                    <xsl:when test="@caption[.='']">
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:value-of select="@caption" />
                    </xsl:otherwise>
               </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
               <xsl:choose>
                    <xsl:when test="@caption[.='']">
                    </xsl:when>
                    <xsl:when test="@coltype[.='50']">  <!-- phone type is 50 -->
                       <A TASK="CALL"><xsl:attribute name="NUMBER"><xsl:value-of select="@caption"/></xsl:attribute><xsl:value-of select="@caption"/></A>
                    </xsl:when>
                    <xsl:otherwise>
                       <A TASK="GO"><xsl:attribute name="DEST"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@caption"/></A>
                    </xsl:otherwise>
               </xsl:choose>
          </xsl:otherwise>
     </xsl:choose>
     <BR />
</xsl:template>

</xsl:stylesheet>