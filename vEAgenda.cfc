
<cfcomponent displayname="vEAgenda" hint="main view circuit for eAgenda" output="false">
    <cffunction name="prefuseaction" displayname="prefuseaction" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <cfset local.attributes = arguments.MyFusebox.variables().attributes>

        <!--- *** START - SECURE COMP VERIFICATION *** --->
        <!--- check nav bar links secure component access --->

        <!---- set secured area ---->
        <cfset arguments.event.setValue("securedAreaName", "EAG NAVIGATION BAR")>

        <!---- secure component structure (BEGINS) ---->
        <cfset local.secStruct = StructNew()>
        <cfset local.secStruct.securedCompAccess = StructNew()>
        <cfset local.secStruct.securedCompAccess["AGENDA ITEM REQUEST"] = "Y">
        <cfset local.secStruct.securedCompAccess["AGENDA ITEMS"] = "Y">
        <cfset local.secStruct.securedCompAccess["AGENDA ITEMS SEARCH"] = "Y">
        <cfset local.secStruct.securedCompAccess["AGENDA SETTING LTR"] = "Y">
        <cfset local.secStruct.securedCompAccess["WORK QUEUE"] = "Y">
        <cfset local.secStruct.securedCompAccess["BUILD DRAFT AGENDA"] = "Y">
        <cfset local.secStruct.securedCompAccess["MARK AGENDA"] = "Y">
        <cfset local.secStruct.securedCompAccess["MAINTAIN AGENDAS"] = "Y">
        <cfset local.secStruct.securedCompAccess["FUTURE SET LIST"] = "Y">
        <cfset local.secStruct.securedCompAccess["ACTIVITY ACTIONS"] = "Y">
        <cfset local.secStruct.securedCompAccess["MARKED AGENDA"] = "Y">
        <cfset local.secStruct.securedCompAccess["FINALIZED AGENDA"] = "Y">
        <cfset local.secStruct.securedCompAccess["DRAFT AGENDA"] = "Y">
        <cfset arguments.event.setValue("secStruct", local.secStruct)>
        <!---- secure component structure (ENDS) ---->

        <!---
            Since the login screen manages the logout, and client vars are deleted on logout but the client.userID
            var is needed to check secure component access, don't call the secure comp function when the fuseaction
            is the login screen.
        --->
        <cfif local.attributes.fuseaction NEQ "eAgenda.EAGC0100eAgendaLogin">
            <!---- verify access to secure components ---->
            <cfset local.secComp = new com.Security()>
            <cfset local.secStruct = local.secComp.getSecuredComponent(argumentCollection:arguments)>
        </cfif>
        <!--- *** END - SECURE COMP VERIFICATION *** --->


        <!--- START Nav bar links [AT = "agenda team", PA = "program area"] --->
        <!---- Maintain Agendas [AT] ---->
        <cfset arguments.event.xfa("maintAgenda", "eAgenda.EAGC0600MaintainAgenda")>
        <!--- Work Queue [AT] --->
        <cfset arguments.event.xfa("wq", "eAgenda.EAGC0300workQueue")>
        <!--- Agenda Items [PA] --->
        <cfset arguments.event.xfa("ai", "eAgenda.EAGC0200agendaItems")>
        <!--- Activity Actions [AA] --->
        <cfset arguments.event.xfa("aa", "eAgenda.EAGC0500ActivityActions")>
        <!---- Marked Agenda [AT] ---->
        <cfset arguments.event.xfa("markedAgenda", "eAgenda.EAGC0800markedAgenda")>
        <!---- Search Agenda Items [AT & PA] ---->
        <cfset arguments.event.xfa("searchAgenda", "eAgenda.EAGC1000searchAgendaItems")>
        <!--- END Nav bar links --->

        <cfinclude template="dsp_tceq_home_header.cfm">

        <cfreturn>
    </cffunction>

    <cffunction name="postfuseaction" displayname="postfuseaction" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfinclude template="dsp_tceq_home_footer.cfm" />

        <cfreturn />
    </cffunction>

    <cffunction name="vEAGC0100eAgendaLogin" displayname="vEAGC0100eAgendaLogin" description="displays login page" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset local.error0 = arguments.event.getValue("error0") />
        <cfset local.error1 = arguments.event.getValue("error1") />
        <cfset local.error2 = arguments.event.getValue("error2") />
        <cfset local.clearvar = arguments.event.getValue("clearvar") />

        <cfset DeleteClientVariable("userID") />
        <cfset DeleteClientVariable("pw") />
        <cfset DeleteClientVariable("userType") />

        <!--- insert jQuery into <head> tag --->
        <cfhtmlHead text='
        <script type="text/javascript">
            $(document).ready(function(){
                $("##loginForm").validate({
                    rules: {
                        userID: {required: true},
                        pw: {required: true}
                    },
                    messages: {
                        userID: {required: "You must enter a User ID"},
                        pw: {required: "You must enter a Password"}
                    },
                    errorPlacement: function(error, element) {
                        if (element.attr("name") == "userID") {
                            $("##error1").html(error);
                            $("##error1").show();
                        }
                        else if (element.attr("name") == "pw") {
                            $("##error2").html(error);
                            $("##error2").show();
                        }
                        else {
                            error.insertAfter(element);
                        }
                    },
                    submitHandler: function(form){
                        form.submit();
                    }
                });
            });
        </script>
        ' >

        <cfoutput>

        <div id="content">
            <br />
            <br />
            <br />
            <div align="center">
                <h3>#arguments.event.getValue("pagesubheader")#</h3>
                <br />
                <form action="#arguments.myFusebox.getMyself()##arguments.event.xfa('next')#" name="loginForm" id="loginForm" method="post">
                    <div style="width:55%; align:center" id="fieldset">
                        <fieldset class="border" style="padding-top:-12%; width:70%;">
                            <div style="padding:2%">
                                <label for="userID">User ID: <span id="error1" class="redbold" aria-live="assertive">#local.error1#</span> </label>
                            </div>
                            <div>
                                <span class="required">*</span>&nbsp;<input type="text" name="userID" id="userID" size="32" maxlength="8" value="" />
                            </div>
                            <div style="padding:2%">
                                <label for="pw">Password: <span id="error2" class="redbold" aria-live="assertive">#local.error2#</span></label>
                            </div>
                            <div>
                                <span class="required">*</span>&nbsp;<input type="password" name="pw" id="pw" size="32" maxlength="20" value="" />
                            </div>
                            <div style="padding:2%" id="formButtons">
                                <input type="submit" value="Login" class="buttonfield" title="Login to eAgenda" />
                                <span style="padding-left:5%; margin-left:5%">
                                    <input type="reset" value="Clear" class="buttonfield" title="Clear" />
                                </span>
                                <div id="errorMsg">
                                    <p>
                                        <span class="redbold">#local.error0#</span>
                                    </p>
                                </div>
                            </div>
                            <span class="required">*</span>Mandatory field
                        </fieldset>
                    </div>
                </form>
            </div>
        </div>
        </cfoutput>

        <cfreturn />
    </cffunction>

    <!---
        vEAGC0300workQueue

        The main purpose of this web page is to allow the TCEQ Agenda Team users to view the Agenda Items list and manage their work.
        This web page will be flowed to from the logon page after a successful login or by clicking the Work Queue link on the Navigation bar.

     --->

    <cffunction name="vEAGC0300workQueue" displayname="vEAGC0300workQueue" description="agenda team landing page" access="public" returntype="void" output="true">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <cfset local.attributes = arguments.MyFusebox.variables().attributes>

        <!--- get secure component access --->
        <cfset local.showSaveBtn = arguments.event.getValue("securedCompAccessValidSave")>
        <cfset local.showNewAgendaItemBtn = arguments.event.getValue("securedCompAccessValidNew")>

        <!--- get queries --->
        <cfset local.docketNumReqList = arguments.event.getValue("docketNumReqList")>
        <cfset local.qryDocketNumReqList = local.docketNumReqList.resultSet>
        <cfset arguments.event.setValue("qryDocketNumReqList", local.qryDocketNumReqList)>

        <cfset local.itemApprvReqList = arguments.event.getValue("itemApprvReqList")>
        <cfset local.qryItemApprvReqList = local.itemApprvReqList.resultSet>

        <cfset local.agendaDtReqList = arguments.event.getValue("agendaDtReqList")>
        <cfset local.qryAgendaDtReqList = local.agendaDtReqList.resultSet>

        <cfset local.qryAgendaDates = arguments.event.getValue("qryAgendaDates")>

        <!--- set defaults --->
        <cfparam name="local.attributes.CurrentPage" default="1">
        <cfparam name="local.attributes.sec" default="0">
        <cfset local.updateAgendaDtResult = arguments.event.getValue("updateAgendaDtResult")>

        <!---- set default display count (PAGING) ---->
        <cfset local.docketNumReqListSize = local.docketNumReqList.listSize>
        <cfset local.docketNumReqDispCnt = local.docketNumReqListSize.resultSet.desc_txt>
        <cfset arguments.event.setValue("docketNumReqDispCnt", local.docketNumReqDispCnt)>

        <cfset local.itemApprovalReqListSize = local.itemApprvReqList.listSize>
        <cfset local.itemApprovalReqDispCnt = local.itemApprovalReqListSize.resultSet.desc_txt>

        <cfset local.agendaDtReqListSize = local.agendaDtReqList.listSize>
        <cfset local.agendaDtReqDispCnt = local.agendaDtReqListSize.resultSet.desc_txt>

        <!---- set current page for each section (PAGING) ---->
        <cfif local.attributes.sec GT 0>
            <cfset local.section = local.attributes.sec>

            <cfswitch expression="#local.section#">
                <cfcase value="1">
                    <cfset local.currPgSec1 = local.attributes.CurrentPage>
                    <cfset local.currPgSec2 = local.attributes.currPgSec2Val>
                    <cfset local.currPgSec3 = local.attributes.currPgSec3Val>
                </cfcase>

                <cfcase value="2">
                    <cfset local.currPgSec1 = local.attributes.currPgSec1Val>
                    <cfset local.currPgSec2 = local.attributes.CurrentPage>
                    <cfset local.currPgSec3 = local.attributes.currPgSec3Val>
                </cfcase>

                <cfcase value="3">
                    <cfset local.currPgSec1 = local.attributes.currPgSec1Val>
                    <cfset local.currPgSec2 = local.attributes.currPgSec2Val>
                    <cfset local.currPgSec3 = local.attributes.CurrentPage>
                </cfcase>

                <cfdefaultcase>
                    <cfset local.currPgSec1 = 1>
                    <cfset local.currPgSec2 = 1>
                    <cfset local.currPgSec3 = 1>
                </cfdefaultcase>
            </cfswitch>

        <cfelse>

            <!---- set defaults ---->
            <cfset local.currPgSec1 = 1>
            <cfset local.currPgSec2 = 1>
            <cfset local.currPgSec3 = 1>
            <!--- default query records to display --->
            <cfset local.fromPage = 1>
            <cfset local.toPage = 10>

        </cfif>

        <cfset arguments.event.setValue("currPgSec1", local.currPgSec1)>
        <cfset arguments.event.setValue("currPgSec2", local.currPgSec2)>
        <cfset arguments.event.setValue("currPgSec3", local.currPgSec3)>

        <!--- insert jQuery into <head> tag --->
        <cfhtmlHead text='
            <script type="text/javascript">
                function clearChanges(fa) {
                    location.href = "#arguments.myFusebox.getMyself()#"+fa;
                }
            </script>
        ' >

        <cfoutput>
        <!--- START error msg output --->
        <cfif isStruct(local.updateAgendaDtResult)>
            <cfset local.cnt = 1>
            <cfloop list="#local.updateAgendaDtResult.errorID#" index="local.i">
                <cfif local.i GT 0>
                    <br />
                    <div class="error_info">
                        <span class="redbold">&nbsp;ERROR! #ListGetAt(local.updateAgendaDtResult.errorMsg, local.cnt)#
                        <cfif local.i EQ 4> <!--- PROXY ERROR --->
                            <cfloop query="local.agendaDtReqList">
                                <cfif TRIM(local.agendaDtReqList.agenda_item_id) EQ TRIM(ListGetAt(local.updateAgendaDtResult.agendaItemID, local.cnt))>
                                    &nbsp;Docket Number: #TRIM(local.agendaDtReqList.agy_dkt_num_txt)#
                                </cfif>
                            </cfloop>
                            , Return Code: #ListGetAt(local.updateAgendaDtResult.returnCode, local.cnt)#, Reason Code: #ListGetAt(local.updateAgendaDtResult.reasonCode, local.cnt)#
                        </cfif>
                        </span>
                    </div>
                    <cfset local.cnt++>
                </cfif>
            </cfloop>
        </cfif>
        <!--- END error msg output --->
        <div class="content" id="content">
            <hr />
            <form action="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#" name="workQueue" id="workQueue" method="post">
                <fieldset>
                    <legend>Docket Number Requested</legend>
                    <cfset dspDocketNumReqList(arguments.myFusebox, arguments.event, 1)>
                </fieldset>

                <fieldset>
                    <legend>Item Approval Requested</legend>

                    <cfif local.qryItemApprvReqList.recordCount GT 0>
                        <!--- call Paging object --->
                        <cfset local.PagingSec2 = application.utilsObj.pageThru(local.qryItemApprvReqList.recordCount, local.itemApprovalReqDispCnt, 50, local.currPgSec2, cgi.SCRIPT_NAME, "&fuseaction=#arguments.event.xfa('paging')#&sec=2&currPgSec1Val=#local.currPgSec1#&currPgSec2Val=#local.currPgSec2#&currPgSec3Val=#local.currPgSec3#&flow=ns")>

                        <!---- top paging displayed (BEGINS) ---->
                        <div style="padding-bottom:2px">
                            #local.PagingSec2.PT_PageThru#&nbsp;
                            #local.PagingSec2.PT_StartRow#-#local.PagingSec2.PT_EndRow#
                            &nbsp;of&nbsp;
                            #local.qryItemApprvReqList.recordCount#&nbsp;
                            <cfif local.qryItemApprvReqList.recordCount EQ 1>Record<cfelse>Records</cfif>
                        </div>
                        <!---- top paging displayed (ENDS) ---->

                        <!---- set qry start and stop ---->
                        <cfset local.fromPage = local.PagingSec2.PT_StartRow>
                        <cfset local.toPage = local.PagingSec2.PT_EndRow>

                        <table class="datadisplay" id="itemApproveRequestTbl">
                            <tr>
                                <th scope="col">Proposed Agenda Date</th>
                                <th scope="col">Docket Number</th>
                                <th scope="col">Item</th>
                                <th scope="col">Additional ID</th>
                                <th scope="col">Regulated Entity</th>
                                <th scope="col">Principal</th>
                            </tr>
                            <cfloop query="local.qryItemApprvReqList" startrow="#local.fromPage#" endrow="#local.toPage#">
                                <cfset local.sendID = local.qryItemApprvReqList.agy_dkt_num_txt NEQ "" ? "&agendaItemID=#agenda_item_id#":"&itemID=#item_id#">
                                <tr>
                                    <td>#TRIM(local.qryItemApprvReqList.req_dt)#</td>
                                    <td><a href="#arguments.myFusebox.getMyself()##arguments.event.xfa('link')##local.sendID#&mode=edit">#TRIM(local.qryItemApprvReqList.agy_dkt_num_txt)#</a></td>
                                    <td>#TRIM(local.qryItemApprvReqList.item_num)#</td>
                                    <td>#TRIM(local.qryItemApprvReqList.pgm_cd)# #TRIM(local.qryItemApprvReqList.addn_num_txt)#<cfif local.qryItemApprvReqList.multi_addn_num EQ "Y">*</cfif></td>
                                    <td>#TRIM(local.qryItemApprvReqList.re_num_txt)# #LEFT(TRIM(local.qryItemApprvReqList.reg_ent_name),20)#<cfif local.qryItemApprvReqList.multi_re EQ "Y">*</cfif></td>
                                    <td>#TRIM(local.qryItemApprvReqList.princ_num_txt)# #LEFT(TRIM(local.qryItemApprvReqList.princ_name), 20)#<cfif local.qryItemApprvReqList.multi_princ EQ "Y">*</cfif></td>
                                </tr>
                            </cfloop>
                        </table>

                        <!---- bottom paging displayed (BEGINS) ---->
                        <div style="padding-bottom:2px">
                            #local.PagingSec2.PT_PageThru#&nbsp;
                            #local.PagingSec2.PT_StartRow#-#local.PagingSec2.PT_EndRow#
                            &nbsp;of&nbsp;
                            #local.qryItemApprvReqList.recordCount#&nbsp;
                            <cfif local.qryItemApprvReqList.recordCount EQ 1>Record<cfelse>Records</cfif>
                        </div>
                        <!---- bottom paging displayed (ENDS) ---->
                    <cfelse>
                        <br /><span class="redbold">No Item Approval Requested Items Available</span><br />
                    </cfif>
                </fieldset>

                <fieldset>
                    <legend>Agenda Date Required</legend>

                    <cfif local.qryAgendaDtReqList.recordCount GT 0>
                        <!--- call Paging object --->
                        <cfset local.PagingSec3 = application.utilsObj.pageThru(local.qryAgendaDtReqList.recordCount, local.agendaDtReqDispCnt, 50, local.currPgSec3, cgi.SCRIPT_NAME, "&fuseaction=#arguments.event.xfa('paging')#&sec=3&currPgSec1Val=#local.currPgSec1#&currPgSec2Val=#local.currPgSec2#&currPgSec3Val=#local.currPgSec3#&flow=ns")>

                        <!---- top paging displayed (BEGINS) ---->
                        <div style="padding-bottom:2px">
                            #local.PagingSec3.PT_PageThru#&nbsp;
                            #local.PagingSec3.PT_StartRow#-#local.PagingSec3.PT_EndRow#
                            &nbsp;of&nbsp;
                            #local.qryAgendaDtReqList.recordCount#&nbsp;
                            <cfif local.qryAgendaDtReqList.recordCount EQ 1>Record<cfelse>Records</cfif>
                        </div>
                        <!---- top paging displayed (ENDS) ---->

                        <!---- set qry start and stop ---->
                        <cfset local.fromPage = local.PagingSec3.PT_StartRow>
                        <cfset local.toPage = local.PagingSec3.PT_EndRow>

                        <table class="datadisplay" id="agendaDateReqTbl">
                            <tr>
                                <th scope="col">Docket Number</th>
                                <th scope="col">Item</th>
                                <th scope="col">Additional ID</th>
                                <th scope="col">Regulated Entity</th>
                                <th scope="col">Principal</th>
                                <th scope="col">Agenda Date</th>
                            </tr>
                            <cfloop query="local.qryAgendaDtReqList" startrow="#local.fromPage#" endrow="#local.toPage#">
                                <cfset local.sendID = local.qryAgendaDtReqList.agy_dkt_num_txt NEQ "" ? "&agendaItemID=#agenda_item_id#":"&itemID=#item_id#">
                                <tr>
                                    <td><a href="#arguments.myFusebox.getMyself()##arguments.event.xfa('link')##local.sendID#&mode=edit">#TRIM(local.qryAgendaDtReqList.agy_dkt_num_txt)#</a></td>
                                    <td>#TRIM(local.qryAgendaDtReqList.item_num)#</td>
                                    <td>#TRIM(local.qryAgendaDtReqList.pgm_cd)# #TRIM(local.qryAgendaDtReqList.addn_num_txt)#<cfif local.qryAgendaDtReqList.multi_addn_num EQ "Y">*</cfif></td>
                                    <td>#TRIM(local.qryAgendaDtReqList.re_num_txt)# #LEFT(TRIM(local.qryAgendaDtReqList.reg_ent_name),20)#<cfif local.qryAgendaDtReqList.multi_re EQ "Y">*</cfif></td>
                                    <td>#TRIM(local.qryAgendaDtReqList.princ_num_txt)# #LEFT(TRIM(local.qryAgendaDtReqList.princ_name), 20)#<cfif local.qryAgendaDtReqList.multi_princ EQ "Y">*</cfif></td>
                                    <td>
                                        <select id="#local.qryAgendaDtReqList.agenda_item_id#" name="#local.qryAgendaDtReqList.agenda_item_id#">
                                            <option value="0" selected="selected">PENDING</option>
                                            <cfloop query="local.qryAgendaDates">
                                                <option value="#local.qryAgendaDates.agenda_id#">#dateFormat(local.qryAgendaDates.agenda_dt, "mm/dd/yyyy")#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                </tr>
                            </cfloop>
                        </table>
                        <!---- bottom paging displayed (BEGINS) ---->
                        <div style="padding-bottom:2px">
                            #local.PagingSec3.PT_PageThru#&nbsp;
                            #local.PagingSec3.PT_StartRow#-#local.PagingSec3.PT_EndRow#
                            &nbsp;of&nbsp;
                            #local.qryAgendaDtReqList.recordCount#&nbsp;
                            <cfif local.qryAgendaDtReqList.recordCount EQ 1>Record<cfelse>Records</cfif>
                        </div>
                        <!---- bottom paging displayed (ENDS) ---->
                    <cfelse>
                        <br /><span class="redbold">No Agenda Date Required Items Available</span><br />
                    </cfif>
                    <br />
                    <div id="formButtons" style="text-align:center">
                        <!--- *** PLEASE NOTE: NON STANDARD FUNCTIONALITY OF CLEAR AND CANCEL BUTTONS ***
                            Because this is the landing page, it behaves slightly differently from other pages.
                            Usually, Cancel is going to return to the calling page, but here it resets the page
                            to its original condition (i.e., all three lists are reset to page 1 if they have moved forward).
                            Clear will leave all three lists on their current page, but will reset the Agenda Date drop downs
                            to their last saved value. Of course, it is possible when Clear is clicked that the current page
                            in all 3 lists will be page 1 and no Agenda Dates will have been changed, so the end result of
                            clicking Cancel and Clear could easily be the same. --->
                        <cfif local.showNewAgendaItemBtn EQ "Y">
                            <input type="button" id="newAgendaItemBtn" name="newAgendaItemBtn" value="New Agenda Item" class="buttonfield" title="New Agenda Item" onclick="f_clear_noconfirm('#arguments.event.xfa('link')#','new');">
                        </cfif>
                        <cfif local.qryAgendaDtReqList.recordCount GT 0>
                            <cfif local.showSaveBtn EQ "Y">
                                <input type="submit" id="btnWQSave" value="Save" class="buttonfield" title="save" />
                            </cfif>
                        <input type="reset" id="btnWQClear" value="Clear" class="buttonfield" title="clear" />
                        </cfif>
                        <input type="button" id="btnWQCancel" value="Cancel" class="buttonfield" title="cancel" onClick="clearChanges('#arguments.event.xfa('cancel')#')" />
                    </div>
                </fieldset>
            </form>
        </div>
        </cfoutput>

        <cfreturn>
    </cffunction>



    <!----
        The main purpose of this web page is to allow the TCEQ Agenda Team to maintain Agendas and their Categories order.
        This web page will be flowed to by clicking the Add Agenda link on the Navigation bar to add a new Agenda,
        or by clicking Agenda Type link in the Maintain Agenda page to edit an Agenda.

      
     ---->
    <cffunction name="vEAGC0700eAgendaDetail" displayname="vEAGC0700eAgendaDetail" description="displays eAgenda Detail page" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <!---- set defaults ---->
        <cfparam name="local.nxtCatOrder" default="1">
        <cfset local.attributes = myfusebox.variables().attributes>

        <!---- set default agenda item count ---->
        <cfset local.agendaItemCount = 0>
        <cfset local.disableDeleteCount = 0>

        <!---- default lock days ---->
        <cfset local.qryProgramAreaLockDays = arguments.event.getValue("qryProgramAreaLockDays")>
        <cfset local.qryAgencyLockDays = arguments.event.getValue("qryAgencyLockDays")>

        <!---- set agenda detail component access rights variable ---->
        <cfset local.saveAgendaRights = arguments.event.getValue("securedCompAccessValid_Save")>
        <cfset local.deleteAgendaRights = arguments.event.getValue("securedCompAccessValid_Delete")>

        <!---- set queries ---->
        <cfset local.qryAgendaStatus = arguments.event.getValue("qryAgendaStatus")>
        <cfset local.qryAgendaType = arguments.event.getValue("qryAgendaType")>
        <cfset local.qryAgendaCategory = arguments.event.getValue("qryAgendaCategory")>
        <cfset local.qryCurrentAgendaCategory = arguments.event.getValue("qryCurrentAgendaCategory")>
        <cfset local.qryAgendaDetail = arguments.event.getValue("qryAgendaDetail")>
        <cfset local.qryAgendaApproval = arguments.event.getValue("qryAgendaApproval")>
        <cfset local.qryAgendaItemCount = arguments.event.getValue("qryAgendaItemCount")>

        <!---- set header ---->
        <cfset local.qryGetHeader = arguments.event.getValue("qryGetHeader")>
        <cfset local.agendaHeader = isDefined("local.qryGetHeader.comnt_txt") AND local.qryGetHeader.comnt_txt NEQ "" ? local.qryGetHeader.comnt_txt : "">

        <!---- set footer ---->
        <cfset local.qryGetFooter = arguments.event.getValue("qryGetFooter")>
        <cfset local.agendaFooter = isDefined("local.qryGetFooter.comnt_txt") AND local.qryGetFooter.comnt_txt NEQ "" ? local.qryGetFooter.comnt_txt : "">

        <!---- set comments ---->
        <cfif local.attributes.mode EQ "EDIT">
            <cfset local.qryGetComments = arguments.event.getValue("qryGetComments")>
            <cfset local.agendaComment = isDefined('local.qryGetComments.comnt_txt') AND local.qryGetComments.comnt_txt NEQ "" ? local.qryGetComments.comnt_txt : "">
            <cfset local.agendaCommentID = local.qryGetComments.comnt_id>
            <cfset local.commentSupCedUserId = local.qryGetComments.superceded_user_id>
        <cfelse>
            <cfset local.agendaComment = "">
            <cfset local.agendaCommentID = 0>
            <cfset local.commentSupCedUserId = "">
        </cfif>

        <!---- date picker script (BEGINS) ---->
        <style>
            .ui-datepicker {border:5px groove #00F}
        </style>

        <cfsavecontent variable="jsCode">
            <cfoutput>
	            <script type='text/javascript'>
	                 <!---- confirm delete ---->
	                 function confirmDelete()
	                 {
	                   var  dAgenda = confirm("Are you sure you want to delete this Agenda?")

	                   if(dAgenda)
	                   {
	                    document.forms["agendaDetailForm"].submit();
	                   }
	                 }

	                 <!---- check status ---->
	                 function checkStatus(status)
	                 {
	                   if(status != "")
	                   {
		                   if(status != "Approved")
		                   {
		                    document.getElementById("Delete").disabled = false;
		                   }
	                   }
	                 }

	                 <!---- change/update header ---->
	                 function updateHeader()
	                 {
	                   var  fHeader = confirm("Header updated! \n Do you want to update all existing Agendas?")

	                   if(fHeader)
	                   {
	                    document.getElementById("headerFutureUse").value = 1;
	                    document.getElementById("headerUpdated").value = 1;
	                   }else{
	                    document.getElementById("headerUpdated").value = 1;
	                   }
	                 }

	                 <!---- change/update footer ---->
	                 function updateFooter()
	                 {
	                   var  fFooter = confirm("Footer updated! \n Do you want to update all existing Agendas?")

	                   if(fFooter)
	                   {
	                    document.getElementById("footerFutureUse").value = 1;
	                    document.getElementById("footerUpdated").value = 1;
	                   }else{
	                    document.getElementById("footerUpdated").value = 1;
	                   }
	                 }

	                <!---- change/update comments ---->
	                function updateComments()
	                {
	                   document.getElementById("commentsUpdated").value = 1;
	                }

	                 <!---- calculates program area & agency lock dates (BEGINS) ---->
	                 <!---- create var consisting of js date functions (START) ---->
	                 function prgmLockDate(prgmDays,agencyDays,date)
	                 {
	                     // set default dates
	                     var pDate = new Date(date);
	                     var aDate = new Date(date);

	                     // set program area lock date
	                     pDate.setDate(pDate.getDate() + prgmDays);

	                     // set agency lock date
	                     aDate.setDate(aDate.getDate() + agencyDays);

	                     /************** program lock date **************/
	                     // set month
	                     if(pDate.getMonth() + 1 < 10)
	                         {
	                             prgmMonth = "0"+ (pDate.getMonth() + 1);
	                         }
	                     else
	                         {
	                             prgmMonth = pDate.getMonth() + 1;
	                         }

	                     // set day
	                     if(pDate.getDate() < 10)
	                         {
	                             prgmDay = "0"+ pDate.getDate();
	                         }
	                     else
	                         {
	                             prgmDay = pDate.getDate();
	                         }

	                     // set year
	                     prgmYear = pDate.getFullYear();


	                     /************** agency lock date **************/
	                     // set month
	                     if(aDate.getMonth() + 1 < 10)
	                         {
	                             agMonth = "0"+ (aDate.getMonth() + 1);
	                         }
	                     else
	                         {
	                             agMonth = aDate.getMonth() + 1;
	                         }

	                     // set day
	                     if(aDate.getDate() < 10)
	                         {
	                             agDay = "0"+ aDate.getDate();
	                         }
	                     else
	                         {
	                             agDay = aDate.getDate();
	                         }

	                     // set year
	                     agYear = aDate.getFullYear();

	                    /************** set dates/times & send dates/times to screen **************/
	                    // set default dates
	                    agencyLockDate = agMonth + "/" + agDay + "/" + agYear;
	                    programLockDate = prgmMonth + "/" + prgmDay + "/" + prgmYear;

	                    // set agenda default time
	                    document.getElementById("agendaTime").value = "09:30:00";

	                    // set agency lock date & time
	                    document.getElementById("agency_wide_lock_dt").value = agencyLockDate;
	                    document.getElementById("agency_wide_lockTime").value = "11:59:59";
	                    document.getElementById("agency_dt_time_ampm").value = "PM";

	                    // set program lock date & time
	                    document.getElementById("pgm_area_lock_dt").value = programLockDate;
	                    document.getElementById("pgm_area_lockTime").value = "11:59:59";
	                    document.getElementById("pgm_dt_time_ampm").value = "PM";
	                 }
	                 <!---- create var consisting of js date functions (END) ---->
	                 <!---- calculates program area & agency lock dates (ENDS) ---->

	                 <!---- validate agenda form fields (BEGINS) ---->
	                 <!---- create var consisting of jquery validation (START) ---->
	                 $(document).ready(function(){
	                   $("##gendaDetailForm").validate({
	                       rules:
	                       {
	                           agenda_dt: {required: true},
	                           agendaTime: {required: true},
	                           agenda_status: {required: true},
	                           agenda_type: {required: true},
	                           pgm_area_lock_dt: {required: true},
	                           pgm_area_lockTime: {required: true},
	                           agency_wide_lock_dt: {required: true},
	                           agency_wide_lockTime: {required: true}
	                       },
	                       messages:
	                       {
	                           agenda_dt: {required: "*You must enter a Agenda Date!"},
	                           agendaTime: {required: "*You must enter a Agenda Time!"},
	                           agenda_status: {required: "*You must enter a Agenda Status!"},
	                           agenda_type: {required:"*You must enter a Agenda Type!"},
	                           pgm_area_lock_dt: {required: "*You must enter a Program Area Lock Date!"},
	                           pgm_area_lockTime: {required: "*You must enter a Program Area Lock Time!"},
	                           agency_wide_lock_dt: {required: "*You must enter a Agency Date!"},
	                           agency_wide_lockTime: {required: "*You must enter a Agency Time!"}
	                       },
	                       errorPlacement: function(error, element) {
	                           if (element.attr("name") == "agenda_dt")
	                           {
	                               $("##agendaDateErr").html(error);
	                               $("##agendaDateErr").show();
	                           }
	                           else if (element.attr("name") == "agendaTime")
	                           {
	                               $("##agendaTimeErr").html(error);
	                               $("##agendaTimeErr").show();
	                           }
	                           else if (element.attr("name") == "agenda_status")
	                           {
	                               $("##agendaStatusErr").html(error);
	                               $("##agendaStatusErr").show();
	                           }
	                           else if (element.attr("name") == "agenda_type")
	                           {
	                               $("##agendaTypeErr").html(error);
	                               $("##agendaTypeErr").show();
	                           }
	                           else if (element.attr("name") == "pgm_area_lock_dt")
	                           {
	                               $("##prgmLockDateErr").html(error);
	                               $("##prgmLockDateErr").show();
	                           }
	                           else if (element.attr("name") == "pgm_area_lockTime")
	                           {
	                               $("##prgmLockTimeErr").html(error);
	                               $("##prgmLockTimeErr").show();
	                           }
	                           else if (element.attr("name") == "agency_wide_lock_dt")
	                           {
	                               $("##agencyLockDateErr").html(error);
	                               $("##agencyLockDateErr").show();
	                           }
	                           else if (element.attr("name") == "agency_wide_lockTime")
	                           {
	                               $("##agencyLockTimeErr").html(error);
	                               $("##agencyLockTimeErr").show();
	                           }
	                           else {
	                               error.insertAfter(element);
	                           }
	                       },
	                       submitHandler: function(form){
	                           form.submit();
	                       }
	                   });
	                 });
	                 <!---- create var consisting of jquery validation (END) ---->
	                 <!---- validate agenda form fields (ENDS) ---->
	             </script>
            </cfoutput>
        </cfsavecontent>

        <!---- javascript code display (START) ---->
        <cfhtmlhead text="#jsCode#">
        <!---- javascript code display (END) ---->

        <!---- javascript for date picker (START) ---->
        <cfhtmlhead text="#application.utilsObj.datePicker('agenda_dt,pgm_area_lock_dt,agency_wide_lock_dt')#">
        <!---- javascript for date picker (END) ---->

        <cfoutput>
            <div id="content">
            <fieldset>
                <!---- agenda form validation errors (BEGINS) ---->
                <cfif isDefined("client.agendaFormErrors")>
                    <cfwddx action="wddx2cfml" input="#client.agendaFormErrors#" output="local.stFormErrors">
                    <!---- delete client variable containing agenda form field errors ---->
                    <cfset DeleteClientVariable("agendaFormErrors")>
                    <cfif StructCount(local.stFormErrors) NEQ 0>
                        <p>
                            <span class="redbold">
                                <cfloop list="#structKeyList(local.stFormErrors)#" index="i">
                                    #local.stFormErrors[i]#
                                    <br />
                                </cfloop>
                            </span>
                        </p>
                        <!---- delete struct variable containing agenda form field errors ---->
                        <cfset StructClear(local.stFormErrors)>
                    </cfif>
                </cfif>
                <!---- agenda form validation errors (ENDS) ---->

                <!---- agenda form processing errors (BEGINS) ---->
                <cfif isDefined("client.agendaProcessErrors")>
                    <cfwddx action="wddx2cfml" input="#client.agendaProcessErrors#" output="local.stProcessErrors">
                    <!---- delete client variable containing agenda process errors ---->
                    <cfset DeleteClientVariable("agendaProcessErrors")>
                    <cfif local.stProcessErrors.success NEQ "Y">
                        <p>
                            <span class="redbold">
                                #local.stProcessErrors.errormsg#! <br />
                            </span>
                        </p>
                        <!---- delete struct variable containing agenda process errors ---->
                        <cfset StructClear(local.stProcessErrors)>
                    </cfif>
                </cfif>
                <!---- agenda form processing errors (ENDS) ---->

                <!---- convert form data client variable to structure ---->
                    <cfwddx action="wddx2cfml" input="#client.vEAGC0700eAgendaDetail#" output="local.stAgendaInfo">

                <!---- set local variables from existing agenda (BEGINS) ---->
                <cfif local.attributes.mode EQ "EDIT">
                    <cfset local.agendaID = local.qryAgendaDetail.agenda_id>
                    <cfset local.agendaApprovedBy = local.qryAgendaApproval.recordcount GT 0? "#local.qryAgendaApproval.first_name# #local.qryAgendaApproval.last_name#" : "">
                    <cfset local.agendaAmPm = timeFormat(local.qryAgendaDetail.agenda_dt, "tt")>
                    <cfset local.pmLockAmPm = timeFormat(local.qryAgendaDetail.pgm_area_lock_dt, "tt")>
                    <cfset local.agencyLockAmPm = timeFormat(local.qryAgendaDetail.agency_wide_lock_dt, "tt")>
                    <cfset local.agendaApprDate = dateFormat(local.qryAgendaDetail.agenda_appr_dt, "mm/dd/yyyy") NEQ "01/01/0001" ? dateFormat(local.qryAgendaDetail.agenda_appr_dt, "mm/dd/yyyy") : "">

                    <!---- get item count and delete count based off agenda item count qry ---->
                    <cfloop query="local.qryAgendaItemCount">
                        <cfif listFindNoCase("COMPLETED,ONGOING",local.qryAgendaItemCount.status_cd) GT 0>
                            <cfset local.disableDeleteCount++>
                        </cfif>
                        <cfset local.agendaItemCount += local.qryAgendaItemCount.agenda_item_count>
                    </cfloop>

                    <!---- decide if delete button should be disabled ---->
                    <cfset disableDelete = local.disableDeleteCount GT 0 OR local.qryAgendaDetail.agenda_status EQ "Approved" ? "disabled" : "">

                    <!---- update structure with query results ---->
                    <cfset structUpdate(local.stAgendaInfo, "agenda_dt", dateFormat(local.qryAgendaDetail.agenda_dt, "mm/dd/yyyy"))>
                    <cfset structUpdate(local.stAgendaInfo, "agendaTime", timeFormat(local.qryAgendaDetail.agenda_dt, "hh:mm"))>
                    <cfset structUpdate(local.stAgendaInfo, "agenda_status", local.qryAgendaDetail.agenda_status)>
                    <cfset structUpdate(local.stAgendaInfo, "agenda_type", local.qryAgendaDetail.agenda_typ)>
                    <cfset structUpdate(local.stAgendaInfo, "pgm_area_lock_dt", dateFormat(local.qryAgendaDetail.pgm_area_lock_dt, "mm/dd/yyyy"))>
                    <cfset structUpdate(local.stAgendaInfo, "pgm_area_lockTime", timeFormat(local.qryAgendaDetail.pgm_area_lock_dt, "hh:mm"))>
                    <cfset structUpdate(local.stAgendaInfo, "agency_wide_lock_dt", dateFormat(local.qryAgendaDetail.agency_wide_lock_dt, "mm/dd/yyyy"))>
                    <cfset structUpdate(local.stAgendaInfo, "agency_wide_lockTime", timeFormat(local.qryAgendaDetail.agency_wide_lock_dt, "hh:mm"))>
                <cfelse>
                    <!---- set local default variables ---->
                    <cfset local.agendaID = 0>
                    <cfset local.agendaAmPm = "AM">
                    <cfset local.pmLockAmPm = "AM">
                    <cfset local.agencyLockAmPm = "AM">
                </cfif>
                <!---- set variables for existing agenda (ENDS) ---->

                <legend>
                    Agenda Detail
                </legend>

                <form action="#arguments.myFusebox.getMyself()##arguments.event.xfa("next")#" name="agendaDetailForm" id="agendaDetailForm" method="post">
                    <!---- pass agenda id ---->
                    <input type="hidden" name="agenda_id" value="#local.agendaID#" />

                    <div id="proj">
                        <!---- agenda date/time (BEGINS) ---->
                        <p>
                            <!---- date input (START) ---->
                            <label for="agenda_dt" valign="bottom">Date:<span class="required">*</span></label>
                            <input type="text" name="agenda_dt" id="agenda_dt" size="11" maxlength="10" value="#local.stAgendaInfo.agenda_dt#" onChange="prgmLockDate(#local.qryProgramAreaLockDays#,#local.qryAgencyLockDays#,this.value);" />
                            <!---- date format ---->
                            (MM/DD/YYYY)
                            <!---- date input (END) ---->

                            <!---- time input (START) ---->
                            <span class="bold" style="vertical-align:top">Time:<span class="required">*</span></span>
                            <input type="text" name="agendaTime" id="agendaTime" size="6" maxlength="10" value="#local.stAgendaInfo.agendaTime#" />
                            <select name="agenda_dt_time_ampm" id="agenda_dt_time_ampm" style="font-size:11px;vertical-align:bottom">
                                <option value="">
                                    &nbsp;
                                </option>
                                <option value="AM" <cfif local.agendaAmPm EQ "AM">selected="selected"</cfif>>
                                    AM
                                </option>
                                <option value="PM" <cfif local.agendaAmPm EQ "PM">selected="selected"</cfif>>
                                    PM
                                </option>
                            </select>
                            <!---- time format ---->
                            (HH:MM) (AM/PM)
                            <!---- time input (END) ---->
                        </p>

                        <!---- validation errs (START) ---->
                        <p>
                            <div id="agendaDateErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                            <div id="agendaTimeErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                        </p>
                        <!---- validation errs (END) ---->
                        <!---- agenda date/time (ENDS) ---->

                        <!---- agenda status (BEGINS) ---->
                        <p>
                            <label for="agenda_status">Status:<span class="required">*</span></label>
                            <!---- set agenda status (START) ---->
                            <select name="agenda_status" id="agenda_status" onChange="checkStatus(this.value)">
                                <option value="">
                                    &nbsp;
                                </option>
                                <cfloop query="local.qryAgendaStatus">
                                    <option value="#codeText#" <cfif codeText EQ local.stAgendaInfo.agenda_status> selected="selected" </cfif>>
                                        #descText#
                                    </option>
                                </cfloop>
                            </select>
                            <!---- set agenda status (END) ---->
                        </p>

                        <!---- validation errs (START) ---->
                        <p>
                            <div id="agendaStatusErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                        </p>
                        <!---- validation errs (END) ---->

                        <!---- agenda status (ENDS) ---->

                        <!---- agenda type (BEGINS) ---->
                        <p>
                            <label for="agenda_type">Type:<span class="required">*</span></label>
                            <!---- set agenda type (START)---->
                            <select name="agenda_type" id="agenda_type">
                                <option value="">
                                    &nbsp;
                                </option>
                                <cfloop query="local.qryAgendaType">
                                    <option value="#TRIM(codeText)#" <cfif TRIM(codeText) EQ local.stAgendaInfo.agenda_type> selected="selected" </cfif>>
                                        #descText#
                                    </option>
                                </cfloop>
                            </select>
                            <!---- set agenda type (END) ---->
                        </p>

                        <!---- validation errs (START) ---->
                        <p>
                            <div id="agendaTypeErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                        </p>
                        <!---- validation errs (END) ---->
                        <!---- agenda type (ENDS) ---->

                        <!---- agenda program lock date/time (BEGINS) ---->
                        <p>
                            <!---- date input (START) ---->
                            <label for="pgm_area_lock_dt">Program Area Lock Date:<span class="required">*</span></label>
                            <input type="text" name="pgm_area_lock_dt" id="pgm_area_lock_dt" size="11" maxlength="10" value="#local.stAgendaInfo.pgm_area_lock_dt#" />
                            <!---- date format ---->
                            (MM/DD/YYYY)
                            <!---- date input (END) ---->

                            <!---- time input (START) ---->
                            <span class="bold" style="vertical-align:top">Time:<span class="required">*</span></span>
                            <input type="text" name="pgm_area_lockTime" id="pgm_area_lockTime" size="6" maxlength="10" value="#local.stAgendaInfo.pgm_area_lockTime#" />
                            <select name="pgm_dt_time_ampm" id="pgm_dt_time_ampm" style="font-size:11px; vertical-align:bottom">
                                <option value="">&nbsp;</option>
                                <option value="AM" <cfif local.pmLockAmPm EQ "AM">selected="selected"</cfif>>AM</option>
                                <option value="PM" <cfif local.pmLockAmPm EQ "PM">selected="selected"</cfif>>PM</option>
                            </select>
                            <!---- time format ---->
                            (HH:MM) (AM/PM)
                            <!---- time input (END) ---->
                        </p>

                        <!---- validation errs (START) ---->
                        <p>
                            <div id="prgmLockDateErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                            <div id="prgmLockTimeErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                        </p>
                        <!---- validation errs (END) ---->
                        <!---- agenda program lock date/time (ENDS) ---->

                        <!---- agenda agency lock date/time (BEGINS) ---->
                        <p>
                            <!---- date input (START)---->
                            <label for="agency_wide_lock_dt">Agency Lock Date:<span class="required">*</span></label>
                            <input type="text" name="agency_wide_lock_dt" id="agency_wide_lock_dt" size="11" maxlength="10" value="#local.stAgendaInfo.agency_wide_lock_dt#" />
                            <!---- date format ---->
                            (MM/DD/YYYY)
                            <!---- date input (END) ---->

                            <!---- time input (START) ---->
                            <span class="bold" style="vertical-align:top">Time:<span class="required">*</span></span>
                            <input type="text" name="agency_wide_lockTime" id="agency_wide_lockTime" size="6" maxlength="10" value="#local.stAgendaInfo.agency_wide_lockTime#" />
                            <select name="agency_dt_time_ampm" id="agency_dt_time_ampm"  style="font-size:11px; vertical-align:bottom">
                                <option value="">&nbsp;</option>
                                <option value="AM" <cfif local.agencyLockAmPm EQ "AM">selected="selected"</cfif>>AM</option>
                                <option value="PM" <cfif local.agencyLockAmPm EQ "PM">selected="selected"</cfif>>PM</option>
                            </select>
                            <!---- time format ---->
                            (HH:MM) (AM/PM)
                            <!---- time input (END) ---->
                        </p>

                        <!---- validation errs (START) ---->
                        <p>
                            <div id="agencyLockDateErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                            <div id="agencyLockTimeErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                        </p>
                        <!---- validation errs (END) ---->
                        <!---- agenda agency lock date/time (ENDS) ---->

                        <!---- when in edit mode add 3 sections (BEGINS) ---->
                        <cfif local.attributes.mode EQ "EDIT">
                            <!---- general counsel approval date ---->
                            <cfif local.agendaApprDate NEQ "">
	                            <p>
	                                <label for="general_counsel">General Counsel Approval Date:</label>
	                                <span class="required">#local.agendaApprDate#</span>
	                            </p>
                            </cfif>

                            <!---- approved by ---->
                            <cfif local.agendaApprovedBy NEQ "">
	                            <p>
	                                <label for="approved_by">Approved By:</label>
	                                <span class="required">#local.agendaApprovedBy#</span>
	                            </p>
                            </cfif>

                            <!---- agenda item count ---->
                            <p>
                                <label for="agenda_item_count">Agenda Item Count:</label>
                                <span class="required">#local.agendaItemCount#</span>
                            </p>
                        </cfif>
                        <!---- when in edit mode add 3 sections (ENDS) ---->
                        <p>
                            <!---- header ---->
                            <label for="header_txt">Header:</label>
                            <!---- input header ---->
                            <!---- written/formatted this way to eliminate white space from screen (slaughter 3/20/13) ---->
                            <cfif isDefined('local.stAgendaInfo.header_txt')>
                                <textarea name="header_txt" id="header_txt" cols="150" rows="4" onChange="updateHeader()">#local.stAgendaInfo.header_txt#
                                </textarea>
                            <cfelse>
                                <textarea name="header_txt" id="header_txt" cols="150" rows="4" onChange="updateHeader()">#local.agendaHeader#
                                </textarea>
                            </cfif>
                            <!---- pass hidden arguments need to modify header ---->
                            <input type="hidden" name="headerId" id="headerId" value="#local.qryGetHeader.comnt_id#" />
                            <input type="hidden" name="headerSupCedUserId" id="headerSupCedUserId" value="#local.qryGetHeader.superceded_user_id#" />
                            <input type="hidden" name="headerFutureUse" id="headerFutureUse" value="" />
                            <input type="hidden" name="headerUpdated" id="headerUpdated" value="" />
                        </p>

                        <p>
                            <!---- footer ---->
                            <label for="footer_txt">Footer:</label>
                            <!---- input footer ---->
                            <!---- written/formatted this way to eliminate white space from screen (slaughter 3/20/13) ---->
                            <cfif isDefined('local.stAgendaInfo.footer_txt')>
                                <textarea name="footer_txt" id="footer_txt" cols="150" rows="4" onChange="updateFooter()">#local.stAgendaInfo.footer_txt#
                                </textarea>
                            <cfelse>
                                <textarea name="footer_txt" id="footer_txt" cols="150" rows="4" onChange="updateFooter()">#local.agendaFooter#
                                </textarea>
                            </cfif>
                            <!---- pass hidden arguments need to modify footer ---->
                            <input type="hidden" name="footerId" id="footerId" value="#local.qryGetFooter.comnt_id#" />
                            <input type="hidden" name="footerSupCedUserId" id="footerSupCedUserId" value="#local.qryGetFooter.superceded_user_id#" />
                            <input type="hidden" name="footerFutureUse" id="footerFutureUse" value="" />
                            <input type="hidden" name="footerUpdated" id="footerUpdated" value="" />
                        </p>

                        <p>
                            <!---- comments ---->
                            <label for="comment_txt">Comment:</label>
                            <!---- input comments ---->
                            <!---- written/formatted this way to eliminate white space from screen (slaughter 3/20/13) ---->
                            <cfif isDefined('local.stAgendaInfo.comment_txt')>
                                <textarea name="comment_txt" id="comment_txt" cols="150" rows="4" onChange="updateComments()">#local.stAgendaInfo.comment_txt#
                                </textarea>
                            <cfelse>
                                <textarea name="comment_txt" id="comment_txt" cols="150" rows="4" onChange="updateComments()">#local.agendaComment#
                                </textarea>
                            </cfif>
                            <!---- pass hidden arguments need to modify comments ---->
                            <input type="hidden" name="commentId" id="commentId" value="#local.agendaCommentID#" />
                            <input type="hidden" name="commentSupCedUserId" id="commentSupCedUserId" value="#local.commentSupCedUserId#" />
                            <input type="hidden" name="commentsUpdated" id="commentsUpdated" value="" />
                        </p>
                        <cfif local.attributes.mode EQ "EDIT">
                            <!---- pass approval date ---->
                            <input type="hidden" name="approval_dt" id="approval_dt" value="#local.agendaApprDate#" />

                            <fieldset>
                                <legend>
                                    Agenda Category
                                </legend>
                                <div align="center" id="agendaCategory">
                                    <!---- current agenda categories (BEGINS) ---->
                                    <!---- send across category count ---->
                                    <input type="hidden" name="agendaCatRecCount" id="agendaCatRecCount" value="#local.qryCurrentAgendaCategory.recordcount#" />

                                    <cfloop query="local.qryCurrentAgendaCategory">
                                        <p>
                                                <input type="text" name="agendaCategory_#currentRow#" id="agendaCategory_#currentRow#" size="77" maxlength="77" value="#agenda_cat_name#" />
                                                <input type="hidden" name="agendaCategoryID_#currentRow#" id="agendaCategoryID_#currentRow#" value="#agenda_cat_id#" />
                                                <input type="hidden" name="agendaCatCode_#currentRow#" id="agendaCatCode__#currentRow#" value="#agenda_cat_cd#" />

                                            :
                                                <input type="text" name="agendaCatOrder_#currentRow#" id="agendaCatOrder_#currentRow#" size="3" maxlength="3" value="#agenda_cat_order#" />
                                        </p>
                                        <!---- set next agenda category order num ---->
                                        <cfset local.nxtCatOrder = local.qryCurrentAgendaCategory.agenda_cat_order + 1>
                                    </cfloop>
                                    <!---- current agenda categories (ENDS) ---->

                                    <!---- set new agenda category (ac) (BEGINS) ---->
                                    <p>
                                        <!---- titles ---->
                                        <span style="margin-left:15%;font-weight:bold">New Agenda Category Name</span>
                                        <span style="margin-left:25%;font-weight:bold">Category Type&nbsp;</span>
                                    </p>

                                    <p>
                                        <!---- new category name ---->
                                        <input type="text" name="new_category_name" id="new_category_name" style="margin-left:20%" size="77" maxlength="77" value="" />
                                        <!---- set new category ---->
                                        <select name="new_category_type" id="new_category_type">
                                            <option value="">
                                                &nbsp;
                                            </option>
                                            <cfloop query="local.qryAgendaCategory">
                                                <option value="CR" title="#descText#">
                                                    #LEFT(descText,20)#
                                                </option>
                                            </cfloop>
                                        </select>
                                        :
                                        <!---- set new category type ---->
                                        <input type="text" name="nxtCatOrder" id="nxtCatOrder" size="3" maxlength="3" value="#nxtCatOrder#" />
                                    </p>
                                    <!---- set new agenda category (ENDS) ---->
                                </div>
                            </fieldset>
                        </cfif>

                        <div align="center" id="compFooter">
                            <!---- secure component display (BEGINS) ---->
                            <p>
                                <!---- page name ---->
                                <cfset page_name="Maintain Agenda">

                                <!---- save agenda ---->
                                <cfif local.saveAgendaRights EQ "Y">
                                    <input type="submit" name="Save" value="Save" class="buttonfield" />
                                </cfif>

                                <!---- delete agenda ---->
                                <cfif local.attributes.mode EQ "EDIT">
                                    <cfif local.deleteAgendaRights EQ "Y">
                                        <input type="button" name="Delete" id="Delete" value="Delete" class="buttonfield" #disableDelete# onClick="confirmDelete()" />
                                    </cfif>
                                </cfif>

                                <!---- reset from field to original state ---->
                                <input type="button" name="Clear" value="Clear" class="buttonfield" onclick="f_clear_noconfirm('#arguments.event.xfa('current')#','#local.attributes.mode#','#local.agendaID#');" />

                                <!---- cancel modifications/additions to agenda ---->
                                <input type="button" name="Cancel" value="Cancel" class="buttonfield" onclick="f_cancel_confirm('#page_name#','#arguments.event.xfa('back')#');" />
                                <br />
                            </p>
                            <!---- secure component display (ENDS) ---->

                            <!---- notates required fields ---->
                            <p>
                                <span class="required">*</span> Mandatory field
                            </p>
                        </div>
                    </div>
                </form>
            </fieldset>
            </div>
        </cfoutput>

      <cfreturn>
    </cffunction>

    <!----
        The main purpose of this web page is to allow the TCEQ Agenda Team and the Program Areas to search for an Agenda Item using various search criteria.
        This web page will be flowed to by clicking the Search Agenda Items on the Navigation bar.

     ---->
    <cffunction name="vEAGC1000searchAgendaItems" displayname="vEAGC1000searchAgendaItems" description="displays agenda item search page" access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true" />
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true" />

        <!---- set default vars ---->
        <cfset local.attributes = arguments.MyFusebox.variables().attributes>

        <!---- set default display count and current page ---->
        <cfparam name="local.attributes.CurrentPage" default="1">

        <!---- set current page ---->
        <cfset local.currentPage = local.attributes.CurrentPage>

        <!--- get list size for paging --->
        <cfset local.displayCount = arguments.event.getValue("getListSize")>

        <!---- set default qry start and stop ---->
        <cfparam name="local.fromPage" default="1">
        <cfparam name="local.toPage" default="#local.displayCount#">

        <!---- set data driven variables ---->
        <cfset local.qryAgendaStatus = arguments.event.getValue("qryAgendaStatus")>
        <cfset local.qryNonCrAddtlId = arguments.event.getValue("qryNonCrAddtlId")>
        <cfset local.crProgramDropDown = arguments.event.getValue("crProgramDropDown")>
        <cfset local.agendaItmSrchRslts = arguments.event.getValue("agendaItmSrchRslts")>

        <!---- default vars ---->
        <cfparam name="message_code" default="success">

        <!---- javascript (BEGINS) ---->
        <cfsavecontent variable="jsCalls">
            <cfoutput>
                <script type='text/javascript'>
                        function clearForm(formName)
                        {
                            window.location.href=("#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#&flow=clear&formName="+formName);
                        }


                        $(document).ready(function(){
                               $("##docketSearchForm").validate({
                                   rules:
                                   {
                                       agy_dkt_num_txt: {required: true}
                                   },
                                   messages:
                                   {
                                       agy_dkt_num_txt: {required: "*You must enter a Docket Number!"}
                                   },
                                   errorPlacement: function(error, element) {
                                       if (element.attr("name") == "agy_dkt_num_txt")
                                       {
                                           $("##docketSearchErr").html(error);
                                           $("##docketSearchErr").show();
                                       }
                           },
                           submitHandler: function(form){
                               form.submit();
                           }
                       });

                          $("##agendaStatusSearchForm").validate({
                              rules:
                              {
                                  agendaStatus: {required: true}
                                   },
                              messages:
                              {
                                  agendaStatus: {required: "*You must select an Agenda Status!"}
                              },
                              errorPlacement: function(error, element) {
                                  if (element.attr("name") == "agendaStatus")
                                  {
                                      $("##statusSearchErr").html(error);
                                      $("##statusSearchErr").show();
                                  }
                              },
                                   submitHandler: function(form){
                                       form.submit();
                                   }
                               });

                          $("##crAddtlIdSearchForm").validate({
                              rules:
                              {
                                  cr_addn_num_txt: {required: true}
                              },
                              messages:
                              {
                                  cr_addn_num_txt: {required: "*You must enter an Additional ID!"}
                              },
                              errorPlacement: function(error, element) {
                                  if (element.attr("name") == "cr_addn_num_txt")
                                  {
                                      $("##crAddtlIdSearchErr").html(error);
                                      $("##crAddtlIdSearchErr").show();
                                  }
                              },
                              submitHandler: function(form){
                                  form.submit();
                              }
                          });

                          $("##nonCrAddtlIdSearchForm").validate({
                              rules:
                              {
                                  noncr_addn_num_txt: {required: true}
                              },
                              messages:
                              {
                                  noncr_addn_num_txt: {required: "*You must enter an Additional ID!"}
                              },
                              errorPlacement: function(error, element) {
                                  if (element.attr("name") == "noncr_addn_num_txt")
                                  {
                                      $("##nCrAddtlIdSearchErr").html(error);
                                      $("##nCrAddtlIdSearchErr").show();
                                  }
                              },
                              submitHandler: function(form){
                                  form.submit();
                              }
                          });

                          $("##regEntitySearchForm").validate({
                              rules:
                              {
                                  rn_ref_num_txt: {required: true}
                              },
                              messages:
                              {
                                  rn_ref_num_txt: {required: "*You must enter an RN Number!"}
                              },
                              errorPlacement: function(error, element) {
                                  if (element.attr("name") == "rn_ref_num_txt")
                                  {
                                      $("##regEntSearchErr").html(error);
                                      $("##regEntSearchErr").show();
                                  }
                              },
                              submitHandler: function(form){
                                  form.submit();
                              }
                          });

                          $("##customerNumSearchForm").validate({
                              rules:
                              {
                                  pr_ref_num_txt: {required: true}
                              },
                              messages:
                              {
                                  pr_ref_num_txt: {required: "*You must enter an CN Number!"}
                              },
                              errorPlacement: function(error, element) {
                                  if (element.attr("name") == "pr_ref_num_txt")
                                  {
                                      $("##custNumSearchErr").html(error);
                                      $("##custNumSearchErr").show();
                                  }
                              },
                              submitHandler: function(form){
                                  form.submit();
                              }
                          });
                      });
                </script>
            </cfoutput>
        </cfsavecontent>

        <!---- place js in html head ---->
        <cfhtmlhead text="#jsCalls#">

        <cfoutput>
            <div id="content">
                <div id="agendaItemSearch">
                    <!---- available search criteria (BEGINS) ---->
                    <fieldset>
                        <legend style="margin-top:-1%">Available Search Criteria</legend>
                        <br />

                        <!---- docket number search form (START) ---->
                        <cfif isDefined("client.vEAGC1000searchAgendaItems_docketNumber")>
                             <cfwddx action="wddx2cfml" input="#client.vEAGC1000searchAgendaItems_docketNumber#" output="local.stAnItmSrchCrit">
                         <cfelse>
                            <!---- set default search struct ---->
                            <cfparam name="local.stAnItmSrchCrit.agy_dkt_num_txt" default="">
                        </cfif>
                        <form name="docketSearchForm" id="docketSearchForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#" method="post">
                             <!---- set hidden field telling controller which form was submitted ---->
                            <input type="hidden" name="formSubmitted" id="formSubmitted" value="docketNum">

                            <fieldset>
                                <legend style="margin-top:-2%">Docket</legend>
                                    <p>
                                        <label for="docketNum">Docket&nbsp;Number:<span class="required">*</span></label>
                                        <input type="text" name="agy_dkt_num_txt" id="agy_dkt_num_txt" size="17" maxlength="15" value="#local.stAnItmSrchCrit.agy_dkt_num_txt#" tabindex="8" />
                                        &nbsp;<span class="forminstructions">(example format: 2001-1918-AIR, add -E for enforcement case.)</span>
                                        <div id="docketSearchErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                                    </p>
                                    <div>
                                        <span class="buttoninput">&nbsp;</span>
                                        <input type="submit" name="searchDocketNum" id="searchDocketNum" value="Search" class="buttonfield" />
                                        <input type="button" name="clearDocketNum" id="clearDocketNum"  value="Clear" class="buttonfield" onClick="clearForm('docketNum')" />
                                    </div>
                            </fieldset>
                        </form>
                        <!---- docket number search form (END) ---->

                        <br />

                        <!---- agenda item status search form (START) ---->
                        <cfif isDefined("client.vEAGC1000searchAgendaItems_agendaStatus")>
                            <cfwddx action="wddx2cfml" input="#client.vEAGC1000searchAgendaItems_agendaStatus#" output="local.stAnItmSrchCrit">
                        <cfelse>
                            <!---- set default search struct ---->
                            <cfparam name="local.stAnItmSrchCrit.agendaStatus" default="">
                        </cfif>

                        <form name="agendaStatusSearchForm" id="agendaStatusSearchForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#" method="post">
                            <!---- set hidden field telling controller which form was submitted ---->
                             <input type="hidden" name="formSubmitted" id="formSubmitted" value="agendaStatus">

                            <fieldset>
                                <legend style="margin-top:-2%">Agenda&nbsp;Item</legend>
                                    <p>
                                        <label for="agenda_dt">Status:<span class="required">*</span></label>
                                        <select name="agendaStatus" id="agendaStatus">
                                            <option value=""></option>
                                            <cfloop query="local.qryAgendaStatus">
                                                <option value="#Trim(codeText)#" <cfif local.stAnItmSrchCrit.agendaStatus EQ codeText>selected</cfif>>
                                                    #uCase(descText)#
                                                </option>
                                            </cfloop>
                                        </select>
                                        <div id="statusSearchErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                                    </p>
                                    <div>
                                        <span class="buttoninput">&nbsp;</span>
                                        <input type="submit" name="searchAgendaStatus" id="searchAgendaStatus" value="Search" class="buttonfield" />
                                        <input type="button" name="clearAgendaStatus" id="clearAgendaStatus"  value="Clear" class="buttonfield" onClick="clearForm('agendaStatus')" />
                                    </div>
                            </fieldset>
                        </form>
                        <!---- agenda item status search form (END) ---->

                        <br />

                        <!---- central reg additional id search form (START) ---->
                        <cfif isDefined("client.vEAGC1000searchAgendaItems_crAddtlId")>
                            <cfwddx action="wddx2cfml" input="#client.vEAGC1000searchAgendaItems_crAddtlId#" output="local.stAnItmSrchCrit">
                        <cfelse>
                            <!---- set default search struct ---->
                            <cfparam name="local.stAnItmSrchCrit.cr_pgm_id" default="">
                            <cfparam name="local.stAnItmSrchCrit.cr_addn_num_txt" default="">
                        </cfif>

                        <form name="crAddtlIdSearchForm" id="crAddtlIdSearchForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#" method="post">
                            <!---- set hidden field telling controller which form was submitted ---->
                            <input type="hidden" name="formSubmitted" id="formSubmitted" value="crAddtlId">

                            <fieldset>
                                <legend style="margin-top:-2%">Central Registry Additional&nbsp;ID</legend>
                                <p>
                                    <label for="pgm_id">Program: </label>
                                    <select name="cr_pgm_id" id="cr_pgm_id">
                                        <option value="">&nbsp;</option>
                                        <!---- determining user's team and if in enforcement role in eAgenda ---->
                                        <cfif client.userType EQ "progArea">
                                            <!---- drop down list based on users security level (PROXY) ---->
                                            <cfloop from="1" to="#arraylen(local.crProgramDropDown)#" index="local.i">
                                                <option value="#TRIM(local.crProgramDropDown[local.i][2])#"<cfif local.stAnItmSrchCrit.cr_pgm_id EQ TRIM(local.crProgramDropDown[local.i][2])>selected</cfif>>
                                                    #local.crProgramDropDown[local.i][3]#
                                                </option>
                                            </cfloop>
                                        <cfelse>
                                            <!---- display entire drop down list (SQL) ---->
                                            <cfloop query="local.crProgramDropDown.resultset">
                                                <option value="#pgm_cd#"<cfif local.stAnItmSrchCrit.cr_pgm_id EQ pgm_cd>selected</cfif>>
                                                    #uCase(pgm_name)#
                                                </option>
                                            </cfloop>
                                        </cfif>
                                    </select>
                                </p>

                                <p>
                                    <label for="cr_addn_num_txt">Additional&nbsp;ID:<span class="required">*</span></label>
                                    <input type="text" name="cr_addn_num_txt" id="cr_addn_num_txt" size="15" maxlength="15" value="#local.stAnItmSrchCrit.cr_addn_num_txt#" />
                                    <div id="crAddtlIdSearchErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                                </p>

                                <div>
                                    <span class="buttoninput">&nbsp;</span>
                                    <input type="submit" name="searchAddtlIdCr" id="searchAddtlIdCr" value="Search" class="buttonfield" />
                                    <input type="button" name="clearAddtlIdCr" id="clearAddtlIdCr"  value="Clear" class="buttonfield" onClick="clearForm('crAddtlId')" />
                                </div>
                            </fieldset>
                        </form>
                        <!---- central reg additional id search form (END) ---->

                        <br />

                        <!---- non central reg additional id search form (START) ---->
                        <cfif isDefined("client.vEAGC1000searchAgendaItems_nonCrAddtlId")>
                            <cfwddx action="wddx2cfml" input="#client.vEAGC1000searchAgendaItems_nonCrAddtlId#" output="local.stAnItmSrchCrit">
                        <cfelse>
                            <!---- set default search struct ---->
                            <cfparam name="local.stAnItmSrchCrit.noncr_pgm_id" default="">
                            <cfparam name="local.stAnItmSrchCrit.noncr_addn_num_txt" default="">
                        </cfif>

                        <form name="nonCrAddtlIdSearchForm" id="nonCrAddtlIdSearchForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#" method="post">
                            <!---- set hidden field telling controller which form was submitted ---->
                            <input type="hidden" name="formSubmitted" id="formSubmitted" value="nonCrAddtlId">

                            <fieldset>
                                <legend style="margin-top:-2%">Non-Central Registry Additional&nbsp;ID</legend>

                                <p>
                                    <label for="pgm_id">Program: </label>
                                    <select name="noncr_pgm_id" id="noncr_pgm_id">
                                        <option value=""></option>
                                        <cfloop query="local.qryNonCrAddtlId">
                                            <option value="#codeText#"<cfif local.stAnItmSrchCrit.noncr_pgm_id EQ codeText>selected</cfif>>
                                                #uCase(nameText)#
                                            </option>
                                        </cfloop>
                                    </select>
                                </p>

                                <p>
                                    <label for="noncr_addn_num_txt">Additional&nbsp;ID:<span class="required">*</span></label>
                                    <input type="text" name="noncr_addn_num_txt" id="noncr_addn_num_txt" size="15" maxlength="15" value="#local.stAnItmSrchCrit.noncr_addn_num_txt#" />
                                    <div id="nCrAddtlIdSearchErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                                </p>

                                <div>
                                    <span class="buttoninput">&nbsp;</span>
                                    <input type="submit" name="searchAddtlIdCr" id="searchAddtlIdNonCr" value="Search" class="buttonfield" />
                                    <input type="button" name="clearAddtlIdCr" id="clearAddtlIdNonCr"  value="Clear" class="buttonfield" onClick="clearForm('nonCrAddtlId')" />
                                </div>
                            </fieldset>
                        </form>
                        <!---- non central reg additional id search form (END) ---->

                        <br />

                        <!---- regulated entity search form (START) ---->
                        <cfif isDefined("client.vEAGC1000searchAgendaItems_regEntity")>
                            <cfwddx action="wddx2cfml" input="#client.vEAGC1000searchAgendaItems_regEntity#" output="local.stAnItmSrchCrit">
                        <cfelse>
                            <!---- set default search struct ---->
                            <cfparam name="local.stAnItmSrchCrit.rn_ref_num_txt" default="">
                        </cfif>

                        <form name="regEntitySearchForm" id="regEntitySearchForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#" method="post">
                            <!---- set hidden field telling controller which form was submitted ---->
                            <input type="hidden" name="formSubmitted" id="formSubmitted" value="regEntity">

                            <fieldset>
                                <legend style="margin-top:-2%">Regulated&nbsp;Entity</legend>
                                <p>
                                    <label for="item_num">RN&nbsp;Number:<span class="required">*</span></label>
                                    <input type="text" name="rn_ref_num_txt" id="rn_ref_num_txt" size="12" maxlength="11" value="#local.stAnItmSrchCrit.rn_ref_num_txt#" tabindex="8" />
                                    &nbsp;<span class="forminstructions"></span>
                                    <div id="regEntSearchErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                                </p>

                                <div>
                                    <span class="buttoninput">&nbsp;</span>
                                    <input type="submit" name="searchRegEntity" id="searchRegEntity" value="Search" class="buttonfield" />
                                    <input type="button" name="clearAddtlIdCr" id="clearAddtlIdNonCr"  value="Clear" class="buttonfield" onClick="clearForm('regEntity')" />
                                </div>
                            </fieldset>
                        </form>
                        <!---- regulated entity search form (END) ---->

                        <br />

                        <!---- customer number search form (START) ---->
                        <cfif isDefined("client.vEAGC1000searchAgendaItems_custNumber")>
                            <cfwddx action="wddx2cfml" input="#client.vEAGC1000searchAgendaItems_custNumber#" output="local.stAnItmSrchCrit">
                        <cfelse>
                            <!---- set default search struct ---->
                            <cfparam name="local.stAnItmSrchCrit.pr_ref_num_txt" default="">
                        </cfif>

                        <form name="customerNumSearchForm" id="customerNumSearchForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('search')#" method="post">
                            <!---- set hidden field telling controller which form was submitted ---->
                            <input type="hidden" name="formSubmitted" id="formSubmitted" value="custNumber">
                            <fieldset>
                                <legend style="margin-top:-2%">Customer</legend>
                                <p>
                                    <label for="item_num">CN Number:<span class="required">*</span></label>
                                    <input type="text" name="pr_ref_num_txt" id="pr_ref_num_txt" size="11" maxlength="12" value="#local.stAnItmSrchCrit.pr_ref_num_txt#" tabindex="8" />
                                    &nbsp;<span class="forminstructions"></span>
                                    <div id="custNumSearchErr" class="redbold" aria-live="assertive" style="font-size:10px; padding-left: 25%;"></div>
                                </p>

                                <div>
                                    <span class="buttoninput">&nbsp;</span>
                                    <input type="submit" name="searchCustomerNum" id="searchCustomerNum" value="Search" class="buttonfield" />
                                    <input type="button" name="clearCustomerNum" id="clearCustomerNum"  value="Clear" class="buttonfield" onClick="clearForm('custNumber')" />
                                </div>
                            </fieldset>
                        </form>
                        <!---- customer number search form (END) ---->

                        <!---- notates required fields ---->
                        <p style="text-align:center;margin-right:10%">
                            <span class="required">*</span> Indicates a Mandatory field within the search type
                        </p>
                    </fieldset>
                    <!---- available search criteria (ENDS) ---->
                </div>

                <!--- ************  Search result List ************ --->
                <cfif isDefined("local.stAnItmSrchCrit.formSubmitted") AND local.stAnItmSrchCrit.formSubmitted NEQ "">
                     <cfif local.agendaItmSrchRslts.recordcount>
                             <br />
                             <div class="paginghead">
                                 Your Search Returned <span class="bold">#local.agendaItmSrchRslts.recordcount#</span> Records.
                                 <cfif local.agendaItmSrchRslts.recordcount gt 100>
                                     You may refine your search.
                                 </cfif>
                                 Click on a Item Number to view the detail information.
                             </div>

                             <br />

                             <cfset local.Paging = application.utilsObj.pageThru(local.agendaItmSrchRslts.recordCount, local.displayCount, 50, local.CurrentPage, cgi.SCRIPT_NAME, "&fuseaction=#arguments.event.xfa('search')#&formSubmitted=#local.stAnItmSrchCrit.formSubmitted#")>

                             <!---- paging displayed (BEGINS) ---->
                             <div style="padding-bottom:2px">
                                 #local.Paging.PT_PageThru#&nbsp;
                                 #local.Paging.PT_StartRow#-#local.Paging.PT_EndRow#
                                 &nbsp;of&nbsp;
                                 #local.agendaItmSrchRslts.recordCount#&nbsp;
                                 Records
                             </div>
                             <!---- paging displayed (ENDS) ---->

                             <!---- set qry start and stop ---->
                             <cfset local.fromPage = local.Paging.PT_StartRow>
                             <cfset local.toPage = local.Paging.PT_EndRow>

                             <table class="datadisplay">
                             <tr>
                                 <th scope="col">Item</th>
                                 <th scope="col">Docket&nbsp;Number</th>
                                 <th scope="col">Assigned</th>
                                 <th scope="col">Program</th>
                                 <th scope="col">Additional&nbsp;ID</th>
                                 <th scope="col">Regulated&nbsp;Entity</th>
                                 <th scope="col">Principal</th>
                             </tr>
                             <cfloop query="local.agendaItmSrchRslts" startrow="#local.fromPage#" endrow="#local.toPage#">
                                 <!---- decide which id to send, agenda item id or item id ---->
                                 <cfset local.sendID = local.agendaItmSrchRslts.Agenda_Item_ID NEQ "" ? "&agendaItemID=#Agenda_Item_ID#":"&itemID=#Item_ID#">
                                 <tr>
                                     <td>
                                         <cfif (Trim(status_cd) EQ "PENDING" AND client.userType EQ "agendaTm") OR (Trim(status_cd) NEQ "PENDING")>
                                             <a href="#arguments.myFusebox.getMyself()##arguments.event.xfa('urlLink')##local.sendID#">#item_num#</a>
                                         </cfif>
                                     </td>
                                     <td><a href="#arguments.myFusebox.getMyself()##arguments.event.xfa('urlLink')##local.sendID#">#agy_dkt_num_txt#</a></td>
                                     <td>#dateFormat(dkt_num_assn_dt, "mm/dd/yyyy")#</td>
                                     <td>#htmleditformat(pgm_cd)#</td>
                                     <td>#htmleditformat(addn_id)#</td>
                                     <td>#reg_ent_name# (#ref_num_txt#)</td>
                                     <td>#princ_name# (#cn#)</td>
                                 </tr>
                             </cfloop>
                             </table>

                             <!---- paging displayed (BEGINS) ---->
                             <div style="padding-bottom:2px">
                                 #local.Paging.PT_PageThru#&nbsp;
                                 #local.Paging.PT_StartRow#-#local.Paging.PT_EndRow#
                                 &nbsp;of&nbsp;
                                 #local.agendaItmSrchRslts.recordCount#&nbsp;
                                 Records
                             </div>
                             <!---- paging displayed (ENDS) ---->

                         <br />
                         <cfelse>
                             Your Search Returned <span class="bold">#local.agendaItmSrchRslts.recordcount#</span> Records. Try your search again.
                     </cfif>
                </cfif>
            </div>
        </cfoutput>

      <cfreturn>
    </cffunction>


    <!----
		The main purpose of this web page is to allow the TCEQ Agenda Team to document the Commissioners Decision on each Agenda Item on an Agenda.
        This web page will be flowed to by clicking the Marked Agenda link on the Navigation bar.

     ---->
    <cffunction name="vEAGC0800markedAgenda" displayname="vEAGC0800markedAgenda" description="allows the agenda team to document the commissioners� decision on each agenda item on an agenda." access="public" returntype="void">
        <cfargument name="myFusebox" displayName="myFusebox" type="struct" hint="The Fusebox structure" required="true">
        <cfargument name="event" displayName="event" type="struct" hint="The event structure" required="true">

        <!---- set default vars ---->
        <cfset local.attributes = arguments.MyFusebox.variables().attributes>
        <cfset local.commChairCnt = 0>
        <cfset local.apprAgenda = 0>
        <cfset orgGenCounsel = "0,0">
        <cfparam name="catTxt" default="">


        <!---- set component access rights variable ---->
        <cfset local.saveAgendaRights = arguments.event.getValue("securedCompAccessValid_Save")>
        <cfset local.approveAgendaRights = arguments.event.getValue("securedCompAccessValid_Approve")>

        <!--- current agenda date in use --->
        <cfset local.curAgendaDt = dateFormat(arguments.event.getValue("curAgendaDt"), "mm/dd/yyyy")>

        <!--- current agenda time in use --->
        <cfset local.curAgendaTm = timeFormat(arguments.event.getValue("curAgendaDt"), "hh:mm")>

        <!--- current agenda id in use --->
        <cfset local.curAgendaID = arguments.event.getValue("curAgendaID")>

        <!--- current agenda status in use --->
        <cfset local.curAgendaStatus = arguments.event.getValue("curAgendaStatus")>

        <!--- current agenda approval date --->
        <cfset local.curApprlDt = arguments.event.getValue("curApprlDt")>

        <!--- get list size for paging --->
        <cfset local.displayCount = arguments.event.getValue("getListSize")>

        <!---- set default display count and current page ---->
        <cfparam name="local.displayCount" default="#local.displayCount#">
        <cfparam name="local.attributes.CurrentPage" default="1">

        <!--- qry results to variables (START) --->
	        <!--- agenda dates --->
			<cfset local.agendaDates = arguments.event.getValue("qryMarkedAgendaDts")>

	        <!--- commissioners --->
	        <cfset local.qryGetCommChair = arguments.event.getValue("qryGetCommChair")>

            <!--- general counsel --->
            <cfset local.qryGetGenCounsel = arguments.event.getValue("qryGetGenCounsel")>

            <!--- document type dropdown --->
            <cfset local.qryDoctype = arguments.event.getValue("qryDoctype")>

            <!--- action item dropdown --->
            <cfset local.qryAction = arguments.event.getValue("qryAction")>

            <!--- agenda items details --->
            <cfset local.qryGetAgendaDetails = arguments.event.getValue("getAgendaDetails")>

            <!--- activity actions that indicate an agenda item is being carried forward to a future agenda --->
            <cfset local.qryActivityAct = arguments.event.getValue("getActivityAct")>

            <!--- future agenda dates --->
            <cfset local.qryFutureAgendaDts = arguments.event.getValue("qryAgendaDts")>

            <!--- current user mem id --->
            <cfset local.qryCurrUser = arguments.event.getValue("qryCurrUser")>

            <!--- convert local.qryActivityAct to an array for jquery to process --->
			<cfset local.arrActivityAct = ArrayNew(1)>
            <cfoutput query="local.qryActivityAct">
                <cfset local.activAct = "#desc_txt#||#gen_cd_txt#">
                <cfset arrayAppend(local.arrActivityAct,local.activAct)>
            </cfoutput>
        <!--- qry results to variables (END) --->

        <!---- set default qry start and stop ---->
        <cfparam name="local.fromPage" default="1">
        <cfparam name="local.toPage" default="#local.displayCount#">

        <!---- set add agenda component access variable ---->
        <cfset local.addAgendaRights = arguments.event.getValue("securedCompAccessValid")>

        <!---- set current page ---->
        <cfset local.currentPage = local.attributes.CurrentPage>

        <cfoutput>
	        <!---- save jquery script as a variable and then send it to the head section of the page ---->
	        <cfsavecontent variable="jQueryCode">
	            <script type="text/javascript">
                    // convert cf local.arrActivityAct array into a js object format
					var activityAct = #serializeJson(local.arrActivityAct)#;

	                $(document).ready(function()
	                 {
	                 	// determine which more button was clicked
						$("input:button").click(function()
							{
								//this will give you the ID of the clicked button
								btnId = $(this).attr("id");
							}
						);

						// compare activity actions in order to determine if an agenda item is being carried forward to a future agenda
						// upon a match create a dropdown with future agenda dates next to appropriate agenda item
	                    $(".pass").change(function()
		                    {
		                    	// set element name in a variable
	                            var btnId = $(this).attr("name").split("_");

	                            // verify which button is being clicked
	                            if(btnId[0] == "docType" || btnId[0] == "actItem")
		                        {
	                                // set a current row variable for name and id
	                                var currentRow = $(this).attr("name").split("_").pop();

		                            var compareValues = $("##docType_"+currentRow).val()+"||"+$("##actItem_"+currentRow).val();
		                            $.each(activityAct, function (i, action)
		                                {
		                                    if (action == compareValues)
		                                    {
		                                        // add future agenda dates dropdown
				                                var newInput = '<select name="fAgendaDts_' + currentRow + '" id="fAgendaDts_' + currentRow + '"><option value="">&nbsp;</option><cfloop query="local.qryFutureAgendaDts"><option value="#agenda_id#">#Trim(dateFormat(agenda_dt, "mm/dd/yyyy"))#</option></cfloop></select><br />'
				                                $("##futureAgendaDts_"+currentRow).before(newInput);
		                                    }
		                                }
		                            );
		                        }
	                        }
	                     );

                        // set default input count
                        var activityActCount = 1;

		                $(".pass").click(function()
		                {
	                        // set element name in a variable
		                	var btnId = $(this).attr("name").split("_");

                            // verify which button is being clicked
		                	if(btnId[0] == "addActivityAct")
		                	{
			                	// set a current row variable for name and id
			                	var currentRow = $(this).attr("name").split("_").pop();

			                	// adjust counter
				                activityActCount++;

	                            // add new doc type dropdown
				                var newInput = '<br /><br /><select name="docType_' + currentRow + '" id="docType_' + currentRow + '_' + activityActCount + '"><option value="">&nbsp;</option><cfloop query="local.qryDoctype"><option value="#gen_cd_txt#">#desc_txt#</option></cfloop></select><br />'
				                $("##addActivityAct_"+currentRow).before(newInput);comntTxt_

	                            // add new action item dropdown
	                            newInput = '<br /><br /><select name="actItem_' + currentRow + '" id="actItem_' + currentRow + '"><option value="">&nbsp;</option><cfloop query="local.qryAction"><option value="#gen_cd_txt#">#desc_txt#</option></cfloop></select><br />'
	                            $("##addActItem_"+currentRow).before(newInput);

	                            // add new commissioners decision text area
	                            newInput = '<br /><textarea name="comntTxt_' + currentRow + '" id="comntTxt_' + currentRow + '" cols="25" rows="4"></textarea><br />'
	                            $("##addComntTxt_"+currentRow).before(newInput);
                            }
		                });

                        // verify approval date is greater than agenda date
                        $("##apprAgenda").click(function()
                        {
                            // compare agenda date with approval date
                            // submit form if the approval date is greater than agenda date
                            if ($("##apprlDt").val() < $("##curAgendaDt").val())
                                {
                                 alert("Approval date must be greater than the Agenda date!");
                                 $("##apprlDt").select()
                                 return false;
                                }
                            else
                            {
                                return true;
                            }
                        });

                        // reload page when a new agenda date is selected
                        $("##search_agenda_dt").change(function(){
                            window.location="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#&nAgendaDt=" + this.value
                        });

	                    // confirm on save verify approval date
	                    $("##saveApprl").click(function()
	                    {
                            // confirm user wants to save agenda updates
                            // verify if there has been an approval date added
                            // submit form on confirmation when there is no approval date
                            // when there is an approval date and if the approval date is greater than agenda date, submit
                            if($("##apprlDt").val() != "")
                            {
		                        if($("##apprlDt").val() < $("##curAgendaDt").val())
		                            {
		                             alert("Approval date must be greater than the Agenda date!");
		                             $("##apprlDt").select()
		                             return false;
		                            }
		                        else
		                        {
		                            return true;
		                        }
	                        }
	                        else
	                        {
								if (confirm("Are you sure you want to save this Agenda?"))
								    {
								        return true;
								    }
								        return false;
	                        }
	                    });

	                    // reload page when a new agenda date is selected
						$("##search_agenda_dt").change(function(){
						    window.location="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#&nAgendaDt=" + this.value
						});
	                });
	            </script>
	        </cfsavecontent>

	        <!---- send to the head section of the page ---->
	        <cfhtmlhead text="#jQueryCode#">

	        <!---- javascript for date picker (START) ---->
	        <cfhtmlhead text="#application.utilsObj.datePicker('apprlDt')#">
	        <!---- javascript for date picker (END) ---->

	        <!---- display (BEGINS) ---->
			<div id="content">
	            <!---- marked agenda form processing errors (BEGINS) ---->
                <cfif isDefined("client.markedAgendaProcessErrors")>
                    <cfwddx action="wddx2cfml" input="#client.markedAgendaProcessErrors#" output="local.stProcessErrors">
                    <!---- delete client variable containing agenda process errors ---->
                    <cfset DeleteClientVariable("markedAgendaProcessErrors")>
                    <p>
                        <span class="redbold">
                            #local.stProcessErrors.errormsg#! <br />
                        </span>
                    </p>
                    <!---- delete struct variable containing marked agenda process errors ---->
                    <cfset StructClear(local.stProcessErrors)>
                </cfif>
                <!---- marked agenda form processing errors (ENDS) ---->

                <div id="agb_search">
	                <form name="approveAgendaForm" id="approveAgendaForm" action="#arguments.myFusebox.getMyself()##arguments.event.xfa('submit')#" method="post">
						<fieldset>
							<legend style="margin-top:-1%">Agenda Information</legend>
				            <!--- search form (BEGINS) --->
							<p>
	                            <!--- agenda dates (START) --->
								<label for="agenda_dt">Date:<span class="required">*</span></label>

								<!--- send the current agenda date and time back to the server --->
                                <input type="hidden" name="curAgendaDt" id="curAgendaDt" value="#local.curAgendaDt#" />
                                <input type="hidden" name="curAgendaTm" id="curAgendaTm" value="#local.curAgendaTm#" />

                                <!--- send the current user's mem id back to the server --->
                                <input type="hidden" name="curUserId" id="curUserId" value="#local.qryCurrUser#" />

								<select name="search_agenda_dt" id="search_agenda_dt" >
									<cfloop query="local.agendaDates">
										<option value="#agenda_id#" <cfif curAgendaID EQ agenda_id>selected</cfif>>#dateFormat(agenda_dt,"mm/dd/yyyy")#</option>
									</cfloop>
								</select>
					            <!--- agenda dates (END) --->

	                               <!--- commissioners (START) --->
	                               <cfloop query="local.qryGetCommChair">
	                                   <cfset local.commChairCnt = ++local.commChairCnt>
									   <input type="checkbox" name="commChair_#local.commChairCnt#" id="commChair_#local.commChairCnt#" <cfif attendedAgenda EQ 1>checked</cfif>  value="#Trim(title_cd)#,#staff_mem_id#" /> <span class="bold">#first_name# #last_name#</span>
									   <!--- send the onload status of the commChair element back to the server --->
                                       <input type="hidden" name="orgCommChair_#local.commChairCnt#" id="orgCommChair_#local.commChairCnt#" value="#attendedAgenda#">
	                               </cfloop>

					               <!--- send the total commChair elements back to the server --->
					               <input type="hidden" name="commChairCnt" id="commChairCnt" value="#local.qryGetCommChair.recordCount#">
					            <!--- commissioners (END) --->
							</p>

							<p>
	                            <!--- general counsel (START) --->
								<label class="bold" style="margin-left:20%">General Counsel:</label>
								<select name="genCounsel" id="genCounsel" >
									<option value=""></option>
	                                <cfloop query="local.qryGetGenCounsel">
										<option value="#Trim(title_cd)#,#staff_mem_id#" <cfif attendedAgenda EQ 1>selected</cfif>>#first_name# #last_name#</option>
                                        <!--- set the onload state for general counsel --->
                                        <cfif attendedAgenda GT 0>
	                                        <cfset orgGenCounsel = "#staff_mem_id#,#attendedAgenda#">
                                        </cfif>
									</cfloop>
								</select>

                                <!--- send the onload status of the commChair element back to the server --->
                                <input type="hidden" name="orgGenCounsel" id="orgGenCounsel" value="#orgGenCounsel#">
					            <!--- general counsel (END) --->

								<!--- approval date (START) --->
								<span class="bold">Approval Date:</span><input name="apprlDt" id="apprlDt" type="text" size="10" maxlength="11" value="#local.curApprlDt#" />&nbsp;(mm/dd/yyyy)
					            <!--- approval date (END) --->
							</p>
				            <!--- search form (ENDS) --->
						</fieldset>

						<cfif local.qryGetAgendaDetails.recordcount GT 0>
							<fieldset>
								<legend style="margin-top:-1%">Mark Agenda Items</legend>
								<!--- ************  Search result List ************ --->
	                             <div class="paginghead">
	                                 Your Search Returned <span class="bold">#local.qryGetAgendaDetails.recordcount#</span> Records.
	                                 <cfif local.qryGetAgendaDetails.recordcount gt 100>
	                                     You may refine your search.
	                                 </cfif>
	                             </div>

	                             <br />

	                             <cfset local.Paging = application.utilsObj.pageThru(local.qryGetAgendaDetails.recordcount, local.displayCount, 50, local.CurrentPage, cgi.SCRIPT_NAME, "&fuseaction=#arguments.event.xfa('submit')#")>

	                             <!---- paging displayed (BEGINS) ---->
	                             <div style="padding-bottom:2px">
	                                 #local.Paging.PT_PageThru#&nbsp;
	                                 #local.Paging.PT_StartRow#-#local.Paging.PT_EndRow#
	                                 &nbsp;of&nbsp;
	                                 #local.qryGetAgendaDetails.recordcount#&nbsp;
	                                 Records
	                             </div>
	                             <!---- paging displayed (ENDS) ---->

	                             <!---- set qry start and stop ---->
	                             <cfset local.fromPage = local.Paging.PT_StartRow>
	                             <cfset local.toPage = local.Paging.PT_EndRow>

								<table class="datadisplay" summary="Non-Item Work Queue results">
									<tr>
										<th>Docket Number</th>
										<th>Item</th>
										<th>Document Type</th>
										<th>Action</th>
										<th colspan="2">Commissioners' Decision</th>
	                                </tr>

									<cfloop query="local.qryGetAgendaDetails" startrow="#local.fromPage#" endrow="#local.toPage#">
										<tr>
                                            <!--- clicking the docket url takes the user to agenda item details --->
											<td width="15%"><a href="##">#local.qryGetAgendaDetails.agy_dkt_num_txt#</a></td>
											<td width="2%">
                                                #local.qryGetAgendaDetails.item_num#
                                                <!--- send back the agenda item number to the server --->
                                                <input type="hidden" name="agendaItmId_#currentRow#" id="agendaItmId_#currentRow#" value="#local.qryGetAgendaDetails.item_num#">
                                            </td>
											<td width="20%">
												<select name="docType_#currentRow#" id="docType_#currentRow#" class="pass">
	                                                <option value="">&nbsp;</option>
													<cfloop query="local.qryDoctype">
														<option value="#gen_cd_txt#"  <cfif local.qryGetAgendaDetails.chk_item_num EQ gen_cd_txt>selected<cfelseif right(local.qryGetAgendaDetails.agy_dkt_num_txt,2) EQ "-E" AND gen_cd_txt EQ "COMM">selected</cfif>>
															#desc_txt#
													    </option>
	                                                </cfloop>
	                                            </select>
												<cfif right(local.qryGetAgendaDetails.agy_dkt_num_txt,2) NEQ "-E">
													<input type="button" name="addActivityAct_#currentRow#"  id="addActivityAct_#currentRow#" value="More" alt="add more activity action" class="buttonfield pass" tabindex="13" />
	                                            </cfif>
	                                        </td>
											<td width="15%">
												<select name="actItem_#currentRow#" id="actItem_#currentRow#" class="pass">
	                                                <option value="">&nbsp;</option>
													<cfloop query="local.qryAction">
														<option value="#gen_cd_txt#"  <cfif local.qryGetAgendaDetails.answer_txt EQ gen_cd_txt>selected<cfelseif right(local.qryGetAgendaDetails.agy_dkt_num_txt,2) EQ "-E" AND gen_cd_txt eq "GRANTED">selected="selected"</cfif>>
															#desc_txt#
														</option>
	                                                </cfloop>
	                                            </select>

                                                <!--- place holder for actItem dynamic field creation --->
                                                <span name="addActItem_#currentRow#" id="addActItem_#currentRow#"></span>
	                                        </td>
											<td style="border-right:0px">
												<cfif right(local.qryGetAgendaDetails.agy_dkt_num_txt,2) EQ "-E">
													<cfset comntTxt = comnt_txt EQ "" ? "Approve the #agendaItmCat# &nbsp; &nbsp; ; all agree.":comnt_txt>
                                                <cfelse>
                                                    <cfset comntTxt = comnt_txt>
	                                            </cfif>
                                                <!--- commissioners comments --->
												<textarea name="comntTxt_#currentRow#" id="comntTxt_#currentRow#" cols="25" rows="4">#comntTxt#</textarea>
	                                         </td>
                                             <td width="10%" valign="top">
                                                 <!--- place holder for future agenda dates --->
                                                 <span id="futureAgendaDts_#currentRow#" style="vertical-align:top"></span>
                                             </td>
	                                    </tr>
								        <!--- check agenda status code --->
	                                    <cfset local.apprAgenda = status_cd NEQ "Complete" AND status_cd NEQ "Ongoing" ? ++local.apprAgenda:0>

                                        <!--- send agenda item status code back to the server --->
                                        <input type="hidden" name="agendaItmStat_#currentRow#" id="agendaItmStat_#currentRow#" value="#status_cd#">

                                        <!--- send check list item id back to the server --->
                                        <input type="hidden" name="activActItmId_#currentRow#" id="activActItmId_#currentRow#" value="#chk_item_id#">
		                            </cfloop>

                                    <!--- pass the total agenda item count back to server --->
                                    <input type="hidden" name="agendaItmCt" id="agendaItmCt" value="#local.qryGetAgendaDetails.recordcount#">
								</table>

                                <!---- paging displayed (BEGINS) ---->
                                <div style="padding-bottom:2px">
                                    #local.Paging.PT_PageThru#&nbsp;
                                    #local.Paging.PT_StartRow#-#local.Paging.PT_EndRow#
                                    &nbsp;of&nbsp;
                                    #local.qryGetAgendaDetails.recordcount#&nbsp;
                                    Records
	                            </div>
                                <!---- paging displayed (ENDS) ---->

			                    <div id="re_info">
		                            <p>
										<label for="agenda_dt">&nbsp;</label>
	                                    <!--- save agenda --->
                                        <cfif local.saveAgendaRights EQ "Y">
											<input type="submit" name="saveApprl" id="saveApprl" value="Save" class="buttonfield" tabindex="13" />
                                        </cfif>

		                                <!--- approve agenda --->
		                                <!--- verify has not already been approved --->
                                        <cfif local.approveAgendaRights EQ "Y">
			                                <cfif local.curAgendaStatus NEQ "APPROVED">
			                                    <!--- make sure approval date is GT agenda date --->
												<cfif dateFormat(now(), "mm/dd/yyyy") GT dateFormat(local.curAgendaDt, "mm/dd/yyyy")>
			                                        <!--- if there are items without the proper status disable the approveal button --->
			                                        <cfset disableAppr = local.apprAgenda NEQ 0 ? "disabled":"">
				                                    <input type="submit" name="apprAgenda"  id="apprAgenda" value="Approve" #disableAppr# class="buttonfield" tabindex="13" />
			                                    </cfif>
			                                </cfif>
                                        </cfif>
										<input type="reset" name="clear"  value="clear" class="buttonfield" onfocus="return SetFormAction(this,'XFA.clear');" tabindex="14"  />
										<input type="button" name="cancel"  value="Cancel" class="buttonfield"  onclick="f_cancel_confirm('Work Queue','#arguments.event.xfa('cancel')#');" tabindex="14"  />
		                            </p>
			                    </div>
	                        </fieldset>
		                </cfif>
	                </form>
                </div>
           </div>
        </cfoutput>
        <!---- display (ENDS) ---->

        <cfreturn />
    </cffunction>
</cfcomponent>
