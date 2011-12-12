<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="text" indent="no" />    

    <xsl:template match="/"> 
        <xsl:apply-templates select="contacts" mode="header"/> 
        <xsl:apply-templates select="contacts" mode="data"/> 
    </xsl:template>

    <!-- HEADER ROW -->
        
    <xsl:template match="contacts" mode="header">
        <xsl:text>Name</xsl:text><xsl:text>,</xsl:text>
        <xsl:text>Emails</xsl:text><xsl:text>,</xsl:text>
        <xsl:text>Hobbies</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- DATA RECORDS -->
    
    <xsl:template match="contacts" mode="data">
        <xsl:apply-templates select="contact"/>
    </xsl:template>

    <xsl:template match="contact">
        <xsl:call-template name="singular_field"><xsl:with-param name="fieldname" select="name"/></xsl:call-template> <xsl:value-of select="','"/>
        <xsl:call-template name="plural_field_text"><xsl:with-param name="fieldname" select="emails"/></xsl:call-template> <xsl:value-of select="','"/>
        <xsl:call-template name="plural_field_boolean"><xsl:with-param name="fieldname" select="hobbies"/></xsl:call-template>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <!-- HELPER FUNCTIONS -->
    
    <xsl:template name="plural_field_text">
        <xsl:param name="fieldname"/>
        <xsl:call-template name="singular_field">
            <xsl:with-param name="fieldname">
                <xsl:for-each select="$fieldname/*">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>      
    
    <xsl:template name="plural_field_boolean">
        <xsl:param name="fieldname"/>
        <xsl:call-template name="singular_field">
            <xsl:with-param name="fieldname">
                <xsl:for-each select="$fieldname/*">
                    <xsl:value-of select="name(.)"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>        

    <xsl:template name="singular_field">
        <xsl:param name="fieldname"/>

        <xsl:variable name="linefeed">
            <xsl:text>&#10;</xsl:text>
        </xsl:variable>
        
        <xsl:choose>
            
            <xsl:when test="contains( $fieldname, '&quot;' )">
                <!-- Field contains a quote. We must enclose this field in quotes,
                    and we must escape each of the quotes in the field value.
                -->
                <xsl:text>"</xsl:text>
                
                <xsl:call-template name="escape_quotes">
                    <xsl:with-param name="string" select="$fieldname" />
                </xsl:call-template>
                
                <xsl:text>"</xsl:text>
            </xsl:when>
            
            <xsl:when test="contains( $fieldname, ',' ) or
                contains( $fieldname, $linefeed )" >
                <!-- Field contains a comma and/or a linefeed.
                    We must enclose this field in quotes.
                -->
                <xsl:text>"</xsl:text>
                <xsl:value-of select="$fieldname" />
                <xsl:text>"</xsl:text>
            </xsl:when>
            
            <xsl:otherwise>
                <!-- No need to enclose this field in quotes.
                -->
                <xsl:value-of select="$fieldname" />
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="escape_quotes">
        <xsl:param name="string" />
        
        <xsl:value-of select="substring-before( $string, '&quot;' )" />
        <xsl:text>""</xsl:text>
        
        <xsl:variable name="substring_after_first_quote"
            select="substring-after( $string, '&quot;' )" />
        
        <xsl:choose>
            
            <xsl:when test="not( contains( $substring_after_first_quote,
                '&quot;' ) )">
                <xsl:value-of select="$substring_after_first_quote" />
            </xsl:when>
            
            <xsl:otherwise>
                <!-- The substring after the first quote contains a quote.
                    So, we call ourself recursively to escape the quotes
                    in the substring after the first quote.
                -->
                
                <xsl:call-template name="escape_quotes">
                    <xsl:with-param name="string" select="$substring_after_first_quote"
                    />
                </xsl:call-template>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>

</xsl:stylesheet>