<cfcomponent>

    <!--- Application name --->
    <cfset this.name = "EcommerceApp">

    <cfset this.datasource = "ecommerce">

    <!--- Enable session  --->
    <cfset this.sessionManagement = true>

    <!--- Session timeout (2 hours) --->
    <cfset this.sessionTimeout = createTimeSpan(0, 2, 0, 0)>

    <cffunction name="onApplicationStart" returnType="boolean">
        <cfreturn true>
    </cffunction>

    <cffunction name="onRequestStart">

        <cfargument name="targetPage">



    </cffunction>

</cfcomponent>