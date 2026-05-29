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

<cfquery name="qCoupons" datasource="ecommerce">
    SELECT 
        coupon_id,
        title,
        min_amount,
        discount_amount,
        is_active
    FROM coupons
    WHERE is_active = 1
</cfquery>

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

                <h5 class="mt-3 mb-3 fw-semibold"> Available Coupons</h5>

                <div class="row g-3">

                <cfoutput query="qCoupons">

                    <cfset isEligible = (grandTotal GTE min_amount)>

                    <div class="col-12 col-sm-6 col-md-4 col-lg-3">

                        <div class="card border-0 shadow-sm h-100 coupon-card position-relative">

                            <!-- Top Ribbon -->
                            <div class="position-absolute top-0 end-0 m-2">
                                <cfif isEligible>
                                    <span class="badge bg-success px-2 py-1">Available</span>
                                <cfelse>
                                    <span class="badge bg-secondary px-2 py-1">Locked</span>
                                </cfif>
                            </div>

                            <div class="card-body text-center">

                                <!-- Coupon Title -->
                                <h6 class="fw-bold text-uppercase mb-2 text-primary">
                                    #title#
                                </h6>

                                <!-- Discount Circle -->
                                <div class="discount-circle mx-auto mb-2">
                                    <span class="fw-bold">Rs #discount_amount#</span><br>
                                    <small class="text-muted">OFF</small>
                                </div>

                                <!-- Min Order -->
                                <p class="mb-2 text-muted small">
                                    Min. order: <strong>Rs #min_amount#</strong>
                                </p>

                                <!-- Apply Button -->
                                <button
                                    class="btn btn-dark btn-sm w-100 rounded-pill"
                                    onclick="selectCoupon(#coupon_id#, #discount_amount#)"
                                    <cfif NOT isEligible>disabled</cfif>
                                >
                                    Apply Coupon
                                </button>

                            </div>
                        </div>

                    </div>

                </cfoutput>

                </div>

                

                <div class="card shadow-sm mt-4">

                    <div class="card-body">

                        <h5 class="mb-3">Order Summary</h5>

                        <div class="d-flex justify-content-between">
                            <span>Total</span>
                            <span>Rs <cfoutput>#grandTotal#</cfoutput></span>
                        </div>

                        <div class="d-flex justify-content-between text-danger">
                            <span>Discount</span>
                            <span>- Rs <span id="discountAmount">0</span></span>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-between fw-bold fs-5">
                            <span>Final Total</span>
                            <span id="finalTotal" data-original="<cfoutput>#grandTotal#</cfoutput>">
                                <cfoutput>#grandTotal#</cfoutput>
                            </span>
                        </div>

                        <button class="btn btn-success w-100 mt-3" onclick="checkout()">
                            Proceed To Checkout
                        </button>

                    </div>

                </div>

            </cfif>

        </div>

    </div>

</div>


<script>

let selectedCouponId = null;
let selectedDiscount = 0;

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

            selectedCouponId = null;
            selectedDiscount = 0;

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

            selectedCouponId = null;
            selectedDiscount = 0;

            location.reload();

        }

    });

}


function checkout(){

    Swal.fire({
        title: "Confirm Purchase?",
        icon: "question",
        showCancelButton: true,
        confirmButtonText: "Yes"
    }).then((result) => {

        if(result.isConfirmed){

            $.ajax({
                url: "/ecommerce/api/Product.cfc?method=checkout",
                type: "POST",
                dataType: "json",

                data: {
                    coupon_id: selectedCouponId,
                    discount_amount: selectedDiscount
                },

                success: function(res){

                    if(res.STATUS){

                        Swal.fire({
                            icon: "success",
                            title: "Success",
                            text: res.MESSAGE
                        }).then(() => {
                            window.location = "../customer/purchaseHistory.cfm";
                        });

                    } else {

                        Swal.fire({
                            icon: "error",
                            title: "Failed",
                            text: res.MESSAGE
                        });

                    }

                },

                error: function(xhr){
                    console.log(xhr.responseText);
                }

            });

        }

    });

}

function selectCoupon(coupon_id, discount_amount){

    selectedCouponId = coupon_id;
    selectedDiscount = parseFloat(discount_amount);

    let grandTotal = parseFloat($("#finalTotal").attr("data-original"));

    let final = grandTotal - selectedDiscount;
    if(final < 0) final = 0;

    $("#discountAmount").text(selectedDiscount);
    $("#finalTotal").text(final);

    Swal.fire({
        icon: "success",
        title: "Coupon Applied",
        text: "Rs " + selectedDiscount + " discount applied"
    });
}

</script>

</body>
</html>