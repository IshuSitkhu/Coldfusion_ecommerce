<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<cfset user_id = session.user_id>

<cfquery name="qOrders" datasource="ecommerce">

    SELECT
        o.order_id,
        o.quantity,
        o.price,
        o.total_price,
        o.order_date,
        p.product_name

    FROM orders o

    INNER JOIN products p
        ON o.product_id = p.product_id

    WHERE o.user_id =
        <cfqueryparam
            value="#user_id#"
            cfsqltype="cf_sql_integer">

    ORDER BY o.order_date DESC

</cfquery>

<cfset grandTotal = 0>

<cfoutput query="qOrders">
    <cfset grandTotal += total_price>
</cfoutput>

<!DOCTYPE html>
<html>

<head>
    <title>Purchase History</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet">

    <style>
        .history-card {
            border-radius: 15px;
        }

        .total-box {
            font-size: 20px;
            font-weight: bold;
        }
    </style>
</head>

<body class="bg-light">

    <div class="container mt-4">

        <div class="card shadow history-card">

            <div class="card-header bg-dark text-white">

                <h4 class="mb-0">
                    Purchase History
                </h4>

            </div>

            <div class="card-body">

                <cfif qOrders.recordCount EQ 0>

                    <div class="text-center p-5 text-muted">
                        No purchase history found
                    </div>

                <cfelse>

                    <table class="table table-hover align-middle">

                        <thead class="table-light">

                            <tr>
                                <th>Order ID</th>
                                <th>Product</th>
                                <th>Qty</th>
                                <th>Price</th>
                                <th>Total</th>
                                <th>Date</th>
                            </tr>

                        </thead>

                        <tbody>

                            <cfoutput query="qOrders">

                                <tr>

                                    <td>
                                        ## #order_id#
                                    </td>

                                    <td>
                                        <strong>
                                            #product_name#
                                        </strong>
                                    </td>

                                    <td>
                                        #quantity#
                                    </td>

                                    <td>
                                        Rs #price#
                                    </td>

                                    <td>
                                        Rs #total_price#
                                    </td>

                                    <td>
                                        #dateFormat(order_date,"dd-mmm-yyyy")#
                                        <br>
                                        <small class="text-muted">
                                            #timeFormat(order_date,"hh:mm tt")#
                                        </small>
                                    </td>

                                </tr>

                            </cfoutput>

                        </tbody>

                    </table>

                    <hr>

                    <div class="d-flex justify-content-end">

                        <div class="total-box">

                            Total Purchased:
                            Rs

                            <cfoutput>
                                #grandTotal#
                            </cfoutput>

                        </div>

                    </div>

                </cfif>

            </div>

        </div>

    </div>

</body>

</html>