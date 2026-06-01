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

</cfcomponent>