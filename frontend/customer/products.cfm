<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Products</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Select2 -->
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

    $("#categoryFilter").select2({
        placeholder: "Select Category",
        width: '200px'
    });

    $("#sellerFilter").select2({
        placeholder: "Select Seller",
        width: '200px'
    });

    loadFilters();
    loadProducts();
});


function loadFilters(){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getSellers",
        type: "GET",
        dataType: "json",
        success: function(res){

            let options = `<option value=""></option>`;

            res.data.forEach(function(s){
                options += `<option value="${s.user_id}">${s.username}</option>`;
            });

            $("#sellerFilter").html(options);
        }
    });

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getMyProducts",
        type: "GET",
        dataType: "json",
        success: function(res){

            let unique = [...new Set(res.data.map(p => p.category))];

            let options = `<option value=""></option>`;

            unique.forEach(function(c){
                options += `<option value="${c}">${c}</option>`;
            });

            $("#categoryFilter").html(options);
        }
    });
}

function loadProducts(){

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

            if(!res.STATUS){
                $("#productGrid").html(`<div class="text-danger text-center">Failed loading products</div>`);
                return;
            }

            let html = "";

            res.DATA.forEach(function(p){

                html += `
                <div class="col-md-3 mb-3">
                    <div class="product-card">

                        <h6>${p.PRODUCT_NAME}</h6>

                        <div class="text-muted small">
                            ${p.CATEGORY} | ${p.SELLER_NAME}
                        </div>

                        <div class="price mt-2">
                            Rs ${p.PRICE}
                        </div>

                        <button class="btn btn-sm btn-primary mt-2 w-100">
                            View
                        </button>

                    </div>
                </div>
                `;
            });

            $("#productGrid").html(html);
        }
    });
}


$("#categoryFilter").on("change", function(){
    category = $(this).val();
    loadProducts();
});

$("#sellerFilter").on("change", function(){
    seller = $(this).val();
    loadProducts();
});

$("#resetBtn").on("click", function(){

    category = "";
    seller = "";

    $("#categoryFilter").val("").trigger("change");
    $("#sellerFilter").val("").trigger("change");

    loadProducts();
});

</script>

</body>
</html>