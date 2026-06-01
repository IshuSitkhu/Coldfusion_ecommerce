<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Products</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        .product-card{
            border: 1px solid #eee;
            border-radius: 10px;
            padding: 15px;
            transition: 0.2s;
            height: 100%;
        }

        .product-card:hover{
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }

        .price{
            font-size: 18px;
            font-weight: bold;
            color: #198754;
        }
    </style>
</head>

<body class="bg-light">

<div class="container mt-4">

    <div class="card shadow-sm mb-3">
        <div class="card-body d-flex gap-2 flex-wrap align-items-center">

            <select id="categoryFilter" class="form-select w-auto">
                <option value="">All Categories</option>
            </select>

            <select id="sellerFilter" class="form-select w-auto">
                <option value="">All Sellers</option>
            </select>

            <button class="btn btn-dark ms-auto" id="resetBtn">
                Reset
            </button>

        </div>
    </div>

    <div class="row" id="productGrid">
        <div class="text-center text-muted">Loading products...</div>
    </div>

    

</div>

<script>

let category = "";
let seller = "";
let CURRENT_USER_ID = <cfoutput>#session.user_id#</cfoutput>;

$(document).ready(function () {

    console.log("PAGE LOADED");

    // INIT SELECT2 ONCE
    $("#categoryFilter").select2({
        placeholder: "Select Category",
        width: '200px'
    });

    $("#sellerFilter").select2({
        placeholder: "Select Seller",
        width: '200px'
    });

    console.log("SELECT2 INITIALIZED");

    loadFilters();
    loadProducts();
});

function loadFilters(){

    console.log("LOADING FILTERS STARTED");

    // SELLERS
    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getSellers",
        type: "GET",
        dataType: "json",

        success: function(res){

            console.log("SELLERS API RESPONSE:", res);

            let options = `<option value=""></option>`;

            (res.DATA || []).forEach(function(s){
                console.log("SELLER ITEM:", s);
                options += `<option value="${s.USER_ID}">${s.USERNAME}</option>`;
            });

            $("#sellerFilter").html(options).trigger("change");

            console.log("SELLER FILTER LOADED");
        },

        error: function(xhr){
            console.log("SELLER API ERROR:", xhr.responseText);
        }
    });

    // CATEGORIES
    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getCategories",
        type: "GET",
        dataType: "json",

        success: function(res){

            console.log("CATEGORY RESPONSE:", res);

            let categories = res.DATA || [];

            console.log("CATEGORIES:", categories);

            let options = `<option value=""></option>`;

            categories.forEach(function(c){
                console.log("CATEGORY ITEM:", c);
                options += `<option value="${c}">${c}</option>`;
            });

            $("#categoryFilter").html(options);
            $("#categoryFilter").trigger("change");

            console.log("CATEGORY DROPDOWN LOADED");
        }
    });
}


function loadProducts(){

    console.log("LOAD PRODUCTS CALLED");
    console.log("CURRENT CATEGORY:", category);
    console.log("CURRENT SELLER:", seller);

    $("#productGrid").html(`<div class="text-center">Loading...</div>`);

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getAllProductsForCustomer",
        type: "GET",
        data: {
            category: category,
            seller_id: seller
        },
        dataType: "json",

        success: function(res){

            console.log("PRODUCT API RAW RESPONSE:", res);

            let data = res.data || res.DATA || [];
            let status = res.status ?? res.STATUS;

            console.log("NORMALIZED STATUS:", status);
            console.log("NORMALIZED DATA:", data);

            if(!status){
                console.log("API STATUS FALSE");
                $("#productGrid").html(`<div class="text-danger text-center">Failed loading products</div>`);
                return;
            }

            if(!Array.isArray(data)){
                console.log("DATA NOT ARRAY:", data);
                data = [];
            }

            if(data.length === 0){
                console.log("NO PRODUCTS FOUND AFTER FILTER");
                $("#productGrid").html(`<div class="text-muted text-center">No products found</div>`);
                return;
            }

            let html = "";

            data.forEach(function(p){

                console.log("PRODUCT ITEM:", p);

                html += `
                <div class="col-md-3 mb-3">
                    <div class="card product-card shadow-sm border-0 h-100">

                        <h6 class="fw-bold mb-1 text-truncate">
                            ${p.PRODUCT_NAME}
                        </h6>

                        <div class="small text-muted mb-1">
                            <i class="bi bi-person"></i> Seller: ${p.SELLER_NAME}
                        </div>

                        <div class="small text-muted">
                            <i class="bi bi-tag"></i> ${p.CATEGORY}
                        </div>

                    <div class="price mt-2">
                        Rs ${p.PRICE}
                    </div>
                    <div>
                        <button class="btn btn-primary btn-sm" onclick="addToCart(${p.PRODUCT_ID})">
                            Add to Cart
                        </button>

                        <button class="btn btn-success btn-sm" onclick="buyNow(${p.PRODUCT_ID}, ${p.PRICE})">
                            Buy Now
                        </button>
                    </div>
                    

                    </div>
                </div>
                `;
            });

            $("#productGrid").html(html);

            console.log("PRODUCT GRID RENDERED");
        },

        error: function(xhr){
            console.log("PRODUCT API ERROR:", xhr.responseText);
            $("#productGrid").html(`<div class="text-danger text-center">Server Error</div>`);
        }
    });
}


