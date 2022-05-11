
<cfcomponent displayname="Security" hint="establish security" output="true">

    <cffunction name="checkTestCookie" description="check if test cookie got set" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset arguments.event.setValue("loginFlag", "goodtogo") />

        <cfif NOT isDefined("cookie.cfsectrial")>
            <cfset arguments.event.setValue("loginFlag", "needscookies") />
        <cfelse>
            <cfif cookie.cfsectrial NEQ "good">
                <cfset arguments.event.setValue("loginFlag", "cookieerr") />
            </cfif>
        </cfif>

        <cfreturn />
    </cffunction>

    <cffunction name="loginUserAccess" description="validate that userid/password were passed and then call Security proxy to verify user has access" access="public" returntype="void" output="false">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <!--- set params --->
        <cfset client.authorized = "N">
        <cfset local.error0 = "">
        <cfset local.error1 = "">
        <cfset local.error2 = "">
        <cfset local.securedAreaName = arguments.event.getValue("securedAreaName")>
        <cfset local.userID = arguments.event.getValue("userID")>
        <cfset local.pw = arguments.event.getValue("pw")>

        <!--- Check to make sure a variable was passed. --->
        <cfif local.userID EQ "">
            <cfset local.error1 = URLEncodedFormat("You must enter a User ID")>
            <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('back')#&error1=#local.error1#&userID=#local.userID#" addtoken="no">
        </cfif>
        <cfif local.pw EQ "">
            <cfset local.error2 = URLEncodedFormat("You must enter a Password")>
            <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('back')#&error2=#local.error2#&userID=#local.userID#" addtoken="no">
        </cfif>

        <cfset client.userID = local.userID>
        <cfset client.pw = local.pw>

        <!--- Call Security Proxy --->
        <cftry>
            <cfset local.security = createObject("Java", "Csv001sc.Abean.Cssv01s1AuthorizationServer").init()>

            <!---- set imports for proxy call ---->
            <cfset local.security.setImportIsec1SecuredApplicationName(arguments.myFusebox.variables().this.appName)>
            <cfset local.security.setImportIsec1SecuredAreaName(local.securedAreaName)>
            <cfset local.security.setImportPasswordReqSecurityVerificationWorkPasswordRequired("N")>
            <cfset local.security.setImportRequestTypeSecurityVerificationWorkRequestType("CL")>
            <cfset local.security.setImportSoftwareUserId(JavaCast("string", client.userID))>

            <!---- execute the security proxy ---->
            <cfset local.security.setClientID(JavaCast("string", client.userID))>
            <cfset local.security.setClientPassword(JavaCast("string", client.pw))>
            <cfset local.security.execute()>
