<!---- ref jquery files ---->
<cfhtmlhead text='<script src="javascript/jquery-1.9.1.min.js"></script>#chr(13)##chr(10)#'>
<cfhtmlhead text='<script src="javascript/jquery-ui-1.10.0.custom/js/jquery-ui-1.10.0.custom.min.js"></script>#chr(13)##chr(10)#'>

<!---- initiate cfcs ---->
<cfset o_grantFunding  = createobject("component","#Replace(Replace(request.root,'/',''),'/','.','all')#.cfc.grantFirstFunding")>

<cfif NOT IsDefined("c_fromValidateApplPage")>
	<cfinclude template="#pgmAreaLayoutsPath#/act_determineInitialGrantFlg.cfm">
	<cfif trim(v_init_grant_flg) EQ "Y">
		<cfset xfa.return="pgmAreaLayouts.initReqMenu">
	<cfelse>
	    <cfinclude template="#applicationPath#/act_grantHeader.cfm">
        <cfset attributes.pageHeading="Revision - Application" >
		<cfset xfa.return="revisions.grantRevsFormalMinor&pgm_grant_seq_num=#pgm_grant_seq_num#&usas_num_txt=#usas_num_txt#">
	</cfif>
</cfif>

<cfif IsDefined("c_fromValidateApplPage")>
	<cfif trim(c_fromValidateApplPage) EQ "Y">
		<cfset xfa.return="validateAppl.validateAppl">
	</cfif>
</cfif>

<span class="pageNav">
   <cfoutput>
	  <a href="#self#?fuseaction=#xfa.return#"><img src="images/leftArrow.gif" align="bottom" alt="Return" border="0" />Return</a>
   </cfoutput>
</span>

<br /><br />

<!--- display grant header information --->
<cfset v_tableWidth="89%">
<cfinclude template="#applicationPath#/dsp_grantHeader.cfm">

<br />

<cfif trim(v_grant_close_out_status_cd) NEQ "ACTIVE">
    <ul class="info">
        Note: Since this Grant is already closed, you are no longer <br />allowed to make any changes
    </ul>
</cfif>

<!---- date picker script (BEGINS) ---->
<cfhtmlhead text='
    <script type="text/javascript" src="javascript/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="javascript/jquery-ui-1.10.0.custom/jquery-ui-1.10.0.custom.min.js"></script>
    <link rel="stylesheet" type="text/css" href="javascript/jquery-ui-1.10.0.custom/css/cupertino/jquery-ui-1.10.0.custom.min.css" />
'>

<cfhtmlhead text="#application.utilsObj.datePicker('START_DT,END_DT,eo12372Date')#">

