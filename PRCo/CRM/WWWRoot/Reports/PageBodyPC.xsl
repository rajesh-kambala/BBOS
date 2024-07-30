<?xml version='1.0' encoding='utf-8' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
    <TABLE ALIGN="CENTER" STYLE="border-collapse: collapse">
      <xsl:for-each select="REPORT/BAND">
        <xsl:choose>
          <xsl:when test="@TYPE[.='BLANKROW']">
            <xsl:apply-templates select="BLANKROW" />
          </xsl:when>
          <xsl:when test="@TYPE[.='CHART']">
            <xsl:apply-templates select="CHART" />
          </xsl:when>
          <xsl:when test="@TYPE[.='COLUMNHEADER']">
            <xsl:apply-templates select="COLUMNHEADER" />
          </xsl:when>
          <xsl:when test="@TYPE[.='DETAIL']">
            <xsl:apply-templates select="DETAIL" />
          </xsl:when>
          <xsl:when test="@TYPE[.='GROUPFOOTER']">
            <xsl:apply-templates select="GROUPFOOTER" />
          </xsl:when>
          <xsl:when test="@TYPE[.='PAGEFOOTER']">
            <xsl:apply-templates select="PAGEFOOTER" />
          </xsl:when>
          <xsl:when test="@TYPE[.='PAGEHEADER']">
            <xsl:apply-templates select="PAGEHEADER" />
          </xsl:when>
          <xsl:when test="@TYPE[.='SEARCHPARAMS']">
            <xsl:apply-templates select="SEARCHPARAMS" />
          </xsl:when>
          <xsl:when test="@TYPE[.='SUBDETAIL']">
            <xsl:apply-templates select="SUBDETAIL" />
          </xsl:when>
          <xsl:when test="@TYPE[.='SUMMARY']">
            <xsl:apply-templates select="SUMMARY" />
          </xsl:when>
          <xsl:when test="@TYPE[.='TITLE']">
            <xsl:apply-templates select="TITLE" />
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </TABLE>
</xsl:template>

<xsl:template match="BLANKROW">
  <TR CLASS="BLANKROW">
    <TD>
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      &#160;
    </TD>
  </TR>
</xsl:template>

<xsl:template match="CHART">
  <TR>
    <TD VALIGN="TOP">
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <IMG>
        <xsl:attribute name="ALT">
          <xsl:value-of select="@ALT" />
        </xsl:attribute>
        <xsl:attribute name="SRC">
          <xsl:value-of select="@SRC" />
        </xsl:attribute>
      </IMG>
    </TD>
  </TR>
</xsl:template>

<xsl:template match="COLUMNHEADER">
  <TR>
    <xsl:for-each select="COLUMNHEADERFIELD">
      <TD CLASS="REPORTCOLUMNHEADER">
        <xsl:attribute name="STYLE">text-align:
          <xsl:choose>
            <xsl:when test="@ALIGN[.='LEFT']">left</xsl:when>
            <xsl:when test="@ALIGN[.='CENTER']">center</xsl:when>
            <xsl:when test="@ALIGN[.='RIGHT']">right</xsl:when>
          <xsl:otherwise>left</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="."/>
        <xsl:if test="@SORT[.!='']">
          <IMG ALIGN="MIDDLE" BORDER="0">
            <xsl:attribute name="SRC">
              <xsl:value-of select="@SORT" />
            </xsl:attribute>
          </IMG>
        </xsl:if>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>

