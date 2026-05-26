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

</cfcomponent>