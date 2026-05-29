<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<cfset user_id = session.user_id>

<cfquery name="qOrders" datasource="ecommerce">

    SELECT
        o.order_id,
        o.product_id,
        o.quantity,
        o.price,
        o.total_price,
        o.discount_amount,
        o.final_total,
        o.order_date,
        o.return_status,
        o.return_date,
        p.product_name

    FROM orders o

    INNER JOIN products p
        ON o.product_id = p.product_id

    WHERE o.user_id =
        <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">

    ORDER BY o.order_date DESC

</cfquery>

<!--- SAFE GRAND TOTAL CALCULATION (FIX FOR ERROR) --->
<cfset grandTotal = 0>

<cfoutput query="qOrders">

    <cfif len(trim(final_total)) AND isNumeric(final_total)>
        <cfset grandTotal += final_total>
    </cfif>

</cfoutput>

<!DOCTYPE html>
<html>

<head>
    <title>Purchase History</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

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
            <h4 class="mb-0">Purchase History</h4>
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
                        <th>Product</th>
                        <th>Qty</th>
                        <th>Price</th>
                        <th>Total</th>
                        <th>Discount</th>
                        
                        <th>Date</th>
                        <th>Return</th>
                    </tr>
                </thead>

                <tbody>

                    <cfoutput query="qOrders">

                        <tr>

                            <td><strong>#product_name#</strong></td>

                            <td>#quantity#</td>

                            <td>Rs #price#</td>

                            <td>Rs #total_price#</td>

                            <!-- DISCOUNT SAFE -->
                            <td class="text-danger">
                                <cfif NOT len(trim(discount_amount)) OR discount_amount EQ 0>
                                    -
                                <cfelse>
                                    - Rs #discount_amount#
                                </cfif>
                            </td>

                           

                            <td>
                                #dateFormat(order_date,"dd-mmm-yyyy")#
                                <br>
                                <small class="text-muted">
                                    #timeFormat(order_date,"hh:mm tt")#
                                </small>
                            </td>

                            <td>

                                <cfset daysPassed = dateDiff("d", order_date, now())>

                                <cfif return_status EQ "returned">

                                    <span class="badge bg-danger">Returned</span>

                                <cfelseif daysPassed LTE 7>

                                    <button
                                        class="btn btn-warning btn-sm"
                                        onclick="returnProduct(#order_id#)">
                                        Return Product
                                    </button>

                                <cfelse>

                                    <span class="text-muted">Return Expired</span>

                                </cfif>

                            </td>

                        </tr>

                    </cfoutput>

                </tbody>

            </table>

            <hr>

            <div class="d-flex justify-content-end">
                <div class="total-box">
                    Total Purchased:
                    Rs <cfoutput>#grandTotal#</cfoutput>
                </div>
            </div>

        </cfif>

        </div>
    </div>
</div>

<script>

function returnProduct(order_id){

    Swal.fire({
        title: "Return Product?",
        text: "This action cannot be undone",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Yes, Return"
    }).then((result)=>{

        if(result.isConfirmed){

            $.ajax({
                url: "/ecommerce/api/Product.cfc?method=returnProduct",
                type: "POST",
                data: { order_id: order_id },
                dataType: "json",

                success:function(res){

                    let status = res.STATUS ?? res.status;
                    let message = res.MESSAGE ?? res.message;

                    if(status){

                        Swal.fire({
                            icon:"success",
                            title:"Returned",
                            text: message
                        }).then(()=> location.reload());

                    } else {

                        Swal.fire({
                            icon:"error",
                            title:"Failed",
                            text: message
                        });

                    }
                }
            });

        }

    });

}

</script>

</body>
</html>