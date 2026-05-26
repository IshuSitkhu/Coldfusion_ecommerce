<cfcomponent output="false">

<cffunction name="register" access="remote" returntype="struct" returnformat="json">

    <cfargument name="first_name" required="true">
    <cfargument name="last_name" required="true">
    <cfargument name="username" required="true">
    <cfargument name="address" required="true">
    <cfargument name="email" required="true">
    <cfargument name="password" required="true">
    <cfargument name="role" required="true">

    <cfset var result = {}>

    <cfset arguments.first_name = trim(arguments.first_name)>
    <cfset arguments.last_name = trim(arguments.last_name)>
    <cfset arguments.username = trim(arguments.username)>
    <cfset arguments.address = trim(arguments.address)>
    <cfset arguments.email = trim(arguments.email)>
    <cfset arguments.password = trim(arguments.password)>
    <cfset arguments.role = trim(arguments.role)>

    <cfif trim(arguments.first_name) EQ "" OR
          trim(arguments.last_name) EQ "" OR
          trim(arguments.username) EQ "" OR
          trim(arguments.address) EQ "" OR
          trim(arguments.email) EQ "" OR
          trim(arguments.password) EQ "" OR
          trim(arguments.role) EQ "">

        <cfset result.status = false>
        <cfset result.message = "All fields are required">
        <cfreturn result>

    </cfif>

    <cfif Len(arguments.first_name) LT 3 OR Len(arguments.last_name) LT 3 OR Len(arguments.username) LT 3>

        <cfset result.status = false>
        <cfset result.message = "First name, last name, and username must be at least 3 characters long">
        <cfreturn result>

    </cfif>

    <cfif NOT REFind("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$", arguments.email)>

        <cfset result.status = false>
        <cfset result.message = "Invalid email format">
        <cfreturn result>

    </cfif>

    <cfif NOT REFindNoCase("^[A-Za-z0-9._%+-]+@gmail\.com$", arguments.email)>
        <cfset result.status = false>
        <cfset result.message = "Only Gmail addresses are allowed (example@gmail.com)">
        <cfreturn result>
    </cfif>

    <cfif NOT REFind("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$", arguments.password)>

        <cfset result.status = false>
        <cfset result.message = "Password must be 8+ chars with uppercase, lowercase, number & special character">
        <cfreturn result>

    </cfif>


    <cftry>

        <cfquery name="checkEmail" datasource="ecommerce">
            SELECT user_id 
            FROM users
            WHERE email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif checkEmail.recordCount GT 0>
            <cfset result.status = false>
            <cfset result.message = "Email already exists">
            <cfreturn result>
        </cfif>

        <cfquery name="checkUsername" datasource="ecommerce">
            SELECT user_id 
            FROM users
            WHERE username = <cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif checkUsername.recordCount GT 0>
            <cfset result.status = false>
            <cfset result.message = "Username already exists">
            <cfreturn result>
        </cfif>


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
                GETDATE()
            )
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Registration successful">

        <cfcatch>
            <cfset result.status = false>
            <cfset result.message = "Server error: " & cfcatch.message>
        </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="login" access="remote" returntype="struct" returnformat="json">

    <cfargument name="email" required="true">
    <cfargument name="password" required="true">

    <cfset var result = {}>

    <cfif trim(arguments.email) EQ "" OR trim(arguments.password) EQ "">
        <cfset result.status = false>
        <cfset result.message = "Email and password required">
        <cfreturn result>
    </cfif>

    <cfquery name="getUser" datasource="ecommerce">
        SELECT *
        FROM users
        WHERE email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif getUser.recordCount EQ 0>
        <cfset result.status = false>
        <cfset result.message = "Invalid email or password">
        <cfreturn result>
    </cfif>

    <cfif getUser.password NEQ arguments.password>
        <cfset result.status = false>
        <cfset result.message = "Invalid email or password">
        <cfreturn result>
    </cfif>

    <cfif getUser.status NEQ "active">
        <cfset result.status = false>
        <cfset result.message = "Account is inactive">
        <cfreturn result>
    </cfif>


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

    <cfreturn {
        "status" = true,
        "message" = "Logged out successfully"
    }>

</cffunction>

</cfcomponent>