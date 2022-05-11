<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <title>Sudden Impact</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

  <!--- HEADER--->   
    <cfinclude template="includes/header.cfm">        
  <!--- // HEADER ---> 

  <!---- default vars ---->
    <cfparam name="profile_ID" default="10">

  <!---- profile query (BEGINS) ---->
    <cfquery name="getProfile">
      SELECT tp.teamID, tp.firstName, tp.lastName, tp.position, tp.email, t.hasGameChanger
      FROM   teamProfiles AS tp INNER JOIN
             Teams AS t ON tp.teamID = t.teamID
      WHERE  (tp.profileID = #profile_ID#)
    </cfquery>

  <!---- grab head coach and manager (BEGINS) ---->
    <cfquery name="getCoach">
      SELECT tp.firstName, tp.lastName, tp.position, tp.email
      FROM   teamProfiles AS tp INNER JOIN
             Teams AS t ON tp.teamID = t.teamID
      WHERE  tp.teamID = #getProfile.teamID# AND (tp.position = 'Head Coach' OR tp.position = 'Manager')
      Order by tp.position DESC
    </cfquery>    
  <!---- grab head coach and manager (ENDS) ---->

    <!---- set vars ---->
    <cfset name = '#getProfile.firstName# #getProfile.lastName#'>
    <cfset position = getProfile.position EQ ''?'':getProfile.position>
    <cfset email = getProfile.email EQ ''?'':getProfile.email>
    <cfset hasGameChanger = getProfile.hasGameChanger>

    <!---- set team background (BEGINS) ---->
    <cfswitch expression="#getProfile.teamID#">
      <!---- 10U ---->
      <cfcase value="1">
        <cfset teamBg = 'profile-teambg-10U'>
      </cfcase>

      <!---- 12U ---->
      <cfcase value="2">
        <cfset teamBg = 'profile-teambg-12U'>
      </cfcase>

      <!---- 14U ---->
      <cfcase value="3">
        <cfset teamBg = 'profile-teambg-14U'>
      </cfcase>

      <!---- 16U ---->
      <cfcase value="4">
        <cfset teamBg = 'profile-teambg-16U'>
      </cfcase>

      <!---- 18U ---->
      <cfcase value="5">
        <cfset teamBg = 'profile-teambg-gold'>
      </cfcase>
    </cfswitch>
    <!---- set team background (ENDS) ---->

    <cfquery name="getProfileDetails">
      Select field, value
      From teamDetails
      Where profileID = #profile_ID#
    </cfquery>
  <!---- profile query (ENDS) ---->

  <!---- set profile details vars  (BEGINS) ---->
  <cfloop query="getProfileDetails">
    <cfswitch expression="#field#">

      <!---- jersey number ---->
      <cfcase value="jerseyNumber">
        <cfset jerseyNumber = value>
      </cfcase>

      <!---- graduation year ---->
      <cfcase value="gradYear">
        <cfset gradYear = value>
      </cfcase>

      <!---- college committment ---->
      <cfcase value="College">
        <cfset committed = value>
      </cfcase>

      <!---- height ---->
      <cfcase value="height">
        <cfset height = value>
      </cfcase>

      <!---- high school ---->
      <cfcase value="school">
        <cfset school = value>
      </cfcase>

      <!---- gpa ---->
      <cfcase value="gpa">
        <cfset gpa = value>
      </cfcase>

      <!---- class ranking ---->
      <cfcase value="rank">
        <cfset rank = value>
      </cfcase>

      <!---- sat/act ---->
      <cfcase value="SATs">
        <cfset sat_act = value>
      </cfcase>

      <!---- registered w/ ncaa ---->
      <cfcase value="ncaa">
        <cfset ncaa = value>
      </cfcase>

      <!---- parents name ---->
      <cfcase value="parents">
        <cfset parents = value>
      </cfcase>

      <!---- goals ---->
      <cfcase value="goals">
        <cfset goals = value>
      </cfcase>

      <!---- bats ---->
      <cfcase value="bats">
        <cfswitch expression="#value#">

          <cfcase value="L">
            <cfset bats = 'Left'>
          </cfcase>

          <cfcase value="R">
            <cfset bats = 'Right'>
          </cfcase>

          <cfdefaultcase>
            <cfset bats = 'Left/Right'>
          </cfdefaultcase>

        </cfswitch>
      </cfcase>

      <!---- throws ---->
      <cfcase value="throws">
        <cfswitch expression="#value#">

          <cfcase value="L">
            <cfset throws = 'Left'>
          </cfcase>

          <cfcase value="R">
            <cfset throws = 'Right'>
          </cfcase>

          <cfdefaultcase>
            <cfset throws = 'Left/Right'>
          </cfdefaultcase>

        </cfswitch>
      </cfcase>

      <!---- academic interests ---->
      <cfcase value="interests">
        <cfset interests = value>
      </cfcase>

      <!---- athletic travel ball ---->
      <cfcase value="AthleticTravel">
        <cfset a_travelBall = value>
      </cfcase>
      
      <!---- athletic high school ---->
      <cfcase value="AthleticSchool">
        <cfset a_highSchool = value>
      </cfcase>

      <!---- hobbies ---->
      <cfcase value="hobbies">
        <cfset hobbies = value>
      </cfcase>

      <!---- other awards ---->
      <cfcase value="awards">
        <cfset awards = value>
      </cfcase>

      <!---- college pic ---->
      <cfcase value="collegePic">
        <cfset collegePic = value>
      </cfcase>

      <!---- profile pic ---->
      <cfcase value="profilePic">
        <cfset profilePic = value>
      </cfcase>

      <!---- youtube link 1 ---->
      <cfcase value="YouTube1">
        <cfset YouTube1 = value>
      </cfcase>

      <!---- youtube link 2 ---->
      <cfcase value="YouTube2">
        <cfset YouTube2 = value>
      </cfcase>

      <!---- youtube link 3 ---->
      <cfcase value="YouTube3">
        <cfset YouTube3 = value>
      </cfcase>


    </cfswitch>
  </cfloop>
  <!---- set profile details vars (ENDS) ---->

    <!---- display game changer (BEGINS) ---->
    <cfif hasGameChanger EQ 1>
      <div id="gamechanger">
        <div id="gamechanger-app">
          <iframe src="http://www.gamechanger.io/scoreboard-4eb14b3ad55a3815ea0001a6?g=5&amp;p=4ea6ff55fca1c125480001fa" frameborder="0" height="90" scrolling="no" width="728">
          </iframe>
        </div>
      </div>
    </cfif>
    <!---- display game changer (ENDS) ---->

    <!---- team menu (BEGINS) ---->
    <div id="team-menu">
      <div id="team-menu-container">
        <div id="team-menu-logo"><img src="images/team-menu-logo.png" width="150" height="63" alt="Gold-Logo" /></div>
        <div id="team-menu-text">
          <div id="menu-team">
            <ul>
              <li><a href="#">Home</a></li>
              <li><a href="#">About</a></li>   
              <li><a href="#">News</a></li>
              <li><a href="#">Links</a></li>
              <li><a href="#">Forms</a></li>
              <li><a href="#">Contact</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    <!---- team menu (ENDS) ---->

    <cfoutput>
      <div id="content-area-profile">
        <div id="profile-left">
          <div id="profile-image-frame">
            <div id="profile-image">
              <cfif isDefined('profilePic')>
                <img src="images/profiles/#profilePic#.jpg" width="225" height="280" id="profilepic" />
              <cfelse>
                <img src="images/profiles/noimage-profile.jpg" width="225" height="280" id="profilepic" />
              </cfif>
            </div>
          </div>
          <div id="profile-print"><a href="##"></a></div>

          <!---- profile left side (BEGINS) ---->
          <div id="profile-left-text">
            <table width="250" border="0" cellspacing="0" cellpadding="2">

              <cfif isDefined('school')>
                <tr>
                  <td width="97" align="right" valign="top">High School:</td>
                  <td width="143" align="left" valign="top" class="leftstats" id="highschool">#school#</td>
                </tr>            
              </cfif>
              
              <cfif isDefined('gpa')>
                <tr>
                  <td align="right" valign="top">GPA:</td>
                  <td align="left" valign="top" class="leftstats" id="gpa">#gpa#</td>
                </tr>
              </cfif>

              <cfif isDefined('rank')>
                <tr>
                  <td align="right" valign="top">Class Rank:</td>
                  <td align="left" valign="top" class="leftstats" id="classrank">#rank#</td>
                </tr>
              </cfif>
              
              <cfif isDefined('sat_act')>
                <tr>
                  <td align="right" valign="top">SAT/ACT:</td>
                  <td align="left" valign="top" class="leftstats" id="satact">#sat_act#</td>
                </tr>
              </cfif>
              
              <cfif isDefined('ncaa')>
                <tr>
                  <td width="97" align="right" valign="top">Registered/NCAA:</td>
                  <td align="left" valign="top" class="leftstats" id="satact">#ncaa#</td>
                </tr>
              </cfif>
              
              <tr>
                <td align="right" valign="top">&nbsp;</td>
                <td align="left" valign="top">&nbsp;</td>
              </tr>
              
              <cfif isDefined('parents')>
                <tr>
                  <td align="right" valign="top">Parents:</td>
                  <td align="left" valign="top" class="leftstats" id="parents">#parents#</td>
                </tr>
              </cfif>
              
              <cfif getCoach.recordCount GT 0>
                <cfloop query="getCoach">
                  <cfif position EQ 'Manager'>
                    <tr>
                      <td align="right" valign="top">Manager:</td>
                      <td align="left" valign="top" class="leftstats" id="mngrName">#firstName# #lastName#</td>
                    </tr>
                    <tr>
                      <td align="right" valign="top">Manager Email:</td>
                      <td align="left" valign="top" class="leftstats" id="coachName">#email#</td>
                    </tr>
                  <cfelse>
                    <tr>
                      <td align="right" valign="top">Head Coach:</td>
                      <td align="left" valign="top" class="leftstats" id="coachName">#firstName# #lastName#</td>
                    </tr>
                    <tr>
                      <td align="right" valign="top">Coach Email:</td>
                      <td align="left" valign="top" class="leftstats" id="coachName">#email#</td>
                    </tr>
                  </cfif>
                  
                </cfloop>
              </cfif>

            </table>
          </div>
          <!---- profile left side (ENDS) ---->
        </div>
        
        <!---- profile right side (BEGINS) ---->
        <div id="profile-right">
          <div id="#teamBg#">
            <!---- name ---->
            <div id="profile-player">#name#</div>
          </div>

          <!---- check if player is committed to a college (BEGINS) ---->
          <cfif isDefined('committed')>
            <div id="profile-committed">
              <table width="715" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <!---- college logo display (BEGINS) ---->
                  <cfif isDefined('collegePic')>
                    <td width="230" rowspan="2" align="right" valign="middle"><img src="images/profiles/thumbs/college/#collegePic#.jpg" width="80" height="80" id="collegelogo" /></td>
                  <cfelse>
                    <td width="230" rowspan="2" align="right" valign="middle"></td>
                  </cfif>
                  <!---- college logo display (ENDS) ---->
                  <td width="18" rowspan="2" valign="middle">&nbsp;</td>
                  <td width="468" height="37" align="left" valign="bottom">Committed to</td>
                </tr>
                <tr>
                  <td align="left" valign="top" id="college" style="font-size:24px">#committed#</td>
                </tr>
              </table>
            </div>
          </cfif>
          <!---- check if player is committed to a college (ENDS) ---->

          <div id="profile-stats1">
            <table width="715" border="0" cellspacing="0" cellpadding="2">
              <cfif isDefined('jerseyNumber')>
                <tr>
                  <td width="227" align="right" valign="top">Jersey Number:</td>
                  <td width="470" align="left" valign="top" class="rightstats" id="number">#jerseyNumber#</td>
                </tr>
              </cfif>
             
              <cfif isDefined('gradYear')>
                <tr>
                  <td align="right" valign="top">Graduation Year:</td>
                  <td align="left" valign="top" class="rightstats" id="gradyear">#gradYear#</td>
                </tr>
              </cfif>

              <cfif isDefined('position')>
                <tr>
                  <td align="right" valign="top">Positions:</td>
                  <td align="left" valign="top" class="rightstats" id="position">#position#</td>
                </tr>
              </cfif>

              <cfif email NEQ ''>
                <tr>
                  <td align="right" valign="top">Email:</td>
                  <td align="left" valign="top" class="rightstats" id="email">#email#</td>
                </tr>
              </cfif>

            </table>
          </div>

          <div id="profile-stats2">
            <table width="715" border="0" cellspacing="0" cellpadding="2">
              <cfif isDefined('height')>
                <tr>
                  <td width="227" align="right" valign="top">Height:</td>
                  <td width="470" align="left" valign="top" class="rightstats" id="height">#height#</td>
                </tr>
              </cfif>

              <cfif isDefined('bats')>
                <tr>
                  <td align="right" valign="top">Bats:</td>
                  <td align="left" valign="top" class="rightstats" id="bats">#bats#</td>
                </tr>
              </cfif>

              <cfif isDefined('throws')>
                <tr>
                  <td align="right" valign="top">Throws:</td>
                  <td align="left" valign="top" class="rightstats" id="throws">#throws#</td>
                </tr>
              </cfif>

            </table>
          </div>

          <div id="profile-stats3">
            <table width="715" border="0" cellspacing="0" cellpadding="2">
              <cfif isDefined('interests')>
                <tr>
                  <td width="227" align="right" valign="top">Academic Interests:</td>
                  <td width="470" align="left" valign="top" class="rightstats" id="interests">#interests#</td>
                </tr>
              </cfif>

              <cfif isDefined('hobbies')>
                <tr>
                  <td align="right" valign="top">Hobbies:</td>
                  <td align="left" valign="top" class="rightstats" id="hobbies">#hobbies#</td>
                </tr>
              </cfif>

              <cfif isDefined('a_travelBall')>
                <tr>
                  <td align="right" valign="top">Athletic Travel Ball:</td>
                  <td align="left" valign="top" class="rightstats" id="travelball">#a_travelBall#</td>
                </tr>
              </cfif>

              <cfif isDefined('a_highSchool')>
                <tr>
                  <td align="right" valign="top">Athletic High School:</td>
                  <td align="left" valign="top" class="rightstats" id="athletichs">#a_highSchool#</td>
                </tr>
              </cfif>

              <cfif isDefined('awards')>
                <tr>
                  <td align="right" valign="top">Other Awards:</td>
                  <td align="left" valign="top" class="rightstats" id="athletichs">#awards#</td>
                </tr>
              </cfif>

            </table>
          </div>
          </div>
        </div>

      <!--- FOOTER--->   
        <cfinclude template="includes/footer.cfm">        
      <!--- // FOOTER ---> 

      </div>
    </cfoutput>
  </body>
</html>