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

<cffunction name="adminUpdateProduct" access="remote" returntype="struct" returnformat="json">

    <cfargument name="product_id" required="true">
    <cfargument name="name" required="true">
    <cfargument name="category" required="true">
    <cfargument name="price" required="true">
    <cfargument name="stock" required="true">
    <cfargument name="description" required="true">

    <cfset var result = {}>

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
    </cfquery>

    <cfset result.status=true>
    <cfset result.message="Product updated successfully">
    <cfset result.detail=cfcatch.detail>

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

<cffunction name="addReview" access="remote" returntype="void" output="true">

    <cfargument name="product_id" type="numeric" required="true">

    <cfset var result = {STATUS=false, MESSAGE=""}>
    <cfset var user_id = session.user_id>

    <cftry>

        <cfquery name="checkReview" datasource="ecommerce">
            SELECT review_id
            FROM product_reviews
            WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
            AND user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif checkReview.recordCount GT 0>

            <cfset result.STATUS = false>
            <cfset result.MESSAGE = "You already reviewed this product">

        <cfelse>

            <cfquery datasource="ecommerce">
                INSERT INTO product_reviews (product_id, user_id, is_reviewed)
                VALUES (
                    <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">,
                    1
                )
            </cfquery>

            <cfset result.STATUS = true>
            <cfset result.MESSAGE = "Thanks! Review recorded">

        </cfif>

        <cfcatch>
            <cfset result.STATUS = false>
            <cfset result.MESSAGE = cfcatch.message>
        </cfcatch>

    </cftry>

    <!--- CRITICAL FIX --->
    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>

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

        <cfquery name="qProducts" datasource="ecommerce">
            SELECT 
                p.product_id,
                p.product_name,
                p.category,
                p.price,
                p.stock,
                p.status,
                p.description,
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
                    description = qProducts.description,
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

        <cfquery name="q" datasource="ecommerce">
            SELECT 
                p.status,
                p.product_name,
                u.email,
                u.username
            FROM products p
            INNER JOIN users u
                ON p.seller_id = u.user_id
            WHERE p.product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset var newStatus = (q.status EQ "active") ? "inactive" : "active">

        <cfquery datasource="ecommerce">
            UPDATE products
            SET status = <cfqueryparam value="#newStatus#" cfsqltype="cf_sql_varchar">
            WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfmail
            to="#q.email#"
            from="ishusitikhu6@gmail.com"
            subject="Product Status Updated"
            type="html">

            Hello #q.username#,<br><br>

            Your product <b>#q.product_name#</b> status has been changed to:

            <b>#ucase(newStatus)#</b><br><br>

            <cfif newStatus EQ "inactive">
                Your product has been disabled by admin.
            <cfelse>
                Your product is now active again.
            </cfif>

            <br><br>
            Regards,<br>
            Admin Team

        </cfmail>

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

<cffunction name="getAllProductsForCustomer" access="remote" returntype="struct" returnformat="json">

    <cfargument name="category" required="false" default="">
    <cfargument name="seller_id" required="false" default="">

    <cfset var result = {}>

    <cftry>

        <cfquery name="qProducts" datasource="ecommerce">
            SELECT 
                p.product_id,
                p.product_name,
                p.category,
                p.price,
                p.stock,
                p.status,
                p.seller_id,
                p.total_reviews,
                u.username AS seller_name
            FROM products p
            INNER JOIN users u
                ON p.seller_id = u.user_id
            WHERE p.status = 'active'

            <cfif arguments.category NEQ "">
                AND p.category = <cfqueryparam value="#arguments.category#" cfsqltype="cf_sql_varchar">
            </cfif>

            <cfif arguments.seller_id NEQ "">
                AND p.seller_id = <cfqueryparam value="#arguments.seller_id#" cfsqltype="cf_sql_integer">
            </cfif>

        </cfquery>

        <cfset var data = []>

        <cfloop query="qProducts">

            <cfset arrayAppend(data, {
                product_id = qProducts.product_id,
                product_name = qProducts.product_name,
                category = qProducts.category,
                price = qProducts.price,
                stock = qProducts.stock,
                status = qProducts.status,
                seller_id = qProducts.seller_id,
                total_reviews=qProduct.total_reviews,
                seller_name = qProducts.seller_name
            })>

        </cfloop>

        <cfset result.status = true>
        <cfset result.data = data>
        <cfset result.count = arrayLen(data)>

    <cfcatch>

        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
        <cfset result.detail = cfcatch.detail>

    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="getCategories" access="remote" returntype="struct" returnformat="json">

    <cfset var result = {}>

    <cftry>

        <cfquery name="q" datasource="ecommerce">
            SELECT DISTINCT category
            FROM products
            WHERE status = 'active'
            ORDER BY category
        </cfquery>

        <cfset var data = []>

        <cfloop query="q">
            <cfset arrayAppend(data, q.category)>
        </cfloop>

        <cfset result.status = true>
        <cfset result.data = data>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="getProductDescription" access="remote" returntype="struct" returnformat="json">
    <cfargument name="product_id" required="true">

    <cfset var result = {}>
    
    <cftry>

        <cfquery name="q" datasource="ecommerce">
            SELECT 
                product_id,
                product_name,
                category,
                price,
                description
            FROM products
            WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.STATUS = true>
        <cfset result.DATA = q>

        <cfcatch>
            <cfset result.STATUS = false>
            <cfset result.MESSAGE = cfcatch.message>
        </cfcatch>

    </cftry>

    <cfreturn result>
