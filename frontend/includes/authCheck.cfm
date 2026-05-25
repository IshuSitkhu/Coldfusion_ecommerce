<!--- CHECK LOGIN --->
<cfif NOT structKeyExists(session, "user_id")>

    <cflocation url="../login.cfm" addToken="false">

</cfif>

<!--- GET CURRENT PAGE PATH --->
<cfset currentPath = cgi.script_name>

<!--- ROLE PROTECTION --->
<cfif currentPath CONTAINS "/admin/" AND session.role NEQ "admin">

    <cflocation url="../login.cfm" addToken="false">

</cfif>

<cfif currentPath CONTAINS "/seller/" AND session.role NEQ "seller">

    <cflocation url="../login.cfm" addToken="false">

</cfif>

<cfif currentPath CONTAINS "/customer/" AND session.role NEQ "customer">

    <cflocation url="../login.cfm" addToken="false">

</cfif>