<!---- date picker script (ENDS) ---->
<cfoutput>
    <!---- save jquery script as a variable and then send it to the head section of the page ---->
    <cfsavecontent variable="jQueryCode">
	    <script>
	        $(document).ready(function()
	         {
	            //when a previous revision is chosen the funding amounts are updated using ajax
	            $("##prevRev").change(function()
	             {
	                // amendment number and revision number are in list form, they have to be split up before sending to method
	                var prevRevs = $("##prevRev").val();
	                var amendRevs = prevRevs.split(",");
	                $.ajax(
	                {
	                    // make an ajax call to the chgFundAmounts method in the grantFirstFunding cfc passing in amend_num, revs_num, and pgm_grant_seq_num
	                    url: "cfc/grantFirstFunding.cfc?method=chgFundAmounts",

	                    // the type of data that we're expecting back from the server
	                    datatype:"html",
	                    data: {
	                            // parameters passed to the method
	                            amendNum: amendRevs[0], //previous amendment number
	                            revsNum: amendRevs[1], //previous revision number
	                            curAmendNum: #v_amend_num#, //current amendment number
	                            curRevsNum: #v_revs_num#, //current revision number
	                            seqNum: #pgm_grant_seq_num#, //program grant sequence number
	                            applApprFLG: "#applDates.APPL_APPR_FLG#" //application approval flag
	                          } ,
	                    // force results not to be cached by the browser; this adds a URL parameter of with a random number example:_=1355844626784
	                    cache:false,

	                    // error message
	                    error: function() {alert("there was an error");},

	                    // function that runs after the ajax call is complete
	                    // displays the resultset from the ajax call
	                    success: function(gaiGrantFunds)
	                    {
	                        $("##fundsForm").html(gaiGrantFunds.trim());
	                    }
	                });
	            });

	            // verify new amounts entered do not change total
	            $("##fundsForm").submit(function()
	            {
	                // fund amounts set to variables
	                var fed = $("##fedAmt").val();
	                var appl = $("##appAmt").val();
	                var state = $("##stateAmt").val();
	                var local = $("##localAmt").val();
	                var pgm = $("##pgmAmt").val();
	                var other = $("##otherAmt").val();
	                var total = $("##totalAmt").val();

	                // add values together and set variable
	                var newTotal = parseFloat(fed) + parseFloat(appl) + parseFloat(state) + parseFloat(local) + parseFloat(pgm) + parseFloat(other);

	                // compare new total with existing total
	                // submit form if the new total matches the existing total
	                if (total != newTotal)
	                    {
	                     alert("The total cannot change!");
	                     return false;
	                    }
	                else
	                {
	                    return true;
	                }
	            });
	        });
	    </script>
    </cfsavecontent>

    <!---- send to the head section of the page ---->
    <cfhtmlhead text="#jQueryCode#">

	<!---- revision information form ---->
	<form name="revForm" action="#self#?fuseaction=genApplInfo.GAIGrantRevisionType" method="post">
	    <input type="hidden" name="grant_seq_num" value="#v_grant_seq_num#">
	    <input type="hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">

	    <!---- set form action type (add/edit) ---->
	    <cfif variables.extRevType.recordcount EQ 0>
		    <input type="hidden" name="qryAction" value="Add">
        <cfelse>
            <input type="hidden" name="qryAction" value="Edit">
        </cfif>

	    <span style="padding-left:5%;">Revision Information:</span>
	    <table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="90%">
	        <tr>
	            <td align="right" bgcolor="Silver" width="45%">
	                Revision Type:
	            </td>
	            <td>
	                <select name="revType" id="revType">
	                    <option val=""></option>
                        <cfloop query="variables.revType">
						    <option value="#GEN_CD_TXT#" <cfif variables.extRevType.Typ_CD EQ GEN_CD_TXT>selected</cfif>>#DESC_TXT#</option>
                        </cfloop>
	                </select>
	            </td>
	        </tr>
	        <tr>
	            <td align="right" bgcolor="Silver" width="45%">
	                Other (Specify):
	            </td>
	            <td>
	                <input type="text" name="revOther" id="revOther" maxlength="50" size="50" value="#variables.extRevType.expl_txt#">
	            </td>
	        </tr>
		    <cfif applDates.APPL_APPR_FLG NEQ "Y">
		        <tr>
		            <td colspan="2" class="buttons">
		                <input name="submitRev" id="submitRev" type="submit" value="Edit" class="secured"  />
		            </td>
		        </tr>
		    </cfif>
	    </table>
	</form>

	<br />

	<!---- grant duration form ---->
	<form name="grantDurationForm" action="#self#?fuseaction=genApplInfo.GAIGrantDurationUpdate" method="post">
		<input type="hidden" name="GRANT_APPL_SEQ_NUM" value="#applDates.GRANT_APPL_SEQ_NUM#">
		<input type="hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">
	    <span style="padding-left:5%;">Grant Duration:</span>
	    <table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="90%">
	        <tr>
	            <td align="right" bgcolor="Silver" width="45%">
	                Start Date:
	            </td>
	            <td>
	                <input name="START_DT" type="text" value="#Dateformat(applDates.START_DT,'mm/dd/yyyy')#" maxlength="10"  size="10"  id="START_DT"  onblur="return validateDate(this)" />&nbsp;
	            </td>
	        </tr>
	        <tr>
	            <td align="right" bgcolor="Silver" width="45%">
	                End Date:
	            </td>
	            <td>
	                <input name="END_DT" type="text" value="#Dateformat(applDates.END_DT,'mm/dd/yyyy')#" maxlength="10"  size="10"  id="END_DT"  onblur="return validateDate(this)" />&nbsp;
	            </td>
	        </tr>
			<cfif applDates.APPL_APPR_FLG NEQ "Y">
				<tr>
	                <td colspan="2" class="buttons">
	                    <input name="submitRev" id="submitRev" type="submit" value="Edit" class="secured"  />
	                </td>
				</tr>
			</cfif>
	    </table>
	</form>

	<br />

	<!---- application information ---->
	<table align="center" border="0" width="90%">
		<tr>
			<td>
				<cfif GAIApplInfoDetail.recordCount EQ 0>
					Applicant Information - <a href="#self#?fuseaction=genApplInfo.GAIApplInfoAddEdit&pgm_grant_seq_num=#pgm_grant_seq_num#&usas_num_txt=#usas_num_txt#">Add</a><br /><br />
				<cfelse>
					<form name="form" action="index.cfm?fuseaction=genApplInfo.GAIApplInfoAddEdit" method="post">
						<input type="Hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">
						<input type="Hidden" name="v_pageNameFrom" value="GAIApplInfo">
						<input type="Hidden" name="v_pageType" value="EDIT">

						Applicant Information:
						<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="100%">
							<tr>
								<td align="right" bgcolor="Silver" width="45%">&nbsp;Agency Name:</td>
								<td>#GAIApplInfoDetail.agy_name#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">&nbsp;TCEQ Federal Grant Analyst:</td>
								<td>#GAIApplInfoDetail.agy_fed_grant_analyst_name#</td>
							</tr>
							<tr>
								<td align="right" valign="top" bgcolor="Silver" width="45%">&nbsp;Applicant Mailing Address:</th>
								<td>
								    #GAIApplInfoDetail.addr1_txt#<br>
		                            <cfif #GAIApplInfoDetail.addr2_txt# NEQ "">#GAIApplInfoDetail.addr2_txt#<br></cfif>
		                            #GAIApplInfoDetail.city_name#, #GAIApplInfoDetail.state_cd# - #GAIApplInfoDetail.zip_cd#
								</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">&nbsp;Lead Division:</th>
								<td>#GAIApplInfoDetail.div_num_cd# - #GAIApplInfoDetail.div_title_name#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Data Universal Numbering System (DUNS) Number:</th>
								<td valign="top">#GAIApplInfoDetail.duns_num#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Employer Identification Number (EIN):</th>
								<td>#GAIApplInfoDetail.empr_id_num#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Applicant Congressional District:</td>
								<td>TX-#numberFormat(10, "000")#</td>
							</tr>
		                    <cfif applDates.APPL_APPR_FLG NEQ "Y">
			                    <tr>
			                        <td align="center" colspan="2">
	                                    <input type="submit" name="submitButton" value="Edit"/>
			                        </td>
			                    </tr>
		                    </cfif>
						</table>
					</form>
                </cfif>
			</td>
		</tr>
	</table>

	<br />

	<!---- executive order form ---->
	<table align="center" border="0" width="90%">
		<tr>
			<td>
				<form name="form" action="index.cfm?fuseaction=genApplInfo.GAIInterGovtRevInfoAddEdit" method="post">
					<input type="Hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">
					<input type="Hidden" name="v_pageNameFrom" value="GAIInterGovtRevInfo">
					<input type="Hidden" name="v_pageType" value="EDIT">

					Is Application Subject to Review by State Under Executive Order 12372 Process?
					<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="100%">
						<tr>
                            <!---- value will be in list form and will pass the sai_typ_cd and subj_eo_12372_ind data to the db ---->
							<td><input type="radio" name="eo12372" value="TXR,Y" <cfif GAIInterGovtRevInfoDetail.sai_typ_cd Contains "TXR">checked</cfif>></td>
							<td valign="top">
								a. This application was made available to the State under the Executive Order 12372 Process for review on:
								<input name="eo12372Date" type="text" value="#DateFormat(GAIInterGovtRevInfoDetail.sai_rev_dt, 'MM/DD/YYYY')#" maxlength="10" size="10" id="eo12372Date" />
								<a href="javascript:NewCal('eo12372Date','mmddyyyy')"><img src="images/cal.gif" width="16" height="16" border="0" alt="Pick a date" /></a>
							</td>
						</tr>
						<tr>
                            <!---- value will be in list form and will pass the sai_typ_cd and subj_eo_12372_ind data to the db ---->
							<td><input type="radio" name="eo12372" value="NS,Y" <cfif GAIInterGovtRevInfoDetail.sai_typ_cd Contains "NS">checked</cfif>></td>
							<td valign="top">
								b. Program is subject to E.O. 12372 but has not been selected by the State for review.
							</td>
						</tr>
						<tr>
                            <!---- value will be in list form and will pass the sai_typ_cd and subj_eo_12372_ind data to the db ---->
							<td><input type="radio" name="eo12372" value="NA,N" <cfif GAIInterGovtRevInfoDetail.sai_typ_cd Contains "NA">checked</cfif>></td>
							<td valign="top">
								c. Progam is not covered by E.O. 12372.
							</td>
						</tr>
                        <cfif applDates.APPL_APPR_FLG NEQ "Y">
                            <tr>
                                <td align="center" colspan="2">
                                    <input type="submit" name="submitButton" value="Edit"/>
                                </td>
                            </tr>
                        </cfif>
					</table>
				</form>
			</td>
		</tr>
	</table>

	<br />

	<!---- affected by grant form ---->
	<table align="center" border="0" width="90%">
		<tr>
			<td>
                <cfif getGrantCounty.recordCount EQ 0>
		            Areas Affected By Grant (Congressional Districts) - <a href="#self#?fuseaction=countyAssoc.showDistricts&heading=genapp&seqNum=#v_grant_seq_num#&grant_seq_num=#v_grant_seq_num#&pgm_grant_seq_num=#pgm_grant_seq_num#&name=GRANT&return=#currcircuit#.genApplInfo&v_pageType=GAI">Add</a><br /><br />
                <cfelse>
					Areas Affected By Grant:
					<form name="form" action="#self#?fuseaction=countyAssoc.showDistricts&seqNum=#v_grant_seq_num#&grant_seq_num=#v_grant_seq_num#&pgm_grant_seq_num=#pgm_grant_seq_num#&name=GRANT&return=#currcircuit#.genApplInfo&v_pageType=GAI" method="post" onsubmit="return _CF_checkCFForm_2(this)">
						<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="100%">
							<tr>
								<td align="right" valign="top" bgcolor="silver" width="45%">Congressional Districts:</td>
								<td colspan="">
									<select name="congDist" id="congDist" multiple="multiple" size="10" style="width:150px;">
										<cfloop query="variables.congDist">
											<option val="TX-#numberFormat(dist_num, '000')#">TX-#numberFormat(dist_num, "000")#</option>
										</cfloop>
									</select>
								</td>
							</tr>
			                <cfif #applDates.APPL_APPR_FLG# NEQ "Y">
			                    <tr>
			                        <td align="center" colspan="2">
		                                <input type="submit" name="submitButton" value="Edit"/>
	                                </td>
			                    </tr>
			                </cfif>
				        </table>
			        </form>
                </cfif>
			</td>
		</tr>
	</table>

	<br />

	<!---- counties form ---->
	<table align="center" border="0" width="90%">
	    <tr>
	        <td>
                <cfif getGrantCounty.recordCount EQ 0>
                    Areas Affected By Grant (Counties) - <a href="#self#?fuseaction=countyAssoc.showCounties&heading=genapp&seqNum=#v_grant_seq_num#&grant_seq_num=#v_grant_seq_num#&pgm_grant_seq_num=#pgm_grant_seq_num#&name=GRANT&return=#currcircuit#.genApplInfo&v_pageType=GAI">Add</a><br /><br />
                <cfelse>
		            <form name="form" action="#self#?fuseaction=countyAssoc.showCounties&seqNum=#v_grant_seq_num#&grant_seq_num=#v_grant_seq_num#&pgm_grant_seq_num=#pgm_grant_seq_num#&name=GRANT&return=#currcircuit#.genApplInfo&v_pageType=GAI" method="post" onsubmit="return _CF_checkCFForm_2(this)">
		                <table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="100%">
		                    <tr>
		                        <td align="right" valign="top" bgcolor="silver" width="45%">County(ies):</td>
		                        <td colspan="">
						            <select name="cnty_name" multiple="multiple" size="15" style="width:150px;">
		                                <cfloop query="getGrantCounty">
							                <option value="#CNTY_ID#">#CNTY_NAME#</option>
						                </cfloop>
						            </select>
		                        </td>
		                    </tr>
	                        <cfif #applDates.APPL_APPR_FLG# NEQ "Y">
	                            <tr>
	                                <td align="center" colspan="2">
	                                    <input type="submit" name="submitButton" value="Edit"/>
	                                </td>
	                            </tr>
	                        </cfif>
		                </table>
		            </form>
                </cfif>
	        </td>
	    </tr>
	</table>

	<br />

	<!---- grant type/media form ---->
	<table align="center" border="0" width="90%">
		<tr>
			<td>
				<cfif v_GAIGrantTypeMediaDetailRecordCount EQ 0>
				    Grant Type and Media - <a href="#self#?fuseaction=genApplInfo.GAIGrantTypeMediaAddEdit&pgm_grant_seq_num=#pgm_grant_seq_num#&usas_num_txt=#usas_num_txt#">Add</a><br /><br />
				<cfelse>
					<form name="form" action="index.cfm?fuseaction=genApplInfo.GAIGrantTypeMediaAddEdit" method="post">
						<input type="Hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">
						<input type="Hidden" name="v_pageNameFrom" value="GAIGrantMediaType">
						<input type="Hidden" name="v_pageType" value="EDIT">
						Grant Type and Media:
						<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="100%">
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Media Type:</th>
								<td valign="top">AIR</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Performance Partnership Grant (PPG):</th>
								<td valign="top">
			                       <cfif ppgDetail.ppg_flg EQ "Y">
			                          <cfset v_ppg_flg="YES">
			                       <cfelseif ppgDetail.ppg_flg EQ "N">
			                          <cfset v_ppg_flg="NO">
			                       </cfif>
			                       #v_ppg_flg#
		                        </td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">&nbsp;Type of Grant:</th>
								<td valign="top">#grantTypeDetail.appl_subm_typ_name#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">&nbsp;Grant Description:</th>
								<td valign="top">#ppgDetail.comnt_txt#</td>
							</tr>
		                    <cfif applDates.APPL_APPR_FLG NEQ "Y">
		                        <tr>
		                            <td align="center" colspan="2"><input type="submit" name="submitButton" value="Edit"/></td>
		                        </tr>
		                    </cfif>
						</table>
					</form>
	            </cfif>
			</td>
		</tr>
	</table>

	<br />

	<table align="center" border="0" width="90%">
		<tr>
			<td>
                <cfif GAIGrantorCFRDetail.RecordCount EQ 0>
	                Grantor and CFR - <a href="#self#?fuseaction=genApplInfo.GAIGrantorCFRAdd&pgm_grant_seq_num=#pgm_grant_seq_num#&v_pageNameFrom=GAIGrantorCFR&v_pageType=EDIT&usas_num_txt=#usas_num_txt#">Add</a>
                    <br /><br />
                <cfelse>
					<form name="form" action="index.cfm?fuseaction=genApplInfo.GAIGrantorCFREdit" method="post">
						<input type="Hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">
						<input type="Hidden" name="v_pageNameFrom" value="GAIGrantorCFR">
						<input type="Hidden" name="v_pageType" value="EDIT">
						Grantor and CFR:
						<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="100%">
							<tr>
								<td align="right" bgcolor="Silver" width="45%">CFDA Number:</td>
								<td valign="top">
			                        <cfif IsDefined("grantCFDADetail.cfda_num_cd")>
			                            #grantCFDADetail.cfda_num_cd#
			                        </cfif>
		                        </td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%" valign="top">CFDA Name:</td>
								<td valign="top">
			                        <cfif IsDefined("grantCFDADetail.cfda_pgm_title_txt")>
			                             #grantCFDADetail.cfda_pgm_title_txt#
			                        </cfif>
		                        </td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%" valign="top">CFDA Comment:</td>
								<td valign="top">
			                        <cfif IsDefined("getlatestCFDARevsComnt.cfda_revs_comnt_txt")>
			                             #getlatestCFDARevsComnt.cfda_revs_comnt_txt#
			                        </cfif>
								</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Grantor Agency:</td>
								<td valign="top">#GAIGrantorCFRDetail.grantor_agy_name#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">EPA Region:</td>
								<td valign="top">#GAIGrantorCFRDetail.epa_region_name#</td>
							</tr>
							<tr>
								<td align="right" bgcolor="Silver" width="45%">Code of Federal Regulations (CFR) Governing Citation<br />CFR Name/Agency/Part:</td>
								<td colspan="2" valign="top">#getGrantorCFRCitDetail.title_num#/#getGrantorCFRCitDetail.agy_dept_name#/#getGrantorCFRCitDetail.applic_cfr_part_num_cd#</td>
							</tr>
		                    <cfif applDates.APPL_APPR_FLG NEQ "Y">
		                        <tr>
		                            <td align="center" colspan="2"><input type="submit" name="submitButton" value="Edit"/></td>
		                        </tr>
		                    </cfif>
						</table>
					</form>
                </cfif>
			</td>
		</tr>
	</table>

	<br />

	<!---- previous revisions ---->
	<form name="preRevForm" id="preRevForm">
		<span style="padding-left:5%;">Previous Revision:</span><br />
		<span style="padding-left:5%;font-size:75%;">(Populates 424A "Previous" column)</span>
		<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="90%">
			<tr>
				<td align="right" bgcolor="Silver" width="45%">
					Previous Revision:
				</td>
				<td>
                    <cfif variables.prevRevisions.recordcount GT 0>
						<select name="prevRev" id="prevRev">
	                        <cfloop query="variables.prevRevisions">
								<option value="#amend_num#,#revs_num#">#amend_num#.#revs_num#</option>
	                        </cfloop>
						</select>
                    <cfelse>
                        &nbsp;#Trim(v_amend_num)#.#Trim(v_revs_num)#
                    </cfif>
				</td>
			</tr>
		</table>
	</form>

	<br />

	<!---- grant funding ---->
    <div aria-live="assertive">
		<form name="fundsForm"  id="fundsForm" action="#self#?fuseaction=genApplInfo.GAI424Funding" method="post">
	        <input type="hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">
	        <input type="hidden" name="amend_num" value="#Trim(v_amend_num)#">
	        <input type="hidden" name="revs_num" value="#Trim(v_revs_num)#">

			<span style="padding-left:5%;">First Funding or Amount of Change ($):</span><br />
			<span style="padding-left:5%;font-size:75%;">(Based on previous revision selected above. Populates 424 and should not include previous revisions.)</span>
			<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="90%">
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						a. Federal:
					</td>
					<td>
		                <input type="input" name="fedAmt" id="fedAmt" style="text-align:right;border:0px" readonly  value="#numberFormat(v_fedTotal, '99999.99')#"/>
					</td>
				</tr>
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						b. Applicant:
					</td>
					<td>
		                <input type="input" name="appAmt" id="appAmt" style="text-align:right;"  value="#numberFormat(v_applTotal,  '99999.99')#"/>
	                    <input type="hidden" name="preRevAppAmt" id="preRevAppAmt" value="#numberFormat(variables.preRevApplFunds.applicant_total_amt,  '99999.99')#"/>
					</td>
				</tr>
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						c. State:
					</td>
					<td>
		                <input type="input" name="stateAmt" id="stateAmt" style="text-align:right;"  value="#numberFormat(v_stateTotal,  '99999.99')#"/>
	                    <input type="hidden" name="preRevStateAmt" id="preRevStateAmt" value="#numberFormat(variables.preRevStateFunds.state_total_amt,  '99999.99')#"/>
					</td>
				</tr>
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						d. Local:
					</td>
					<td>
		                <input type="input" name="localAmt" id="localAmt" style="text-align:right;"  value="#numberFormat(v_localTotal,  '99999.99')#"/>
	                    <input type="hidden" name="preRevLocalAmt" id="preRevLocalAmt" value="#numberFormat(variables.preRevLocalFunds.local_total_amt,  '99999.99')#"/>
					</td>
				</tr>
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						e. Other:
					</td>
					<td>
		                <input type="input" name="otherAmt" id="otherAmt" style="text-align:right;"  value="#numberFormat(v_otherTotal,  '99999.99')#"/>
	                    <input type="hidden" name="preRevOtherAmt" id="preRevOtherAmt" value="#numberFormat(variables.preRevOtherFunds.OtherTotalAmt,  '99999.99')#"/>
					</td>
				</tr>
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						f. Program Income:
					</td>
					<td>
		                <input type="input" name="pgmAmt" id="pgmAmt" style="text-align:right"  value="#numberFormat(v_pgmTotal,  '99999.99')#"/>
	                    <input type="hidden" name="preRevPgmAmt" id="preRevPgmAmt" value="#numberFormat(variables.preRevPgmFunds.pgm_total_amt,  '99999.99')#"/>
					</td>
				</tr>
				<tr>
					<td align="right" bgcolor="Silver" width="45%">
						g. Total:
					</td>
					<td>
		                <input type="label" name="totalAmt" id="totalAmt" style="text-align:right;border:0px" readonly value="#numberFormat(v_fundTotal,  '99999.99')#"/>
					</td>
				</tr>
	            <cfif (applDates.APPL_APPR_FLG NEQ "Y") AND (v_fedTotal NEQ v_fundTotal)>
	                <tr>
	                    <td align="center" colspan="2"><input type="submit" name="submitButton" id="submitButton" value="Edit"/></td>
	                </tr>
	            </cfif>
			</table>
		</form>
    </div>

	<br />

    <!---- authorized representative form ---->
	<form name="authRepForm" action="#self#?fuseaction=genApplInfo.GAIGrantAuthorizedRep" method="post">
        <input type="hidden" name="grant_seq_num" value="#v_grant_seq_num#">
        <input type="hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">

        <!---- set form action type (add/edit) ---->
        <cfif variables.extAuthRep.recordcount EQ 0>
            <input type="hidden" name="qryAction" value="Add">
        <cfelse>
            <input type="hidden" name="qryAction" value="Edit">
        </cfif>

		<span style="padding-left:5%;">Authorized Representative:</span>
		<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="90%">
			<tr>
				<td align="right" bgcolor="Silver" width="45%">
					Name:
				</td>
				<td>
					<select name="authRepName" id="authRepName" style="width:99%">
						<option value=""></option>
		                <cfloop query="variables.authRepNames">
		                    <option value="#Trim(GEN_CD_TXT)#,#Trim(DESC_TXT)#"<cfif variables.extAuthRep.grant_auth_rep_name EQ Trim(DESC_TXT)>selected</cfif>>#DESC_TXT#</option>
	                    </cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right" bgcolor="Silver" width="45%">
					Title:
				</td>
				<td>
					<select name="authRepTitle" id="authRepTitle" style="width:99%">
	                    <option value=""></option>
	                    <cfloop query="variables.authRepTitles">
	                        <option value="#Trim(DESC_TXT)#"<cfif variables.extAuthRep.grant_auth_rep_title EQ Trim(DESC_TXT)>selected</cfif>>#DESC_TXT#</option>
	                    </cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right" bgcolor="Silver" width="45%">
					Is Signature Required in Grants Module?:
				</td>
				<td>
					<select name="authRepSigReq" id="authRepSigReq" style="width:99%">
						<option value="Yes"<cfif variables.extAuthRep.grant_auth_rep_sig_req EQ "Yes">selected</cfif>>Yes</option>
						<option value="No"<cfif variables.extAuthRep.grant_auth_rep_sig_req EQ "No">selected</cfif>>No</option>
						<option value="Signed Outside Grants Module"<cfif variables.extAuthRep.grant_auth_rep_sig_req Contains "Signed">selected</cfif>>Signed Outside Grants Module</option>
					</select>
				</td>
			</tr>
            <cfif applDates.APPL_APPR_FLG NEQ "Y">
                <tr>
                    <td align="center" colspan="2"><input type="submit" name="submitButton" value="Edit"/></td>
                </tr>
            </cfif>
		</table>
	</form>

	<br />

    <!---- comments ---->
	<form name="commentForm" action="#self#?fuseaction=genApplInfo.GAIGrantComments" method="post">
        <input type="hidden" name="grant_seq_num" value="#v_grant_seq_num#">
        <input type="hidden" name="pgm_grant_seq_num" value="#pgm_grant_seq_num#">

		<span style="padding-left:5%;">Comment:</span><br />
		<span style="padding-left:5%;font-size:75%;">(Populates 424A "Remarks" field)</span>
		<table align="center" class="list" cellspacing="1" cellpadding="1" border="1" width="90%">
			<tr>
				<td align="right" bgcolor="Silver" width="45%">
					Comment:
				</td>
				<td>
					<textarea rows="5" cols="50" name="ComntTXT">#ppgDetail.Comnt_TXT#</textarea>
				</td>
			</tr>
            <cfif applDates.APPL_APPR_FLG NEQ "Y">
                <tr>
                    <td align="center" colspan="2"><input type="submit" name="submitButton" value="Edit" class="secured"/></td>
                </tr>
            </cfif>
		</table>
	</form>
</cfoutput>

<cfset fieldNameListTemp="pgm_grant_seq_num">
<cfset fieldValueListTemp=pgm_grant_seq_num>

<cfcookie name="fieldNameList" value="" expires="now">
<cfcookie name="fieldValueList" value="" expires="now">

<cfcookie name="fieldNameList" value="#fieldNameListTemp#">
<cfcookie name="fieldValueList" value="#fieldValueListTemp#">
