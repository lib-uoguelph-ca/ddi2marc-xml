<?xml version="1.0" encoding="utf-8"?>
<!--

=============================================================================

Filename : ddi2marc-xml.xsl
Author   : Chris Charles <ccharles@uoguelph.ca>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

XSLT to convert DDI XML to MARC XML written for Michelle Edwards at the
University of Guelph Library.


Using this file
~~~~~~~~~~~~~~~

This file is a standards-compliant XML transformation file. It can be used
with a variety of software. The author likes to use Xalan-J, an
Apache-licensed open source XSLT processor.

To use this file with Xalan-J, run something like this from the command line:

    java -jar /path/to/xalan.jar -IN [DDI-XML file] \
        -XSL ddi2marc-xml.xsl -OUT [OUTPUT FILE]

This stylesheet uses some Extended XSLT (EXSLT) tags, so using an XSLT
processor that supports EXSLT is pretty important.

=============================================================================

-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:ex="http://exslt.org/dates-and-times"

                extension-element-prefixes="ex"
                exclude-result-prefixes="marc xalan">

  <xsl:output method="xml" indent="yes" xalan:indent-amount="2"/>

  <!-- We don't want to copy text() nodes, which is the default. -->
  <xsl:template match="text()"/>

  <xsl:template match="/codeBook/stdyDscr">
    <xsl:text>

    </xsl:text>
    <xsl:comment>
      This file was automatically generated from DDI XML input using the
      ddi2marc-xml.xsl file from the University of Guelph Library.
    </xsl:comment>
    <xsl:text>

    </xsl:text>
    <collection xmlns="http://www.loc.gov/MARC21/slim">
      <record>

        <!--

        Unfortunately there doesn't seem to be any clear documentation about
        how the leader can be modified for MARCXML (in contrast to MARC). The
        logical record length, for instance, really has no place in an XML
        document and could be quite challenging to calculate.

        The Dublin Core to MARCXML stylesheet located at

            http://www.loc.gov/standards/marcxml/xslt/DC2MARC21slim.xsl

        seems to indicate that this fixed-length field doesn't even need to
        be fully provided. To be safe, I would prefer to generate a string of
        the expected length.

        It looks like this default value should work:

            http://www.oclc.org/developer/documentation/worldcat-search-api/marc-xml-sample

        -->
        <leader><xsl:text>00000    a2200000   4500</xsl:text></leader>

        <controlfield tag="005">
          <xsl:call-template name="tag005"/>
        </controlfield>
        <controlfield tag="008">
          <xsl:call-template name="tag008"/>
        </controlfield>

        <!-- Title -->
        <datafield ind1="0" ind2="0" tag="245">
          <subfield code="a">
            <xsl:value-of select="normalize-space(citation/titlStmt/titl)"/>
          </subfield>
          <xsl:if test="citation/titleStmt/subTitle">
            <subfield code="b">
              <xsl:value-of select="normalize-space(citation/titleStmt/subTitl)"/>
            </subfield>
          </xsl:if>
        </datafield>

        <!-- Authors -->
        <xsl:for-each select="/codeBook/docDscr/citation/rspStmt/AuthEnty">
          <datafield tag="720" ind1=" " ind2=" ">
            <subfield code="a"><xsl:value-of select="normalize-space(text())"/></subfield>
            <subfield code="e">author</subfield>
          </datafield>
        </xsl:for-each>

        <!-- Publication and distribution -->
        <datafield ind1=" " ind2=" " tag="260">

          <subfield code="a">
            <xsl:value-of select="normalize-space(/codeBook/docDscr/citation/prodStmt/prodPlac)"/>
          </subfield>
          <subfield code="b">
            <xsl:value-of select="normalize-space(/codeBook/docDscr/citation/prodStmt/producer)"/>
          </subfield>
          <subfield code="c">
            <xsl:value-of select="normalize-space(/codeBook/docDscr/citation/prodStmt/prodDate)"/>
          </subfield>
        </datafield>

        <!-- Summary, etc. -->
        <!-- I'm going to assume that the abstract fits nicely here. -->
        <datafield ind1=" " ind2=" " tag="520">
          <subfield code="a">
            <xsl:value-of select="normalize-space(stdyInfo/abstract)"/>
          </subfield>
        </datafield>

        <!-- Keywords -->
        <xsl:for-each select="stdyInfo/subject/keyword">
          <datafield tag="653" ind1="0" ind2=" ">
            <subfield code="a">
              <xsl:value-of select="normalize-space(text())"/>
            </subfield>
          </datafield>
        </xsl:for-each>

        <!-- Links -->
        <xsl:for-each select="/codeBook/docDscr/citation/holdings">
          <datafield tag="856" ind2=" ">
            <xsl:choose>

              <!-- Email -->
              <xsl:when test="starts-with(translate(@URI, 'MAILTO', 'mailto'), 'mailto:')">
                <xsl:attribute name="ind1">0</xsl:attribute>
              </xsl:when>

              <!-- FTP -->
              <xsl:when test="starts-with(translate(@URI, 'FTP', 'ftp'), 'ftp:')">
                <xsl:attribute name="ind1">1</xsl:attribute>
              </xsl:when>

              <!-- Telnet -->
              <!-- TODO: Figure out why this isn't working. -->
              <xsl:when test="starts-with(translate(@URI, 'TELN', 'teln'), 'telnet:')">
                <xsl:attribute name="ind1">2</xsl:attribute>
              </xsl:when>

              <!-- I'm not sure what URI prefix would be used for option 3,
                   "dial-up". It's also something that I don't expect to
                   need, so I'm not including it for the time being. -->

              <!-- HTTP -->
              <xsl:when test="starts-with(translate(@URI, 'HTP', 'htp'), 'http:')">
                <xsl:attribute name="ind1">4</xsl:attribute>
              </xsl:when>

              <!-- Some other provided protocol -->
              <xsl:when test="contains(@URI, '://')">
                <xsl:attribute name="ind1">7</xsl:attribute>
                <subfield code="2">
                  <xsl:value-of select="translate(substring-before(@URI, '://'), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                </subfield>
              </xsl:when>

              <!-- Default: No information given -->
              <xsl:otherwise>
                <xsl:attribute name="ind1"><xsl:text> </xsl:text></xsl:attribute>
              </xsl:otherwise>

            </xsl:choose>
            <subfield code="u">
              <xsl:value-of select="@URI"/>
            </subfield>
            <subfield code="y">
              <xsl:value-of select="normalize-space(text())"/>
            </subfield>
            <subfield code="z">
              <xsl:value-of select="@location"/>
            </subfield>
          </datafield>
        </xsl:for-each>

      </record>
    </collection>
  </xsl:template>


  <!-- Date and Time of Latest Transaction as YYYYMMDDHHMMSS.F in 24h time. -->
  <!-- Using the current time. -->
  <xsl:template name="tag005">
    <xsl:variable name="timestamp" select="format-number(ex:year(), '0000')"/>
    <xsl:variable name="timestamp" select="concat($timestamp, format-number(ex:month-in-year(), '00'))"/>
    <xsl:variable name="timestamp" select="concat($timestamp, format-number(ex:day-in-month(), '00'))"/>
    <xsl:variable name="timestamp" select="concat($timestamp, format-number(ex:hour-in-day(), '00'))"/>
    <xsl:variable name="timestamp" select="concat($timestamp, format-number(ex:minute-in-hour(), '00'))"/>
    <xsl:variable name="timestamp" select="concat($timestamp, format-number(ex:second-in-minute(), '00'))"/>

    <!-- Can't find smaller-than-second granularity in XSLT. -->
    <xsl:variable name="timestamp" select="concat($timestamp, '.0')"/>

    <xsl:value-of select="$timestamp"/>
  </xsl:template>


  <!-- Tag 008 is somewhat complex, with several pieces of data packed into a
       single string. -->
  <xsl:template name="tag008">

    <xsl:variable name="prod-date" select="/codeBook/docDscr/citation/prodStmt/prodDate/@date"/>

    <!-- 00-05 - Date entered on file (the date the MARC record was created,
         so the date the XSLT is run) in YYMMDD format. -->
    <xsl:variable name="packed-string" select="format-number(substring(ex:year(), 3, 2), '00')"/>
    <xsl:variable name="packed-string" select="concat(format-number($packed-string, ex:month-in-year()), '00')"/>
    <xsl:variable name="packed-string" select="concat(format-number($packed-string, ex:day-in-month()), '00')"/>

    <!-- 06 - Type of date/Publication status -->
    <!-- e - Detailed date -->
    <xsl:variable name="packed-string" select="concat($packed-string, 'e')"/>

    <!-- 07-10 - Date 1; 11-14 - Date 2 -->
    <xsl:variable name="packed-string" select="concat($packed-string, format-number(ex:year(ex:date($prod-date)), '0000'))"/>
    <xsl:variable name="packed-string" select="concat($packed-string, format-number(ex:month-in-year(ex:date($prod-date)), '00'))"/>
    <xsl:variable name="packed-string" select="concat($packed-string, format-number(ex:day-in-month(ex:date($prod-date)), '00'))"/>

    <!-- 15-17 - Place of publication, production, or execution -->
    <!-- Not including this for now. -->
    <xsl:variable name="packed-string" select="concat($packed-string, '|||')"/>

    <!-- 18-34 - Medium-specific fields -->
    <!-- Just use spaces for now. -->
    <xsl:variable name="packed-string" select="concat($packed-string, '                 ')"/>

    <!-- 35-37 - Language -->
    <!-- Don't include this for now. -->
    <xsl:variable name="packed-string" select="concat($packed-string, '|||')"/>

    <!-- 38 - Modified record -->
    <!-- 39 - Cataloging source -->
    <!-- Use 'no attempt to code' for these. -->
    <xsl:variable name="packed-string" select="concat($packed-string, '||')"/>

    <!-- Spit the finalized string out. -->
    <xsl:value-of select="$packed-string"/>

  </xsl:template>

</xsl:stylesheet>