</cffunction>

<cffunction name="addToCart" access="remote" returntype="struct" returnformat="json">

    <cfargument name="user_id" required="true">
    <cfargument name="product_id" required="true">
    <cfargument name="quantity" required="false" default="1">

    <cfset var result = {}>

    <cftry>

        <!--- VALIDATION --->
        <cfif NOT len(arguments.product_id)>
            <cfset result.status = false>
            <cfset result.message = "Product ID missing">
            <cfreturn result>
        </cfif>

        <!--- CHECK IF ITEM ALREADY EXISTS IN CART --->
        <cfquery name="qCheck" datasource="ecommerce">
            SELECT cart_id, quantity
            FROM cart
            WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">
            AND product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif qCheck.recordCount GT 0>

            <!--- UPDATE EXISTING CART ITEM --->
            <cfquery datasource="ecommerce">
                UPDATE cart
                SET quantity = quantity + <cfqueryparam value="#arguments.quantity#" cfsqltype="cf_sql_integer">
                WHERE cart_id = <cfqueryparam value="#qCheck.cart_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.message = "Cart updated (quantity increased)">

        <cfelse>

            <cfquery name="qProduct" datasource="ecommerce">
                SELECT stock
                FROM products
                WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qProduct.recordCount EQ 0>
                <cfset result.status = false>
                <cfset result.message = "Product not found">
                <cfreturn result>
            </cfif>

            <!--- INSERT NEW CART ITEM --->
            <cfquery datasource="ecommerce">
                INSERT INTO cart(user_id, product_id, quantity)
                VALUES(
                    <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#arguments.quantity#" cfsqltype="cf_sql_integer">
                )
            </cfquery>

            <cfset result.message = "Added to cart">

        </cfif>

        <cfset result.status = true>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
        <cfset result.detail = cfcatch.detail>
    </cfcatch>

    </cftry>

    <cfreturn result>
</cffunction>

<cffunction name="removeItem" access="remote" returntype="struct" returnformat="json">

    <cfargument name="cart_id" required="true">

    <cfset var result = {}>

    <cftry>

        <cfquery datasource="ecommerce">
            DELETE FROM cart
            WHERE cart_id = <cfqueryparam value="#arguments.cart_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.status = true>
        <cfset result.message = "Item removed">

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>
</cffunction>

<cffunction name="increaseQty" access="remote" returntype="struct" returnformat="json">

    <cfargument name="cart_id" required="true">

    <cfquery datasource="ecommerce">
        UPDATE cart
        SET quantity = quantity + 1
        WHERE cart_id = <cfqueryparam value="#arguments.cart_id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfreturn {status=true, message="Increased"}>
</cffunction>

<cffunction name="decreaseQty" access="remote" returntype="struct" returnformat="json">

    <cfargument name="cart_id" required="true">

    <cfquery datasource="ecommerce">
        UPDATE cart
        SET quantity = CASE 
            WHEN quantity > 1 THEN quantity - 1 
            ELSE 1 
        END
        WHERE cart_id = <cfqueryparam value="#arguments.cart_id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfreturn {status=true, message="Decreased"}>
</cffunction>

