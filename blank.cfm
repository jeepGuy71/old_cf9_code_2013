<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!---- initiate cfcs (begins) ---->
<cfscript>
    o_teamRoster  = createobject("component","cfc.teamRoster");
    o_teamSchedule  = createobject("component","cfc.teamSchedules");
    o_teamNews = createobject("component","cfc.teamNews");
    o_teamGallery = createobject("component","cfc.teamGallery");
    o_teamDocs = createobject("component","cfc.teamDocs");
</cfscript>
<!---- initiate cfcs (ends) ---->

<!---- ajax calls (begins) ---->
    <cfajaxproxy cfc="cfc.teamProfiles"  jsclassname="o_team_Profile"  />
    <cfajaxproxy cfc="cfc.teamSchedules"  jsclassname="o_teamSchedules"  />
    <cfajaxproxy cfc="cfc.teamNews"  jsclassname="o_teamNews"  />
    <cfajaxproxy cfc="cfc.teamGallery"  jsclassname="o_teamGallery"  />\
    <cfajaxproxy cfc="cfc.teamDocs"  jsclassname="o_teamDocs"  />
<!---- ajax calls (ends) ---->

<!---- set default vars ---->
<cfparam name="pageView" default="0">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<meta charset="utf-8">
		<title>ADMIN</title>
		<link rel="stylesheet" type="text/css" href="css/admin.css" />
	</head>

	<body>
	<cfif isDefined('session.admin_teamID')>
	   	<div id="admin-logout">
	   		<!---- top nav (BEGINS) ---->
	   		<table width="800" border="0" align="center" cellpadding="0" cellspacing="0">
			    <tr>
			      <td width="631" height="56" align="right" valign="bottom">
			      	  <!---- sup user can change teams ---->
				      <cfif session.admin_teamID NEQ 0>
				      	<!---- change teams ---->
				      	<cfif pageView EQ 'roster' OR pageView EQ 'schedule'>
							<form action="super.cfm" name="changeForm" method="Post" id="admin-team-change"> 
								<input type="hidden" Name="changeTeams" value="True"> 
							</form> 		      	

					      	<img src="images/button-changeteam.png" alt="" width="106" height="30" onClick="changeTeams();" />
				      	</cfif>
				      </cfif>
			      </td>
			      <td width="10" align="right" valign="bottom">&nbsp;</td>
			      <td width="113" align="left" valign="bottom">
			      	<!---- logout user ---->
					<form action="index.cfm" name="logoutForm" method="Post" id="admin-team-logout"> 
						<input type="hidden" Name="Logout" value="Logout"> 
					</form> 		      	
					<img src="images/button-logout.png" alt="" width="106" height="30" onClick="logout();" />
			      </td>
			      <td width="49" align="left" valign="bottom">
			      	<!---- send sup user to main menu ---->
				    <cfif IsUserInRole(1)>
			      		<img src="images/button-mainmenu.png" alt="" width="39" height="30" onClick="javascript:window.open('super.cfm','_self');" />
			      	</cfif>
			      </td>
		        </tr>
		    </table>
		    <!---- top nav (ENDS) ---->
		 </div>

			<div id="admin-main">
			  <!---- main admin nav (BEGINS) ---->
			  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0">
			    <tr>
			      <!---- logo ---->
			      <td align="center"><img src="images/admin-logo-dark.png" alt="" width="85" height="43" /></td>
				  <cfif session.admin_teamID NEQ 0>
				      <td align="center">
				      	<!---- roster ---->
						<form action="blank.cfm" name="rosterForm" method="Post"> 
						    <input type="hidden" Name="pageView" value="roster"> 
						</form>  
		                <!---- process roster request ----> 
				      	<img src="images/button-menu-roster.png" alt="" width="156" height="43" onClick="roster();" />
				      </td>

				      <td align="center">
				      	<!---- schedule ---->
						<form action="blank.cfm" name="scheduleForm" method="Post"> 
						    <input type="hidden" Name="pageView" value="schedule"> 
						</form>  
		                <!---- process schedule request ----> 
				      	<img src="images/button-menu-schedule.png" alt="" width="156" height="43" onClick="schedule();" />
				      </td>

				      <td align="center">
				      	<!---- news ---->
						<form action="blank.cfm" name="newsForm" method="Post"> 
						    <input type="hidden" Name="pageView" value="news"> 
						</form>  
		                <!---- process news request ----> 
				      	<img src="images/button-menu-news.png" alt="" width="156" height="43" onClick="news();" />
				      </td>

				      <td align="center">
				      	<!---- gallery ---->
						<form action="blank.cfm" name="galleryForm" method="Post"> 
						    <input type="hidden" Name="pageView" value="gallery"> 
						</form>  
		                <!---- process gallery request ---->		      	
		                <img src="images/button-menu-gallery.png" alt="" width="156" height="43" onClick="gallery();" />
				      </td>
			      </cfif>
		        </tr>
		      </table>
		      <!---- main admin nav (ENDS) ---->
			      <!---- page view (BEGINS) ---->
			      <cfswitch expression="#pageView#">
					<!---- roster details (BEGINS) ---->
			      	<cfcase value="roster">
			      		<br />
			      		<br />
						<!---- call cfc to get roster ---->
						<cfset getRoster = o_teamRoster.rosterLineUp(session.admin_teamID)>

						<!---- add new profile (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/form-profile-ad.png" name="addProfile" id="addProfile" onClick="javascript:window.open('form.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new profile (STOP) ---->

						<br />

						<cfoutput> 
							<!---- roster line up (BEGINS) ---->
							<table cellpadding="5" cellspacing="1" border="0" width="800" align="center">
								<tr>
									<th  class="bg-tableheader">Name</th>
									<th class="bg-tableheader">Position</th>
									<th class="bg-tableheader"></th>
	                                <th class="bg-tableheader"></th>
								</tr>
								<cfloop query="getRoster">
									<tr class="bg-table">
										<td width="132" valign="middle">
											#firstName# #lastName#
									  </td>
										<td width="196" valign="middle">
											#position#
									  </td>
										<!---- edit profile ---->
										<td width="132" align="center" valign="middle">
											<form action="form.cfm" method="post" name="rosterForm">
												<input type="image" src="images/button-edit.png" name="editProfile" id="editProfile">
												<input type="hidden" name="profileAction" id="profileAction" value="update">
												<input type="hidden" name="profile_ID" id="profile_ID" value="#profileID#">
                                        	</form>
										</td>
										<!---- remove profile ---->
										<td width="132" align="center" valign="middle">
											<input type="image" src="images/button-delete.png" name="removeProfile" id="removeProfile" onClick="removeProfile(#profileID#)">
                                            
										</td>
									</tr>
								</cfloop>
							</table>
							<!---- roster line up (ENDS) ---->
						</cfoutput>

						<br /> 

						<!---- add new profile / return to main menu (STOP) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/form-profile-ad.png" name="addProfile" id="addProfile" onClick="javascript:window.open('form.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new profile / return to main menu (STOP) ---->

						<br />
						<br /> 
			      	</cfcase>
					<!---- roster details (ENDS) ---->

					<!---- schedule details (BEGINS) ---->
			      	<cfcase value="schedule">
			      		<br />
			      		<br />
						<!---- call cfc to get schedule ---->
						<cfset getSchedule = o_teamSchedule.scheduledEvents(session.admin_teamID)>

						<!---- add new event (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/button-addevent.png" name="addSchedule" id="addSchedule" onClick="javascript:window.open('schedule.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new event (STOP) ---->

						<br />

						<cfoutput> 
							<!---- scheduled events (BEGINS) ---->
							<table cellpadding="1" cellspacing="1" border="0" width="100%" align="center">
								<tr>
									<th class="bg-tableheader">Date</th>
									<th class="bg-tableheader">Tournament</th>
									<th class="bg-tableheader">Location</th>
									<th class="bg-tableheader">&nbsp;</th>
                                    <th class="bg-tableheader">&nbsp;</th>
								</tr>
								<cfloop query="getSchedule">

									<!---- set event date var (START) ---->
									<cfset eventDate = endDate NEQ ''?"#dateFormat(startDate, 'mm/dd/yyyy')# - #dateFormat(endDate, 'mm/dd/yyyy')#":"#dateFormat(startDate, 'mm/dd/yyyy')#">
									<!---- set event date var (END) ---->

									<tr class="bg-table">
										<td width="91" valign="top">
											#eventDate#
										</td>
										<td width="236" valign="top">
											#event#
										</td>
										<td width="148" valign="top">
											#location#
										</td>
										<!---- edit scheduled event ---->
										<td width="132" align="center" valign="top">
											<form action="schedule.cfm" method="post" name="scheduleForm">
												<input type="image" src="images/button-edit.png" name="editSchedule" id="editSchedule">
												<input type="hidden" name="eventAction" id="eventAction" value="update">
												<input type="hidden" name="scheduleID" id="scheduleID" value="#scheduleID#">
	                                        </form>
										</td>
										<!---- remove scheduled event ---->
										<td width="132" align="center" valign="top">
											<input type="image" src="images/button-delete.png" name="removeEvent" id="removeEvent" onClick="removeEvent(#scheduleID#)">
										</td>
									</tr>
								</cfloop>
							</table>
							<!---- scheduled events (ENDS) ---->
						</cfoutput>

						<br /> 

						<!---- add new event (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/button-addevent.png" name="addSchedule" id="addSchedule" onClick="javascript:window.open('schedule.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new event (STOP) ---->

						<br />
						<br /> 
			      	</cfcase>
					<!---- schedule details (ENDS) ---->

					<!---- news details (BEGINS) ---->
			      	<cfcase value="news">
			      		<br />
			      		<br />
						<!---- call cfc to get news ---->
						<cfset getNews = o_teamNews.newsItems(session.admin_teamID)>

						<!---- add news item or announcement (START) ---->
						<table cellpadding="0" cellspacing="0" width="50%" border="0" align="center">
							<tr>
								<td align="center">
									<!---- add news item ---->
									<input type="image" src="images/button-addnews.png" name="addNewsItem" id="addNewsItem" onClick="javascript:window.open('news.cfm?','_self');">
				    				<cfif IsUserInRole(0)>
										<!---- add player announcement ---->
										<input type="image" src="images/button-addplayernews.png" name="addPlayerNews" id="addPlayerNews" onClick="javascript:window.open('news.cfm?pageView=pNews','_self');">
									</cfif>

								</td>
							</tr>
						</table>
						<!---- add news item or announcement (END) ---->

						<br />

						<cfoutput> 
							<!---- news items (BEGINS) ---->
							<table cellpadding="1" cellspacing="1" border="0" width="100%" align="center">
								<tr>
									<th class="bg-tableheader">Date</th>
									<th class="bg-tableheader">Title</th>
									<th class="bg-tableheader">&nbsp;</th>
                                    <th class="bg-tableheader">&nbsp;</th>
								</tr>
								<cfloop query="getNews">
									<tr class="bg-table">
										<td width="91">
											#dateformat(nDate,'mm/dd/yyyy')#
										</td>
										<td width="396">
											#title#
										</td>
										<!---- edit news item ---->
										<td width="132" align="center">
											<form action="news.cfm" method="post" name="newsForm">
												<input type="image" src="images/button-edit.png" name="editnews" id="editnews">
												<input type="hidden" name="itemAction" id="itemAction" value="update">
												<input type="hidden" name="newsID" id="newsID" value="#newsID#">
                                        	</form>
										</td>
										<!---- remove news item ---->
										<td width="132" align="center">
											<input type="image" src="images/button-delete.png" name="removeItem" id="removeItem" onClick="removeItem(#newsID#)">
										</td>
									</tr>
								</cfloop>
							</table>
							<!---- news items (ENDS) ---->
						</cfoutput>

						<br /> 

						<!---- add news item or announcement (START) ---->
						<table cellpadding="0" cellspacing="0" width="50%" border="0" align="center">
							<tr>
								<td align="center">
									<!---- add news item ---->
									<input type="image" src="images/button-addnews.png" name="addNewsItem" id="addNewsItem" onClick="javascript:window.open('news.cfm?','_self');">
				    				<cfif IsUserInRole(0)>
										<!---- add player announcement ---->
										<input type="image" src="images/button-addplayernews.png" name="addPlayerNews" id="addPlayerNews" onClick="javascript:window.open('news.cfm?pageView=pNews','_self');">
									</cfif>
								</td>
							</tr>
						</table>
						<!---- add news item or announcement (STOP) ---->

						<br />
						<br /> 
			      	</cfcase>
					<!---- news details (ENDS) ---->

					<!---- gallery details (BEGINS) ---->
			      	<cfcase value="gallery">
			      		<!---- set team dirs ---->
			      		<cfswitch expression="#session.admin_teamID#">
			      			<cfcase value="1">
			      				<cfset teamDir = '10U'>
			      			</cfcase>
			      			<cfcase value="2">
			      				<cfset teamDir = '12U'>
			      			</cfcase>
			      			<cfcase value="3">
			      				<cfset teamDir = '14U'>
			      			</cfcase>
			      			<cfcase value="4">
			      				<cfset teamDir = '16U'>
			      			</cfcase>
			      			<cfcase value="5">
			      				<cfset teamDir = '18U'>
			      			</cfcase>
			      			<cfdefaultcase>
			      				<cfset teamDir = 'main'>
			      			</cfdefaultcase>
			      		</cfswitch>

			      		<br />
			      		<br />

						<!---- call cfc to getimg list ---->
						<cfset getGallery = o_teamGallery.imgList(session.admin_teamID)>

						<!---- add new image (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/button-addimage.png" name="addImage" id="addImage" onClick="javascript:window.open('gallery.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new image (STOP) ---->

						<br />

						<cfoutput> 
							<!---- image list (BEGINS) ---->
							<table cellpadding="1" cellspacing="1" border="0" width="100%" align="center">
								<tr>
									<th class="bg-tableheader">Image Title</th>
									<th class="bg-tableheader">Image Name</th>
									<th class="bg-tableheader">&nbsp;</th>
								</tr>
								<cfloop query="getGallery">
									<tr class="bg-table">
										<td width="263" valign="middle">
											#imgDesc#
									  	</td>
										<td width="263" valign="middle">
											#imgName#
									  	</td>
										<!---- remove image ---->
										<td width="237" align="left" valign="middle">
											<a href="../../images/gallery/#teamDir#/#imgName#" target="_blank"><img src="images/button-previewimage.png" border="0"></a>										
											<input type="image" src="images/button-delete.png" name="removeImage" id="removeImage" onClick="removeImage(#imgID#)">
										</td>
									</tr>
								</cfloop>
							</table>
							<!---- image list (ENDS) ---->
						</cfoutput>

						<br /> 

						<!---- add new image (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/button-addimage.png" name="addImage" id="addImage" onClick="javascript:window.open('gallery.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new image (STOP) ---->

						<br />
						<br /> 
			      	</cfcase>
					<!---- gallery details (ENDS) ---->

					<!---- doc details (BEGINS) ---->
			      	<cfcase value="docs">

						<!---- call cfc to getimg list ---->
						<cfset getDocs = o_teamDocs.docList()>

						<!---- add new doc (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/button-adddoc.png" name="addDoc" id="addDoc" onClick="javascript:window.open('documents.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new doc (STOP) ---->

						<br />

						<cfoutput> 
							<!---- doc list (BEGINS) ---->
							<table cellpadding="1" cellspacing="1" border="0" width="100%" align="center">
								<tr>
									<th class="bg-tableheader">Document Title</th>
									<th class="bg-tableheader">Document Name</th>
									<th class="bg-tableheader">&nbsp;</th>
								</tr>
								<cfloop query="getDocs">
									<tr class="bg-table">
										<td width="263" valign="middle">
											#docDesc#
									  	</td>
										<td width="263" valign="middle">
											#docName#
									  	</td>
										<!---- remove doc ---->
										<td width="237" align="left" valign="middle">
											<a href="../../docs/#docName#" target="_blank"><img src="images/button-previewimage.png" border="0"></a>										
											<input type="image" src="images/button-delete.png" name="removeFile" id="removeFile" onClick="removeFile(#docID#)">
										</td>
									</tr>
								</cfloop>
							</table>
							<!---- doc list (ENDS) ---->
						</cfoutput>

						<br /> 

						<!---- add new doc (START) ---->
						<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
							<tr>
								<td align="center">
									<input type="image" src="images/button-adddoc.png" name="addDoc" id="addDoc" onClick="javascript:window.open('documents.cfm','_self');">
								</td>
							</tr>
						</table>
						<!---- add new doc (STOP) ---->

						<br />
						<br /> 
			      	</cfcase>
					<!---- doc details (ENDS) ---->

			      	<!---- return to main screen ---->
			      	<cfdefaultcase>
			      		<cflocation url="index.cfm" addtoken="false">
			      	</cfdefaultcase>
			      </cfswitch>
			  <cfelse>
				<cflocation url="index.cfm" addtoken="false">
			  </cfif>
		      <!---- page view (ENDS) ---->
			</div>
	</body>
</html>

<!---- javascript starts here ---->
<script type='text/javascript'>
    function logout()
    {
        document.forms["logoutForm"].submit();    
    }
    
    function changeTeams()
    {
        document.forms["changeForm"].submit();    
    }


    function roster()
    {
        document.forms["rosterForm"].submit();    
    }

    function schedule()
    {
        document.forms["scheduleForm"].submit();    
    }

    function news()
    {
        document.forms["newsForm"].submit();    
    }

    function gallery()
    {
        document.forms["galleryForm"].submit();    
    }

    function removeProfile(profileID)
    {
         var deleteProfile = new o_team_Profile();
         deleteProfile.inactivateProfile(profileID);

         window.open('blank.cfm?pageView=roster','_self');
    }

    function removeEvent(scheduleID)
    {
         var deleteEvent = new o_teamSchedules();
         deleteEvent.deleteScheduledEvent(scheduleID);

         window.open('blank.cfm?pageView=schedule','_self');
    }

    function removeItem(newsID)
    {
         var deleteEvent = new o_teamNews();
         deleteEvent.deleteNewsItem(newsID);

         window.open('blank.cfm?pageView=news','_self');
    }

    function removeImage(imgID)
    {
         var deleteImage = new o_teamGallery();
         deleteImage.deleteImage(imgID);

         window.open('blank.cfm?pageView=gallery','_self');
    }

    function removeFile(docID)
    {
         var deleteImage = new o_teamDocs();
         deleteImage.deleteFile(docID);

         window.open('blank.cfm?pageView=docs','_self');
    }




</script>
<!---- javascript ends here ---->
