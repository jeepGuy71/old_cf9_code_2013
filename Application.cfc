

<!--- this line needs to be customized per environment --->
<cfcomponent extends="fusebox5.Application" output="false">
    <cfscript>
        // all items in the this scope are accessible from myFusebox.variables().this

        //set application name based on the directory path
        this.name = right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'), 64);

        this.sessionManagement = true;
        this.ApplicationTimeout = CreateTimeSpan(1, 0, 0, 0);
        this.SessionTimeout = CreateTimeSpan(0, 0, 1, 0);
        this.SessionManagement = true;
        this.ClientManagement = true;
        this.SetDomainCookies = false;
        this.datasource = "enf";
        this.dbUser = "webuser";
        this.dbPW = "webuser";
        this.appCode = "EAG";
        this.appName = "EAGENDA";
        this.fullAppName = "eAgenda";
        this.domain = ".tceq.texas.gov";
        this.LoginSecuredAreaName = "LOGON";
        this.cfSecPwdKey="d4WEY4EdLuTlHyTzShLBUw==";
		this.uploadpath = "H:\uploads\eagenda";

        // must enable implicit (no-XML) mode!
        FUSEBOX_PARAMETERS.allowImplicitFusebox = true;

        // the rest is taken straight from the traditional fusebox.xml skeleton:
        FUSEBOX_PARAMETERS.defaultFuseaction = "eAgenda.EAGC0100eAgendaLogin";
        // you may want to change this to development-full-load mode:
        // FUSEBOX_PARAMETERS.mode = "development-circuit-load";
        FUSEBOX_PARAMETERS.mode = "development-full-load";
        // FUSEBOX_PARAMETERS.mode = "production";
        FUSEBOX_PARAMETERS.conditionalParse = true;
        // change this to something more secure:
        FUSEBOX_PARAMETERS.password = "";
        FUSEBOX_PARAMETERS.strictMode = true;
        FUSEBOX_PARAMETERS.debug = true;
        // we use the core file error templates:
        FUSEBOX_PARAMETERS.errortemplatesPath = "/fusebox5/errortemplates/";

        // These are all default values that can be overridden:
        FUSEBOX_PARAMETERS.fuseactionVariable = "fuseaction";
        // FUSEBOX_PARAMETERS.precedenceFormOrUrl = "form";
        // FUSEBOX_PARAMETERS.scriptFileDelimiter = "cfm";
        // FUSEBOX_PARAMETERS.maskedFileDelimiters = "htm,cfm,cfml,php,php4,asp,aspx";
        // FUSEBOX_PARAMETERS.characterEncoding = "utf-8";
        // FUSEBOX_PARAMETERS.strictMode = false;
        // FUSEBOX_PARAMETERS.allowImplicitCircuits = false;

        // force the directory in which we start to ensure CFC initialization works:
        FUSEBOX_CALLER_PATH = getDirectoryFromPath(getCurrentTemplatePath());
    </cfscript>

    <cfsetting requesttimeout="300" showdebugoutput="#FUSEBOX_PARAMETERS.debug#" enablecfoutputonly="false" />

    <!---
        if you define any onXxxYyy() handler methods, remember to start by calling
            super.onXxxYyy(argumentCollection=arguments)
        so that Fusebox's own methods are executed before yours
    --->

    <cffunction name="onFuseboxApplicationStart" output="false">
        <cfset super.onFuseboxApplicationStart() />

        <!--- code formerly in fusebox.appinit.cfm or the appinit global fuseaction --->
        <cfset myFusebox.getApplicationData().startTime = now() />

		<cfset application.jsPath       = "includes/js" />
        <cfset application.jQueryPath   = "#application.jsPath#/jQuery" />
        <cfset application.jQueryUIPath = "#application.jsPath#/jQueryUI" />
        <cfset application.jQueryFile   = "#application.jQueryPath#/jquery-1.9.0.js" />
        <cfset application.jQueryUIFile = "#application.jQueryUIPath#/jquery-ui-1.10.0.custom.min.js" />
        <cfset application.jQueryValid  = "#application.jQueryPath#/plugins/jquery.validate.min.js" />
        <cfset application.jQueryUICSS  = "#application.jQueryUIPath#/css/smoothness/jquery-ui-1.10.0.custom.min.css" />

		<cfset application.cssPath = "includes/css" />
		<cfset application.images = "includes/images" />

        <!--- Fuseactions that are not added to the navigation stack, ever --->
        <cfset application.fuseNoStack = "security,cancel,redirect,back,return,clear">

        <!--- NOTE: THIS IS BEING LOADED IN TO APPLICATION SCOPE. YOU WILL NEED TO FORCE A RELOAD BY PASSING IN THE CORRECT URL VARIABLES
                IF ANYTHING CHANGES IN THIS CFC --->

        <cfif !structKeyExists(application, "utilsObj") OR
              (structKeyExists(url, "reload") AND structKeyExists(url, "pw") AND compareNoCase(url.pw, myFuseBox.variables().fusebox_parameters.password) EQ 0)>
            <cflock scope="Application" timeout="5" throwontimeout="true" type="exclusive">
                <cfset application.utilsObj = new com.utils()>
            </cflock>
        </cfif>
    </cffunction>

    <cffunction name="onRequestStart" output="false">
        <cfargument name="targetPage" />

        <cfset super.onRequestStart(arguments.targetPage) />

		<cfset request.displaytimer = 'yes' />
		<cfset request.navBarTitle = 'eAgenda' />

		<!--- Set Variables based on Environment --->
		<cfif FindNoCase("dev",cgi.server_name)>
		    <!--- allow debug --->
            <cfsetting showdebugoutput="true" />

            <!--- Set this to be the title you want displayed in the html title tag --->
	        <cfset request.browserTitle  = "Texas Commission on Environmental Quality - eAgenda - DEV" />
	        <cfset request.webserviceloc = "http://www10dev/cbt/services" />
	        <cfset request.environment   = "Development" />
            <cfset request.comCfg        = "TCP tceq4sprhgend1 3301">
            <cfset request.webserviceloc = "http://www10dev/cbt/services">
		<cfelseif FindNoCase("et",cgi.server_name) OR FindNoCase("ut",cgi.server_name)>
	        <!--- turn debug off --->
	        <cfsetting showdebugoutput="false" />

            <!--- Set this to be the title you want displayed in the html title tag --->
	        <cfset request.browserTitle  = "Texas Commission on Environmental Quality - eAgenda - USER TEST" />
	        <cfset request.webserviceloc = "http://www10tst" & Right(machinename,1) & ".tceq.state.tx.us/cbt/services" />
	        <cfset request.environment   = "User Test">
            <cfset request.comCfg        = "TCP TCEQ-VIP-GENT 3301">
            <cfset request.webserviceloc = "http://www10tst#variables.machineNumber#.tceq.state.tx.us/cbt/services">
		<cfelseif FindNoCase("ext",cgi.server_name) OR FindNoCase("prd",cgi.server_name) or FindNoCase("agm2.tceq.state.tx.us",cgi.server_name)>
	        <!--- turn debug off --->
	        <cfsetting showdebugoutput="false" />

            <!--- Set this to be the title you want displayed in the html title tag --->
	        <cfset request.browserTitle  = "Texas Commission on Environmental Quality - eAgenda" />
	        <cfset request.webserviceloc = "http://www10ext" & Right(machinename,1) & ".tceq.state.tx.us/cbt/services" />
	        <cfset request.environment   = "Production" />
            <cfset request.comCfg        = "TCP TCEQ-VIP-GENP 3301">
            <cfset request.webserviceloc = "http://www10ext#variables.machineNumber#.tceq.state.tx.us/cbt/services">
	    </cfif>

    </cffunction>

    <cffunction name="onError">
        <cfargument name="exception" />
        <cfset super.onError(arguments.exception) />
    </cffunction>
</cfcomponent>
