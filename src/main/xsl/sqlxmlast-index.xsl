<?xml version="1.0" encoding="UTF-8"?>
<!--
     sqlxmlast-shorten.xsl

     Stylesheet to compress elements in sqlxml ast files
     The basic idea is to shorten nestings of single elements like

     <a><b><c>x</c></b></a>         becomes <c rule-path="a b">x</c>
     <a><b><c>x</c><d>y</d></b></a> becomes <b rule-path="a"><c>x</c><d>y</d></b></b>

     Since the grammar fo oracle is realy big and there are many cases of deep single
     element nestings the resulting xml/json AST files downstream are signicant smaller
     and also the queries on these AST's are a lot easier to formulate

     Jurgen Hildebrand (ei@xs4all.nl)
     25052021
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:g="urn:xmlast:grammar"
    xmlns:t="urn:xmlast:token"
    xmlns:c="urn:xmlast:comment"
    xmlns:f="urn:xmlast:function" exclude-result-prefixes="xs" expand-text="yes">

    <xsl:param name="filename"></xsl:param>
    <xsl:param name="filedir">.</xsl:param>
    <xsl:param name="ast-uri"/>
    <xsl:output method="html" indent="yes"/>
    <xsl:strip-space elements="*"/>


    <xsl:variable name="uri">{$ast-uri}?recurse=yes;select=*.xml;stable=yes</xsl:variable>
    <xsl:variable name="doc-collecion" select="collection($uri)"/>
    <xsl:variable name="doc-refs">
        <xsl:for-each select="$doc-collecion">
            <a href="{replace(replace(document-uri(.),$ast-uri,''),'\.xml$','.html')}"/>
        </xsl:for-each>
    </xsl:variable>

    <xsl:template match="/">

        <html class="rr-root">
            <head>
                <meta charset="utf-8" />
                <link rel="stylesheet" type="text/css" href="railroad.css" />
            </head>
            <body>
                <h1>Rail Road Station</h1>
                <ul>
                    <xsl:for-each-group select="$doc-refs/a" group-by="replace(@href,'(.*?)/.*','$1')">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:variable name="grammars">
                           <xsl:for-each select="current-group()">
                                <xsl:sort select="@href"/>
                                <xsl:variable name="href" select="@href"/>
                                <xsl:copy>
                                    <xsl:copy-of select="@*"/>
                                    <xsl:value-of select="replace(replace($href,'.*/',''),'.ast.html','')"/>
                                </xsl:copy>
                                <xsl:value-of select="' '"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <li>
                            <xsl:choose>
                                <xsl:when test="count($grammars/a) gt 1">
                                     <xsl:value-of select="current-grouping-key()"/>
                                     <xsl:value-of select="' - '"/>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:for-each select="$grammars/a">
                                <xsl:sequence select="."/>
                                <xsl:value-of select="' '"/>
                            </xsl:for-each>
                        </li>
                    </xsl:for-each-group>
                </ul>
            </body>
        </html>

    </xsl:template>

</xsl:stylesheet>

