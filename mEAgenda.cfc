
<cfcomponent displayname="mEAgenda" hint="main model circuit for eAgenda" output="false">

    <cffunction name="Security" description="establish security" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset arguments.event.setValue("securedAreaName", "LOGON")>

        <cfset local.secObj = new com.Security()>
        <cfset local.secObj.loginUserAccess(argumentCollection:arguments)>
        <cfset arguments.event.setValue("IDNum15" , application.utilsObj.generate15DigitID())>
        <cfset event.setValue("loginFlag", "notLoggedIn")>
        <cfset local.secObj.loginActiveUser(argumentCollection:arguments)>

        <!--- set default user type --->
        <cfset client.userType = "">

        <!--- determine if user is in OGC and set client var --->
        <cfset local.getUserDiv = getStaffMemInfo(myFusebox:arguments.myFusebox, event:arguments.event, SFTWR_USER_ID:client.userID)>
        <cfset local.qryUserDiv = local.getUserDiv.resultSet>
        <cfif local.qryUserDiv.recordCount GT 0>
            <cfswitch expression="#local.qryUserDiv.title_cd#">
                <cfcase value="COUNSEL,COUNSELA">
                    <cfset client.userType = "OGC">
                </cfcase>
            </cfswitch>
        </cfif>

        <!--- get user's role and determine if on Agenda Team or in Enforcement and set client var --->
        <cfset local.getUserRole = getStaffMemInfo(arguments.myFusebox, arguments.event, client.userID, "true")>
        <cfset local.qryUserRole = local.getUserRole.resultSet>
        <cfif local.qryUserRole.recordCount GT 0>
            <cfloop query="local.qryUserRole">
                <cfswitch expression="#local.qryUserRole.role_cd#">
                    <cfcase value="AGENDA TM">
                        <cfset client.userType = "agendaTm">
                    </cfcase>
                    <cfcase value="INVESTIGAT,ENFCOORDIN">
                        <cfif client.userType NEQ "agendaTm" AND client.userType NEQ "OGC">
                            <cfset client.userType = "enforce">
                        </cfif>
                    </cfcase>
                </cfswitch>
                <cfbreak>
            </cfloop>
        </cfif>

        <!--- If not Agenda team, Enforcement, or OGC, then user is part of the Program Area team --->
        <cfif client.userType EQ "">
            <cfset client.userType = "progArea">
        </cfif>

        <cfif compareNoCase(event.getValue('loginFlag'), "goodToGo") NEQ 0>
            <cfset arguments.myFusebox.do("eAgenda.logout")>
        </cfif>

        <cfreturn>

    </cffunction>




    <cffunction name="mEAGC0200agendaItems" description="gets data for Program Area Team landing page" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <!--- *** START AWAITING AGENDA REQUEST SECTION *** --->
        <cfset local.awaitAgendaReqList = getFullAgendaLists(arguments.myFusebox, arguments.event, "ACTIVE", "ITEM", "AWAITING AGENDA REQUEST LIST SIZE")>
        <cfset arguments.event.setValue("awaitAgendaReqList", local.awaitAgendaReqList)>
        <!--- ** END AWAITING AGENDA REQUEST SECTION ** --->


        <!--- *** START RETURNED AGENDA REQUEST SECTION *** --->
        <cfset local.returnedAgendaReqList = getFullAgendaLists(arguments.myFusebox, arguments.event, "RETURNED", "AGENDA", "RETURNED AGENDA REQUEST LIST SIZE")>
        <cfset arguments.event.setValue("returnedAgendaReqList", local.returnedAgendaReqList)>
        <!--- ** END RETURNED AGENDA REQUEST SECTION ** --->


        <!--- *** START DOCKET NUMBER REQUESTED SECTION *** --->
        <cfset local.docketNumReqList = getFullAgendaLists(arguments.myFusebox, arguments.event, "PENDING", "ITEM", "DOCKET NUMBER REQUESTED LIST SIZE")>
        <cfset arguments.event.setValue("docketNumReqList", local.docketNumReqList)>
        <!--- ** END DOCKET NUMBER REQUESTED SECTION ** --->

        <cfreturn>
    </cffunction>

    <cffunction name="mEAGC0300workQueue" description="gets data for work queue Agenda Team landing page" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <!--- *** START DOCKET NUMBER REQUESTED SECTION *** --->
        <cfset local.docketNumReqList = getFullAgendaLists(arguments.myFusebox, arguments.event, "PENDING", "ITEM", "DOCKET NUMBER REQUESTED LIST SIZE")>
        <cfset arguments.event.setValue("docketNumReqList", local.docketNumReqList)>
        <!--- ** END DOCKET NUMBER REQUESTED SECTION ** --->


        <!--- *** START ITEM APPROVAL REQUESTED SECTION *** --->
        <cfset local.itemApprvReqList = getFullAgendaLists(arguments.myFusebox, arguments.event, "REQUESTED", "AGENDA", "ITEM APPROVAL REQUEST LIST SIZE")>
        <cfset arguments.event.setValue("itemApprvReqList", local.itemApprvReqList)>
        <!--- ** END ITEM APPROVAL REQUESTED SECTION ** --->


        <!--- *** START AGENDA DATE REQUIRED SECTION *** --->
        <cfset local.agendaDtReqList = getFullAgendaLists(arguments.myFusebox, arguments.event, "PENDING" , "AGENDA", "AGENDA DATE REQUIRED LIST SIZE")>
        <cfset arguments.event.setValue("agendaDtReqList", local.agendaDtReqList)>

        <!---- get agency lock days ---->
        <cfset local.qryAgencyLockDays = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event ,'CID EAGENDA DEFAULTS','AGENCY LOCK DAYS')>
        <cfset local.agencyLockDays = local.qryAgencyLockDays.resultset.DESC_TXT>

        <!--- get agenda dates --->
        <cfset local.qryAgendaDates = getAgendaDates(arguments.myFusebox, arguments.event, local.agencyLockDays)>
        <cfset arguments.event.setValue("qryAgendaDates", local.qryAgendaDates.resultSet)>
        <!--- ** END AGENDA DATE REQUIRED SECTION ** --->

        <cfreturn>
    </cffunction>

    <cffunction name="mEAGC0300workQueueSave" displayname="mEAGC0300workQueueSave" description="update agenda item status from work queue page submit" access="public" returntype="struct" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset local.attributes = arguments.MyFusebox.variables().attributes>

        <!--- initialize return structure --->
        <cfset local.rtnStruct = {errorID = 0, errorMSG = "", success = "", returnCode = "", reasonCode = "", agendaItemID = "", agendaID = ""}>
        <!--- ERROR IDs:
            4 = proxy error, check return and reason codes
            5 = form returns no values --->

        <cfset local.formValsStruct = structNew()>
        <cfloop list="#local.attributes.fieldNames#" index="local.i">
            <cfif TRIM(local.attributes[local.i]) GT 0>
                <cfset local.formValsStruct["#local.i#"] = TRIM(local.attributes[local.i])>
            </cfif>
        </cfloop>

        <cfif !structIsEmpty(local.formValsStruct)>
            <!--- loop over the list of agenda items to be updated and use proxy to update them in the db --->
            <cfset local.index = 0>
            <cfset local.cnt = 1>
            <cfloop collection="#local.formValsStruct#" item="local.agendaItemID">
                <!--- create proxy object ---->
                <cfset local.wqSubmitObj = createObject("Java", "Cid008sc.Abean.Cidr7300WorkQueue").init() />

                <!--- set proxy values --->
                <cfset local.wqSubmitObj.setImportApplicationTnrccCommonWorkApplicationName(arguments.myFusebox.variables().this.appName)>
                <cfset local.wqSubmitObj.setImportGroupCount(local.cnt)>
                <cfset local.wqSubmitObj.setImportGrpIagn1AgendaId(local.index, JavaCast("double", TRIM(local.formValsStruct[local.agendaItemID])))>
                <cfset local.wqSubmitObj.setImportGrpIagn1AgendaItemId(local.index, JavaCast("double", TRIM(local.agendaItemID)))>
                <cfset local.wqSubmitObj.setClientID(JavaCast("string", client.userID)) />
                <cfset local.wqSubmitObj.setClientPassword(JavaCast("string", client.pw)) />
                <cfset local.wqSubmitObj.setCommandSent('UPDATE')>

                <!---- execute the proxy ---->
                <cfset local.wqSubmitObj.execute()>

                <!--- populate return struct based on proxy outcome --->
                <cfif local.wqSubmitObj.getExportIerr1FormattedErrorReturnCode() EQ 1 AND local.wqSubmitObj.getExportIerr1FormattedErrorReasonCode() EQ 0>
                    <cfset local.rtnStruct.success = ListAppend(local.rtnStruct.success, "Y")>
                    <cfset local.rtnStruct.errorID = ListAppend(local.rtnStruct.errorID, 0)>
                    <!--- populate return struct with proxy output --->
                    <cfset local.rtnStruct.returnCode = ListAppend(local.rtnStruct.returnCode, local.wqSubmitObj.getExportIerr1FormattedErrorReturnCode())>
                    <cfset local.rtnStruct.reasonCode = ListAppend(local.rtnStruct.reasonCode, local.wqSubmitObj.getExportIerr1FormattedErrorReasonCode())>
                <cfelse>
                    <cfset local.rtnStruct.success = ListAppend(local.rtnStruct.success, "N")>
                    <cfset local.rtnStruct.errorID = ListAppend(local.rtnStruct.errorID, 4)>
                    <!--- populate return struct with proxy output --->
                    <cfset local.rtnStruct.returnCode = ListAppend(local.rtnStruct.returnCode, local.wqSubmitObj.getExportIerr1FormattedErrorReturnCode())>
                    <cfset local.rtnStruct.reasonCode = ListAppend(local.rtnStruct.reasonCode, local.wqSubmitObj.getExportIerr1FormattedErrorReasonCode())>
                    <cfset local.rtnStruct.errorMSG = ListAppend(local.rtnStruct.errorMSG, local.wqSubmitObj.getExportIerr1FormattedErrorFormattedErrorMessage())>
                    <cfset local.rtnStruct.agendaItemID = ListAppend(local.rtnStruct.agendaItemID, TRIM(local.agendaItemID))>
                    <cfset local.rtnStruct.agendaID = ListAppend(local.rtnStruct.agendaID, TRIM(local.formValsStruct[local.agendaItemID]))>
                </cfif>
                <cfset local.index++>
                <cfset local.cnt++>
            </cfloop>
        <cfelse>
            <!--- trap errors and return information in structure so calling application can decide what to do about it --->
            <cfset local.rtnStruct.success     = "N">
            <cfset local.rtnStruct.errorID     = 5>
            <cfset local.rtnStruct.errorMSG    = "No agenda dates were selected">
            <cfreturn local.rtnStruct>
        </cfif>


        <cfset local.rtnStruct.resultSet = local.formValsStruct>

        <cfreturn local.rtnStruct>
    </cffunction>






    <cffunction name="mEAGC0700GetAgendaStatus" displayname="mEAGC0700GetAgendaStatus" description="displays agenda status" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <!---- set defaults vars ---->
        <cfset local.attributes = myfusebox.variables()>
        <cfset local.mode = isDefined("local.attributes.attributes.mode") ? local.attributes.attributes.mode : "">
        <cfset local.agenda_ID = isDefined("local.attributes.attributes.id") ? local.attributes.attributes.id : 0>


        <!---- call cfc/methods and set return values (BEGINS) ---->
        <cfset local.qryAgendaStatus = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,"CID AGENDA STATUS","","name_txt","ASC")>
        <cfset arguments.event.setValue("qryAgendaStatus", local.qryAgendaStatus.resultset)>

        <cfset local.qryAgendaType = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,"CID AGENDA TYPE","","name_txt","ASC")>
        <cfset arguments.event.setValue("qryAgendaType", local.qryAgendaType.resultset)>

        <!---- set program area lock days default ---->
        <cfset local.qryProgramAreaLockDays = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event ,"CID EAGENDA DEFAULTS","PROGRAM AREA LOCK DAYS")>
        <cfset arguments.event.setValue("qryProgramAreaLockDays", local.qryProgramAreaLockDays.resultset.DESC_TXT)>

        <!---- set agency lock days default ---->
        <cfset local.qryAgencyLockDays = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event ,"CID EAGENDA DEFAULTS","AGENCY LOCK DAYS")>
        <cfset arguments.event.setValue("qryAgencyLockDays", local.qryAgencyLockDays.resultset.DESC_TXT)>

        <!---- set agenda id ---->
        <cfset local.qryAgendaDetail = getAgendaDetail(arguments.myFusebox, arguments.event , local.agenda_ID)>
        <cfset arguments.event.setValue("qryAgendaDetail", local.qryAgendaDetail.resultset)>
        <cfif local.mode NEQ "EDIT">
            <!---- reset the agenda id to recent by agenda date ---->
            <!---- use agenda id to get the header and footer ---->
            <cfset local.agenda_id = local.qryAgendaDetail.resultset.agenda_id>
        </cfif>

        <!---- set agenda header default ---->
        <cfset local.qryGetHeader = getComment(arguments.myFusebox, arguments.event, local.agenda_id, "HEADER")>
        <cfset arguments.event.setValue("qryGetHeader", local.qryGetHeader.resultset)>

        <!---- set agenda footer default ---->
        <cfset local.qryGetFooter = getComment(arguments.myFusebox, arguments.event, local.agenda_id, "FOOTER")>
        <cfset arguments.event.setValue("qryGetFooter", local.qryGetFooter.resultset)>
        <!---- call cfc/methods and set return values (ENDS) ---->


        <cfif local.mode EQ "EDIT">
            <!---- call cfc/method and set return values (BEGINS) ---->
            <!---- get all agenda categories ---->
            <cfset local.qryAgendaCategory = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,"CID AGENDA CATEGORY","","name_txt","ASC")>
            <cfset arguments.event.setValue("qryAgendaCategory", local.qryAgendaCategory.resultset)>

            <!---- get agenda approval details ---->
            <cfset local.qryAgendaApproval = getAgendaApproval(arguments.myFusebox, arguments.event, local.agenda_id)>
            <cfset arguments.event.setValue("qryAgendaApproval", local.qryAgendaApproval.resultSet)>

            <!---- get agenda item count ---->
            <cfset local.qryAgendaItemCount = getFindCount(arguments.myFusebox, arguments.event, local.agenda_id, "True")>
            <cfset arguments.event.setValue("qryAgendaItemCount", local.qryAgendaItemCount.resultSet)>

            <!---- get agenda categories related to select agenda id ---->
            <cfset local.qryCurrentAgendaCategory = getAgendaCategories(arguments.myFusebox, arguments.event, local.agenda_id, "Item")>
            <cfset arguments.event.setValue("qryCurrentAgendaCategory", local.qryCurrentAgendaCategory.resultSet)>

            <!---- get agenda comments ---->
            <cfset local.qryGetComments = getComment(arguments.myFusebox, arguments.event, local.agenda_id, "COMMENT")>
            <cfset arguments.event.setValue("qryGetComments", local.qryGetComments.resultSet)>
             <!---- call cfc/method and set return values (ENDS) ---->
         </cfif>

         <cfreturn>
    </cffunction>


    <!--- START  function --->
    <cffunction name="getAgendaList" displayname="getAgendaList" access="public" output="false" returntype="array">
         <cfargument name="myFusebox" type="struct" required="true" />
         <cfargument name="event" type="struct" hint="The event structure" required="true" />
         <cfargument name="dsnUN" type="string" required="false" default="">
         <cfargument name="dsnPW" type="string" required="false" default="">
         <cfargument name="dsn" type="string" required="false" default="">

        <cfif arguments.dsn EQ "">
             <cfset arguments.dsn = myFusebox.variables().this.datasource />
         </cfif>

         <cfif arguments.dsnUN EQ "">
             <cfset arguments.dsnUN = myFusebox.variables().this.dbUser />
         </cfif>

         <cfif arguments.dsnPW EQ "">
             <cfset arguments.dsnPW = myFusebox.variables().this.dbPW />
         </cfif>

        <cfsilent>

         <!--- initialize return structure --->
         <cfset local.rtnStruct = {errorID = 0, errorMSG = ""}>

        <cfif #Dateformat(now(),'mm')# gt 8>
             <cfset local.start_fiscal_year = '01/01/' & #Dateformat(now(),'yyyy')#>
         <cfelse>
             <cfset local.start_fiscal_year =  '01/01/' & #Dateformat(now(),'yyyy')# - 1>
         </cfif>

         <cftry>
             <cfquery name="local.qryAgendaList" datasource="#arguments.dsn#" username="#arguments.dsnUN#" password="#arguments.dsnPW#">
               SELECT AGENDA_ID as agenda_id
                 , TYP_CD as agenda_typ
                 , DT_AND_TM_TMSTMP as agenda_dt
                 , STATUS_CD as agenda_status
                 , PGM_AREA_LOCK_TMSTMP as pgm_area_lock_dt
                 , AGY_LOCK_TMSTMP as agency_wide_lock_dt
                 , count(*) as agenda_item_count
                FROM AN_AGENDA
                WHERE DT_AND_TM_TMSTMP >= current_date
                GROUP BY AGENDA_ID, TYP_CD, DT_AND_TM_TMSTMP, STATUS_CD, PGM_AREA_LOCK_TMSTMP, AGY_LOCK_TMSTMP
                ORDER BY agenda_dt asc, agenda_typ asc
            </cfquery>

            <cfcatch type="database">
                 <!--- trap DB errors and return information in structure so calling application can decide what to do about it --->
                 <cfset local.rtnStruct.errorID     = 1>
                 <cfset local.rtnStruct.errorMSG    = cfcatch.Message>
                 <cfset local.rtnStruct.errorStruct = cfcatch>
                 <cfreturn local.rtnStruct>
            </cfcatch>
        </cftry>

        <cfset local.arAgendaInfo = arrayNew(1)>

        <cfloop query="local.qryAgendaList">
            <cfset local.qry_Find_Count = getFindcount(arguments.myFusebox, arguments.event, agenda_id)>
            <cfset local.qryFindCount = local.qry_Find_Count.resultSet>
            <cfset arguments.event.setValue("qryFindCount", local.qryFindCount)>

            <cfset local.qryAgendaType = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,'CID AGENDA TYPE', agenda_typ)>
            <cfset arguments.event.setValue("qryAgendaType", local.qryAgendaType)>

            <cfset local.qryAgendaStatus = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,'CID AGENDA STATUS', agenda_status)>
            <cfset arguments.event.setValue("qryAgendaStatus", local.qryAgendaStatus)>

            <cfset local.stAgendaInfo = structNew()>
               <cfset local.stAgendaInfo.agenda_id = agenda_id>
               <cfset local.stAgendaInfo.agenda_dt = Dateformat(agenda_dt,'mm/dd/yyyy')>
               <cfset local.stAgendaInfo.agenda_type = qryAgendaType.resultSet.descText>
               <cfset local.stAgendaInfo.agenda_status = qryAgendaStatus.resultSet.descText>
               <cfset local.stAgendaInfo.pgm_area_lock_dt = Dateformat(pgm_area_lock_dt,'mm/dd/yyyy')>
               <cfset local.stAgendaInfo.agency_wide_lock_dt = Dateformat(agency_wide_lock_dt,'mm/dd/yyyy')>
               <cfset local.stAgendaInfo.agenda_item_count = qryFindCount.agenda_item_count>
               <cfset arrayAppend(local.arAgendaInfo, local.stAgendaInfo)>
        </cfloop>

        <cfset local.rtnStruct.resultSet = local.qryAgendaList>

        <cfreturn local.arAgendaInfo>
       </cfsilent>
   </cffunction>
    <!--- END  function --->





    <!--- START  function --->
    <cffunction name="getAgendaCategories" displayname="getAgendaCategories" access="public" output="false" returntype="struct">
        <!--- *** PLEASE NOTE! *** Since this function is being called by a remote function, the "myFusebox" and "event" arguments
        were made not required and since those arguments are structs, the "type" parameter has been removed to prevent erroring --->
        <cfargument name="myFusebox"    required="false">
        <cfargument name="event"        required="false" hint="The event structure">
        <cfargument name="agenda_id"    required="false" type="numeric" default="0" hint="default value will return last approved agenda detail">
        <cfargument name="ITEMFlag"     required="false" type="string" default="" hint="valid value = 'ITEM'">
        <cfargument name="dsnUN"        required="false" type="string" default="">
        <cfargument name="dsnPW"        required="false" type="string" default="">
        <cfargument name="dsn"          required="false" type="string" default="">

        <cfif arguments.dsn EQ "">
            <cfset arguments.dsn = myFusebox.variables().this.datasource>
        </cfif>

        <cfif arguments.dsnUN EQ "">
            <cfset arguments.dsnUN = myFusebox.variables().this.dbUser>
        </cfif>

        <cfif arguments.dsnPW EQ "">
            <cfset arguments.dsnPW = myFusebox.variables().this.dbPW>
        </cfif>

        <cfsilent>

        <!--- initialize return structure --->
        <cfset local.rtnStruct = {errorID = 0, errorMSG = ""}>

        <cftry>
            <cfquery name="local.qryAgendaCategories" datasource="#arguments.dsn#" username="#arguments.dsnUN#" password="#arguments.dsnPW#">
                SELECT <cfif arguments.ITEMFlag EQ "ITEM">DISTINCT</cfif>
                        TRIM(A.AGENDA_ID) AS agenda_id
                       ,TRIM(A.TYP_CD) AS agenda_typ
                       ,TRIM(A.DT_AND_TM_TMSTMP) AS agenda_dt
                       ,TRIM(A.STATUS_CD) AS agenda_status
                       ,TRIM(A.PGM_AREA_LOCK_TMSTMP) AS pgm_area_lock_dt
                       ,TRIM(A.AGY_LOCK_TMSTMP) AS agency_wide_lock_dt
                       ,TRIM(A.APPR_DT) AS appr_dt
                       ,TRIM(A.LOC_LINE_1_TXT) AS loc_line_1_txt
                       ,TRIM(A.LOC_LINE_2_TXT) AS loc_line_2_txt
                       ,TRIM(CAT.AGENDA_CAT_ID) AS agenda_cat_id
                       ,TRIM(CAT.CAT_CD) AS agenda_cat_cd
                       ,TRIM(CAT.NAME_TXT) AS agenda_cat_name
                       <!--- because order_num is in the ORDER BY clause, it can't be trimmed --->
                       ,CAT.ORDER_NUM AS agenda_cat_order
                FROM AN_AGENDA A
                    ,AN_AGENDA_CAT CAT
                    <cfif arguments.ITEMFlag EQ "ITEM">
                        ,AN_AGENDA_ITEM AIT
                    </cfif>
                WHERE 1=1
                    AND A.AGENDA_ID = <cfqueryparam value="#arguments.agenda_id#" cfsqltype="cf_sql_numeric">
                    AND A.AGENDA_ID = CAT.AGENDA_ID
                    <cfif arguments.ITEMFlag EQ "ITEM">
                        AND AIT.AGENDA_CAT_ID = CAT.AGENDA_CAT_ID
                    </cfif>
                ORDER BY CAT.ORDER_NUM ASC
            </cfquery>

            <cfcatch type="database">
                 <!--- trap DB errors and return information in structure so calling application can decide what to do about it --->
                 <cfset local.rtnStruct.errorID     = 1>
                 <cfset local.rtnStruct.errorMSG    = cfcatch.Message>
                 <cfset local.rtnStruct.errorStruct = cfcatch>
                 <cfreturn local.rtnStruct>
            </cfcatch>
        </cftry>

        <cfset local.rtnStruct.resultSet = local.qryAgendaCategories>

        <cfreturn local.rtnStruct>
        </cfsilent>

   </cffunction>
    <!--- END  function --->






   <!--- START  function --->
   <cffunction name="processAgenda" displayname="processAgenda" description="Process of an agenda, from adding, updating, or deleting to validating form fields." access="public" output="false" returntype="void">
       <cfargument name="myFusebox" type="struct" required="true">
       <cfargument name="event" type="struct" hint="The event structure" required="true">
       <cfargument name="dsnUN" type="string" required="false" default="">
       <cfargument name="dsnPW" type="string" required="false" default="">
       <cfargument name="dsn" type="string" required="false" default="">

       <!--- set dsn variables --->
       <cfif arguments.dsn EQ "">
           <cfset arguments.dsn = myFusebox.variables().this.datasource>
       </cfif>

       <cfif arguments.dsnUN EQ "">
           <cfset arguments.dsnUN = myFusebox.variables().this.dbUser>
       </cfif>

       <cfif arguments.dsnPW EQ "">
           <cfset arguments.dsnPW = myFusebox.variables().this.dbPW>
       </cfif>

       <!--- set default struct variable --->
       <cfset local.attributes = arguments.MyFusebox.variables().attributes>

       <!--- set default error struct --->
       <cfset local.stErrors = structNew()>

       <!--- initialize return structure --->
       <cfset local.rtnStruct = {errorID = 0, errorMSG = "", success = "", returnCode = "", reasonCode = "", agendaID = ""}>
       <!--- ERROR IDs:
           4 = proxy error, check return and reason codes
           5 = Struct is empty
       --->

       <!--- determine how to proceed and process agenda (BEGINS)--->
       <cfif isDefined("local.attributes.SAVE")>
           <!--- call method to place form data into a struct --->
           <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC0700eAgendaDetail")>

           <!--- set error messages if violations are found --->
           <!--- check agenda date --->
           <cfif TRIM(local.attributes.agenda_dt) EQ "" OR !isDate(TRIM(local.attributes.agenda_dt))>
               <cfset local.stErrors["agenda_dt"] = "Agenda Date Required! (mm/dd/yyyy)">
           </cfif>

           <!--- check agenda time --->
           <cfif TRIM(local.attributes.agendaTime) EQ "">
               <cfset local.stErrors["agendaTime"] = "Agenda Time Required!">
           </cfif>

           <!--- check agenda status --->
           <cfif TRIM(local.attributes.agenda_status) EQ "">
               <cfset local.stErrors["agenda_status"] = "Agenda Status Required!">
           </cfif>

           <!--- check agenda type --->
           <cfif TRIM(local.attributes.agenda_type) EQ "">
               <cfset local.stErrors["agenda_type"] = "Agenda Type Required!">
           </cfif>

           <!---- check agenda program area lock date ---->
           <cfif TRIM(local.attributes.pgm_area_lock_dt) EQ "" OR !isDate(TRIM(local.attributes.pgm_area_lock_dt))>
               <cfset local.stErrors["pgm_area_lock_dt"] = "Program Area Lock Date Required! (mm/dd/yyyy)">
           </cfif>

           <!---- check agenda program area lock time ---->
           <cfif TRIM(local.attributes.pgm_area_lockTime) EQ "">
               <cfset local.stErrors["pgm_area_lockTime"] = "Program Area Lock Time Required!">
           </cfif>

           <!---- check agenda agency wide lock date ---->
           <cfif TRIM(local.attributes.agency_wide_lock_dt) EQ "" OR !isDate(TRIM(local.attributes.agency_wide_lock_dt))>
               <cfset local.stErrors["agency_wide_lock_dt"] = "Agency Lock Date Required! (mm/dd/yyyy)">
           </cfif>

           <!---- check agenda agency wide lock time ---->
           <cfif TRIM(local.attributes.agency_wide_lockTime) EQ "">
               <cfset local.stErrors["agency_wide_lockTime"] = "Agency Lock Time Required!">
           </cfif>

           <!---- process agenda (START) ---->
           <cfif !structIsEmpty(local.stErrors)>
               <!---- set form violations inside a client var ---->
               <cfwddx action="cfml2wddx" input="#local.stErrors#" output="client.agendaFormErrors">
               <!---- send user back to correct form violations ---->
               <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('current')#&mode=#local.attributes.mode#&agenda_id=#local.attributes.agenda_id#" addtoken="no">

           <cfelse>

               <!---- determine if adding agenda or updating ---->
               <cfif local.attributes.mode EQ "Edit">

                   <!---- *********************************
                   //////////// UPDATE AGENDA ////////////
                   ********************************** ---->

                   <!---- set the form data client variable to a struct ---->
                   <cfwddx action="wddx2cfml" input="#client.vEAGC0700eAgendaDetail#" output="local.updateAgendaDetails">

                   <!---- set new variable for agenda date and time combined ---->
                   <cfset local.agendaDateTime = "#local.updateAgendaDetails.agenda_dt##local.updateAgendaDetails.agendaTime#">
                   <cfset local.agendaDateTime = Dateformat(local.agendaDateTime,"yyyymmddHHmmssSSSSSS")>

                   <!---- set new variable for program area lock date and time combined ---->
                   <cfset local.programLockDateTime = "#local.updateAgendaDetails.pgm_area_lock_dt##local.updateAgendaDetails.pgm_area_lockTime#">
                   <cfset local.programLockDateTime = Dateformat(local.programLockDateTime,"yyyymmddHHmmssSSSSSS")>

                   <!---- set new variable for agency lock date and time combined ---->
                   <cfset local.agencyLockDateTime = "#local.updateAgendaDetails.agency_wide_lock_dt##local.updateAgendaDetails.agency_wide_lockTime#">
                   <cfset local.agencyLockDateTime = Dateformat(local.agencyLockDateTime,"yyyymmddHHmmssSSSSSS")>

                   <!---- set new approval date variable ---->
                   <cfset local.agendaApprovalDate = local.updateAgendaDetails.approval_dt NEQ "" ? Dateformat(local.updateAgendaDetails.approval_dt,"yyyymmdd") : "">

                   <!---- update agenda (START) ---->
                   <cfset local.updateAgendaObj = createObject("Java", "Cid008sc.Abean.Cidr7700AgendaDetail").init()>
                   <cfset local.updateAgendaObj.setImportApplicationTnrccCommonWorkApplicationName(arguments.myFusebox.variables().this.appName)>
                   <cfset local.updateAgendaObj.setClientID(JavaCast("string", client.userID))>
                   <cfset local.updateAgendaObj.setClientPassword(JavaCast("string", client.pw))>

                   <!---- set imports for proxy call ---->
                   <cfset local.updateAgendaObj.setCommandSent("UPDATE")>
                   <cfset local.updateAgendaObj.setImportIagn1AgendaId(JavaCast("double", local.updateAgendaDetails.agenda_id))>
                   <cfset local.updateAgendaObj.setImportIagn1AgendaTypeCode(JavaCast("string", local.updateAgendaDetails.agenda_type))>
                   <cfset local.updateAgendaObj.setAsStringImportIagn1AgendaDateAndTime(JavaCast("string", local.agendaDateTime))>
                   <cfset local.updateAgendaObj.setImportIagn1AgendaStatusCode(JavaCast("string", local.updateAgendaDetails.agenda_status))>
                   <cfset local.updateAgendaObj.setAsStringImportIagn1AgendaProgramAreaLockDate(JavaCast("string", local.programLockDateTime))>
                   <cfset local.updateAgendaObj.setAsStringImportIagn1AgendaAgencyLockDate(JavaCast("string", local.agencyLockDateTime))>
                   <cfset local.updateAgendaObj.setAsStringImportIagn1AgendaApprovalDate(JavaCast("string", local.agendaApprovalDate))>

                   <!---- loop thru agenda categories ---->
                   <cfif local.updateAgendaDetails.agendaCatRecCount GT 0>
                       <cfset local.index = 0>

                       <!---- set variables to use inside category proxy calls ---->
                       <cfloop index="local.i" from="1" to="#local.updateAgendaDetails.agendaCatRecCount#">
                           <cfset local.catID = local.updateAgendaDetails["agendaCategoryID_#local.i#"]>
                           <cfset local.catOrder = local.updateAgendaDetails["agendaCatOrder_#local.i#"]>
                           <cfset local.catCode = local.updateAgendaDetails["agendaCatCode_#local.i#"]>
                           <cfset local.catName = local.updateAgendaDetails["AGENDACATEGORY_#local.i#"]>

                           <!---- existing category proxy calls ---->
                           <cfset local.updateAgendaObj.setImportGroupCount(local.i)>
                           <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryId(local.index, JavaCast("double", local.catID))>
                           <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryOrder(local.index, JavaCast("double", local.catOrder))>
                           <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryCategoryCode(local.index, JavaCast("string", local.catCode))>
                           <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryName(local.index, JavaCast("string", local.catName))>

                           <cfset local.index++>
                       </cfloop>
                   </cfif>

                   <!---- check for new category being added ---->
                   <cfif local.updateAgendaDetails.new_category_type NEQ "">
                       <cfset local.updateAgendaObj.setImportGroupCount(1)>
                       <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryId(0, JavaCast("double", 0))>
                       <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryOrder(0, JavaCast("double", local.updateAgendaDetails.nxtCatOrder))>
                       <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryCategoryCode(0, JavaCast("string", local.updateAgendaDetails.new_category_type))>
                       <cfset local.updateAgendaObj.setImportGrpAgendaCategoryIagn1AgendaCategoryName(0, JavaCast("string", UCase(local.updateAgendaDetails.new_category_name)))>
                   </cfif>

                   <!---- check for header changes ---->
                   <cfif local.updateAgendaDetails.headerUpdated EQ 1>
                       <cfset local.updateAgendaObj.setImportHeaderIcnt1CommentId(JavaCast("double", local.updateAgendaDetails.headerId))>
					   <cfset local.updateAgendaObj.setImportHeaderIcnt1CommentCommentText(JavaCast("string", local.updateAgendaDetails.header_txt))>
                       <!---- verify if existing agendas get updated to new header ---->
                       <cfif local.updateAgendaDetails.headerFutureUse EQ 1>
                           <cfset local.updateAgendaObj.setImportFutureHeaderAgendasFlgTnrccCommonWorkFlag(JavaCast("string", "Y"))>
                       </cfif>
                   </cfif>

                   <!---- check for footer changes ---->
                   <cfif local.updateAgendaDetails.footerUpdated EQ 1>
                       <cfset local.updateAgendaObj.setImportFooterIcnt1CommentId(JavaCast("double", local.updateAgendaDetails.footerId))>
					   <cfset local.updateAgendaObj.setImportFooterIcnt1CommentCommentText(JavaCast("string", local.updateAgendaDetails.footer_txt))>
                       <!---- verify if existing agendas get updated to new footer ---->
                       <cfif local.updateAgendaDetails.footerFutureUse EQ 1>
                           <cfset local.updateAgendaObj.setImportFutureFooterAgendasFlgTnrccCommonWorkFlag(JavaCast("string", "Y"))>
                       </cfif>
                   </cfif>

                   <!---- check for comment changes ---->
                   <cfif local.updateAgendaDetails.commentsUpdated EQ 1>
                      <cfset local.updateAgendaObj.setImportCommentIcnt1CommentId(JavaCast("double", local.updateAgendaDetails.commentId))>
	                  <cfset local.updateAgendaObj.setImportCommentIcnt1CommentCommentText(JavaCast("string", local.updateAgendaDetails.comment_txt))>
                   </cfif>

                   <!---- execute the proxy ---->
                   <cfset local.updateAgendaObj.execute()>
                   <!---- update agenda (STOP) ---->

                   <!--- populate return struct based on proxy outcome --->
                   <cfif local.updateAgendaObj.getExportIerr1FormattedErrorReturnCode() EQ 1 AND local.updateAgendaObj.getExportIerr1FormattedErrorReasonCode() EQ 0>
                       <cfset local.rtnStruct.success = "Y">
                       <cfset local.rtnStruct.errorID = 0>

                       <!--- populate return struct with proxy output --->
                       <cfset local.rtnStruct.returnCode = local.updateAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                       <cfset local.rtnStruct.reasonCode = local.updateAgendaObj.getExportIerr1FormattedErrorReasonCode()>
                   <cfelse>
                       <cfset local.rtnStruct.success = "N">
                       <cfset local.rtnStruct.errorID = 4>

                       <!--- populate return struct with proxy output --->
                       <cfset local.rtnStruct.returnCode = local.updateAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                       <cfset local.rtnStruct.reasonCode = local.updateAgendaObj.getExportIerr1FormattedErrorReasonCode()>
                       <cfset local.rtnStruct.errorMSG = local.updateAgendaObj.getExportIerr1FormattedErrorFormattedErrorMessage()>
                       <cfset local.rtnStruct.agendaID = TRIM(local.attributes.agenda_id)>
                   </cfif>

                   <!---- set process success/failure mgs to client variable ---->
                   <cfwddx action="cfml2wddx" input="#local.rtnStruct#" output="client.agendaProcessErrors">

                   <!---- delete update form struct ---->
                   <cfset structClear(local.updateAgendaDetails)>

                   <!---- delete proxy error struct ---->
                   <cfif local.rtnStruct.success EQ "Y">
                       <cfset structClear(local.rtnStruct)>
                   </cfif>

                   <!---- send user back to the agenda ---->
                   <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('current')#&mode=#local.attributes.mode#&id=#local.attributes.agenda_id#" addtoken="no">

               <cfelse>

                   <!---- *********************************
                   //////////// ADD AN AGENDA ////////////
                   ********************************** ---->

                   <!---- set the form data client variable to a struct ---->
                   <cfwddx action="wddx2cfml" input="#client.vEAGC0700eAgendaDetail#" output="local.addAgendaDetails">

                   <!---- set new variable for agenda date and time combined ---->
                   <cfset local.agendaDateTime = "#local.addAgendaDetails.agenda_dt##local.addAgendaDetails.agendaTime#">
                   <cfset local.agendaDateTime = Dateformat(local.agendaDateTime,"yyyymmddHHmmssSSSSSS")>

                   <!---- set new variable for program area lock date and time combined ---->
                   <cfset local.programLockDateTime = "#local.addAgendaDetails.pgm_area_lock_dt##local.addAgendaDetails.pgm_area_lockTime#">
                   <cfset local.programLockDateTime = Dateformat(local.programLockDateTime,"yyyymmddHHmmssSSSSSS")>

                   <!---- set new variable for agency lock date and time combined ---->
                   <cfset local.agencyLockDateTime = "#local.addAgendaDetails.agency_wide_lock_dt##local.addAgendaDetails.agency_wide_lockTime#">
                   <cfset local.agencyLockDateTime = Dateformat(local.agencyLockDateTime,"yyyymmddHHmmssSSSSSS")>

                   <!---- add agenda (START) ---->
                   <cfset local.addAgendaObj = createObject("Java", "Cid008sc.Abean.Cidr7700AgendaDetail").init()>
                   <cfset local.addAgendaObj.setImportApplicationTnrccCommonWorkApplicationName(arguments.myFusebox.variables().this.appName)>
                   <cfset local.addAgendaObj.setClientID(JavaCast("string", client.userID))>
                   <cfset local.addAgendaObj.setClientPassword(JavaCast("string", client.pw))>

                   <!---- set imports for proxy call ---->
                   <cfset local.addAgendaObj.setCommandSent("NEW")>
                   <!---- agenda type ---->
                   <cfset local.addAgendaObj.setImportIagn1AgendaTypeCode(JavaCast("string", local.addAgendaDetails.agenda_type))>
                   <!---- agenda date and time ---->
                   <cfset local.addAgendaObj.setAsStringImportIagn1AgendaDateAndTime(JavaCast("string", local.agendaDateTime))>
                   <!---- agenda status ---->
                   <cfset local.addAgendaObj.setImportIagn1AgendaStatusCode(JavaCast("string", local.addAgendaDetails.agenda_status))>
                   <!---- program lock date and time ---->
                   <cfset local.addAgendaObj.setAsStringImportIagn1AgendaProgramAreaLockDate(JavaCast("string", local.programLockDateTime))>
                   <!---- agency lock date and time ---->
                   <cfset local.addAgendaObj.setAsStringImportIagn1AgendaAgencyLockDate(JavaCast("string", local.agencyLockDateTime))>

                   <!---- header comments (START) ---->
                   <cfset local.addAgendaObj.setImportHeaderIcnt1CommentCommentText(JavaCast("string", local.addAgendaDetails.header_txt))>

                   <!---- verify if existing agendas get updated to new header ---->
                   <cfif local.addAgendaDetails.headerFutureUse EQ 1>
                       <cfset local.addAgendaObj.setImportFutureHeaderAgendasFlgTnrccCommonWorkFlag(JavaCast("string", 'Y'))>
                   </cfif>
                   <!---- header comments (END) ---->

                   <!---- footer comments (START) ---->
                   <cfset local.addAgendaObj.setImportFooterIcnt1CommentCommentText(JavaCast("string", local.addAgendaDetails.footer_txt))>

                   <!---- verify if existing agendas get updated to new footer ---->
                   <cfif local.addAgendaDetails.footerFutureUse EQ 1>
                       <cfset local.addAgendaObj.setImportFutureFooterAgendasFlgTnrccCommonWorkFlag(JavaCast("string", 'Y'))>
                   </cfif>
                   <!---- footer comments (END) ---->

                   <!---- user comments ---->
                   <cfset local.addAgendaObj.setImportCommentIcnt1CommentCommentText(JavaCast("string", local.addAgendaDetails.comment_txt))>

                   <!---- execute the proxy ---->
                   <cfset local.addAgendaObj.execute()>
                   <!---- add agenda (STOP) ---->

                   <!--- populate return struct based on proxy outcome --->
                   <cfif local.addAgendaObj.getExportIerr1FormattedErrorReturnCode() EQ 1 AND local.addAgendaObj.getExportIerr1FormattedErrorReasonCode() EQ 0>
                       <cfset local.rtnStruct.success = "Y">
                       <cfset local.rtnStruct.errorID = 0>

                       <!--- populate return struct with proxy output --->
                       <cfset local.rtnStruct.returnCode = local.addAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                       <cfset local.rtnStruct.reasonCode = local.addAgendaObj.getExportIerr1FormattedErrorReasonCode()>
                   <cfelse>
                       <cfset local.rtnStruct.success = "N">
                       <cfset local.rtnStruct.errorID = 4>

                       <!--- populate return struct with proxy output --->
                       <cfset local.rtnStruct.returnCode = local.addAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                       <cfset local.rtnStruct.reasonCode = local.addAgendaObj.getExportIerr1FormattedErrorReasonCode()>
                       <cfset local.rtnStruct.errorMSG = local.addAgendaObj.getExportIerr1FormattedErrorFormattedErrorMessage()>
                       <cfset local.rtnStruct.agendaID = TRIM(local.attributes.agenda_id)>
                   </cfif>

                   <!---- delete add form struct ---->
                   <cfset structClear(local.addAgendaDetails)>

                   <!---- redirect the user based of proxy success ---->
                   <cfif local.rtnStruct.success EQ "N">
                      <!---- set process errors to client variable ---->
                      <cfwddx action="cfml2wddx" input="#local.rtnStruct#" output="client.agendaProcessErrors">

                      <!---- delete proxy error struct ---->
                      <cfset structClear(local.rtnStruct)>

                      <!---- send user back to try again ---->
                      <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('current')#&mode=#local.attributes.mode#" addtoken="no">
                   <cfelse>
                      <!---- clean up variables (START) ---->
                          <!---- delete client variable ---->
                          <cfset DeleteClientVariable('vEAGC0700eAgendaDetail')>

                          <!---- delete proxy error struct ---->
                          <cfset structClear(local.rtnStruct)>

                          <!---- delete agenda process errors client variable ---->
                          <cfset DeleteClientVariable("agendaProcessErrors")>
                      <!---- clean up variables (END) ---->

                      <!---- send user back to add agenda ---->
                      <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('current')#" addtoken="no">
                   </cfif>
               </cfif>
           </cfif>
           <!---- process agenda (STOP) ---->

       <cfelse>

           <!---- *********************************
           //////////// DELETE AGENDA ////////////
           ********************************** ---->

           <!---- delete agenda (START) ---->
           <cfset local.deleteAgendaObj = createObject("Java", "Cid008sc.Abean.Cidr7700AgendaDetail").init()>
           <cfset local.deleteAgendaObj.setImportApplicationTnrccCommonWorkApplicationName(arguments.myFusebox.variables().this.appName)>
           <cfset local.deleteAgendaObj.setClientID(JavaCast("string", client.userID))>
           <cfset local.deleteAgendaObj.setClientPassword(JavaCast("string", client.pw))>

           <!---- set imports for proxy call ---->
           <cfset local.deleteAgendaObj.setCommandSent("DELETE")>
           <cfset local.deleteAgendaObj.setImportIagn1AgendaId(JavaCast("double", local.attributes.agenda_id))>

           <!---- execute the proxy ---->
           <cfset local.deleteAgendaObj.execute()>
           <!---- delete agenda (STOP) ---->

           <!--- populate return struct based on proxy outcome --->
           <cfif local.deleteAgendaObj.getExportIerr1FormattedErrorReturnCode() EQ 1 AND local.deleteAgendaObj.getExportIerr1FormattedErrorReasonCode() EQ 0>
               <cfset local.rtnStruct.success = "Y">
               <cfset local.rtnStruct.errorID = 0>

               <!--- populate return struct with proxy output --->
               <cfset local.rtnStruct.returnCode = local.deleteAgendaObj.getExportIerr1FormattedErrorReturnCode()>
               <cfset local.rtnStruct.reasonCode = local.deleteAgendaObj.getExportIerr1FormattedErrorReasonCode()>
           <cfelse>
               <cfset local.rtnStruct.success = "N">
               <cfset local.rtnStruct.errorID = 4>

               <!--- populate return struct with proxy output --->
               <cfset local.rtnStruct.returnCode = local.deleteAgendaObj.getExportIerr1FormattedErrorReturnCode()>
               <cfset local.rtnStruct.reasonCode = local.deleteAgendaObj.getExportIerr1FormattedErrorReasonCode()>
               <cfset local.rtnStruct.errorMSG = local.deleteAgendaObj.getExportIerr1FormattedErrorFormattedErrorMessage()>
               <cfset local.rtnStruct.agendaID = TRIM(local.attributes.agenda_id)>
           </cfif>

           <!---- redirect the user based of proxy success ---->
           <cfif local.rtnStruct.success EQ "N">
               <!---- set process errors to client variable ---->
               <cfwddx action="cfml2wddx" input="#local.rtnStruct#" output="client.agendaProcessErrors">

               <!---- send user back to try again ---->
               <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('current')#&mode=#local.attributes.mode#&id=#local.attributes.agenda_id#" addtoken="no">
           <cfelse>
               <!---- send user back to maintain agendas page ---->
               <cflocation url="#arguments.myFusebox.getMyself()#eAgenda.EAGC0600MaintainAgenda" addtoken="no">
           </cfif>
       </cfif>
       <!---- determine how to proceed and process agenda (ENDS)---->

       <cfreturn>
   </cffunction>
   <!--- END  function --->






   <cffunction name="mEAGC1000searchAgendaItems" displayname="mEAGC1000searchAgendaItems" description="searches for an agenda item using various search criteria" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <!---- set local attributes ---->
        <cfset local.attributes = arguments.MyFusebox.variables().attributes>

        <!---- initiate cfcs ---->
        <cfset local.eAgendaCrPgmDdObj = new com.Security()>

        <!--- get list size for paging --->
        <cfset local.getListSize = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event, "CID EAGENDA DEFAULTS", "SEARCH AGENDA ITEM LIST SIZE")>
        <cfset arguments.event.setValue("getListSize", local.getListSize.resultset.DESC_TXT)>

        <!---- populate Agenda item status drop down ---->
        <cfset local.qryAgendaStatus = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,"CID AGENDA ITEM STATUS","","name_txt","ASC")>
        <cfset arguments.event.setValue("qryAgendaStatus", local.qryAgendaStatus.resultset)>

        <!---- populate program drop down(non central registry additional id) ---->
        <cfset local.qryNonCrAddtlId = application.utilsObj.getDescFmCodeTypeName(arguments.myFusebox, arguments.event ,"ADDITIONAL ID TYPE","","","","","","","True","True")>
        <cfset arguments.event.setValue("qryNonCrAddtlId", local.qryNonCrAddtlId.resultset)>

        <!---- populate program drop down central registry additional id (BEGINS)  ---->
        <!---- determining user's team and if in enforcement role in eAgenda ---->
        <cfif client.userType EQ "progArea">
            <cfset local.crProgramDropDown = local.eAgendaCrPgmDdObj.getSecuredProxyCrProgramDropDown(myFusebox.variables().this.datasource,myFusebox.variables().this.dbUser, myFusebox.variables().this.dbPW)>
        <cfelse>
            <cfset local.crProgramDropDown = local.eAgendaCrPgmDdObj.getSecuredSQLCrProgramDropDown(myFusebox.variables().this.datasource,myFusebox.variables().this.dbUser, myFusebox.variables().this.dbPW)>
        </cfif>

        <cfset arguments.event.setValue("crProgramDropDown", local.crProgramDropDown)>
        <!---- populate program drop down central registry additional id (ENDS)  ---->

        <!---- set event object to local variable ---->
        <cfset local.agendaItmSearchCriteria = arguments.event.getValue("agendaItmSearchCriteria")>

        <!---- set default search result struct ---->
        <cfset local.agendaItmSrchRslts = StructNew()>
        <cfset local.agendaItmSrchRslts.resultset = queryNew("item_num")>

        <!---- decide which form to submit ---->
        <cfswitch expression="#local.agendaItmSearchCriteria.formSubmitted#">
             <!---- search by docket number ---->
             <cfcase value="docketNum">
                 <!---- call method to place form data into a struct ---->
                 <cfif isDefined("local.attributes.fieldNames")>
                     <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC1000searchAgendaItems_docketNumber")>
                 </cfif>

                 <!---- run query search ---->
                 <cfset local.agendaItmSrchRslts = searchAgendaItems(arguments.myFusebox, arguments.event, "#local.agendaItmSearchCriteria.agy_dkt_num_txt#")>
             </cfcase>

             <!---- search by agenda status ---->
             <cfcase value="agendaStatus">
                 <!---- call method to place form data into a struct ---->
                 <cfif isDefined('local.attributes.fieldNames')>
                     <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC1000searchAgendaItems_agendaStatus")>
                 </cfif>

                 <!---- run query search ---->
                 <cfset local.agendaItmSrchRslts = searchAgendaItems(arguments.myFusebox, arguments.event, "", "#local.agendaItmSearchCriteria.agendaStatus#")>
             </cfcase>

             <!---- search by cr additional id ---->
             <cfcase value="crAddtlId">
                 <!---- call method to place form data into a struct ---->
                 <cfif isDefined("local.attributes.fieldNames")>
                     <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC1000searchAgendaItems_crAddtlId")>
                 </cfif>

                 <!---- run query search ---->
                 <cfset local.agendaItmSrchRslts = searchAgendaItems(arguments.myFusebox, arguments.event, "", "", "#local.agendaItmSearchCriteria.cr_addn_num_txt#", 0, "", "", "#local.agendaItmSearchCriteria.cr_pgm_id#")>
            </cfcase>

            <!---- search by non cr additional id ---->
            <cfcase value="nonCrAddtlId">
                <!---- call method to place form data into a struct ---->
                <cfif isDefined("local.attributes.fieldNames")>
                    <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC1000searchAgendaItems_nonCrAddtlId")>
                </cfif>

                <!---- run query search ---->
                <cfset local.agendaItmSrchRslts = searchAgendaItems(arguments.myFusebox, arguments.event, "", "", 0, "#local.agendaItmSearchCriteria.noncr_addn_num_txt#", "", "", "#local.agendaItmSearchCriteria.noncr_pgm_id#")>
            </cfcase>

            <!---- search by regulated entity ---->
            <cfcase value="regEntity">
                <!---- call method to place form data into a struct ---->
                <cfif isDefined("local.attributes.fieldNames")>
                    <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC1000searchAgendaItems_regEntity")>
                </cfif>

                <!---- run query search ---->
                <cfset local.agendaItmSrchRslts = searchAgendaItems(arguments.myFusebox, arguments.event, "", "", 0, 0, "#local.agendaItmSearchCriteria.rn_ref_num_txt#")>
            </cfcase>

            <!---- search by customer ---->
            <cfcase value="custNumber">
                <!---- call method to place form data into a struct ---->
                <cfif isDefined("local.attributes.fieldNames")>
                    <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC1000searchAgendaItems_custNumber")>
                </cfif>

                <!---- run query search ---->
                <cfset local.agendaItmSrchRslts = searchAgendaItems(arguments.myFusebox, arguments.event, "", "", 0, 0, "", "#local.agendaItmSearchCriteria.pr_ref_num_txt#")>
            </cfcase>
        </cfswitch>

        <!---- set search results in event object ---->
        <cfset arguments.event.setValue("agendaItmSrchRslts", local.agendaItmSrchRslts.resultset)>

        <cfreturn>
   </cffunction>







    <cffunction name="mEAGC0800markedAgenda" displayname="mEAGC0800markedAgenda" description="allows the agenda team to document the commissioners’ decision on each agenda item on an agenda." access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <!--- set datasource --->
        <cfset local.dsn = myFusebox.variables().this.datasource>

        <!--- set database user --->
        <cfset local.dsnUN = myFusebox.variables().this.dbUser>

        <!--- set database password --->
        <cfset local.dsnPW = myFusebox.variables().this.dbPW>

        <!---- set defaults vars ---->
        <cfset local.attributes = myfusebox.variables().attributes>

        <!--- default new agenda date --->
        <cfparam name="local.attributes.nAgendaDt" default="">

        <!--- default list --->
        <cfset local.commAttend = "">
        <cfset local.gcAttend = "">
        <cfset local.aItmCat = "">

        <!---- ****************************************
        ////////// SAVE MARKED AGENDA BEGINS //////////
        ***************************************** ---->
        <cfif isDefined("local.attributes.saveApprl")>
            <!--- call method to place form data into a struct --->
            <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC0800markedAgenda")>

            <!---- set the form data client variable to a struct ---->
            <cfwddx action="wddx2cfml" input="#client.vEAGC0800markedAgenda#" output="local.saveMarkedAgenda">
            <!--- <cfdump var="#local.saveMarkedAgenda#" abort="true"> --->

            <!---- save marked agenda (START) ---->
            <cfset local.svMarkedAgendaObj = createObject("Java", "Cid008sc.Abean.Cidr7800MarkAgendaMaint").init()>
            <cfset local.svMarkedAgendaObj.setImportApplicationTnrccCommonWorkApplicationName(arguments.myFusebox.variables().this.appName)>
            <cfset local.svMarkedAgendaObj.setClientID(JavaCast("string", client.userID))>
            <cfset local.svMarkedAgendaObj.setClientPassword(JavaCast("string", client.pw))>

            <!---- set imports for proxy call ---->
            <cfset local.svMarkedAgendaObj.setCommandSent("SAVE")>
            <cfset local.svMarkedAgendaObj.setImportGroupActivityActionCount(local.saveMarkedAgenda.agendaItmCt)>

            <!--- set default index var --->
			<cfset local.index = 0>

			<!---- set variables to use inside activity action proxy methods ---->
            <cfloop index="local.i" from="1" to="#local.saveMarkedAgenda.agendaItmCt#">
                <cfset local.agendaItmId = local.saveMarkedAgenda["agendaItmId_#local.i#"]>
                <cfset local.agendaItmStat = local.saveMarkedAgenda["agendaItmStat_#local.i#"]>
                <cfset local.activActAnswer = local.saveMarkedAgenda["actItem_#local.i#"]>
                <cfset local.activActDt = Dateformat(local.saveMarkedAgenda.curAgendaDt,"yyyymmddHHmmssSSSSSS")>
                <cfset local.activActComnt = local.saveMarkedAgenda["comntTxt_#local.i#"]>
                <cfset local.activActItmId = local.saveMarkedAgenda["activActItmId_#local.i#"]>
                <cfset local.activActItmNm = local.saveMarkedAgenda["docType_#local.i#"]>

                <!--- check for future agenda --->
                <cfif structKeyExists(local.saveMarkedAgenda,"fAgendaDts_#local.i#")>
                    <cfset local.fAgendaId = local.saveMarkedAgenda["fAgendaDts_#local.i#"]>
                </cfif>

                <!---- activity action proxy methods ---->
                <cfset local.svMarkedAgendaObj.setImportGroupActivityActionCount(local.i)>
                <cfset local.svMarkedAgendaObj.setImportGrpActivityActionIagn1AgendaItemId(local.index, JavaCast("double", 1574784755))>
                <cfset local.svMarkedAgendaObj.setImportGrpActivityActionIagn1AgendaItemStatusCode(local.index, JavaCast("string", local.agendaItmStat))>

                <!--- only send the check list item id to the proxy if it exist --->
                <cfif local.activActItmId NEQ "">
	                <cfset local.svMarkedAgendaObj.setAsStringImportGrpActivityActionIchl1ChecklistItemId(local.index, JavaCast("double", local.activActItmId))>
                </cfif>

                <cfset local.svMarkedAgendaObj.setImportGrpActivityActionIchl1ChecklistItemNumber(local.index, JavaCast("string", local.activActItmNm))>
                <cfset local.svMarkedAgendaObj.setAsStringImportGrpActivityActionIchl1ChecklistItemDate(local.index, JavaCast("string", local.activActDt))>
                <cfset local.svMarkedAgendaObj.setImportGrpActivityActionIchl1ChecklistItemTextAnswer(local.index, JavaCast("string", local.activActAnswer))>
                <cfset local.svMarkedAgendaObj.setImportGrpActivityActionIchl1ChecklistItemComment(local.index, JavaCast("string", local.activActComnt))>

                <!--- if future agenda exists add proxy method --->
                <cfif isDefined("local.fAgendaId")>
                    <cfset local.svMarkedAgendaObj.setAsStringImportGrpActivityCopyToIagn1AgendaId(local.index, JavaCast("double", local.fAgendaId))>
                    <cfset local.svMarkedAgendaObj.setImportGrpActivityActCopyFwdTnrccCommonWorkFlag(local.index, JavaCast("string", "Y"))>
                </cfif>

				<!--- adjust index count --->
                <cfset local.index++>
            </cfloop>

            <!--- pass in the current user's staff mem id --->
            <!--- set current user's id variable --->
            <cfset local.curUserId = local.saveMarkedAgenda.curUserId>
			<cfset local.svMarkedAgendaObj.setImportIstm1StaffMemberId(JavaCast("double", local.curUserId))>

            <!--- if approval date exist run methods --->
			<cfif local.saveMarkedAgenda.apprlDt NEQ "">
                <!--- set the variables needed --->
                <cfset local.agendaId = local.saveMarkedAgenda.search_agenda_dt>
			    <cfset local.apprlDt = Dateformat(local.saveMarkedAgenda.apprlDt,"yyyymmddHHmmssSSSSSS")>
                <cfset local.agendaDateTime = "#local.saveMarkedAgenda.curAgendaDt##local.saveMarkedAgenda.curAgendaTm#">
                <cfset local.agendaDateTime = Dateformat(local.agendaDateTime,"yyyymmddHHmmssSSSSSS")>

				<!--- run proxy methods --->
			    <cfset local.svMarkedAgendaObj.setAsStringImportIagn1AgendaId(JavaCast("double", local.agendaId))>
			    <cfset local.svMarkedAgendaObj.setAsStringImportIagn1AgendaDateAndTime(JavaCast("string", local.agendaDateTime))>
			    <cfset local.svMarkedAgendaObj.setAsStringImportIagn1AgendaApprovalDate(JavaCast("string", local.apprlDt))>
            </cfif>

            <!--- commissioners and genreal counsel agenda attendance --->
            <!--- set default index var --->
            <cfset local.index = 0>

            <!--- verify that general counsel has been passed in --->
            <cfif isDefined('local.saveMarkedAgenda.genCounsel')>
                <!--- first time gen counsel is being selected or no change in/same general counsel --->
                <cfif (ListGetAt(local.saveMarkedAgenda.orgGenCounsel,2) EQ 0) OR (ListGetAt(local.saveMarkedAgenda.orgGenCounsel,1) EQ ListGetAt(local.saveMarkedAgenda.genCounsel,2))>
                    <!--- update the commChairCnt variable by adding 1 --->
                    <cfset structUpdate(local.saveMarkedAgenda, "commChairCnt", ++local.saveMarkedAgenda.commChairCnt)>

                    <!--- add general counsel's id and title into local.saveMarkedAgenda struct --->
                    <cfset local.saveMarkedAgenda["commChair_#local.saveMarkedAgenda.commChairCnt#"] = local.saveMarkedAgenda.genCounsel>

                    <!--- add the agenda mem staff id to the orginal general counsel's variable and set in local.saveMarkedAgenda struct --->
                    <cfset local.saveMarkedAgenda["orgCommChair_#local.saveMarkedAgenda.commChairCnt#"] = ListGetAt(local.saveMarkedAgenda.orgGenCounsel,2)>

				<!--- replace existing general counsel --->
                <cfelseif ListGetAt(local.saveMarkedAgenda.orgGenCounsel,1) NEQ ListGetAt(local.saveMarkedAgenda.genCounsel,2)>
                    <!--- remove existing general counsel (START) --->
	                    <!--- update the commChairCnt variable by adding 1 --->
	                    <cfset structUpdate(local.saveMarkedAgenda, "commChairCnt", ++local.saveMarkedAgenda.commChairCnt)>

	                    <!--- add the agenda mem staff id to the orginal general counsel's variable and set in local.saveMarkedAgenda struct --->
	                    <cfset local.saveMarkedAgenda["orgCommChair_#local.saveMarkedAgenda.commChairCnt#"] = ListGetAt(local.saveMarkedAgenda.orgGenCounsel,2)>
	                <!--- remove existing general counsel (END) --->

                    <!--- add replacement general counsel (START) --->
                        <!--- update the commChairCnt variable by adding 1 --->
                        <cfset structUpdate(local.saveMarkedAgenda, "commChairCnt", ++local.saveMarkedAgenda.commChairCnt)>

                        <!--- add replacement general counsel's id and title into local.saveMarkedAgenda struct --->
                        <cfset local.saveMarkedAgenda["commChair_#local.saveMarkedAgenda.commChairCnt#"] = local.saveMarkedAgenda.genCounsel>

                        <!--- default the orginal general counsel's variable to 0 and set in local.saveMarkedAgenda struct --->
                        <cfset local.saveMarkedAgenda["orgCommChair_#local.saveMarkedAgenda.commChairCnt#"] = 0>
                    <!--- add replacement general counsel (END) --->
                </cfif>
                <cfdump var="#local.saveMarkedAgenda#" abort="true">
            </cfif>

			<cfloop index="local.i" from="1" to="#local.saveMarkedAgenda.commChairCnt#">
                <!--- set defaulr crud flag --->
				<cfset local.crudFlg = "">

                <cfif structKeyExists(local.saveMarkedAgenda,"commChair_#local.i#")>
                    <cfif local.saveMarkedAgenda["orgCommChair_#local.i#"] EQ 0>
					    <!---- set variables to use inside commissioner attendance proxy methods ---->
		                <cfset local.aStaffMemId = 0>
		                <cfset local.aStaffMemRlCd = Trim(ListGetAt(local.saveMarkedAgenda["commChair_#local.i#"],1))>
		                <cfset local.staffMemId = Trim(ListGetAt(local.saveMarkedAgenda["commChair_#local.i#"],2))>
		                <cfset local.crudFlg = "A">
                    </cfif>
                <cfelseif !structKeyExists(local.saveMarkedAgenda,"commChair_#local.i#")>
                    <cfif local.saveMarkedAgenda["orgCommChair_#local.i#"] NEQ 0>
                         <!---- set variables to use inside commissioner attendance proxy methods ---->
                         <cfset local.aStaffMemId = local.saveMarkedAgenda["orgCommChair_#local.i#"]>
                         <cfset local.crudFlg = "D">
                     </cfif>
                </cfif>

                <!---- commissioner and genreal counsel attendance proxy methods ---->
                <cfif local.crudFlg NEQ "">
                    <!--- methods needed for an add or delete --->
	                <cfset local.svMarkedAgendaObj.setImportGroupStaffCount(local.i)>
	                <cfset local.svMarkedAgendaObj.setImportGrpStaffIagn1AgendaStaffMemId(local.index, JavaCast("double", local.aStaffMemId))>

	                <!--- methods needed for an add only --->
                    <cfif local.crudFlg EQ "A">
		                <cfset local.svMarkedAgendaObj.setImportGrpStaffIagn1AgendaStaffMemRoleCode(local.index, JavaCast("string", local.aStaffMemRlCd))>
		                <cfset local.svMarkedAgendaObj.setImportGrpStaffIstm1StaffMemberId(local.index, JavaCast("double", local.staffMemId))>
					</cfif>

                    <!--- flag for an add or delete --->
                    <cfset local.svMarkedAgendaObj.setImportGrpStaffCrudIndTnrccCommonWorkFlag(local.index, JavaCast("string", local.crudFlg))>

                    <!--- adjust index count --->
                    <cfset local.index++>
                </cfif>
            </cfloop>

            <!---- execute the proxy ---->
            <cfset local.svMarkedAgendaObj.execute()>

            <!--- populate return struct based on proxy outcome --->
            <cfif local.svMarkedAgendaObj.getExportIerr1FormattedErrorReturnCode() EQ 1 AND local.svMarkedAgendaObj.getExportIerr1FormattedErrorReasonCode() EQ 0>
                <cfset local.rtnStruct.success = "Y">
                <cfset local.rtnStruct.errorID = 0>

                <!--- success message depending on save or approval --->
                <cfif local.saveMarkedAgenda.apprlDt NEQ "">
                    <cfset local.rtnStruct.errorMSG = "The Agenda was successfully approved.">
                <cfelse>
                    <cfset local.rtnStruct.errorMSG = "The Agenda was successfully saved.">
                </cfif>

                <!--- populate return struct with proxy output --->
                <cfset local.rtnStruct.returnCode = local.svMarkedAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                <cfset local.rtnStruct.reasonCode = local.svMarkedAgendaObj.getExportIerr1FormattedErrorReasonCode()>
            <cfelse>
                <cfset local.rtnStruct.success = "N">
                <cfset local.rtnStruct.errorID = 4>

                <!--- populate return struct with proxy output --->
                <cfset local.rtnStruct.returnCode = local.svMarkedAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                <cfset local.rtnStruct.reasonCode = local.svMarkedAgendaObj.getExportIerr1FormattedErrorReasonCode()>
                <cfset local.rtnStruct.errorMSG = local.svMarkedAgendaObj.getExportIerr1FormattedErrorFormattedErrorMessage()>
                <cfset local.rtnStruct.agendaID = TRIM(local.saveMarkedAgenda.search_agenda_dt)>
            </cfif>

            <!---- delete add form struct ---->
            <cfset structClear(local.saveMarkedAgenda)>

            <!---- redirect the user based of proxy success ---->
            <cfif local.rtnStruct.success EQ "N">
               <!---- set process errors to client variable ---->
               <cfwddx action="cfml2wddx" input="#local.rtnStruct#" output="client.markedAgendaProcessErrors">

               <!---- delete proxy error struct ---->
               <cfset structClear(local.rtnStruct)>

               <!---- send user back to try again ---->
               <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#&nAgendaDt=#local.rtnStruct.agendaID#" addtoken="no">
            <cfelse>
               <!---- clean up variables (START) ---->
                   <!---- delete client variable ---->
                   <cfset DeleteClientVariable('vEAGC0800markedAgenda')>

                   <!---- delete proxy error struct ---->
                   <cfset structClear(local.rtnStruct)>

                   <!---- delete agenda process errors client variable ---->
                   <cfset DeleteClientVariable("markedAgendaProcessErrors")>
               <!---- clean up variables (END) ---->

               <!---- send user back to marked agenda ---->
               <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#&nAgendaDt=#local.rtnStruct.agendaID#" addtoken="no">
            </cfif>
        </cfif>
        <!---- ****************************************
        //////////  SAVE MARKED AGENDA ENDS  //////////
        ***************************************** ---->



        <!---- ****************************************
        ////////// APPROVE MARKED AGENDA BEGINS //////////
        ***************************************** ---->
		<cfif isDefined("local.attributes.apprAgenda")>

            <!--- call method to place form data into a struct --->
            <cfset application.utilsObj.createFormStruct(local.attributes, "vEAGC0800markedAgenda")>

            <!---- set the form data client variable to a struct ---->
            <cfwddx action="wddx2cfml" input="#client.vEAGC0800markedAgenda#" output="local.approveMarkedAgenda">
            <!--- <cfdump var="#local.approveMarkedAgenda#" abort="true"> --->

            <!---- save marked agenda (START) ---->
            <cfset local.apprvMarkedAgendaObj = createObject("Java", "Cid008sc.Abean.Cidr7800MarkAgendaMaint").init()>
            <cfset local.apprvMarkedAgendaObj.setImportApplicationTnrccCommonWorkApplicationName(arguments.myFusebox.variables().this.appName)>
            <cfset local.apprvMarkedAgendaObj.setClientID(JavaCast("string", client.userID))>
            <cfset local.apprvMarkedAgendaObj.setClientPassword(JavaCast("string", client.pw))>

            <!---- set imports for proxy call ---->
            <cfset local.apprvMarkedAgendaObj.setCommandSent("APPROVE")>

            <!--- if approval date exist run methods --->
            <cfif local.approveMarkedAgenda.apprlDt NEQ "">
                <!--- set the variables needed --->
                <cfset local.agendaId = local.approveMarkedAgenda.search_agenda_dt>
                <cfset local.apprlDt = Dateformat(local.approveMarkedAgenda.apprlDt,"yyyymmddHHmmssSSSSSS")>
                <cfset local.agendaDateTime = "#local.approveMarkedAgenda.curAgendaDt##local.approveMarkedAgenda.curAgendaTm#">
                <cfset local.agendaDateTime = Dateformat(local.agendaDateTime,"yyyymmddHHmmssSSSSSS")>

                <!--- run proxy methods --->
                <cfset local.apprvMarkedAgendaObj.setImportIagn1AgendaId(JavaCast("double", 12265654465225))>
                <cfset local.apprvMarkedAgendaObj.setAsStringImportIagn1AgendaDateAndTime(JavaCast("string", local.agendaDateTime))>
                <cfset local.apprvMarkedAgendaObj.setAsStringImportIagn1AgendaApprovalDate(JavaCast("string", local.apprlDt))>
            </cfif>

            <!--- commissioners agenda attendance --->
            <!--- set default index var --->
            <cfset local.index = 0>

            <!--- verify that general counsel has been passed in --->
            <cfif isDefined('local.approveMarkedAgenda.genCounsel')>
                <!--- first time gen counsel is being selected or no change in/same general counsel --->
                <cfif (ListGetAt(local.approveMarkedAgenda.orgGenCounsel,2) EQ 0) OR (ListGetAt(local.approveMarkedAgenda.orgGenCounsel,1) EQ ListGetAt(local.approveMarkedAgenda.genCounsel,2))>
                    <!--- update the commChairCnt variable by adding 1 --->
                    <cfset structUpdate(local.approveMarkedAgenda, "commChairCnt", ++local.approveMarkedAgenda.commChairCnt)>

                    <!--- add general counsel's id and title into local.approveMarkedAgenda struct --->
                    <cfset local.approveMarkedAgenda["commChair_#local.approveMarkedAgenda.commChairCnt#"] = local.approveMarkedAgenda.genCounsel>

                    <!--- add the agenda mem staff id to the orginal general counsel's variable and set in local.approveMarkedAgenda struct --->
                    <cfset local.approveMarkedAgenda["orgCommChair_#local.approveMarkedAgenda.commChairCnt#"] = ListGetAt(local.approveMarkedAgenda.orgGenCounsel,2)>

                <!--- replace existing general counsel --->
                <cfelseif ListGetAt(local.approveMarkedAgenda.orgGenCounsel,1) NEQ ListGetAt(local.approveMarkedAgenda.genCounsel,2)>
                    <!--- remove existing general counsel (START) --->
                        <!--- update the commChairCnt variable by adding 1 --->
                        <cfset structUpdate(local.approveMarkedAgenda, "commChairCnt", ++local.approveMarkedAgenda.commChairCnt)>

                        <!--- add the agenda mem staff id to the orginal general counsel's variable and set in local.approveMarkedAgenda struct --->
                        <cfset local.approveMarkedAgenda["orgCommChair_#local.approveMarkedAgenda.commChairCnt#"] = ListGetAt(local.approveMarkedAgenda.orgGenCounsel,2)>
                    <!--- remove existing general counsel (END) --->

                    <!--- add replacement general counsel (START) --->
                        <!--- update the commChairCnt variable by adding 1 --->
                        <cfset structUpdate(local.approveMarkedAgenda, "commChairCnt", ++local.approveMarkedAgenda.commChairCnt)>

                        <!--- add replacement general counsel's id and title into local.approveMarkedAgenda struct --->
                        <cfset local.approveMarkedAgenda["commChair_#local.approveMarkedAgenda.commChairCnt#"] = local.approveMarkedAgenda.genCounsel>

                        <!--- default the orginal general counsel's variable to 0 and set in local.approveMarkedAgenda struct --->
                        <cfset local.approveMarkedAgenda["orgCommChair_#local.approveMarkedAgenda.commChairCnt#"] = 0>
                    <!--- add replacement general counsel (END) --->
                </cfif>
                <cfdump var="#local.approveMarkedAgenda#" abort="true">
            </cfif>

            <cfloop index="local.i" from="1" to="#local.approveMarkedAgenda.commChairCnt#">
                <!--- set defaulr crud flag --->
                <cfset local.crudFlg = "">

                <cfif structKeyExists(local.approveMarkedAgenda,"commChair_#local.i#")>
                    <cfif local.approveMarkedAgenda["orgCommChair_#local.i#"] EQ 0>
                        <!---- set variables to use inside commissioner attendance proxy methods ---->
                        <cfset local.aStaffMemId = 0>
                        <cfset local.aStaffMemRlCd = Trim(ListGetAt(local.approveMarkedAgenda["commChair_#local.i#"],1))>
                        <cfset local.staffMemId = Trim(ListGetAt(local.approveMarkedAgenda["commChair_#local.i#"],2))>
                        <cfset local.crudFlg = "A">
                    </cfif>
                <cfelseif !structKeyExists(local.approveMarkedAgenda,"commChair_#local.i#")>
                    <cfif local.approveMarkedAgenda["orgCommChair_#local.i#"] NEQ 0>
                         <!---- set variables to use inside commissioner attendance proxy methods ---->
                         <cfset local.aStaffMemId = local.approveMarkedAgenda["orgCommChair_#local.i#"]>
                         <cfset local.crudFlg = "D">
                     </cfif>
                </cfif>

                <!---- commissioner attendance proxy methods ---->
                <cfif local.crudFlg NEQ "">
                    <!--- methods needed for an add or delete --->
                    <cfset local.apprvMarkedAgendaObj.setImportGroupStaffCount(local.i)>
                    <cfset local.apprvMarkedAgendaObj.setImportGrpStaffIagn1AgendaStaffMemId(local.index, JavaCast("double", local.aStaffMemId))>

                    <!--- methods needed for an add only --->
                    <cfif local.crudFlg EQ "A">
                        <cfset local.apprvMarkedAgendaObj.setImportGrpStaffIagn1AgendaStaffMemRoleCode(local.index, JavaCast("string", local.aStaffMemRlCd))>
                        <cfset local.apprvMarkedAgendaObj.setImportGrpStaffIstm1StaffMemberId(local.index, JavaCast("double", local.staffMemId))>
                    </cfif>

                    <!--- flag for an add or delete --->
                    <cfset local.apprvMarkedAgendaObj.setImportGrpStaffCrudIndTnrccCommonWorkFlag(local.index, JavaCast("string", local.crudFlg))>

                    <!--- adjust index count --->
                    <cfset local.index++>
                </cfif>
            </cfloop>

            <!---- execute the proxy ---->
            <cfset local.apprvMarkedAgendaObj.execute()>

            <!--- populate return struct based on proxy outcome --->
            <cfif local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorReturnCode() EQ 1 AND local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorReasonCode() EQ 0>
                <cfset local.rtnStruct.success = "Y">
                <cfset local.rtnStruct.errorID = 0>

                <!--- success message depending on approval --->
                <cfset local.rtnStruct.errorMSG = "The Agenda was successfully approved.">

                <!--- populate return struct with proxy output --->
                <cfset local.rtnStruct.returnCode = local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                <cfset local.rtnStruct.reasonCode = local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorReasonCode()>
            <cfelse>
                <cfset local.rtnStruct.success = "N">
                <cfset local.rtnStruct.errorID = 4>

                <!--- populate return struct with proxy output --->
                <cfset local.rtnStruct.returnCode = local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorReturnCode()>
                <cfset local.rtnStruct.reasonCode = local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorReasonCode()>
                <cfset local.rtnStruct.errorMSG = local.apprvMarkedAgendaObj.getExportIerr1FormattedErrorFormattedErrorMessage()>
                <cfset local.rtnStruct.agendaID = TRIM(local.approveMarkedAgenda.search_agenda_dt)>
            </cfif>

            <!---- delete add form struct ---->
            <cfset structClear(local.approveMarkedAgenda)>

            <!---- redirect the user based of proxy success ---->
            <cfif local.rtnStruct.success EQ "N">
               <!---- set process errors to client variable ---->
               <cfwddx action="cfml2wddx" input="#local.rtnStruct#" output="client.markedAgendaProcessErrors">

               <!---- delete proxy error struct ---->
               <cfset structClear(local.rtnStruct)>

               <!---- send user back to try again ---->
               <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#&nAgendaDt=#local.rtnStruct.agendaID#" addtoken="no">
            <cfelse>
               <!---- clean up variables (START) ---->
                   <!---- delete client variable ---->
                   <cfset DeleteClientVariable('vEAGC0800markedAgenda')>

                   <!---- delete proxy error struct ---->
                   <cfset structClear(local.rtnStruct)>

                   <!---- delete agenda process errors client variable ---->
                   <cfset DeleteClientVariable("markedAgendaProcessErrors")>
               <!---- clean up variables (END) ---->

               <!---- send user back to marked agenda ---->
               <cflocation url="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#&nAgendaDt=#local.rtnStruct.agendaID#" addtoken="no">
            </cfif>
        </cfif>
        <!---- ****************************************
        //////////  APPROVE MARKED AGENDA ENDS  //////////
        ***************************************** ---->


        <!--- call cfc/methods and set return values (BEGINS) --->
			<!--- get list size for paging --->
	        <cfset local.getListSize = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event, "CID EAGENDA DEFAULTS", "MARK AGENDA LIST SIZE")>
	        <cfset arguments.event.setValue("getListSize", local.getListSize.resultset.DESC_TXT)>

           <!--- document type and action dropdowns --->
           <cfset local.qryDoctype = application.utilsObj.getChildRefTblValues(arguments.myFusebox, arguments.event,  "ITEM CHECKLIST DOC TYPE", "AGENDA", "MARKED AGENDA INDICATOR")>
           <cfset arguments.event.setValue("qryDoctype", local.qryDoctype.resultset)>

           <cfset local.qryAction = application.utilsObj.getChildRefTblValues(arguments.myFusebox, arguments.event,  "ITEM CHECKLIST ITEM ACTION", "AGENDA", "MARKED AGENDA INDICATOR")>
           <cfset arguments.event.setValue("qryAction", local.qryAction.resultset)>

           <!--- get activity actions that indicate an agenda item is being carried forward to a future agenda --->
           <cfset local.qryActivityAct = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event, "CID CONTINUING ACTIVITY ACTIONS")>
           <cfset arguments.event.setValue("getActivityAct", local.qryActivityAct.resultset)>

           <!---- populate agenda date drop down ---->
		   <cfset local.qryMarkedAgendaDts = getMarkedAgendaDates(arguments.myFusebox, arguments.event)>
	       <cfset arguments.event.setValue("qryMarkedAgendaDts", local.qryMarkedAgendaDts.resultset)>

          <!---- get agency lock days ---->
          <cfset local.qryAgencyLockDays = application.utilsObj.getRefTblValues(arguments.myFusebox, arguments.event ,"CID EAGENDA DEFAULTS","AGENCY LOCK DAYS")>
          <cfset local.agencyLockDays = local.qryAgencyLockDays.resultset.DESC_TXT>

          <!--- get future agenda dates --->
		  <cfset local.qryAgendaDates = getAgendaDates(arguments.myFusebox, arguments.event, local.agencyLockDays)>
		  <cfset arguments.event.setValue("qryAgendaDts", local.qryAgendaDates.resultSet)>

          <!--- get current user id and title code --->
          <cfset local.qryCurrUser = application.utilsObj.getStaffMemberID(local.dsnUN, local.dsnPW, local.dsn, "#ucase(client.userID)#")>
          <cfset arguments.event.setValue("qryCurrUser", local.qryCurrUser.resultSet.staff_mem_id)>

           <!--- run when user has selected a new agenda date --->
           <!--- use to set "current" agenda related variables --->
           <cfif local.attributes.nAgendaDt NEQ "">
               <cfquery name="local.qoqMarkedAgendaDts" dbtype="query">
		           Select *
	               From [local].qryMarkedAgendaDts.resultset
	               Where agenda_id = <cfqueryparam value="#local.attributes.nAgendaDt#" cfsqltype="cf_sql_numeric">
               </cfquery>
           </cfif>

           <!--- marked agenda search (BEGINS) --->
               <!--- set default agenda related variables --->
               <cfset local.agendaID = local.attributes.nAgendaDt EQ "" ? local.qryMarkedAgendaDts.resultset.agenda_id : local.qoqMarkedAgendaDts.agenda_id>
               <cfset local.agendaDt = local.attributes.nAgendaDt EQ "" ? local.qryMarkedAgendaDts.resultset.agenda_dt : local.qoqMarkedAgendaDts.agenda_dt>
               <cfset local.agendaStatus = local.attributes.nAgendaDt EQ "" ? local.qryMarkedAgendaDts.resultset.status_cd : local.qoqMarkedAgendaDts.status_cd>
               <cfset local.agendaApprlDt = local.attributes.nAgendaDt EQ "" ? dateFormat(local.qryMarkedAgendaDts.resultset.appr_dt, "mm/dd/yyyy") : dateFormat(local.qoqMarkedAgendaDts.appr_dt, "mm/dd/yyyy")>
               <!--- if approval dt is "01/01/0001" set to null --->
               <cfset local.agendaApprlDt = local.agendaApprlDt EQ "01/01/0001" ? "":local.agendaApprlDt>

               <!--- current selected agenda date set to xfa in order to use in the view --->
               <cfset arguments.event.setValue("curAgendaDt", local.agendaDt)>

               <!--- current selected agenda date set to xfa in order to use in the view --->
               <cfset arguments.event.setValue("curAgendaID", local.agendaID)>

               <!--- current selected agenda status set to xfa in order to use in the view --->
               <cfset arguments.event.setValue("curAgendaStatus", local.agendaStatus)>

               <!--- current selected agenda approval date set to xfa in order to use in the view --->
               <cfset arguments.event.setValue("curApprlDt", local.agendaApprlDt)>
           <!--- marked agenda serach (ENDS) --->

           <!--- get commissioners and verify attendance to agenda (START) --->
			   <!--- get commissioners --->
               <cfset local.qryGetCommChair = getCommChair(arguments.myFusebox, arguments.event, dateFormat(local.agendaDt, "mm/dd/yyyy"))>

               <!--- verify if commissioner attended agenda --->
               <cfloop query="local.qryGetCommChair.resultset">
                   <cfquery name="local.commAttended" datasource="#local.dsn#" username="#local.dsnUN#" password="#local.dsnPW#">
                       Select aasm.agenda_staff_mem_id
                       From SM_STAFF_MEM ssm, an_agenda_staff_mem aasm
                       Where aasm.staff_mem_id = <cfqueryparam value="#Staff_Mem_ID#" cfsqltype="cf_sql_numeric">
                       AND aasm.agenda_id = <cfqueryparam value="#local.agendaID#" cfsqltype="cf_sql_numeric">
                   </cfquery>
                   <!--- append whether or not commissioner attended to a list --->
                   <cfset local.commAttend = local.commAttended.recordcount GT 0 ? ListAppend(local.commAttend, local.commAttended.agenda_staff_mem_id): ListAppend(local.commAttend, 0)>
               </cfloop>

               <!--- add a new column to existing commissioner's table called attended --->
               <!--- update new column with the result list created from the local.commAttended query --->
               <!--- use cf function listToArray --->
               <cfset queryAddColumn(local.qryGetCommChair.resultset, "attendedAgenda",listToArray(local.commAttend))>

	           <!--- commissioner qry results set to xfa in order to use in the view --->
	           <cfset arguments.event.setValue("qryGetCommChair", local.qryGetCommChair.resultset)>
           <!--- get commissioners and verify attendance to agenda (END) --->

           <!--- get general counsel --->
           <cfset local.qryGetGenCounsel = getGenCounsel(arguments.myFusebox, arguments.event, dateFormat(local.agendaDt, "mm/dd/yyyy"))>

           <!--- verify if general counsel attended agenda --->
           <cfloop query="local.qryGetGenCounsel.resultset">
               <cfquery name="local.gCounselAttended" datasource="#local.dsn#" username="#local.dsnUN#" password="#local.dsnPW#">
                   Select aasm.agenda_staff_mem_id
                   From SM_STAFF_MEM ssm, an_agenda_staff_mem aasm
                   Where aasm.staff_mem_id = <cfqueryparam value="#Staff_Mem_ID#" cfsqltype="cf_sql_numeric">
                   AND aasm.agenda_id = <cfqueryparam value="#local.agendaID#" cfsqltype="cf_sql_numeric">
               </cfquery>
               <!--- append whether or not general counsel attended to a list --->
			   <cfset local.gcAttend = local.gCounselAttended.recordcount GT 0 ? ListAppend(local.gcAttend, local.gCounselAttended.agenda_staff_mem_id): ListAppend(local.gcAttend, 0)>
           </cfloop>

           <!--- add a new column to existing general counsel's table called attended --->
           <!--- update new column with the result list created from the local.commAttended query --->
           <!--- use cf function listToArray --->
           <cfset queryAddColumn(local.qryGetGenCounsel.resultset, "attendedAgenda",listToArray(local.gcAttend))>

           <!--- general counsel qry results set to xfa in order to use in the view --->
           <cfset arguments.event.setValue("qryGetGenCounsel", local.qryGetGenCounsel.resultset)>

           <!--- search agenda item details for current agenda --->
           <cfset local.qryGetAgendaDetails = getAgendaItemsByAgendaID(arguments.myFusebox, arguments.event, local.agendaID)>

           <!--- get agenda item category from ref table and place it inside local.qryGetAgendaDetails results --->
           <cfloop query="local.qryGetAgendaDetails.resultset">
               <cfquery name="local.gAgendaItmCat" datasource="#local.dsn#" username="#local.dsnUN#" password="#local.dsnPW#">
		           Select name_txt
		           From rf_gen_cd
		           Where gen_cd_txt =  <cfqueryparam value="#cat_cd#" cfsqltype="cf_sql_varchar">
		           AND gen_cd_typ_id = <cfqueryparam value="2697" cfsqltype="cf_sql_numeric">
               </cfquery>
               <!--- append agenda item category name to a list --->
               <cfset local.aItmCat = ListAppend(local.aItmCat, local.gAgendaItmCat.name_txt)>
           </cfloop>

           <!--- add a new column to existing agenda details table called agendaItmCat --->
           <!--- update new column with the result list created from the local.gAgendaItmCat query --->
           <!--- use cf function listToArray --->
           <cfset queryAddColumn(local.qryGetAgendaDetails.resultset, "agendaItmCat",listToArray(local.aItmCat))>

           <!--- agenda details qry results set to xfa in order to use in the view --->
           <cfset arguments.event.setValue("getAgendaDetails", local.qryGetAgendaDetails.resultset)>

        <!--- call cfc/methods and set return values (ENDS) --->


         <cfreturn>
    </cffunction>
</cfcomponent>