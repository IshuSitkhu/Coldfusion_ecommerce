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
                    <div class="product-card">

                    <h6>${p.PRODUCT_NAME}</h6>

                    <div class="text-muted small">
                        Seller - ${p.SELLER_NAME}
                    </div>
                    <div class="text-muted small">
                        ${p.CATEGORY}
                    </div>

                    <div class="price mt-2">
                        Rs ${p.PRICE}
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

</script>

</body>
</html>