$("#categoryFilter").on("change", function () {

    console.log("CATEGORY CHANGE EVENT FIRED");

    category = $(this).val() || "";

    console.log("SELECTED CATEGORY:", category);

    loadProducts();
});


$("#sellerFilter").on("change", function () {

    console.log("SELLER CHANGE EVENT FIRED");

    seller = $(this).val() || "";

    console.log("SELECTED SELLER:", seller);

    loadProducts();
});


$("#resetBtn").on("click", function(){

    console.log("RESET BUTTON CLICKED");

    category = "";
    seller = "";

    $("#categoryFilter").val("").trigger("change");
    $("#sellerFilter").val("").trigger("change");

    console.log("FILTERS RESET");

    loadProducts();
});

let PRODUCT_PRICE = 0;
let SELECTED_PRODUCT_ID = 0;
let DISCOUNT = 0;
let FINAL_PRICE = 0;

function buyNow(product_id, price){

    console.log("DEBUG PRICE:", price);

    SELECTED_PRODUCT_ID = product_id;
    PRODUCT_PRICE = price || 0;

    DISCOUNT = 0;
    FINAL_PRICE = PRODUCT_PRICE;

    $("#mTotal").text(PRODUCT_PRICE);
    $("#mDiscount").text(0);
    $("#mFinal").text(FINAL_PRICE);

    $("#buyModal").modal("show");
}

function openCouponModal() {

    $("#couponModal").modal("show");

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getCouponsForProduct",
        data: { product_id: SELECTED_PRODUCT_ID },
        dataType: "json",

        success: function(res) {

            let data = res.DATA;
            let html = "";

            if (!data || data.length === 0) {
                html = `
                    <div class="alert alert-info text-center">
                        No coupons available for this product.
                    </div>
                `;
            } else {
                data.forEach(c => {
                    html += `                       
                        <div class="border p-2 mb-2">
                            <h6 class="fw-bold text-uppercase mb-2 text-primary">
                                ${c.TITLE}
                            </h6>

                            Discount: Rs.${c.DISCOUNT_AMOUNT}

                            <br><br>

                            <button class="btn btn-sm btn-primary"
                                onclick="applyCoupon(${c.DISCOUNT_AMOUNT}, ${c.MIN_AMOUNT})">
                                Apply
                            </button>
                        </div>
                    `;
                });
            }

            $("#couponList").html(html);
        },

        error: function() {
            $("#couponList").html(`
                <div class="alert alert-danger text-center">
                    Failed to load coupons.
                </div>
            `);
        }
    });
}

function applyCoupon(discount, minAmount){

    if(PRODUCT_PRICE < minAmount){
        alert("Not eligible for this coupon");
        return;
    }

    DISCOUNT = discount;
    FINAL_PRICE = PRODUCT_PRICE - DISCOUNT;

    $("#mDiscount").text(DISCOUNT);
    $("#mFinal").text(FINAL_PRICE);

    $("#couponModal").modal("hide");
}

