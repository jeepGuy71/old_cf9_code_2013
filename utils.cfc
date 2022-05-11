
<cfcomponent displayname = "utils" hint = "Various utilities" output = "true">

    <cffunction name="pageThru" access="public" output="true" returntype="struct">
        <cfargument name = "TotalRecords" type = "numeric" required = "true">
        <cfargument name = "DisplayCount" type = "numeric" required = "true">
        <cfargument name = "PageGroup"    type = "numeric" required = "true">
        <cfargument name = "CurrentPage"  type = "numeric" required = "false" default = "1">
        <cfargument name = "TemplateURL"  type = "string"  required = "false" default = "">
        <cfargument name = "AddedPath"    type = "string"  required = "false" default = "">
        <cfargument name = "ImagePath"    type = "string"  required = "false" default = "NONE">
        <cfargument name = "ImageHeight"  type = "numeric" required = "false" default = "10">
        <cfargument name = "ImageWidth"   type = "numeric" required = "false" default = "10">
        <cfargument name = "HiLiteColor"  type = "string"  required = "false" default = "Red">
        <cfargument name = "PrevStr"      type = "string"  required = "false" default = "&lt;">
        <cfargument name = "PrevGrpStr"   type = "string"  required = "false" default = "&lt;&lt;">
        <cfargument name = "NextStr"      type = "string"  required = "false" default = "&gt;">
        <cfargument name = "NextGroupStr" type = "string"  required = "false" default = "&gt;&gt;">
        <!---
         This function uses some CF9 specific coding techniques
        *** SYNTAX ***

        <cfset local.paging = createObject("mod_udf.utils.cfc").pageThru(
            TOTALRECORDS = "integer", CURRENTPAGE = "integer"    , TEMPLATEURL = "URL Path",
            ADDEDPATH = "string"    , DISPLAYCOUNT = "integer"   , PAGEGROUP = "integer",
            IMAGEPATH = "URL path"  , IMAGEHEIGHT = "integer"    , IMAGEWIDTH = "integer",
            HILIGHTCOLOR = "hex code or color literal"         , PrevStr = "string",
            NEXTSTR = "string"      , PrevGrpStr = "string", NEXTGROUPSTR = "string")>

         - TOTALRECORDS (required) specifies the records returned by the query to be paged through.
         - CURRENTPAGE (required) the current page in the query that is to be displayed.
         - TEMPLATEURL (required) the URL path of the template that is paging though the query.
            This will usually be that same template that is calling CF_PageThru.
         - ADDEDPATH (optional) additonal URL parameters that will tacked on to the navigational URLs.
            The parameter list must start with an amperstand (&)
         - DISPLAYCOUNT (optional) specifies the maximum number of records to be displayed per page.
            The default is 25 records.
         - PAGEGROUP (optional) the maximum numnber of numeric page links to be displayed at one time
            in the page through navigation.  Set PAGEGROUP = "0" to turn page grouping off.
            The default is 10.
         - IMAGEPATH (optional) the URL path of the images to be used in the navigation.  This
            includes buttons for Next/Previous and Next Group/Previous Group.
            The default is "" (empty path) which results in using the current template
            URL directory for images.  Set IMAGEPATH = "NONE" to use hypertext buttons.
         - IMAGEHEIGHT (optional) the height of all image buttons.  The default is 10 pixels.
         - IMAGEWIDTH (optional) the width of all image buttons.  The default is 10 pixels.
         - HILITECOLOR (optional) the text color of the current page number in the page through
            navigation.  The default is "Red".
         - PrevStr (optional) the hyperlink text of the previous button.  The default is "<".
            You must set IMAGEPATH = "NONE" to use this option.
         - NEXTSTR (optional) the hyperlink text of the next button.  The default is ">".
            You must set IMAGEPATH = "NONE" to use this option.
         - PrevGrpStr (optional) the hyperlink text of the previous group button.  The default is "<<".
            You must set IMAGEPATH = "NONE" to use this option.
         - NEXTGROUPSTR (optional) the hyperlink text of the next group button.  The default is ">>".
            You must set IMAGEPATH = "NONE" to use this option.

        *** RETURNED VARS ***

        PT_StartRow  - the first row of the paged query to be displayed on the current page.
        PT_EndRow - the last row of the paged query to be displayed on the current page.
        PT_PageThru - navigation.  Output this variable wherever you want the PageThru navigation
            to be displayed.
        PT_ErrorCode - Numeric error code.  If not zero, an error occured.
        PT_ErrorMsg - Error description.

        --->

        <!---- set defaults ---->
        <cfparam name="local.tabIndexCount" default="1">

        <!--- INITIALIZE VARAIBLES --->
        <cfset local.ErrorCode = 0>
        <cfset local.PageStr = "">

        <!--- ERROR CODES --->
        <cfset local.ErrorArray = ArrayNew(1)>
        <cfset local.ErrorArray[1] = "The 'TotalRecords' parameter must be a positive integer.">
        <cfset local.ErrorArray[2] = "The 'DisplayCount' parameter must be an integer greater than zero.">
        <cfset local.ErrorArray[3] = "The 'PageGroup' parameter must be a positive integer.">
        <cfset local.ErrorArray[4] = "The 'CurrentPage' parameter must be an integer greater than zero.">

        <!--- CHECK IF PARAMETERS PASSED ARE PROPER --->
        <cfif arguments.TotalRecords LT 0>
            <cfset local.ErrorCode = 1>
        </cfif>
        <cfif arguments.DisplayCount LT 1>
            <cfset local.ErrorCode = 2>
        </cfif>
        <cfif arguments.PageGroup LT 0>
            <cfset local.ErrorCode = 3>
        </cfif>
        <cfif arguments.CurrentPage LT 1>
            <cfset local.ErrorCode = 4>
        </cfif>

        <!---    Calculate Page Starts and Stops    --->
        <cfset local.Start = (arguments.CurrentPage - 1) * arguments.DisplayCount + 1>
        <cfset local.End = arguments.CurrentPage * arguments.DisplayCount>
        <cfif local.End GT arguments.TotalRecords>
            <cfset local.End = arguments.TotalRecords>
        </cfif>
        <cfset local.MaxPages = arguments.TotalRecords / arguments.DisplayCount>

        <cfif arguments.TotalRecords MOD arguments.DisplayCount>
            <cfset local.MaxPages = IncrementValue(MaxPages)>
        </cfif>

        <!---    Calculate the range of diaplyed pages    --->
        <cfif local.MaxPages GT arguments.PageGroup AND arguments.PageGroup>
            <cfif (local.MaxPages - arguments.CurrentPage) GT (arguments.PageGroup - 1)>
                <cfset local.FromPage = arguments.CurrentPage>
                <cfset local.ToPage = arguments.CurrentPage + arguments.PageGroup - 1>
            <cfelse>
                <cfset local.FromPage = local.MaxPages - (arguments.PageGroup - 1)>
                <cfset local.ToPage = local.MaxPages>
            </cfif>
        <cfelse>
            <cfset local.FromPage = 1>
            <cfset local.ToPage = local.MaxPages>
        </cfif>

        <!---    Decide to use hypertext or graphic navigation    --->
        <cfif NOT CompareNoCase(UCase(arguments.ImagePath), 'NONE')>
            <cfset local.PGStr = arguments.PrevGrpStr>
            <cfset local.PPStr = arguments.PrevStr>
            <cfset local.NPStr = arguments.NextStr>
            <cfset local.NGStr = arguments.NextGroupStr>
        <cfelse>
            <cfset local.PGStr = "<img src = ""#arguments.ImagePath#lleft.gif""  width = ""#arguments.ImageWidth#"" height = ""#arguments.ImageHeight#"" border=0 align = ""absmiddle"" value = ""#arguments.PrevGrpStr#"">">
            <cfset local.PPStr = "<img src = ""#arguments.ImagePath#left.gif""   width = ""#arguments.ImageWidth#"" height = ""#arguments.ImageHeight#"" border=0 align = ""absmiddle"" value = ""#arguments.PrevStr#"">">
            <cfset local.NPStr = "<img src = ""#arguments.ImagePath#right.gif""  width = ""#arguments.ImageWidth#"" height = ""#arguments.ImageHeight#"" border=0 align = ""absmiddle"" value = ""#arguments.NextStr#"">">
            <cfset local.NGStr = "<img src = ""#arguments.ImagePath#rright.gif"" width = ""#arguments.ImageWidth#"" height = ""#arguments.ImageHeight#"" border=0 align = ""absmiddle"" value = ""#arguments.NextGroupStr#"">">
        </cfif>

        <cfif local.MaxPages GT 1>
            <cfset local.PageStr = "Page&nbsp;">

            <cfif local.FromPage NEQ 1 AND arguments.PageGroup>
                <cfif (arguments.CurrentPage - arguments.PageGroup) GTE 1>
                    <cfset local.Prev = arguments.CurrentPage - arguments.PageGroup>
                <cfelse>
                    <cfset local.Prev = 1>
                </cfif>
                <cfset local.PageStr = local.PageStr & " <a href = ""#arguments.TemplateURL#?currentpage=#local.Prev##arguments.AddedPath#"">#PGStr#</a> ">
            </cfif>

            <cfif arguments.CurrentPage NEQ 1>
                <cfset local.Prev = arguments.CurrentPage - 1>
                <cfset local.PageStr = local.PageStr & " <a href = ""#arguments.TemplateURL#?CurrentPage=#local.Prev##arguments.AddedPath#"">#PPStr#</a> ">
            </cfif>

            <cfloop index = "local.Count" from = "#local.FromPage#" to = "#local.ToPage#">

                <cfif local.Count EQ arguments.CurrentPage>
                    <cfset local.PageStr = local.PageStr & " #local.Count# ">
                <cfelse>
                    <cfset local.PageStr = local.PageStr & " <a href = ""#arguments.TemplateURL#?CurrentPage=#local.Count##arguments.AddedPath#""> #local.Count#</a> ">
                </cfif>
            </cfloop>

            <cfif arguments.CurrentPage NEQ local.MaxPages>
                <cfset local.Next = arguments.CurrentPage + 1>
                <cfset local.PageStr = local.PageStr & " <a href = ""#arguments.TemplateURL#?CurrentPage=#local.Next##arguments.AddedPath#"">#local.NPStr#</a> ">
            </cfif>

            <cfif ToPage NEQ local.MaxPages AND arguments.PageGroup><cfset local.Next = ToPage + 1>
                <cfset local.PageStr = local.PageStr & " <a href = ""#arguments.TemplateURL#?CurrentPage=#local.Next##arguments.AddedPath#"">#local.NGStr#</a> ">
            </cfif>
        </cfif>

        <!--- RETURN VARIABLES --->
        <cfset local.rtnVar.PT_StartRow  = local.Start>
        <cfset local.rtnVar.PT_EndRow    = local.End>
        <cfset local.rtnVar.PT_PageThru  = local.PageStr>
        <cfset local.rtnVar.PT_ErrorCode = local.ErrorCode>

        <cfif local.ErrorCode EQ 0>
            <cfset local.rtnVar.PT_ErrorMsg = "OK.">
        <cfelse>
            <cfset local.rtnVar.PT_ErrorMsg = local.ErrorArray[local.ErrorCode]>
        </cfif>

        <cfreturn local.rtnVar>

    </cffunction>

    <cffunction name="getEmailAddr" returntype="struct" output="true" hint="Retrieves a users email address from the LDAP server">
        <cfargument name="emailUser"  type="string" required="true">

        <cfset local.rtnStruct = {errorID = 0, errorMSG = ""}>

        <cftry>
            <cfldap attributes="mail" server="nldap1" action="query" start="o=tnrcc" name="qUserEmail" username="cn=ldapuser,o=tnrcc" password="nldap1" filter="(&(objectClass=user) (cn=#arguments.emailUser#))" port="389">
            <cfcatch type="any">
                <cfscript>
                    local.stReturnStatus.errorID      = 1;
                    local.stReturnStatus.errorMSG     = "We are experiencing connection or database problems at this time. Please try later.";
                    local.stReturnStatus.emailAddress = "";
                </cfscript>
            </cfcatch>
        </cftry>

        <cfscript>
            if(qUserEmail.recordCount EQ 0)
            {
                local.stReturnStatus.errorID      = 2;
                local.stReturnStatus.errorMSG     = "No email address found";
                local.stReturnStatus.emailAddress = "";
            }
            else
            {
                local.stReturnStatus.emailAddress = qUserEmail.mail;
            }
        </cfscript>

        <cfreturn local.stReturnStatus>

    </cffunction>


    <cffunction name="datePicker" access="public" returntype="string" hint="Generates Javascript block to display a DatePicker on an element" output="true" >
        <cfargument name="targetElementIDs" type="string" required="true"  hint="The ID of an Element that gets a DatePicker assigned to it. Comma delimited list will create multiple date pickers" />
        <cfargument name="fontSize"         type="string" required="false" default="10px" hint="Any valid value for the CSS font-size attribute" />
        <!--- see jQuery UI documentation for what these do, feel free to add new ones as needed --->
        <cfargument name="showOn"           type="string" required="false" default="both" />
        <cfargument name="buttonImageOnly"  type="string" required="false" default="true" />
        <cfargument name="buttonImage"      type="string" required="false" default="includes/images/calendar.gif" />
        <cfargument name="buttonText"       type="string" required="false" default="" />
        <cfargument name="closeText"        type="string" required="false" default="" />
        <cfargument name="prevText"         type="string" required="false" default="" />
        <cfargument name="nextText"         type="string" required="false" default="" />
        <cfargument name="maxDate"          type="string" required="false" default="" />
        <cfargument name="minDate"          type="string" required="false" default="" />
        <cfargument name="showButtonPanel"  type="string" required="false" default="false" />
        <cfargument name="changeMonth"      type="string" required="false" default="false" />
        <cfargument name="changeYear"       type="string" required="false" default="false" />

        <cfoutput>
            <cfsaveContent variable="local.datePickerCode">
                <style>
                    .ui-datepicker {font-size: #arguments.fontSize#;}
                </style>

                <script type="text/javascript">
                    $(document).ready(function(){
                        <cfloop list="#arguments.targetElementIDs#" index="local.i" >
                            $(function(){
                                $("###local.i#").datepicker({
                                    showOn          : "#arguments.showOn#",
                                    <cfif arguments.buttonImage NEQ "">
                                        buttonImage : "#arguments.buttonImage#",
                                    </cfif>
                                    <cfif arguments.buttonImageOnly NEQ "">
                                        buttonImageOnly : #arguments.buttonImageOnly#,
                                    </cfif>
                                    <cfif arguments.buttonText NEQ "">
                                        buttonText  : "#arguments.buttonText#",
                                    </cfif>
                                    <cfif arguments.closeText NEQ "">
                                        closeText   : "#arguments.closeText#",
                                    </cfif>
                                    <cfif arguments.prevText NEQ "">
                                        prevText    : "#arguments.prevText#",
                                    </cfif>
                                    <cfif arguments.nextText NEQ "">
                                        nextText    : "#arguments.nextText#",
                                    </cfif>
                                    <cfif arguments.maxDate NEQ "">
                                        maxDate    : "#arguments.maxDate#",
                                    </cfif>
                                    <cfif arguments.minDate NEQ "">
                                        minDate    : "#arguments.minDate#",
                                    </cfif>
                                    showButtonPanel : #arguments.showButtonPanel#,
                                    changeMonth     : #arguments.changeMonth#,
                                    changeYear      : #arguments.changeYear#
                                });
                            });

                        </cfloop>
                    });
                </script>
            </cfsaveContent>
        </cfoutput>

        <cfreturn local.datePickerCode>

    </cffunction>

    <cffunction name="createFormStruct" displayname="createFormStruct" access="public" output="false" returntype="void" hint="creates a struct based off of form data recieved">
        <cfargument name="dataStruct" type="struct" required="true" />
        <cfargument name="clientVarName" type="string" required="true"/>

        <!---- initialize return structure ---->
        <cfset local.structForm = structNew()>

        <!---- loop thru fieldnames setting new return struct ---->
        <cfloop list="#arguments.dataStruct.fieldnames#" index="local.i">
            <cfset local.structForm["#local.i#"] = arguments.dataStruct["#local.i#"]>
        </cfloop>

         <!---- convert form data struct into a client variable ---->
         <cfwddx action="cfml2wddx" input="#local.structForm#" output="client.#arguments.clientVarName#">

        <cfreturn>
    </cffunction>

    <cffunction name="createNavStack" displayname="navStack" access="public" output="false" returntype="void" hint="Creates the array used for reverse navigation">
        <!--- call this on your login page --->
        <cfset local.navStack = ArrayNew(1)>

        <!--- just in case people didn't clean up behind themselves --->
        <cfset deleteClientVariable("navStack")>

        <cfwddx action="cfml2wddx" input="#local.navStack#" output="client.navStack">

        <cfreturn>

    </cffunction>

    <!--- BEGIN simpleEncrypt FUNCTION --->
    <cffunction name="simpleEncrypt" access="public" returntype="string">
        <cfargument name="strData" type="string" required="Yes">

        <cfscript>
            var x = "";
            var z = 1;
            var t = "";

            for(z eq 1;z le len(arguments.strdata);z=z+1)
            {
                t = Ucase(FormatBaseN(BitXor(asc(mid(arguments.strData, z, 1)), (z mod 256)), 16));

                while(len(t) LT 2)
                    t = "0" & t;

                x = x & t;
            }
        </cfscript>

        <cfreturn reverse(x)>
   </cffunction>
    <!--- END simpleEncrypt FUNCTION --->

    <!--- BEGIN simpleDecrypt FUNCTION --->
    <cffunction name="simpleDecrypt" access="public" returntype="string">
        <cfargument name="strData" type="string" required="Yes">

        <cfscript>
            var y = "";
            var z = 1;
            var t = "";

            var x = reverse(arguments.strData);

            for(z eq 1;z le len(x);z=z+2)
            {
                t = mid(x, z, 2);
                y = y & chr(BitXor(InputBaseN(t, 16), (len(y) + 1) mod 256));
            }
        </cfscript>

        <cfreturn y>
    </cffunction>
    <!--- END simpleDecrypt FUNCTION --->


</cfcomponent>

