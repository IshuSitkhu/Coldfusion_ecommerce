<cfcomponent output="false">

<cffunction name="addProduct" access="remote" returntype="struct" returnformat="json">

    <cfargument name="name" required="true">
    <cfargument name="category" required="true">
    <cfargument name="price" required="true">
    <cfargument name="stock" required="true">
    <cfargument name="description" required="true">

    <cfset var result = {}>

    <cftry>

        <cfif NOT structKeyExists(session, "user_id")>
            <cfset result.status = false>
            <cfset result.message = "Session expired">
            <cfreturn result>
        </cfif>

        <cfquery datasource="ecommerce">
            INSERT INTO products (
                seller_id,
                product_name,
                category,
                price,
                stock,
                description,
                status,
                created_at
            )
            VALUES (
                <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.category#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.price#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#arguments.stock#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">,
                'active',
                GETDATE()
            )
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Product added successfully">

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
        <cfset result.detail = cfcatch.detail>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="updateProduct" access="remote" returntype="struct" returnformat="json">

    <cfargument name="product_id" required="true">
    <cfargument name="name" required="true">
    <cfargument name="category" required="true">
    <cfargument name="price" required="true">
    <cfargument name="stock" required="true">
    <cfargument name="description" required="true">

    <cfset var result = {}>

    <cftry>

        <cfquery datasource="ecommerce">
            UPDATE products
            SET
                product_name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">,
                category = <cfqueryparam value="#arguments.category#" cfsqltype="cf_sql_varchar">,
                price = <cfqueryparam value="#arguments.price#" cfsqltype="cf_sql_decimal">,
                stock = <cfqueryparam value="#arguments.stock#" cfsqltype="cf_sql_integer">,
                description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">

            WHERE product_id =
                <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">

            AND seller_id =
                <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.status=true>
        <cfset result.message="Product updated successfully">

    <cfcatch>
        <cfset result.status=false>
        <cfset result.message=cfcatch.message>
        <cfset result.detail=cfcatch.detail>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>


<cffunction name="getMyProducts" access="remote" returntype="struct" returnformat="json">
            <cfset var result = {}>

            <cftry>

                <cfquery name="qProducts" datasource="ecommerce">
                    SELECT *
                    FROM products
                    WHERE seller_id = <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">
                    ORDER BY created_at DESC
                </cfquery>

                <cfset result.status = true>
                <cfset result.data = []>

                <cfloop query="qProducts">
                    <cfset arrayAppend(result.data, {
                        product_id = qProducts.product_id,
                        product_name = qProducts.product_name,
                        category = qProducts.category,
                        price = qProducts.price,
                        stock = qProducts.stock,
                        description = qProducts.description,
                        status = qProducts.status
                    })>
                </cfloop>

            <cfcatch>
                <cfset result.status = false>
                <cfset result.message = cfcatch.message>
            </cfcatch>

            </cftry>

            <cfreturn result>

</cffunction>


<cffunction name="deleteProduct" access="remote" returntype="struct" returnformat="json">

    <cfargument name="product_id" required="true">

    <cfset var result = {}>

    <cfquery datasource="ecommerce">
        DELETE FROM products
        WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        AND seller_id = <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfset result.status = true>
    <cfset result.message = "Deleted">

    <cfreturn result>

</cffunction>

<cffunction name="getSellers" access="remote" returntype="struct" returnformat="json">

    <cfset var result = {}>

    <cftry>

        <cfquery name="qSellers" datasource="ecommerce">
            SELECT user_id, username
            FROM users
            WHERE role = 'seller'
            ORDER BY username
        </cfquery>

        <cfset result.status = true>
        <cfset result.data = []>

        <cfloop query="qSellers">
            <cfset arrayAppend(result.data, {
                user_id = qSellers.user_id,
                username = qSellers.username
            })>
        </cfloop>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="getAdminProducts" access="remote" returntype="struct" returnformat="json">

    <cfargument name="filter" required="false" default="all">
    <cfargument name="seller_id" required="false" default="">

    <cfset var result = {}>

    <cftry>

        <cflog file="product_debug" text="FILTER=#arguments.filter# | SELLER=#arguments.seller_id#">

        <!--- CLEAN QUERY --->
        <cfquery name="qProducts" datasource="ecommerce">
            SELECT 
                p.product_id,
                p.product_name,
                p.category,
                p.price,
                p.stock,
                p.status,
                p.created_at,
                p.seller_id,
                u.username AS seller_name
            FROM products p
            INNER JOIN users u 
                ON p.seller_id = u.user_id
            ORDER BY p.created_at DESC
        </cfquery>

        <cfset var filteredData = []>

        <cfloop query="qProducts">

            <cfset var includeRow = true>

            <cflog file="product_debug" text="ROW seller_id=#qProducts.seller_id# | FILTER=#arguments.seller_id#">

            <!--- SELLER FILTER --->
            <cfif len(trim(arguments.seller_id)) AND qProducts.seller_id NEQ arguments.seller_id>
                <cfset includeRow = false>
            </cfif>

            <!--- STATUS FILTER --->
            <cfif arguments.filter EQ "active" AND qProducts.status NEQ "active">
                <cfset includeRow = false>
            </cfif>

            <cfif arguments.filter EQ "inactive" AND qProducts.status NEQ "inactive">
                <cfset includeRow = false>
            </cfif>

            <cfif arguments.filter EQ "outofstock" AND qProducts.stock GT 0>
                <cfset includeRow = false>
            </cfif>

            <cfif includeRow>
                <cfset arrayAppend(filteredData, {
                    product_id = qProducts.product_id,
                    product_name = qProducts.product_name,
                    category = qProducts.category,
                    price = qProducts.price,
                    stock = qProducts.stock,
                    status = qProducts.status,
                    seller_name = qProducts.seller_name,
                    created_at = qProducts.created_at
                })>
            </cfif>

        </cfloop>

        <!--- RECENT FILTER --->
        <cfif arguments.filter EQ "recent">
            <cfset arraySort(filteredData, function(a,b){
                return compare(b.created_at, a.created_at)
            })>

            <cfif arrayLen(filteredData) GT 10>
                <cfset filteredData = arraySlice(filteredData, 1, 10)>
            </cfif>
        </cfif>

        <cfset result.status = true>
        <cfset result.data = filteredData>
        <cfset result.count = arrayLen(filteredData)>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
        <cfset result.detail = cfcatch.detail>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="toggleStatus" access="remote" returntype="struct" returnformat="json">

    <cfargument name="product_id" required="true">

    <cfset var result = {}>

    <cftry>

        <!--- GET CURRENT STATUS --->
        <cfquery name="q" datasource="ecommerce">
            SELECT status
            FROM products
            WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- TOGGLE VALUE --->
        <cfset var newStatus = (q.status EQ "active") ? "inactive" : "active">

        <cfquery datasource="ecommerce">
            UPDATE products
            SET status = <cfqueryparam value="#newStatus#" cfsqltype="cf_sql_varchar">
            WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Status updated to " & newStatus>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="getAdminStats" access="remote" returntype="struct" returnformat="json">

    <cfset var result = {}>

    <cftry>

        <cfquery name="qStats" datasource="ecommerce">
            SELECT 
                COUNT(*) AS total_products,

                SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_products,

                SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) AS inactive_products,

                SUM(CASE WHEN stock = 0 THEN 1 ELSE 0 END) AS out_stock
            FROM products
        </cfquery>

        <cfset result.status = true>
        <cfset result.data = {
            total = qStats.total_products,
            active = qStats.active_products,
            inactive = qStats.inactive_products,
            outofstock = qStats.out_stock
        }>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

</cfcomponent>