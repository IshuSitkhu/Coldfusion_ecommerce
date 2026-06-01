<cfcomponent output="false">

    <cffunction name="getUsers" access="remote" returntype="struct" returnformat="json">
        
        <cfset var result = {}>

        <cftry>

            <cfquery name="qUser" datasource="ecommerce">
                SELECT 
                    user_id,
                    username,
                    email,
                    role,
                    address,
                    status,
                    created_at
                FROM users
                ORDER BY created_at DESC
            </cfquery>

            <cfset result.status = true>
            <cfset result.data = []>

            <cfloop query="qUser">
                <cfset arrayAppend(result.data, {
                    user_id = qUser.user_id,
                    username = qUser.username,
                    email = qUser.email,
                    role = qUser.role,
                    address = qUser.address,
                    status = qUser.status
                })>
            </cfloop>

            <cfcatch>
                <cfset result.status = false>
                <cfset result.message = cfcatch.message>
            </cfcatch>

        </cftry>

        <cfreturn result>
    </cffunction>


    <cffunction name="addUsers" access="remote" returntype="struct" returnformat="json">

        <cfargument name="first_name" required="true">
        <cfargument name="last_name" required="true">
        <cfargument name="username" required="true">
        <cfargument name="address" required="true">
        <cfargument name="email" required="true">
        <cfargument name="password" required="true">
        <cfargument name="role" required="true">

        <cfset var result = {}>

        <cftry>

            <cfquery datasource="ecommerce">
                INSERT INTO users (
                    first_name,
                    last_name,
                    username,
                    address,
                    email,
                    password,
                    role,
                    status,
                    created_at
                )
                VALUES (
                    <cfqueryparam value="#arguments.first_name#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.last_name#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.role#" cfsqltype="cf_sql_varchar">,
                    'active',
                    NOW()
                )
            </cfquery>

            <cfset result.status = true>
            <cfset result.message = "User added successfully">

            <cfcatch>
                <cfset result.status = false>
                <cfset result.message = cfcatch.message>
            </cfcatch>

        </cftry>

        <cfreturn result>

    </cffunction>

    <cffunction name="toggleUserStatus" access="remote" returntype="struct" returnformat="json">
    <cfargument name="user_id" required="true">

    <cfset var result = {}>

    <cftry>

        <cfquery name="qUser" datasource="ecommerce">
            SELECT user_id, email, status
            FROM users
            WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif qUser.recordCount EQ 0>
            <cfset result.status = false>
            <cfset result.message = "User not found">
            <cfreturn result>
        </cfif>

        <cfset newStatus = (qUser.status EQ "active") ? "inactive" : "active">

        <cfquery datasource="ecommerce">
            UPDATE users
            SET status = <cfqueryparam value="#newStatus#" cfsqltype="cf_sql_varchar">
            WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif newStatus EQ "inactive">

            <cfmail to="#qUser.email#"
                    from="ishusitikhu6@gmail.com"
                    subject="Account Deactivated"
                    type="html">

                <h3>Your account has been deactivated</h3>
                <p>If you think this is a mistake, please contact support.</p>

            </cfmail>

        </cfif>

        <cfset result.status = true>
        <cfset result.message = "Status updated to " & newStatus>

        <cfcatch>
            <cfset result.status = false>
            <cfset result.message = cfcatch.message>
        </cfcatch>

    </cftry>

    <cfreturn result>
</cffunction>

</cfcomponent>