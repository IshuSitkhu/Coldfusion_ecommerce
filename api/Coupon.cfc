<cfcomponent output="false">

<cffunction name="getCoupons" access="remote" returntype="struct" returnformat="json">

    <cfset var result = {}>

    <cftry>

        <cfquery name="qCoupons" datasource="ecommerce">
            SELECT *
            FROM coupons
            ORDER BY created_at DESC
        </cfquery>

        <cfset result.status = true>
        <cfset result.data = []>

        <cfoutput query="qCoupons">
            <cfset arrayAppend(result.data, {
                coupon_id = coupon_id,
                title = title,
                min_amount = min_amount,
                discount_amount = discount_amount,
                is_active = is_active,
                created_at = dateFormat(created_at, "dd-mmm-yyyy")
            })>
        </cfoutput>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="addCoupon" access="remote" returntype="struct" returnformat="json">

    <cfargument name="title" required="true">
    <cfargument name="min_amount" required="true">
    <cfargument name="discount_amount" required="true">

    <cfset var result = {}>

    <cftry>
        <cfquery name="checkCoupon" datasource="ecommerce">
            SELECT coupon_id 
            FROM coupons
            WHERE title = <cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif checkCoupon.recordCount GT 0>
            <cfset result = {status=false, message="Coupon already exists"}>
            <cfreturn result>
        </cfif>

        <cfquery datasource="ecommerce">
            INSERT INTO coupons(title, min_amount, discount_amount, is_active)
            VALUES (
                <cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#arguments.min_amount#" cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#arguments.discount_amount#" cfsqltype="cf_sql_decimal">,
                1
            )
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Coupon added successfully">

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="deleteCoupon" access="remote" returntype="struct" returnformat="json">

    <cfargument name="coupon_id" required="true">

    <cfset var result = {}>

    <cftry>

        <cfquery datasource="ecommerce">
            DELETE FROM coupons
            WHERE coupon_id = <cfqueryparam value="#arguments.coupon_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Coupon deleted">

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="toggleStatus" access="remote" returntype="struct" returnformat="json">

    <cfargument name="coupon_id" required="true">

    <cfset var result = {}>

    <cftry>

        <cfquery datasource="ecommerce">
            UPDATE coupons
            SET is_active = CASE 
                WHEN is_active = 1 THEN 0 
                ELSE 1 
            END
            WHERE coupon_id = <cfqueryparam value="#arguments.coupon_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Status updated">

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

</cfcomponent>