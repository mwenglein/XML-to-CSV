# Documentation

This XSL file explains how to cleanly convert XML data to comma separated values, making sure fields with commas or quotes inside are properly escaped and enclosed in double quotes as needed.

The transformation below creates one column in the CSV for each field that has been mapped from the XML and and populates it with data from a specific node inside each record in the XML.

Let's assume the following example XML. Please note: some field values contain quotation marks and commas to add some fun during CSV conversion. Also, some fields are nested and appear more than once, either carrying information within the field value (email) or in its label (hobbies).

## Example XML

    <contacts>
        <contact>
            <name>Mike "Air"</name>
            <emails>
                <email>mike1@example.com</email>
                <email>mike2@example.com</email>
                <email>mike3@example.com</email>
            </emails>
            <hobbies>
                <surfing>true</surfing>
                <snowboarding>true</snowboarding>
                <hiking>true</hiking>
            </hobbies>
        </contact>
        <contact>
            <name>John, Johnson</name>
            <emails>
                <email>john1@example.com</email>
                <email>john2@example.com</email>
            </emails>
            <hobbies>
                <swimming>true</swimming>
                <fishing>true</fishing>
            </hobbies>
        </contact>    
        <contact>
            <name>Max</name>
            <emails>
                <email>max1@example.com</email>
            </emails>
            <hobbies>
                <surfing>true</surfing>
                <biking>true</biking>
            </hobbies>
        </contact>
    </contacts>

## XSL Transformation

To convert, we first have to match the actual collection of records...

       <xsl:template match="contacts/contact">

...then each type of field(s) need to be rendered using the right template:

### singular_field
Plain text field containing a single data point.

Example XML: <_name_>**Mike "Air"**</_name_>

       <xsl:call-template name="singular_field"><xsl:with-param name="fieldname" select="name"/></xsl:call-template>
    
### plural_field_text
Nested fields with multiple entries that have information stored in the *value* attribute of each entry:

Example XML: <_emails_> <_email_>**mike1@example.com**</_email_> <_email_>**mike2@example.com**</_email_> </_emails_>

       <xsl:call-template name="plural_field_text"><xsl:with-param name="fieldname" select="emails"/></xsl:call-template>            

### plural_field_boolean
Nested fields containing information in the *name* of each field (e.g. "hobbies"). This structure is often used as a representation of an array of checkboxes on a web form.

Example XML: <_hobbies_> <**surfing**>true</**surfing**> <**biking**>true</**biking**> </_hobbies_>

       <xsl:call-template name="plural_field_boolean"><xsl:with-param name="fieldname" select="hobbies"/></xsl:call-template>            

And of course don't forget to separate fields with a comma!

       <xsl:value-of select="','"/>


### Here's the complete snippet:

PLEASE NOTE: the snipped requires a number of helper functions included in the actual source file (see Code).

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

    <!-- HELPER FUNCTIONS (see full source code) -->

    ...

## The CSV Result

1. note the double quoted (i.e escaped) quotation marks around "Air"
2. values with commas "John, Johnson" have been enclosed in quotation marks
3. multi_... fields are reduced to a semicolon separated list of values, ideal for importing to other systems

All of this makes sure we have proper CSV syntax:

    Name,Emails,Hobbies
    "Mike ""Air""",mike1@example.com;mike2@example.com;mike3@example.com,surfing;snowboarding;hiking
    "John, Johnson",john1@example.com;john2@example.com,swimming;fishing
    Max,max1@example.com,surfing;biking


That's it, have fun!

mike