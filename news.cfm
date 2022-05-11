<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!---- initiate cfcs (begins) ---->
<cfscript>
    o_teamNews  = createobject("component","cfc.teamNews");
    o_teamRoster  = createobject("component","cfc.teamRoster");
</cfscript>
<!---- initiate cfcs (ends) ---->

<!---- ajax calls (begins) ---->
    <cfajaxproxy cfc="cfc.teamNews"  jsclassname="o_teamNews"  />
	<cfajaxproxy cfc="cfc.teamProfiles"  jsclassname="o_teamProfile"  />
<!---- ajax calls (ends) ---->

<!---- default vars ---->
<cfparam name="itemAction" default="add">
<cfparam name="pageView" default="">
<cfparam name="newsID" default="0">
<cfparam name="nDate" default="">
<cfparam name="title" default="">
<cfparam name="content" default="">
<cfparam name="newsImg" default="">
<cfparam name="errMsg" default="">
<cfparam name="method" default="addNewsItem">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<meta charset="utf-8">
		<title>ADMIN NEWS</title>
		<link rel="stylesheet" type="text/css" href="css/admin.css" />
	</head>

	<cfif isDefined('session.admin_teamID')>
		<body>
		   	<div id="admin-logout">
		   		<!---- top nav (BEGINS) ---->
		   		<table width="800" border="0" align="center" cellpadding="0" cellspacing="0">
				    <tr>
				      <td width="631" height="56" align="right" valign="bottom"></td>
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
			      	<img src="images/button-menu-news.png" alt="" width="156" height="43" onClick="News();" />
			      </td>

			      <td align="center">
			      	<!---- gallery ---->
					<form action="blank.cfm" name="galleryForm" method="Post"> 
					    <input type="hidden" Name="pageView" value="gallery"> 
					</form>  
	                <!---- process gallery request ---->		      	
	                <img src="images/button-menu-gallery.png" alt="" width="156" height="43" onClick="gallery();" />
			      </td>

		        </tr>
		      </table>
		      <!---- main admin nav (ENDS) ---->

	   			<!---- edit/add users (BEGIN) ---->

				<!---- call cfc to get user detail ---->
				<cfif itemAction EQ 'update'>
					<cfset getNews = o_teamNews.newsItems(session.admin_teamID,newsID)>	

					<!---- set vars frm query ---->
					<cfset nDate = getNews.nDate>
					<cfset title = getNews.title>
					<cfset content = getNews.body>
					<cfset newsImg = getNews.newsImg>

					<!---- cfc method ---->
					<cfset method = 'updateNewsItem'>

					<cfswitch expression="#errMsg#">
						<cfcase value="1">
			   				<cfset errMsg = 'Sorry, the image you are trying to upload is to big. Please ensure image width is no more than 200 pixels'>
						</cfcase>
						<cfcase value="2">
			   				<cfset errMsg = 'Sorry, the image you are trying to upload is to big. Please ensure image height is no more than 225 pixels'>
						</cfcase>
						<cfcase value="3">
			   				<cfset errMsg = 'Sorry, the image you are trying to upload exceeds the maximum file size. Please ensure the image file size is no more than 100K'>
						</cfcase>
						<cfcase value="4">
			   				<cfset errMsg = 'Sorry, the image you are trying to upload must be a JPG. Please try again'>
						</cfcase>
						<cfcase value="5">
	   						<cfset errMsg = 'No image was uploaded, please try again.'>
						</cfcase>
					</cfswitch>
				</cfif>

				<br />
				<br />

				<cfoutput>
					<table width="500" border="0" align="center" cellpadding="0">
						<form name="news_Form" action="cfc/teamNews.cfc?method=#method#" method="post" enctype="multipart/form-data">
							<cfif itemAction EQ 'update'>
								<input type="hidden" name="newsID" value="#newsID#">
							<cfelse>
								<input type="hidden" name="teamID" value="#session.admin_teamID#">
							</cfif>							
							<tr>
								<td width="215" height="29" align="right" valign="top">Date:</td>
								<td width="307" align="left" valign="top">
									<input type="text" id="nDate" name="nDate" size="10" maxlength="25" value="#dateFormat(nDate, 'mm/dd/yyyy')#" onClick="JavaScript:calcDate(document.forms['news_Form'].nDate,true,'nDate')" /> 
									<A HREF="JavaScript:calcDate(document.forms['news_Form'].nDate,true,'nDate')"><IMG SRC="images/calendar.gif" ALT="Pick Date Using Calendar" BORDER="0"></A>
								</td>
								<td width="70">&nbsp;</td>
							</tr>
							<tr>
								<td width="215" height="29" align="right" valign="top">Title:</td>
								<td width="307" align="left" valign="top"><input class="textinput" type="text" id="title" name="title" value="#title#" /></td>
								<td width="70">&nbsp;</td>
							</tr>
							<tr>
								<td width="215" height="29" align="right" valign="top">Content:</td>
								<td width="307" align="left" valign="top"><input class="textinput" type="text" id="content" name="content" value="#content#" /></td>
								<td width="70">&nbsp;</td>
							</tr>
							<cfif pageView EQ '' AND newsImg Does Not Contain 'profilePic_'>
								<tr>
									<td width="215" height="29" align="right" valign="top">Image:</td>
									<td width="460" align="left" valign="top">
										<input class="textinput" type="file" id="newsImg" name="newsImg" value="" />
										<!---- img view ---->
										<cfif newsImg NEQ ''>
											<a href="../../images/news/#newsImg#.jpg" style="color:black;font-size:10px" target="_blank">Preview Image</a>
										</cfif>
									</td>
								</tr>
							<cfelse>
								<!---- call cfc to get user email ---->
								<cfset getPlayers = o_teamRoster.rosterLineUp(session.admin_teamID)>

								<!---- set player ID ---->
								<cfset playerID = newsImg NEQ ''?rereplace(trim(right(newsImg,3)),'[^0-9]+',''):0>

								<tr>
									<td width="215" height="29" align="right" valign="top">Select Player:</td>
									<td width="80" align="left" valign="top">
										<select id="newsImg" name="newsImg">
											<cfloop query="getPlayers">
												<cfset selPlayer = profileID EQ playerID?'selected':''>
												<option value="profilePic_#profileID#" #selPlayer#> #firstName# #lastName#</option>
											</cfloop>
										</select>
										<!---- img view ---->
										<cfif newsImg NEQ ''>
											<a href="../../images/profiles/thumbs/profile/#newsImg#.jpg" style="color:black;font-size:10px" target="_blank">Preview Image</a>
										</cfif>									
									</td>
								</tr>
							</cfif>
							<tr>
								<td colspan="2" align="center" valign="middle">
									<br />

									<!---- submit admin ---->
									<cfif pageView EQ ''>
										<cfset sub_Bttn = itemAction EQ 'add'?'button-addnews':'button-updatenews'>
									<cfelse>	
										<cfset sub_Bttn = itemAction EQ 'add'?'button-addplayernews':'button-updateplayernews'>
									</cfif>
									<input type="image" src="images/#sub_Bttn#.png">

									<!---- cancel action ---->
									<img height="32" width="123" src="images/form-cancel.png"  onClick="cancelUpdate();" />								
								</td>
							</tr>
						</form>								
					</table>
					<!---- error message ---->
					<center>
						<cfif errMsg NEQ ''>
							<span style="color:red; font-weight:bold">#errMsg#</span>
						</cfif>
					</center>
				</cfoutput>
	   			<!---- edit/add users (END) ---->
			</div>
		</body>
	<cfelse>
		<cflocation url="index.cfm" addtoken="false">
	</cfif>