<cfoutput>#arguments.myFusebox.variables().this.appName# #local.securedAreaName# #local.security.getExportIsec1SecurityWorkReturnCode()# EQ 1 AND #local.security.getExportIsec1SecurityWorkReasonCode()# EQ 0</cfoutput>
            <cftry>
                <cfif local.security.getExportIsec1SecurityWorkReturnCode() EQ 1 AND local.security.getExportIsec1SecurityWorkReasonCode() EQ 0>
                    <cfset client.authorized = "Y">
                <cfelse>
                    <!--- User Does not have access to application or invalid password --->
                    <cfset local.error0 = URLEncodedFormat("Error: " & local.security.getExportIsec1SecurityWorkContextString())>
                    <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('back')#&error0=#local.error0#" addtoken="no">
                </cfif>
            <cfcatch type="any">
                <cfset local.error0 = URLEncodedFormat("Security call failed!<br />Error Details: " & local.security.getExportIsec1SecurityWorkContextString())>
                <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('back')#&error0=#local.error0#&userID=#local.userID#" addtoken="no">
            </cfcatch>
            </cftry>
        <cfcatch type="any">
            <cfset local.error0 = URLEncodedFormat("Security Object call failed!<br />Error Details: " & local.security.getExportIsec1SecurityWorkContextString())>
            <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('back')#&error0=#local.error0#&userID=#local.userID#" addtoken="no">
        </cfcatch>
        </cftry>

        <cfreturn>
    </cffunction>

    <cffunction name="loginActiveUser" description="encrypt user pw and insert user into active user table" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfif CompareNoCase(arguments.event.getValue("loginFlag"), "goodtogo") EQ 0 OR CompareNoCase(arguments.event.getValue("loginFlag"), "notLoggedIn") EQ 0>
            <cftry>
                <!--- Call stored procedure. It's wrapped in a cftry to catch bad passwords.
                 Encrypt the password for storage in the database --->
                <cfset local.IDNum15 = arguments.event.getValue("IDNum15") />
                <cfset local.actv_user_id = Numberformat(local.IDNum15, 999999999999999) />
                <cfset local.dsn = arguments.myFusebox.variables().this.datasource />
                <cfset local.appName = arguments.myFusebox.variables().this.appName />
                <cfset local.cfSecPwdKey = arguments.myFusebox.variables().this.cfSecPwdKey />
                <cfset local.qryActiveUser = userLoggedIn(arguments.myFusebox, arguments.event, client.userID)>

                <cftransaction>
                    <cftry>
                        <cfif local.qryActiveUser.recordcount EQ 0>
                            <cfset arguments.event.setValue("passwd_encrypt_txt", encrypt(client.pw, local.cfSecPwdKey, "Blowfish", "base64") ) />
                            <cfset arguments.event.setValue("actv_user_id", local.actv_user_id) />
                            <cfset arguments.event.setValue("sftwr_user_id", client.userID) />
                            <cfset arguments.event.setValue("command", "INSERT") />
                            <!--- to insert user into database call function modActiveUser --->
                            <cfset modActiveUser(arguments.myFusebox, arguments.event) />
                            <cfset arguments.event.setValue("loginFlag", "goodtogo") />
                        <cfelseif local.qryActiveUser.recordcount EQ 1>
                            <cfif local.qryActiveUser.expire LT now()>
                                <!--- If expiration time is within 1 hr. Reset their login expiration time --->
                                <!--- Applications get 1 hours set expir_tmstmp to "sysdate + 1/24" --->
                                <cfset arguments.event.setValue("sftwr_user_id", qryActiveUser.SFTWR_USER_ID) />
                                <cfset arguments.event.setValue("command", "UPDATE") />
                                <!--- to update user in db call function modActiveUser --->
                                <cfset modActiveUser(arguments.myFusebox, arguments.event) />
                                <cfset arguments.event.setValue("loginFlag", "goodtogo") />
                            <cfelse>
                                <cfset event.setValue("loginFlag", "doubleLogin") />
<!---                                 <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('doubleLogin')#&loginflag=#arguments.event.getValue('loginFlag')#" addtoken="no" /> --->
                            </cfif>
                        <cfelse>
                            <cfset event.setValue("loginFlag", "mustLogin") />