$("#confirmBuyBtn").on("click", function(){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=buyNow",
        type: "POST",
        data: {
            product_id: SELECTED_PRODUCT_ID
        },
        dataType: "json",

        success: function(res){

            $("#couponModal").modal("hide");

            if(res.STATUS){

                Swal.fire("Success", res.MESSAGE, "success");

                window.location = "../customer/purchaseHistory.cfm";

            } else {

                Swal.fire("Error", res.MESSAGE, "error");
            }
        }
    });

});

function confirmBuy() {

    console.log("Sending Purchase Request:", {
        product_id: SELECTED_PRODUCT_ID,
        discount: DISCOUNT,
        final_price: FINAL_PRICE
    });

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=buyNow",
        type: "POST",
        dataType: "json", 
        data: {
            product_id: SELECTED_PRODUCT_ID,
            discount: DISCOUNT,
            final_price: FINAL_PRICE
        },

success: function(res) {

    console.log("Raw Response:", res);
    console.log("TYPE:", typeof res);

    if (typeof res === "string") {
        res = JSON.parse(res);
    }

    console.log("Parsed:", res);
    console.log("STATUS:", res.STATUS);

    $("#buyModal").modal("hide");

    if (res.STATUS === true) {

        Swal.fire({
            icon: "success",
            title: "Purchase Successful!",
            text: res.MESSAGE
        }).then(() => {
            window.location = "../customer/purchaseHistory.cfm";
        });

    } else {

        Swal.fire({
            icon: "error",
            title: "Purchase Failed",
            text: res.MESSAGE || "Something went wrong."
        });

    }
},

        error: function(xhr, status, error) {

            console.error("AJAX Error");
            console.error("Status:", status);
            console.error("Error:", error);
            console.error("Response Text:", xhr.responseText);

            $("#buyModal").modal("hide");

            Swal.fire({
                icon: "error",
                title: "Server Error",
                text: "Unable to complete purchase. Please try again later."
            });
        }
    });
}

function openCouponModal(){

    $("#couponModal").modal("show");

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getCouponsForProduct",
        data: { product_id: SELECTED_PRODUCT_ID },
        dataType: "json",

        success: function(res){

            let data = res.DATA;

            let html = "";

            data.forEach(c => {

                html += `
                    <div class="border p-2 mb-2">
                        <b>${c.TITLE}</b><br>
                        Discount: ${c.DISCOUNT_AMOUNT}

                        <br><br>

                        <button class="btn btn-sm btn-primary"
                        onclick="applyCoupon(${c.DISCOUNT_AMOUNT}, ${c.MIN_AMOUNT})">
                        Apply
                        </button>
                    </div>
                `;
            });

            $("#couponList").html(html);
        }
    });
}


function addToCart(product_id){

    console.log("ADD TO CART CLICKED:", product_id);
    console.log("USER ID:", CURRENT_USER_ID);
    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=addToCart",
        type: "POST",
        data: {
            product_id: product_id,
            user_id: CURRENT_USER_ID,
            quantity: 1
        },

        dataType: "json",   

        success: function(res){

            console.log("ADD TO CART RESPONSE:", res);

            let status = res.STATUS ?? res.status;
            let message = res.MESSAGE ?? res.message;

            console.log("NORMALIZED STATUS:", status);
            console.log("NORMALIZED MESSAGE:", message);

            if(status === true || status === "true"){

                Swal.fire({
                    icon: "success",
                    title: "Success",
                    text: message
                });

            } else {

                Swal.fire({
                    icon: "error",
                    title: "Failed",
                    text: message || "Something went wrong"
                });
            }
        }
    });
}
</script>

<div class="modal fade" id="buyModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title">Checkout</h5>
        <button class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <div class="border p-2 mb-2">
            <div>Total: Rs <span id="mTotal"></span></div>
            <div>Discount: Rs <span id="mDiscount">0</span></div>
            <div><b>Final: Rs <span id="mFinal"></span></b></div>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn btn-warning" onclick="openCouponModal()">Apply Coupon</button>
        <button class="btn btn-success" onclick="confirmBuy()">Buy Now</button>
      </div>

    </div>
  </div>
</div>

<div class="modal fade" id="couponModal">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5>Select Coupon</h5>
        <button class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
      <h4>Available coupons for you.</h4> 
        <div id="couponList"></div>
      </div>

    </div>
  </div>
</div>

</body>
</html>