<cfcomponent output="false">

<cffunction name="register" access="remote" returntype="struct" returnformat="json">

    <cfargument name="first_name" required="true">
    <cfargument name="last_name" required="true">
    <cfargument name="username" required="true">
    <cfargument name="email" required="true">
    <cfargument name="password" required="true">
    <cfargument name="role" required="true">

    <cfset var result = {}>

    <cfif trim(arguments.first_name) EQ "" OR
          trim(arguments.email) EQ "" OR
          trim(arguments.password) EQ "">

        <cfset result.status = false>
        <cfset result.message = "All fields are required">
        <cfreturn result>

    </cfif>

    <cfif NOT REFind("^[^@\s]+@[^@\s]+\.[^@\s]+$", arguments.email)>

        <cfset result.status = false>
        <cfset result.message = "Invalid email format">
        <cfreturn result>

    </cfif>

    <cfif NOT REFind("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$", arguments.password)>

        <cfset result.status = false>
        <cfset result.message = "Password must be 8+ chars with uppercase, lowercase, number & special character">
        <cfreturn result>

    </cfif>

    <cftry>

        <cfquery name="checkUser" datasource="ecommerce">
            SELECT user_id 
            FROM users 
            WHERE email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif checkUser.recordCount GT 0>
            <cfset result.status = false>
            <cfset result.message = "Email already exists">
            <cfreturn result>
        </cfif>

        <cfquery datasource="ecommerce">
            INSERT INTO users (
                first_name,
                last_name,
                username,
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
                <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.role#" cfsqltype="cf_sql_varchar">,
                'active',
                GETDATE()
            )
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Registration successful">

        <cfcatch>

            <cfset result.status = false>
            <cfset result.message = cfcatch.message>

        </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="login" access="remote" returntype="struct" returnformat="json">

    <cfargument name="email" required="true">
    <cfargument name="password" required="true">

    <cfset var result = {}>

    <!--- Empty check --->
    <cfif trim(arguments.email) EQ "" OR trim(arguments.password) EQ "">
        <cfset result.status = false>
        <cfset result.message = "Email and password required">
        <cfreturn result>
    </cfif>

    <!--- Check user --->
    <cfquery name="getUser" datasource="ecommerce">
        SELECT *
        FROM users
        WHERE email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
        AND password = <cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif getUser.recordCount EQ 0>
        <cfset result.status = false>
        <cfset result.message = "Invalid email or password">
        <cfreturn result>
    </cfif>

    <!--- Create session --->
    <cfset session.user_id = getUser.user_id>
    <cfset session.username = getUser.username>
    <cfset session.role = getUser.role>

    <cfset result.status = true>
    <cfset result.message = "Login successful">
    <cfset result.role = getUser.role>

    <cfreturn result>

</cffunction>

<cffunction name="logout" access="remote" returntype="struct" returnformat="json">

    <cfset structClear(session)>

    <cfreturn { "status" = true, "message" = "Logged out successfully" }>
</cffunction>

</cfcomponent>