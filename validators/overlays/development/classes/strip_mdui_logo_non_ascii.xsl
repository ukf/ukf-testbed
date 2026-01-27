<?xml version="1.0" encoding="UTF-8"?>
<!--

    check-mdui-logo-non-ascii.xsl

    Check mdui:Logo elements do not contain non-ASCII characters.

    Author: ??

-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
    xmlns="urn:oasis:names:tc:SAML:2.0:metadata">

    <!--
        Common support functions.
    -->
    <xsl:import href="classpath:_rules/check_framework.xsl"/>

    <!-- Force UTF-8 encoding for the output. -->
    <xsl:output omit-xml-declaration="no" method="xml" encoding="UTF-8" indent="yes"/>

    <!-- TODO THE BELOW IS WRONG. Contains will not match as no regex in XSLT 1.0? -->

    <!-- Match the pattern we want to remove. -->
    <xsl:template match="mdui:Logo[contains(., '[^\x00-\x7F]')]">
        <xsl:call-template name="error"> <!-- TODO changed WARN to ERROR-->
            <xsl:with-param name="m">
                <xsl:text>mdui:Logo containing non-ascii characters removed: '</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>'</xsl:text>
            </xsl:with-param>
        </xsl:call-template>
        <!-- ... and don't copy the element to the output, so that it is removed ... -->
    </xsl:template>

    <!--By default, copy text blocks, comments and attributes unchanged.-->
    <xsl:template match="text()|comment()|@*">
        <xsl:copy/>
    </xsl:template>

    <!-- Copy all elements from the input to the output, along with their attributes and contents. -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