<xsl:template match="DETAIL">
  <TR>
    <xsl:attribute name="STYLE">background: 
      <xsl:choose>
        <xsl:when test="@ROW[.='E']">#EEFFEE</xsl:when>
        <xsl:when test="@ROW[.='O']">#FFFFD8</xsl:when>
      </xsl:choose>
    </xsl:attribute>

    <xsl:for-each select="GROUPHEADERFIELD">
      <TD>
        <xsl:attribute name="CLASS">REPORTGROUPHEADER</xsl:attribute>
        <xsl:value-of select="."/>
      </TD>
    </xsl:for-each>

    <xsl:for-each select="DETAILFIELD">
      <TD>
        <xsl:attribute name="STYLE">text-align:
          <xsl:choose>
            <xsl:when test="@ALIGN[.='LEFT']">left</xsl:when>
            <xsl:when test="@ALIGN[.='CENTER']">center</xsl:when>
            <xsl:when test="@ALIGN[.='RIGHT']">right</xsl:when>
          <xsl:otherwise>left</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>

        <xsl:attribute name="CLASS">REPORTDETAIL</xsl:attribute>

        <xsl:if test="@COLSPAN[.!='']">
          <xsl:attribute name="COLSPAN">
            <xsl:value-of select="@COLSPAN" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@WIDTH[.!='']">
          <xsl:attribute name="WIDTH">
            <xsl:value-of select="@WIDTH" />
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@HREF[.!='']">
            <A HREF="#">
              <xsl:attribute name="CLASS">REPORTDETAIL</xsl:attribute>
              <xsl:attribute name="ONCLICK">
                parent.opener.location='<xsl:value-of select="@HREF" />';
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="BR[.!='']">
                  <xsl:for-each select="BR">
                    <xsl:value-of select="."/>
                    <BR/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </A>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="BR[.!='']">
                <xsl:for-each select="BR">
                  <xsl:value-of select="."/>
                  <BR/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>

<xsl:template match="GROUPFOOTER">
  <TR>
    <xsl:for-each select="GROUPFOOTERFIELD">
      <TD CLASS="REPORTGROUPFOOTER">
        <xsl:attribute name="STYLE">text-align:
          <xsl:choose>
            <xsl:when test="@ALIGN[.='LEFT']">left</xsl:when>
            <xsl:when test="@ALIGN[.='CENTER']">center</xsl:when>
            <xsl:when test="@ALIGN[.='RIGHT']">right</xsl:when>
          <xsl:otherwise>left</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>

<xsl:template match="PAGEFOOTER">
  <TR>
    <TD>
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <TABLE CLASS="REPORTPAGEFOOTER">
        <TR>
          <TD ALIGN="LEFT" WIDTH="33%">
            <xsl:if test="@LDATA[.!='']">
              <xsl:value-of select="@LDATA" />
            </xsl:if>
            <xsl:if test="@LSRC[.!='']">
              <IMG ALT="logo">
                <xsl:attribute name="SRC">
                  <xsl:value-of select="@LSRC" />
                </xsl:attribute>
              </IMG>
            </xsl:if>
          </TD>
          <TD ALIGN="CENTER" WIDTH="33%">
            <xsl:if test="@CDATA[.!='']">
              <xsl:value-of select="@CDATA" />
            </xsl:if>
            <xsl:if test="@CSRC[.!='']">
              <IMG ALT="logo">
                <xsl:attribute name="SRC">
                  <xsl:value-of select="@CSRC" />
                </xsl:attribute>
              </IMG>
            </xsl:if>
          </TD>
          <TD ALIGN="RIGHT" WIDTH="33%">
            <xsl:if test="@RDATA[.!='']">
              <xsl:value-of select="@RDATA" />
            </xsl:if>
            <xsl:if test="@RSRC[.!='']">
              <IMG ALT="logo">
                <xsl:attribute name="SRC">
                  <xsl:value-of select="@RSRC" />
                </xsl:attribute>
              </IMG>
            </xsl:if>
          </TD>
        </TR>
      </TABLE>  
    </TD>
  </TR>
</xsl:template>

