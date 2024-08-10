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
    <!--
         <xsl:mode on-no-match="shallow-copy"/>
    -->    
    <xsl:param name="filename"></xsl:param>
    <xsl:param name="filedir">.</xsl:param>
    
    
    <xsl:output method="html" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:function name="f:path">
        <xsl:param name="in"/>
        <xsl:analyze-string select="$in" regex="[^/]*/(.*)">
            <xsl:matching-substring>../{f:path(regex-group(1))}</xsl:matching-substring>
            <xsl:non-matching-substring>..</xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:variable name="root" select="f:path($filedir)"/>
    
    <xsl:template match="g:ast">
        <html class="rr-root">
            <head>
                <meta charset="utf-8" />
                <link rel="stylesheet" type="text/css" href="{f:path($filedir)}/railroad.css" />
                <!--
                     <link rel="stylesheet" type="text/css" href="ast.css" />
                -->
            </head>
            <body>
                <h1>Railroad {$filedir}/{$filename}</h1>      
                <xsl:apply-templates select="node()"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="c:MULTI_LINE_COMMENT" priority="10">
        <pre>
            <xsl:value-of select="text()"/>
        </pre>
    </xsl:template>

    <xsl:template match="g:prequelConstruct|g:grammarDecl|g:blockSuffix|g:ebnfSuffix"/>
    <xsl:template match="g:altList/t:OR" priority="1"/>
    <xsl:template match="g:ruleAltList/t:OR" priority="1"/>
    <!--
         <xsl:template match="t:*">
         <rr-t>{.}</rr-t>
         </xsl:template>
    -->
    
    <xsl:template match="g:rules">
        <h1>Rules</h1>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="g:ruleSpec/g:lexerRuleSpec">
        <xsl:variable name="name" select="(g:tokenDef,t:TOKEN_REF)[1]"/>
        <h2 id="{$name}">{$name}</h2>
        <p>
            <rr-rr>
                <xsl:apply-templates/>
            </rr-rr>
        </p>
    </xsl:template>
    
    <xsl:template match="g:ruleSpec/g:parserRuleSpec">
        <xsl:variable name="name" select="(g:ruleDef,t:RULE_REF)[1]"/>
        <h2 id="{$name}">{$name}</h2>
        <p>
            <rr-rr>
                <xsl:apply-templates/>
            </rr-rr>
        </p>
    </xsl:template>
    <xsl:template match="g:ruleAltList|g:altList|g:lexerAltList">
        <rr-o>
            <xsl:apply-templates/>
        </rr-o>
    </xsl:template>
    <xsl:template match="g:alternative[count(g:element) gt 1]">
        <rr-a>
            <xsl:apply-templates/>
        </rr-a>
    </xsl:template>
    
    
    <xsl:template match="g:block">
        <xsl:variable name="cardinality" select="following-sibling::g:blockSuffix"/>
        <rr-a>
            <xsl:choose>
                <xsl:when test="$cardinality = '*'">
                    <xsl:attribute name="data-min">0</xsl:attribute>
                    <xsl:attribute name="data-max">inf</xsl:attribute>
                </xsl:when>
                <xsl:when test="$cardinality = '+'">
                    <xsl:attribute name="data-min">1</xsl:attribute>
                    <xsl:attribute name="data-max">inf</xsl:attribute>
                </xsl:when>
                <xsl:when test="$cardinality = '?'">
                    <xsl:attribute name="data-min">0</xsl:attribute>
                    <xsl:attribute name="data-max">1</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </rr-a>
    </xsl:template>

<!--
    lexerRuleBlock
    -->
    
     <xsl:template match="g:characterRange">
         <rr-c>
            <xsl:value-of select="string-join(.//t:*,'')"/>
         </rr-c>
     </xsl:template>

    <xsl:template match="g:atom|g:lexerAtom">
        <xsl:variable name="cardinality" select="following-sibling::g:ebnfSuffix"/>
        <xsl:apply-templates>
            <xsl:with-param name="card-attr" tunnel="true">
                <xsl:choose>
                    <xsl:when test="$cardinality = '*'">
                        <g:a data-min="0" data-max="inf"/>
                    </xsl:when>
                    <xsl:when test="$cardinality = '+'">
                        <g:a data-min="1" data-max="inf"/>
                    </xsl:when>
                    <xsl:when test="$cardinality = '?'">
                        <g:a data-min="0" data-max="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <g:a data-min="1" data-max="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- scrap rule defs -->
    <xsl:template match="g:ruleDef"/>
    
    <xsl:template match="g:ruleref">
        <xsl:param name="card-attr" tunnel="true"/>
        <a href="#{.}">
            <xsl:copy-of select="if ($card-attr) then $card-attr/@* else ()"/>
            <xsl:value-of select=".//t:*"/>
        </a>
    </xsl:template>
    
    <xsl:template match="g:terminal|g:terminalDef">
        <xsl:param name="card-attr" tunnel="true"/>
        <rr-t>
            <xsl:copy-of select="if ($card-attr) then $card-attr/@* else ()"/>
            <xsl:value-of select=".//t:*"/>
        </rr-t>
    </xsl:template>
    
    <xsl:template match="g:lexerAtom/t:*">
        <xsl:param name="card-attr" tunnel="true"/>
        <rr-c>
            <xsl:copy-of select="if ($card-attr) then $card-attr/@* else ()"/>
            <xsl:value-of select=".//t:*"/>
        </rr-c>
    </xsl:template>
    
    <xsl:template match="g:lexerElements">
        <rr-a>
            <xsl:apply-templates/>
        </rr-a>
    </xsl:template>

    <xsl:template match="c:*|text()"/>
    
</xsl:stylesheet>

