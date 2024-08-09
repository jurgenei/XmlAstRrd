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
                xmlns:f="urn:xmlast:function"
                exclude-result-prefixes="xs"
                expand-text="yes">

    <xsl:param name="filename"></xsl:param>
    <xsl:param name="filedir">.</xsl:param>
    <xsl:param name="ast-uri"/>
    <xsl:output method="html" indent="yes"/>
    <xsl:strip-space elements="*"/>


    <xsl:variable name="uri">{$ast-uri}?recurse=yes;select=*.xml;stable=yes</xsl:variable>
    <xsl:variable name="docs" select="collection($uri)"/>

	<xsl:template match="/">

	    <html class="rr-root">
        <head>
            <meta charset="utf-8" />
            <link rel="stylesheet" type="text/css" href="railroad.css" />
        </head>
        <body>
            <h1>Rail Road Languages Index</h1>
            <p>
            <xsl:for-each select="$docs">
                 <xsl:variable name="short" select="replace(replace(document-uri(.),$ast-uri,''),'\.xml$','.html')"/>
                 <a href="{$short}">{$short}</a>
                 {' '}
            </xsl:for-each>
            </p>
        </body>
        </html>

	</xsl:template>

</xsl:stylesheet>