<cffunction name="checkout"
    access="remote"
    returntype="struct"
    returnformat="json">

    <cfargument name="coupon_id" required="false" default="">

    <cfset var result = {}>
    <cfset var grandTotal = 0>
    <cfset var discount = 0>
    <cfset var finalTotal = 0>

    <cftry>

        <!--- GET CART ITEMS --->
        <cfquery name="qCart" datasource="ecommerce">
            SELECT
                c.cart_id,
                c.product_id,
                c.quantity,
                p.price,
                p.stock,
                p.status
            FROM cart c
            INNER JOIN products p
                ON p.product_id = c.product_id
            WHERE c.user_id =
                <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- EMPTY CART CHECK --->
        <cfif qCart.recordCount EQ 0>
            <cfset result.status = false>
            <cfset result.message = "Cart is empty">
            <cfreturn result>
        </cfif>

        <!--- CALCULATE GRAND TOTAL --->
        <cfloop query="qCart">
            <cfset grandTotal += (quantity * price)>
        </cfloop>

        <cfif len(arguments.coupon_id)>

            <cfquery name="qCoupon" datasource="ecommerce">
                SELECT 
                    coupon_id,
                    min_amount,
                    discount_amount,
                    is_active
                FROM coupons
                WHERE coupon_id = <cfqueryparam value="#arguments.coupon_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qCoupon.recordCount GT 0>

                <cfif qCoupon.is_active EQ 1>

                    <cfif grandTotal GTE qCoupon.min_amount>

                        <cfset discount = qCoupon.discount_amount>

                    </cfif>

                </cfif>

            </cfif>

        </cfif>

        <!--- FINAL TOTAL --->
        <cfset finalTotal = grandTotal - discount>

        <cfif finalTotal LT 0>
            <cfset finalTotal = 0>
        </cfif>

        <!--- PROCESS EACH CART ITEM --->
        <cfloop query="qCart">

            <!--- STOCK CHECK --->
            <cfif quantity GT stock>
                <cfset result.status = false>
                <cfset result.message = "Not enough stock for product ID " & product_id>
                <cfreturn result>
            </cfif>

            <cfquery datasource="ecommerce">
            INSERT INTO orders(
                user_id,
                product_id,
                quantity,
                price,
                total_price,
                discount_amount,
                final_total
            )
            VALUES(
                <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#product_id#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#quantity#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#price#" cfsqltype="cf_sql_decimal">,

                <!--- original total --->
                <cfqueryparam value="#quantity * price#" cfsqltype="cf_sql_decimal">,

                <!--- discount per product row (optional but fine) --->
                <cfqueryparam value="#discount#" cfsqltype="cf_sql_decimal">,

                <!--- final total --->
                <cfqueryparam value="#finalTotal#" cfsqltype="cf_sql_decimal">
            )
            </cfquery>

            <!--- REDUCE STOCK --->
            <cfquery datasource="ecommerce">
                UPDATE products
                SET stock = stock - <cfqueryparam value="#quantity#" cfsqltype="cf_sql_integer">
                WHERE product_id = <cfqueryparam value="#product_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- MARK OUT OF STOCK --->
            <cfquery datasource="ecommerce">
                UPDATE products
                SET status = 'outofstock'
                WHERE product_id = <cfqueryparam value="#product_id#" cfsqltype="cf_sql_integer">
                AND stock <= 0
            </cfquery>

        </cfloop>

        <!--- CLEAR CART --->
        <cfquery datasource="ecommerce">
            DELETE FROM cart
            WHERE user_id = <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- SUCCESS RESPONSE --->
        <cfset result.status = true>
        <cfset result.message = "Purchase successful">

        <!--- OPTIONAL RETURN DATA FOR UI --->
        <cfset result.grand_total = grandTotal>
        <cfset result.discount = discount>
        <cfset result.final_total = finalTotal>

    <cfcatch>
        <cfset result.status = false>
        <cfset result.message = cfcatch.message>
        <cfset result.detail = cfcatch.detail>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="buyNow"
        access="remote"
        returntype="struct"
        returnformat="json">

        <cfargument name="product_id" required="true">
        <cfargument name="discount" required="false" default="0">
        <cfargument name="final_price" required="false" default="0">

    <cfset var result = {}>

    <cftry>

        <cfquery name="qProduct" datasource="ecommerce">

            SELECT
                price,
                stock
            FROM products

            WHERE product_id =

            <cfqueryparam
                value="#arguments.product_id#"
                cfsqltype="cf_sql_integer">

        </cfquery>

        <cfif qProduct.stock LTE 0>

            <cfset result.STATUS = false>
            <cfset result.MESSAGE = "Product is out of stock">

            <cfreturn result>

        </cfif>

        <cfquery datasource="ecommerce">

        INSERT INTO orders
        (
            user_id,
            product_id,
            quantity,
            price,
            total_price,
            discount_amount,
            final_total,
            order_date
        )

        VALUES
        (
            <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">,

            <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">,

            1,

            <cfqueryparam value="#qProduct.price#" cfsqltype="cf_sql_decimal">,

            <cfqueryparam value="#qProduct.price#" cfsqltype="cf_sql_decimal">,

            <cfqueryparam value="#arguments.discount#" cfsqltype="cf_sql_decimal">,

            <cfqueryparam value="#arguments.final_price#" cfsqltype="cf_sql_decimal">,

            GETDATE()
        )

        </cfquery>

        <cfquery datasource="ecommerce">

            UPDATE products

            SET stock = stock - 1

            WHERE product_id =

            <cfqueryparam
                value="#arguments.product_id#"
                cfsqltype="cf_sql_integer">

        </cfquery>

        <cfset result.STATUS = true>
        <cfset result.MESSAGE = "Purchase completed successfully">

        <cfcatch>

            <cfset result.STATUS = false>
            <cfset result.MESSAGE = cfcatch.message>

        </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="returnProduct"
        access="remote"
        returntype="struct"
        returnformat="json">

        <cfargument name="order_id" required="true">

        <cfset var result = {}>

        <cftry>
            <cfquery name="qOrder" datasource="ecommerce">

                SELECT
                    order_id,
                    product_id,
                    quantity,
                    order_date,
                    return_status

                FROM orders

                WHERE order_id =

                <cfqueryparam
                    value="#arguments.order_id#"
                    cfsqltype="cf_sql_integer">

                AND user_id =

                <cfqueryparam
                    value="#session.user_id#"
                    cfsqltype="cf_sql_integer">

            </cfquery>

            <cfif qOrder.recordCount EQ 0>

                <cfset result.status = false>
                <cfset result.message = "Order not found">

                <cfreturn result>

            </cfif>

            <cfif qOrder.return_status EQ "returned">

                <cfset result.status = false>
                <cfset result.message = "Product already returned">

                <cfreturn result>

            </cfif>

            <cfset daysPassed =
            dateDiff("d", qOrder.order_date, now())>

            <cfif daysPassed GT 7>

                <cfset result.status = false>
                <cfset result.message = "Return period expired">

                <cfreturn result>

            </cfif>

            <cfquery datasource="ecommerce">

                UPDATE orders

                SET
                    return_status = 'returned',
                    return_date = GETDATE()

                WHERE order_id =

                <cfqueryparam
                    value="#arguments.order_id#"
                    cfsqltype="cf_sql_integer">

            </cfquery>

            <cfquery datasource="ecommerce">

                UPDATE products

                SET stock = stock +

                <cfqueryparam
                    value="#qOrder.quantity#"
                    cfsqltype="cf_sql_integer">

                WHERE product_id =

                <cfqueryparam
                    value="#qOrder.product_id#"
                    cfsqltype="cf_sql_integer">

            </cfquery>

            <cfquery datasource="ecommerce">

                UPDATE products

                SET status = 'active'

                WHERE product_id =

                <cfqueryparam
                    value="#qOrder.product_id#"
                    cfsqltype="cf_sql_integer">

            </cfquery>

            <cfset result.status = true>
            <cfset result.message = "Product returned successfully">

        <cfcatch>

            <cfset result.status = false>
            <cfset result.message = cfcatch.message>
            <cfset result.detail = cfcatch.detail>

        </cfcatch>

        </cftry>

        <cfreturn result>

