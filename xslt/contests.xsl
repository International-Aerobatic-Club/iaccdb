<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:strip-space elements="*"/>
  <xsl:output method="html"/>

  <xsl:template match="contests">
    <ul class="contest-list">
      <xsl:apply-templates mode="contest-list" />
    </ul>
  </xsl:template>

  <xsl:template match="contest" mode="contest-list">
    <li><xsl:value-of select="start"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="name"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="region"/>
      <xsl:text>) </xsl:text>
      <xsl:text>Directed by </xsl:text>
      <xsl:value-of select="director"/>
      <xsl:text>, Chapter </xsl:text>
      <xsl:value-of select="chapter"/> 
    </li>
  </xsl:template>

</xsl:stylesheet>