</html>

<!---- javascript starts here ---->
<script type='text/javascript'>
    function logout()
    {
        document.forms["logoutForm"].submit();    
    }

    function roster()
    {
        document.forms["rosterForm"].submit();    
    }

    function schedule()
    {
        document.forms["scheduleForm"].submit();    
    }

    function News()
    {
        document.forms["newsForm"].submit();    
    }

    function gallery()
    {
        document.forms["galleryForm"].submit();    
    }

    function cancelUpdate()
    {
         var killSessions = new o_teamProfile();
         killSessions.deleteSessions();

         window.open('blank.cfm?pageView=news','_self');
    }
	
	function createSession(sesName,sesValue)
	{
		 var createSession = new o_teamProfile();
		 createSession.createSessions(sesName,sesValue);
	}

	function submitEvent(action)
	{

		if(action == 'add')
		{
        
         document.forms["news_Form"].submit();    

		 /* return user to admin line up */
		 window.open ("blank.cfm?pageView=news","_self");

		}
		else
		{
		 var updateItem = new o_teamNews();
		 updateItem.updateNewsItem(teamID,newsID);

		 /* return user to admin line up */
		window.open ("blank.cfm?pageView=news","_self");

		}
	}

    function calcDate(field,f,date)
    {
         window.dateField=field;
         window.isFirst=f;
         remote=window.open("calendar.html","popupcal","width=200,height=250,screenX=400,screenY=400,top=200,left=600");
         remote.location.href="calendar.html";
         if(remote.opener==null) remote.opener=window;
   }


</script>
<!---- javascript ends here ---->