</cffunction>

<cffunction name="getCouponsForProduct" access="remote" returntype="struct" returnformat="json">

    <cfargument name="product_id" required="true">

    <cfset var result = structNew()>

    <cftry>

        <cfquery name="qProduct" datasource="ecommerce">
            SELECT price
            FROM products
            WHERE product_id = <cfqueryparam value="#arguments.product_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery name="qCoupons" datasource="ecommerce">
            SELECT coupon_id, title, min_amount, discount_amount
            FROM coupons
            WHERE is_active = 1
            AND min_amount <= <cfqueryparam value="#qProduct.price#" cfsqltype="cf_sql_decimal">
        </cfquery>

        <cfset result.STATUS = true>
        <cfset result.DATA = queryToArray(qCoupons)>

        <cfcatch>
            <cfset result.STATUS = false>
            <cfset result.MESSAGE = cfcatch.message>
            <cfset result.DETAIL = cfcatch.detail>
        </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="queryToArray" access="private" returntype="array">
    <cfargument name="q" required="true">

    <cfset var arr = []>

    <cfloop query="arguments.q">
        <cfset arrayAppend(arr, {
            coupon_id = coupon_id,
            title = title,
            min_amount = min_amount,
            discount_amount = discount_amount
        })>
    </cfloop>

    <cfreturn arr>
</cffunction>

</cfcomponent>