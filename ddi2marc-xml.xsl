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
        -XSL ddixml2marcxml.xsl -OUT [OUTPUT FILE]

=============================================================================

-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:xalan="http://xml.apache.org/xalan"

                exclude-result-prefixes="marc xalan">

  <xsl:output method="xml" indent="yes" xalan:indent-amount="2"/>

  <!-- We don't want to copy text() nodes, which is the default. -->
  <xsl:template match="text()"/>

  <xsl:template match="/codeBook/stdyDscr">
    <xsl:comment>
      This file was automatically generated from DDI XML input using the
      ddi2marc-xml.xsl file from the University of Guelph Library.
    </xsl:comment>
    <collection xmlns="http://www.loc.gov/MARC21/slim">
      <record>
        <!-- TODO: Add all the header stuff -->

        <!-- Title -->
        <!-- TODO: Figure out whether we can always use "0" for both indicators. -->
        <datafield ind1="0" ind2="0" tag="245">
          <subfield code="a">
            <xsl:value-of select="citation/titlStmt/titl"/>
          </subfield>
          <xsl:if test="citation/titleStmt/subTitle">
            <subfield code="b">
              <xsl:value-of select="citation/titleStmt/subTitl"/>
            </subfield>
          </xsl:if>
        </datafield>

        <!-- Publication and distribution -->
        <datafield ind1=" " ind2=" " tag="260">

          <subfield code="a">
            <xsl:value-of select="/codeBook/docDscr/citation/prodStmt/prodPlac"/>
          </subfield>
          <subfield code="b">
            <xsl:value-of select="/codeBook/docDscr/citation/prodStmt/producer"/>
          </subfield>
          <subfield code="c">
            <xsl:value-of select="/codeBook/docDscr/citation/prodStmt/prodDate"/>
          </subfield>
        </datafield>

        <!-- Summary, etc. -->
        <!-- I'm going to assume that the abstract fits nicely here. -->
        <datafield ind1=" " ind2=" " tag="520">
          <subfield code="a">
            <xsl:value-of select="stdyInfo/abstract"/>
          </subfield>
        </datafield>

        <!-- Keywords -->
        <xsl:for-each select="stdyInfo/subject/keyword">
          <datafield tag="653" ind1="0" ind2=" ">
            <subfield code="a">
              <xsl:value-of select="text()"/>
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
                <!-- TODO: Get this space to show up. -->
                <xsl:attribute name="ind1"> </xsl:attribute>
              </xsl:otherwise>

            </xsl:choose>
            <subfield code="u">
              <xsl:value-of select="@URI"/>
            </subfield>
            <subfield code="y">
              <xsl:value-of select="text()"/>
            </subfield>
            <subfield code="z">
              <xsl:value-of select="@location"/>
            </subfield>
          </datafield>
        </xsl:for-each>

      </record>
    </collection>
  </xsl:template>

</xsl:stylesheet>