<xsl:template match="PAGEHEADER">
  <TR>
    <TD>
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <TABLE CLASS="REPORTPAGEHEADER">
        <TR>
          <TD ALIGN="LEFT" WIDTH="33%">
            <xsl:if test="@LDATA[.!='']">
              <xsl:value-of select="@LDATA" />
            </xsl:if>
            <xsl:if test="@LSRC[.!='']">
              <IMG ALT="logo">
                <xsl:attribute name="SRC">
                  <xsl:value-of select="@LSRC" />
                </xsl:attribute>
              </IMG>
            </xsl:if>
          </TD>
          <TD ALIGN="CENTER" WIDTH="33%">
            <xsl:if test="@CDATA[.!='']">
              <xsl:value-of select="@CDATA" />
            </xsl:if>
            <xsl:if test="@CSRC[.!='']">
              <IMG ALT="logo">
                <xsl:attribute name="SRC">
                  <xsl:value-of select="@CSRC" />
                </xsl:attribute>
              </IMG>
            </xsl:if>
          </TD>
          <TD ALIGN="RIGHT" WIDTH="33%">
            <xsl:if test="@RDATA[.!='']">
              <xsl:value-of select="@RDATA" />
            </xsl:if>
            <xsl:if test="@RSRC[.!='']">
              <IMG ALT="logo">
                <xsl:attribute name="SRC">
                  <xsl:value-of select="@RSRC" />
                </xsl:attribute>
              </IMG>
            </xsl:if>
          </TD>
        </TR>
      </TABLE>
    </TD>
  </TR>
</xsl:template>

<xsl:template match="IMAGE">
  <IMG ALT="logo">
    <xsl:attribute name="SRC">
      <xsl:value-of select="@SRC" />
    </xsl:attribute>
  </IMG>
</xsl:template>

<xsl:template match="SEARCHPARAMS">
  <TR>
    <TD WIDTH="100%">
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" RULES="NONE">
        <xsl:for-each select="SEARCHPARAMSFIELD">
          <TR>
            <TD CLASS="REPORTSEARCH">
              <B>
                <xsl:if test="@CAPTION[.!='']">
                  <xsl:value-of select="@CAPTION" />
                </xsl:if>
              </B>
            </TD>
            <TD WIDTH="10px">&#160;</TD>
            <TD CLASS="REPORTSEARCH">
              <xsl:if test="@VALUE[.!='']">
                <xsl:value-of select="@VALUE" />
              </xsl:if>
            </TD>
          </TR>
        </xsl:for-each>
      </TABLE>
    </TD>
  </TR>
</xsl:template>

<xsl:template match="SUBDETAIL">
  <TR>
    <TD>
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <TABLE BORDER="1" CELLPADDING="1" CELLSPACING="0" WIDTH="100%">
        <xsl:for-each select="BAND">
          <xsl:choose>
            <xsl:when test="@TYPE[.='BLANKROW']">
              <xsl:apply-templates select="BLANKROW" />
            </xsl:when>
            <xsl:when test="@TYPE[.='CHART']">
              <xsl:apply-templates select="CHART" />
            </xsl:when>
            <xsl:when test="@TYPE[.='COLUMNHEADER']">
              <xsl:apply-templates select="COLUMNHEADER" />
            </xsl:when>
            <xsl:when test="@TYPE[.='DETAIL']">
              <xsl:apply-templates select="DETAIL" />
            </xsl:when>
            <xsl:when test="@TYPE[.='GROUPFOOTER']">
              <xsl:apply-templates select="GROUPFOOTER" />
            </xsl:when>
            <xsl:when test="@TYPE[.='SUBDETAIL']">
              <xsl:apply-templates select="SUBDETAIL" />
            </xsl:when>
            <xsl:when test="@TYPE[.='SUMMARY']">
              <xsl:apply-templates select="SUMMARY" />
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </TABLE>
    </TD>
  </TR>
</xsl:template>

<xsl:template match="SUMMARY">
  <TR>
    <xsl:for-each select="SUMMARYFIELD">
      <TD CLASS="REPORTSUMMARY">
        <xsl:attribute name="STYLE">text-align:
          <xsl:choose>
            <xsl:when test="@ALIGN[.='LEFT']">left</xsl:when>
            <xsl:when test="@ALIGN[.='CENTER']">center</xsl:when>
            <xsl:when test="@ALIGN[.='RIGHT']">right</xsl:when>
          <xsl:otherwise>left</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>

<xsl:template match="TITLE">
  <TR>
    <TD CLASS="REPORTTITLE">
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <xsl:value-of select="."/>
    </TD>
  </TR>
</xsl:template>

</xsl:stylesheet>
