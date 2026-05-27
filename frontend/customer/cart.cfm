<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<cfset user_id = session.user_id>

<cfquery name="qCart" datasource="ecommerce">
    SELECT 
        c.cart_id,
        c.product_id,
        c.quantity,
        p.product_name,
        p.price,
        (c.quantity * p.price) AS total_price
    FROM cart c
    INNER JOIN products p 
        ON p.product_id = c.product_id
    WHERE c.user_id=
    <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset grandTotal = 0>

<cfoutput query="qCart">
    <cfset grandTotal += total_price>
</cfoutput>

<!DOCTYPE html>
<html>
<head>

<title>My Cart</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>

.cart-card{
    border-radius:15px;
}

.total-box{
    font-size:20px;
    font-weight:bold;
}

</style>

</head>

<body class="bg-light">

    <div class="container mt-4">

        <div class="card shadow cart-card">

            <div class="card-header bg-dark text-white">
                <h4 class="mb-0">
                    My Cart
                </h4>
            </div>

            <div class="card-body">

            <cfif qCart.recordCount EQ 0>

                <div class="text-center text-muted p-5">
                    Cart is empty
                </div>

                <cfelse>

                        <table class="table table-hover align-middle">

                            <thead class="table-light">

                                <tr>
                                    <th>Product</th>
                                    <th>Price</th>
                                    <th width="180">Quantity</th>
                                    <th>Total</th>
                                    <th>Action</th>
                                </tr>

                            </thead>

                            <tbody>

                                <cfoutput query="qCart">

                                <tr>

                                    <td>

                                        <strong>#product_name#</strong>

                                    </td>

                                    <td>

                                        Rs #price#

                                    </td>

                                    <td>

                                        <div class="d-flex align-items-center gap-2">

                                            <button 
                                                class="btn btn-sm btn-outline-secondary"
                                                onclick="decreaseQty(#cart_id#)">

                                                -

                                            </button>

                                                <span id="qty#cart_id#">

                                                    #quantity#

                                                </span>

                                            <button 
                                                class="btn btn-sm btn-outline-secondary"
                                                onclick="increaseQty(#cart_id#)">

                                                +

                                            </button>

                                        </div>

                                    </td>

                                    <td>

                                        Rs #total_price#

                                    </td>

                                    <td>

                                        <button
                                            class="btn btn-danger btn-sm"
                                            onclick="removeItem(#cart_id#)">

                                            Remove

                                        </button>

                                    </td>

                                </tr>

                                </cfoutput>

                            </tbody>

                         </table>

                <hr>

                <div class="d-flex justify-content-between align-items-center">

                    <div class="total-box">

                        Total:
                        Rs <span id="grandTotal">
                        <cfoutput>#grandTotal#</cfoutput>
                        </span>

                    </div>

                    <button
                        class="btn btn-success"
                        onclick="checkout()">

                        Proceed To Checkout

                    </button>

                </div>

            </cfif>

        </div>

    </div>

</div>


<script>

console.log("CART PAGE LOADED");

function removeItem(cart_id){

    console.log("REMOVE CLICKED:",cart_id);

    $.ajax({

        url:"/ecommerce/api/Product.cfc?method=removeItem",
        type:"POST",

        data:{
            cart_id:cart_id
        },

        dataType:"json",

        success:function(res){

            console.log("REMOVE RESPONSE:",res);

            Swal.fire({
                icon:"success",
                title:"Removed",
                text:"Item removed successfully"
            })
            .then(()=>{

                location.reload();

            });

        },

        error:function(xhr){

            console.log(xhr.responseText);

        }

    });

}


function increaseQty(cart_id){

    console.log("INCREASE CLICKED:",cart_id);

    $.ajax({

        url:"/ecommerce/api/Product.cfc?method=increaseQty",
        type:"POST",

        data:{
            cart_id:cart_id
        },

        dataType:"json",

        success:function(res){

            console.log("INCREASE RESPONSE:",res);

            location.reload();

        }

    });

}

function decreaseQty(cart_id){

    console.log("DECREASE CLICKED:",cart_id);

    $.ajax({

        url:"/ecommerce/api/Product.cfc?method=decreaseQty",
        type:"POST",

        data:{
            cart_id:cart_id
        },

        dataType:"json",

        success:function(res){

            console.log("DECREASE RESPONSE:",res);

            location.reload();

        }

    });

}


function checkout(){

    console.log("CHECKOUT CLICKED");

    Swal.fire({

        title:"Confirm Purchase?",
        text:"Do you want to continue?",
        icon:"question",
        showCancelButton:true,
        confirmButtonText:"Yes"

    }).then((result)=>{

        if(result.isConfirmed){

            console.log("USER CONFIRMED CHECKOUT");

            $.ajax({

                url:"/ecommerce/api/Product.cfc?method=checkout",
                type:"POST",
                dataType:"json",

                success:function(res){

                    console.log("CHECKOUT RESPONSE:",res);

                    let status=res.STATUS ?? res.status;
                    let message=res.MESSAGE ?? res.message;

                    console.log("STATUS:",status);
                    console.log("MESSAGE:",message);

                    if(status){

                        Swal.fire({

                            icon:"success",
                            title:"Purchase Completed",
                            text:message

                        }).then(()=>{

                            window.location=
                            "../customer/purchaseHistory.cfm";

                        });

                    }
                    else{

                        Swal.fire({

                            icon:"error",
                            title:"Failed",
                            text:message

                        });

                    }

                },

                error:function(xhr){

                    console.log("CHECKOUT ERROR:",
                    xhr.responseText);

                    Swal.fire({

                        icon:"error",
                        title:"Server Error"

                    });

                }

            });

        }

    });

}

</script>

</body>
</html>