<!---                             <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('back')#&loginflag=#arguments.event.getValue('loginFlag')#" addtoken="no" /> --->
                        </cfif>
                        <cfcatch type="any">
                            <cftransaction action="rollback" />
                            <cfset event.setValue("loginFlag", "failed") />
                        </cfcatch>
                    </cftry>
                    <cftransaction action="commit" />
                </cftransaction>
            <cfcatch type="any">
                <cfset event.setValue("loginFlag", "failed") />
            </cfcatch>
            </cftry>
        </cfif>

        <cfreturn />
    </cffunction>

    <cffunction name="modActiveUser" description="insert, update or delete active user from db" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset local.command            = arguments.event.getValue("command") />
        <cfset local.actv_user_id       = arguments.event.getValue("actv_user_id") />
        <cfset local.passwd_encrypt_txt = arguments.event.getValue("passwd_encrypt_txt") />
        <cfset local.dsn                = arguments.myFusebox.variables().this.datasource />
        <cfset local.appName            = arguments.myFusebox.variables().this.appName />

        <cf_TsecStoredProc datasource="#local.dsn#" applicationname="#local.appName#" username="#client.userID#" password="#client.pw#">

        <cftry>
        <cfif local.command EQ 'INSERT'>
            <cfquery name="local.qryInsActiveUser" datasource="#local.dsn#" username="#client.userID#" password="#client.pw#">
                INSERT INTO SECUR_ACTV_USER
                (
                    actv_user_id,
                    sftwr_user_id,
                    appl_name,
                    login_tmstmp,
                    expir_tmstmp,
                    cf_token_num,
                    cf_id_num,
                    passwd_encrypt_txt
                )
                VALUES
                (
                    <cfqueryparam value="#local.actv_user_id#" cfsqltype="cf_sql_number" />,
                    <cfqueryparam value="#uCase(trim(client.userID))#" cfsqltype="cf_sql_varchar" />,
                    <cfqueryparam value="#uCase(trim(local.appName))#" cfsqltype="cf_sql_varchar" />,
                    sysdate,
                    sysdate + (60/1440),
                    <cfqueryparam value="#trim(cookie.cfsectoken)#" cfsqltype="cf_sql_number" />,
                    <cfqueryparam value="#trim(cookie.cfsecid)#" cfsqltype="cf_sql_number" />,
                    <cfqueryparam value="#local.passwd_encrypt_txt#" cfsqltype="cf_sql_varchar" />
                )
            </cfquery>
        <cfelseif local.command EQ 'UPDATE'>
            <cfquery name="local.qryUpdActiveUser" datasource="#local.dsn#" username="#client.userID#" password="#client.pw#">
                UPDATE
                    SECUR_ACTV_USER
                SET
                    expir_tmstmp = sysdate + (60/1440),
                    cf_token_num =  <cfqueryparam value="#trim(cookie.cfsectoken)#" cfsqltype="cf_sql_number" />,
                    cf_id_num = <cfqueryparam value="#trim(cookie.cfsecid)#" cfsqltype="cf_sql_number" />
                WHERE
                        sftwr_user_id = <cfqueryparam value="#uCase(trim(client.userID))#" cfsqltype="cf_sql_varchar" />
                    AND TRIM(appl_name) = <cfqueryparam value="#trim(local.appName)#" cfsqltype="cf_sql_varchar" />
            </cfquery>
        <cfelseif local.command EQ 'DELETE'>
            <cfquery name="local.qryDeleteActiveUser" datasource="#local.dsn#" username="#client.userID#" password="#client.pw#">
                DELETE FROM
                    SECUR_ACTV_USER
                WHERE
                        TRIM(sftwr_user_id) = <cfqueryparam value="#uCase(trim(client.userID))#" cfsqltype="cf_sql_varchar" />
                    AND TRIM(appl_name) = <cfqueryparam value="#trim(local.appName)#" cfsqltype="cf_sql_varchar" />
            </cfquery>
        </cfif>
        <cfcatch type="any">
            <cfdump var="#cfcatch#" abort="true">
        </cfcatch>
        </cftry>
        <cfreturn />
    </cffunction>

    <cffunction name="getSecuredComponent" description="validate that user has access to a specific secured component" access="public" returntype="any" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <!---- set default vars ---->
        <cfset local.securedAreaName = uCase(arguments.event.getValue("securedAreaName"))>

        <!--- verify access to secured component (BEGINS) ---->
        <cfset local.securedCN = createObject("Java", "Csv001sc.Abean.Cssv01s1AuthorizationServer").init()>

        <!---- set imports for proxy call ---->
        <cfset local.securedCN.setImportIsec1SecuredApplicationName(arguments.myFusebox.variables().this.appName)>
        <cfset local.securedCN.setImportIsec1SecuredAreaName(local.securedAreaName)>
        <cfset local.securedCN.setImportPasswordReqSecurityVerificationWorkPasswordRequired("N")>
        <cfset local.securedCN.setImportRequestTypeSecurityVerificationWorkRequestType("CL")>
        <cfset local.securedCN.setImportSoftwareUserId(JavaCast("string", client.userID))>

        <!---- execute the security proxy ---->
        <cfset local.securedCN.setClientID(JavaCast("string", client.userID))>
        <cfset local.securedCN.setClientPassword(JavaCast("string", client.pw))>
        <cfset local.securedCN.execute()>

        <!---- localize the secured component access struct passed in the event argument  ---->
        <cfset local.secStruct = arguments.event.getValue("secStruct")>

        <!---- set default count ---->
        <cfset local.dCompCount = 0>

        <!---- count the number of components in the secured area ---->
        <cfset local.compAreaCount = local.securedCN.getExportGroupCompForAreaCount()>

        <!---- check to see if user has access to all components (BEGINS) ---->
        <cfif local.securedCN.getExportIsec1SecurityWorkReturnCode() EQ 1>
            <cfif local.compAreaCount EQ 0>
            <!---- set securedCompAccess structure for ALL components to 'Y' ---->
                <cfloop collection="#local.secStruct.securedCompAccess#" item="local.Key">
                    <cfset StructUpdate(local.secStruct.securedCompAccess, local.Key, 'Y')>
                </cfloop>
            <cfelse>
                <!---- loop thur using compAreaCount ---->
                <!---- put ALL components into a structure setting authorization ---->
                <cfif local.compAreaCount GT 0>
                    <!---- secure component structure (BEGINS) ---->
                    <cfloop index="local.i" from="1" to="#local.compAreaCount#">
                        <!---- set secured component name into a local var ---->
                        <cfset local.compName = trim(local.securedCN.getExportGrpCompIsec1SecuredComponentName(local.dCompCount))>
                        <!---- set secured component authorization into a local var ---->
                        <cfset local.compAccess = local.securedCN.getExportGrpCompSecurityVerificationWorkAuthorized(local.dCompCount)>

                        <!---- dynamically update secured component struct (STARTS) ---->
                        <cfif structKeyExists(local.secStruct.securedCompAccess, local.compName)>
                            <cfset StructUpdate(local.secStruct.securedCompAccess, local.compName, local.compAccess)>
                        <cfelse> <!--- sometimes a new component can be added but it isn't in the code yet --->
                            <cfset local.secStruct.securedCompAccess[local.compName] = local.compAccess>
                        </cfif>
                        <!---- dynamically update secured component struct (ENDS) ---->

                        <!---- advance counter by 1 ---->
                        <cfset local.dCompCount = local.dCompCount + 1>
                    </cfloop>
                    <!---- secure component structure (ENDS) ---->
                </cfif>
            </cfif>
        <cfelse>
            <!---- Not allowed in here so set securedCompAccess structure for ALL components to 'N' ---->
            <cfloop collection="#local.secStruct.securedCompAccess#" item="local.Key">
                <cfset StructUpdate(local.secStruct.securedCompAccess, local.Key, 'N')>
            </cfloop>
        </cfif>

        <!---- set error messages ---->
        <cfset local.secStruct.returnCode = local.securedCN.getExportIsec1SecurityWorkReturnCode()>
        <cfset local.secStruct.reasonCode = local.securedCN.getExportIsec1SecurityWorkReasonCode()>
        <cfset local.secStruct.msg        = local.securedCN.getExportIsec1SecurityWorkContextString()>

        <!---- check to see if user has access to all components (ENDS) ---->
        <cfreturn local.secStruct>
    </cffunction>

    <cffunction name="getSecuredAreaAccess" description="validate that user has access to a specific secured area" access="public" returntype="any" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <!---- set default vars ---->
        <cfset local.securedAreaName = uCase(arguments.event.getValue("securedAreaName"))>
        <cfset local.securedAreaAccess = "false">

        <!--- create proxy object --->
        <cfset local.security = createObject("Java", "Csv001sc.Abean.Cssv01s1AuthorizationServer").init()>

        <!---- set imports for proxy call ---->
        <cfset local.security.setImportIsec1SecuredApplicationName(arguments.myFusebox.variables().this.appName)>
        <cfset local.security.setImportIsec1SecuredAreaName(local.securedAreaName)>
        <cfset local.security.setImportPasswordReqSecurityVerificationWorkPasswordRequired("N")>
        <cfset local.security.setImportRequestTypeSecurityVerificationWorkRequestType("CL")>
        <cfset local.security.setImportSoftwareUserId(JavaCast("string", client.userID))>

        <!---- execute the security proxy ---->
        <cfset local.security.setClientID(JavaCast("string", client.userID))>
        <cfset local.security.setClientPassword(JavaCast("string", client.pw))>
        <cfset local.security.execute()>


        <cfif local.security.getExportIsec1SecurityWorkReturnCode() EQ 1 AND local.security.getExportIsec1SecurityWorkReasonCode() EQ 0>
            <cfset local.securedAreaAccess = "true">
        </cfif>

        <cfreturn local.securedAreaAccess>
    </cffunction>

    <cffunction name="Logout" description="logout user" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfif structKeyExists(client, "userID")>
            <cftransaction>
                <cftry>
                  <cfset arguments.event.setValue("sftwr_user_id", client.userID) />
                  <cfset arguments.event.setValue("command", "DELETE") />

                  <!--- to delete user from database call function modActiveUser --->
                  <cfset modActiveUser(arguments.myFusebox, arguments.event) />

                  <cfcatch type="any">
                      <cftransaction action="rollback" />
                      <cfset local.loginflag = "failed">
                      <cfrethrow>
                  </cfcatch>
                </cftry>

                <cftransaction action="commit" />

             </cftransaction>
        </cfif>

        <!--- Delete all client variables used during this session --->
        <cfloop list="#GetClientVariablesList()#" index="local.i">
            <cfset DeleteClientVariable("#local.i#") />
        </cfloop>

        <!--- Place CFSECID and CFSECTOKEN as cookies on the users machine and expire them --->
        <cfcookie name="cfsecid" value="" />
        <cfcookie name="cfsectoken" value="" />
        <cfset StructDelete(cookie, "cfsecid")>
        <cfset StructDelete(cookie, "cfsectoken")>
        <cfset StructDelete(request, "cfsecid")>
        <cfset StructDelete(request, "cfsectoken")>

        <cfset arguments.event.setValue("loginflag", "logout")>
       <cfreturn />
    </cffunction>

    <!--- START checkCookies function --->
    <cffunction name="checkCookies" displayname="checkCookies" hint="check if user is already logged in" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset arguments.event.setValue("cookieStat", "goodToGo")>

        <!--- Surround the following in a cftry and cfcatch incase anything goes wrong,
          user will be redirected to the log in page. This will check for existing
          cookies and see if the user is already logged into eAgenda --->
        <cftry>
            <cfif isdefined("cookie.cfsecid")    AND cookie.cfsecid    NEQ "" AND
                  isdefined("cookie.cfsectoken") AND cookie.cfsectoken NEQ "" AND
                  structKeyExists(client, "userID")>
                <!--- Query the database to see if the cookies are in the activ_user table and still valid. --->
                <cfset local.qryCheckLogin = userLoggedIn(arguments.myFusebox, arguments.event, "", cookie.cfsecid, cookie.cfsectoken)>

                <cfif local.qryCheckLogin.Recordcount gt 0>
                    <!--- The cookies are in the table. --->
                    <cfif compareNoCase(local.qryCheckLogin.appl_name, arguments.myFusebox.variables().this.appName) EQ 0 AND
                          local.qryCheckLogin.expiration GT now()>
                        <!--- The session has not expired yet. Send them to the already logged in page. --->
                        <cfset arguments.event.setValue("cookieStat", "doubleLogin")>
                    <cfelseif compareNoCase(local.qryCheckLogin.appl_name, arguments.myFusebox.variables().this.appName) EQ 0 AND
                              local.qryCheckLogin.expiration LT now()>
                        <cfset arguments.event.setValue("cookieStat", "expiredTime")>
                    <cfelse>
                        <!--- they are logged in to another application and the same cookies got generated, let it slide --->
                    </cfif> <!--- end check expiration time --->
                <cfelse>
                    <!--- nothing in the DB that goes with these so get rid of them --->
                    <cfcookie name="cfsecid" value="" />
                    <cfcookie name="cfsectoken" value="" />
                    <cfset StructDelete(cookie, "cfsecid")>
                    <cfset StructDelete(cookie, "cfsectoken")>
                    <cfset StructDelete(request, "cfsecid")>
                    <cfset StructDelete(request, "cfsectoken")>
                    <cfset arguments.event.setValue("cookieStat", "mustlogin")>

                </cfif> <!--- end check recordcount of query --->
            <cfelse>
                <!--- no cookie so must log in --->
                <cfset arguments.event.setValue("cookieStat", "mustlogin")>
            </cfif> <!--- end check for existence cfsecid and cfsectoken--->

            <cfcatch type="any">
                <!--- The only error for this would be if their cookies are messed up.  So get rid of them. --->
                <cfcookie name="cfsecid" value="" />
                <cfcookie name="cfsectoken" value="" />
                <cfset StructDelete(cookie, "cfsecid")>
                <cfset StructDelete(cookie, "cfsectoken")>
                <cfset StructDelete(request, "cfsecid")>
                <cfset StructDelete(request, "cfsectoken")>
            </cfcatch>
        </cftry>

        <cfreturn />

    </cffunction>
    <!--- END checkCookies function --->

    <!--- START setTestCookie function --->
    <cffunction name="setTestCookie" displayname="setTestCookie" hint="set a small cookie that will be checked later on to see if user has cookies enabled." access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfcookie name="cfsectrial" value="good" domain="#arguments.myFusebox.variables().this.domain#" />

        <cfreturn />

    </cffunction>
    <!--- END setTestCookie function --->

    <cffunction name="userLoggedIn" returntype="query" access="private">
        <cfargument name="myFusebox"  type="struct"  required="true" />
        <cfargument name="event"      type="struct"  required="true" />
        <cfargument name="userID"     type="string"  required="false" default="">
        <cfargument name="cfsecid"    type="numeric" required="false" default="0">
        <cfargument name="cfsectoken" type="numeric" required="false" default="0">

        <cfset arguments.userID     = uCase(trim(arguments.userID))>
        <cfset arguments.cfsecidrID = trim(arguments.cfsecid)>
        <cfset arguments.cfsectoken = trim(arguments.cfsectoken)>

        <cfif arguments.userID EQ "">
            <cfif arguments.cfsecid EQ 0 OR arguments.cfsectoken EQ 0>
                <cfthrow type="applName" message="Missing Parameters" detail="Security.userLoggedIn requires userID and applName or cfsecid and cfsectoken or all four.">
            </cfif>
        </cfif>

       <cfquery name="local.qrCheckLogin"  datasource="#arguments.myFusebox.variables().this.datasource#" username="#arguments.myFusebox.variables().this.dbUser#" password="#arguments.myFusebox.variables().this.dbPW#">
              select
                  sau.ACTV_USER_ID,
                  sau.SFTWR_USER_ID,
                  sau.appl_name,
                  sau.LOGIN_TMSTMP,
                  sau.CF_TOKEN_NUM,
                  sau.CF_ID_NUM,
                  sau.PASSWD_ENCRYPT_TXT,
                  to_char(sau.expir_tmstmp, 'yyyy-mm-dd hh24:mi:ss') expire
              from
                  secur_actv_user sau
              where
                  1 = 1
                  <cfif arguments.userID NEQ "">
                      AND sau.sftwr_user_id = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_varchar">
                      AND sau.appl_name = <cfqueryparam value="#arguments.myFusebox.variables().this.appName#" cfsqltype="cf_sql_varchar">
                  </cfif>
                  <cfif arguments.cfsectoken NEQ "0">
                      AND cf_token_num = <cfqueryparam value="#arguments.cfsectoken#" cfsqltype="cf_sql_numeric">
                      AND cf_id_num    = <cfqueryparam value="#arguments.cfsecid#" cfsqltype="cf_sql_numeric">
                  </cfif>
        </cfquery>

        <cfreturn local.qrCheckLogin>

    </cffunction>

    <cffunction name="getSecuredProxyCrProgramDropDown" description="proxy call that gets list of programs the user is authorized to, based on the CR program level security" access="public" returntype="any" output="true">
        <cfargument name="dsn" type="string" required="true">
        <cfargument name="dsnUN" type="string" required="true">
        <cfargument name="dsnPW" type="string" required="true">

         <!---- CR program level security proxy call (BEGINS) ---->
         <cfset local.crPgmListObj = createObject("Java", "Crm006sc.Abean.Crmr5100AdditionalIdDetail").init()>
         <cfset local.crPgmListObj.setClientID(JavaCast("string", client.userID))>
         <cfset local.crPgmListObj.setClientPassword(JavaCast("string", client.pw))>

         <!---- set imports for proxy call ---->
         <cfset local.crPgmListObj.setCommandSent("NEW")>

         <!---- execute the proxy ---->
         <cfset local.crPgmListObj.execute()>
         <!---- CR program level security proxy call (ENDS) ---->

         <!---- if no proxy errors build array (BEGINS) ---->
         <cfif local.crPgmListObj.getExportIerr1FormattedErrorReturnCode() EQ 1>
             <cfset local.pgm_count = local.crPgmListObj.getExportGroupPiCount()>
             <cfset local.pgm_loop = local.pgm_count - 1>

             <!---- start array ---->
             <cfset local.arPgmsorg = arrayNew(2)>

             <cfif local.pgm_count NEQ 0>
                 <!---- loop thru proxy result, run query, and set array ---->
                 <cfloop from="0" to="#local.pgm_loop#" index="local.i">
                     <cfset local.arPgmsorg[ArrayLen(local.arPgmsorg)+1][1] = Numberformat(local.crPgmListObj.getExportGPiIpgm1ProgramId(local.i),'999999999999999')>
                     <cfset local.arPgmsorg[ArrayLen(local.arPgmsorg)][2] = local.crPgmListObj.getExportGPiIpgm1ProgramCode(local.i)>

                     <!---- get program name ---->
                     <cfquery name="qryPgmName" datasource="#arguments.dsn#" username="#arguments.dsnUN#" password="#arguments.dsnPW#">
                         select
                             pgm_name from pg_program
                         where
                             pgm_id = <cfqueryparam value="#Numberformat(local.crPgmListObj.getExportGPiIpgm1ProgramId(local.i),'999999999999999')#" cfsqltype="cf_sql_number">
                     </cfquery>

                     <!---- add program name to array ---->
                     <cfset local.arPgmsorg[ArrayLen(arPgmsorg)][3] = qryPgmName.pgm_name>
                     <cfset local.arPgmsorg[ArrayLen(arPgmsorg)][4] = ''>
                 </cfloop>
             </cfif>

             <!---- start array ---->
             <cfset local.arPgms = arrayNew(2)>

             <!---- loop thru and set array ---->
             <cfloop from="1" to="#arraylen(local.arpgmsorg)#" index="local.i">
                 <!---- set default program access ---->
                 <cfset local.pgm_found = 'N'>

                 <!---- check if user has access to programs ---->
                 <cfloop from="1" to="#arraylen(local.arpgms)#" index="local.j">
                     <!---- update program access ---->
                     <cfif #local.arpgms[local.j][1]# EQ #local.arpgmsorg[local.i][1]#>
                         <cfset local.pgm_found = 'Y'>
                         <cfbreak>
                     </cfif>
                 </cfloop>

                 <cfif local.pgm_found EQ 'N'>
                     <cfset local.arPgms[ArrayLen(local.arPgms)+1][1] = local.arPgmsorg[i][1]>
                     <cfset local.arPgms[ArrayLen(local.arPgms)][2] = local.arPgmsorg[i][2]>
                     <cfset local.arPgms[ArrayLen(local.arPgms)][3] = local.arPgmsorg[i][3]>
                 </cfif>
             </cfloop>

             <!---- update array ---->
             <cfloop from="1" to="#arrayLen(local.arPgms)#" index="local.i">
                 <cfswitch expression="2">
                     <cfcase value="1">
                         <cfset arPgms[local.i][4] = "#local.arPgms[local.i][1]# - #local.i#">
                     </cfcase>

                     <cfcase value="2">
                         <cfset arPgms[local.i][4] =  "#local.arPgms[local.i][2]# - #local.i#">
                     </cfcase>

                     <cfcase value="3">
                         <cfset arPgms[local.i][4] =  "#local.arPgms[local.i][3]# - #local.i#">
                     </cfcase>
                 </cfswitch>
             </cfloop>

             <!---- set temp array ---->
             <cfset local.tempmasarray = arraynew(1)>

             <!---- loop thru and set temp array ---->
             <cfloop from="1" to="#arraylen(local.arPgms)#" index="local.i">
                 <cfset local.tempmasarray[local.i] = local.arPgms[local.i][4]>
             </cfloop>

             <!---- sort array (ASC) ---->
             <cfset arraysort(local.tempmasarray, "textnocase")>

             <!---- set array ---->
             <cfset local.arsortedpgm = arraynew(2)>

             <!---- loop thru and set a array in alphabetical  order ---->
             <cfloop from="1" to="#arraylen(local.tempmasarray)#" index="local.i">
                 <cfloop from="1" to="#arraylen(local.arPgms)#" index="local.i2">
                     <cfif local.tempmasarray[local.i] EQ local.arPgms[local.i2][4]>
                         <cfset local.arsortedpgm[local.i] = local.arPgms[local.i2]>
                         <cfbreak>
                     </cfif>
                 </cfloop>
             </cfloop>
         </cfif>
         <!---- if no proxy errors build array (ENDS) ---->

        <cfreturn local.arsortedpgm />
    </cffunction>

    <cffunction name="getSecuredSQLCrProgramDropDown" description="sql call that gets all programs" access="public" returntype="struct" output="true">
        <cfargument name="dsn" type="string" required="true">
        <cfargument name="dsnUN" type="string" required="true">
        <cfargument name="dsnPW" type="string" required="true">

         <!--- initialize return structure --->
         <cfset local.rtnStruct = {resultSet = ""}>

         <!---- get full list of cr programs ---->
         <cfquery name="local.getCrPrograms" datasource="#arguments.dsn#" username="#arguments.dsnUN#" password="#arguments.dsnPW#">
             SELECT TRIM(pgm_id) AS pgm_id
                , TRIM(pgm_cd) AS pgm_cd
                , TRIM(pgm_name) AS pgm_name
             FROM pg_program
             WHERE pgm_typ_ind_txt <> 'H'
                 AND pgm_end_dt = TO_DATE('12/31/3000', 'MM/DD/YYYY')
             ORDER BY pgm_name
         </cfquery>

         <!---- update return struct with qry results ---->
         <cfset local.rtnStruct.resultSet = local.getCrPrograms>

        <cfreturn local.rtnStruct />
    </cffunction>

    <cffunction name="checkSec" output="false" access="public" returntype="struct" >
        <cfargument name="myFusebox"         type="struct" required="true" hint="The Fusebox structure">
        <cfargument name="event"             type="struct" required="true" hint="The event structure">
        <cfargument name="securedAreaName"   type="string" required="true">
        <cfargument name="securedComponents" type="struct" required="true">

        <cfset local.secStruct = StructNew()>
        <cfset local.secStruct.securedCompAccess = arguments.securedComponents>
        <cfset arguments.event.setValue("secStruct", local.secStruct)>
        <cfset arguments.event.setValue("securedAreaName", arguments.securedAreaName)>

        <cfset local.secStruct = getSecuredComponent(arguments.myFusebox, arguments.event)>

        <cfreturn local.secStruct>

    </cffunction>

</cfcomponent>
