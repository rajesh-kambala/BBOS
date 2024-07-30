<?xml version='1.0' encoding='utf-8' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<HTML>
  <HEAD>
    <META HTTP-EQUIV="Expires" CONTENT="Tue, 04 Dec 1993 21:29:02 GMT" CHARSET="utf-8"/>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"/>
  </HEAD>
  <BODY ALINK="NAVY" LINK="NAVY" VLINK="NAVY">
    <TABLE BGCOLOR="white" BORDER="1" CELLPADDING="1" CELLSPACING="0">
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
  </BODY>
</HTML>
</xsl:template>

<xsl:template match="BLANKROW">
  <TR>
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
    <TD ALIGN="CENTER" VALIGN="TOP">
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
      <TD VALIGN="TOP">
        <xsl:choose>
          <xsl:when test="@ALIGN[.!='']">
            <xsl:attribute name="ALIGN">
              <xsl:value-of select="@ALIGN" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <FONT COLOR="BLACK" SIZE="2" FACE="sans-serif">
          <B>
            <xsl:value-of select="."/>
          </B>
        </FONT>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>

<xsl:template match="DETAIL">
  <TR>
    <xsl:attribute name="BGCOLOR">
      <xsl:choose>
        <xsl:when test="@ROW[.='E']">#AAFFAA</xsl:when>
        <xsl:when test="@ROW[.='O']">#EEFF77</xsl:when>
      </xsl:choose>
    </xsl:attribute>

    <xsl:for-each select="DETAILFIELD">
      <TD VALIGN="TOP">
        <xsl:choose>
          <xsl:when test="@ALIGN[.!='']">
            <xsl:attribute name="ALIGN">
              <xsl:value-of select="@ALIGN" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@COLSPAN[.!='']">
            <xsl:attribute name="COLSPAN">
              <xsl:value-of select="@COLSPAN" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@WIDTH[.!='']">
            <xsl:attribute name="WIDTH">
              <xsl:value-of select="@WIDTH" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <FONT COLOR="NAVY" SIZE="2" FACE="sans-serif">
          <xsl:value-of select="." />
        </FONT>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>
        
<xsl:template match="GROUPFOOTER">
  <TR>
    <xsl:for-each select="GROUPFOOTERFIELD">
      <TD VALIGN="TOP">
        <xsl:choose>
          <xsl:when test="@ALIGN[.!='']">
            <xsl:attribute name="ALIGN">
              <xsl:value-of select="@ALIGN" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <FONT COLOR="NAVY" SIZE="2" FACE="sans-serif">
          <B>
            <xsl:value-of select="." />
          </B>
        </FONT>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>

<xsl:template match="PAGEFOOTER">
  <TR>
    <TD VALIGN="TOP">
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <TABLE>
        <TR>
          <TD ALIGN="LEFT" WIDTH="33%">
            <FONT COLOR="NAVY" SIZE="1" FACE="sans-serif">
              <xsl:choose>
                <xsl:when test="@LDATA[.!='']">
                  <xsl:value-of select="@LDATA" />
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@LSRC[.!='']">
                  <IMG ALT="logo">
                    <xsl:attribute name="SRC">
                      <xsl:value-of select="@LSRC" />
                    </xsl:attribute>
                  </IMG>
                </xsl:when>
              </xsl:choose>
            </FONT>
          </TD>
          <TD ALIGN="CENTER" WIDTH="33%">
            <FONT COLOR="NAVY" SIZE="1" FACE="sans-serif">
              <xsl:choose>
                <xsl:when test="@CDATA[.!='']">
                  <xsl:value-of select="@CDATA" />
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@CSRC[.!='']">
                  <IMG ALT="logo">
                    <xsl:attribute name="SRC">
                      <xsl:value-of select="@CSRC" />
                    </xsl:attribute>
                  </IMG>
                </xsl:when>
              </xsl:choose>
            </FONT>
          </TD>
          <TD ALIGN="RIGHT" WIDTH="33%">
            <FONT COLOR="NAVY" SIZE="1" FACE="sans-serif">
              <xsl:choose>
                <xsl:when test="@RDATA[.!='']">
                  <xsl:value-of select="@RDATA" />
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@RSRC[.!='']">
                  <IMG ALT="logo">
                    <xsl:attribute name="SRC">
                      <xsl:value-of select="@RSRC" />
                    </xsl:attribute>
                  </IMG>
                </xsl:when>
              </xsl:choose>
            </FONT>
          </TD>
        </TR>
      </TABLE>  
    </TD>
  </TR>
</xsl:template>
        
<xsl:template match="PAGEHEADER">
  <TR>
    <TD VALIGN="TOP">
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <TABLE>
        <TR>
          <TD ALIGN="LEFT" WIDTH="33%">
            <FONT COLOR="NAVY" SIZE="1" FACE="sans-serif">
              <xsl:choose>
                <xsl:when test="@LDATA[.!='']">
                  <xsl:value-of select="@LDATA" />
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@LSRC[.!='']">
                  <IMG ALT="logo">
                    <xsl:attribute name="SRC">
                      <xsl:value-of select="@LSRC" />
                    </xsl:attribute>
                  </IMG>
                </xsl:when>
              </xsl:choose>
            </FONT>
          </TD>
          <TD ALIGN="CENTER" WIDTH="33%">
            <FONT COLOR="NAVY" SIZE="1" FACE="sans-serif">
              <xsl:choose>
                <xsl:when test="@CDATA[.!='']">
                  <xsl:value-of select="@CDATA" />
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@CSRC[.!='']">
                  <IMG ALT="logo">
                    <xsl:attribute name="SRC">
                      <xsl:value-of select="@CSRC" />
                    </xsl:attribute>
                  </IMG>
                </xsl:when>
              </xsl:choose>
            </FONT>
          </TD>
          <TD ALIGN="RIGHT" WIDTH="33%">
            <FONT COLOR="NAVY" SIZE="1" FACE="sans-serif">
              <xsl:choose>
                <xsl:when test="@RDATA[.!='']">
                  <xsl:value-of select="@RDATA" />
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="@RSRC[.!='']">
                  <IMG ALT="logo">
                    <xsl:attribute name="SRC">
                      <xsl:value-of select="@RSRC" />
                    </xsl:attribute>
                  </IMG>
                </xsl:when>
              </xsl:choose>
            </FONT>
          </TD>
        </TR>
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
      <TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0">
        <xsl:for-each select="BAND">
          <xsl:choose>
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
      <TD VALIGN="TOP">
        <xsl:choose>
          <xsl:when test="@ALIGN[.!='']">
            <xsl:attribute name="ALIGN">
              <xsl:value-of select="@ALIGN" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <FONT COLOR="NAVY" SIZE="3" FACE="sans-serif">
          <B>
            <xsl:value-of select="." />
          </B>
        </FONT>
      </TD>
    </xsl:for-each>
  </TR>
</xsl:template>
        
<xsl:template match="TITLE">
  <TR>
    <TD ALIGN="CENTER" VALIGN="TOP">
      <xsl:attribute name="COLSPAN">
        <xsl:value-of select="@COLSPAN" />
      </xsl:attribute>
      <FONT COLOR="NAVY" SIZE="6" FACE="sans-serif">
        <B>
          <xsl:value-of select="." />
        </B>
      </FONT>
    </TD>
  </TR>
</xsl:template>

</xsl:stylesheet>