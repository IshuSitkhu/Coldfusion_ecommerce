<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Admin Products</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body class="bg-light">

<div class="container mt-4">

    <div class="row mb-3">

        <div class="col-md-3">
            <div class="card shadow-sm text-center">
                <div class="card-body">
                    <h6>Total Products</h6>
                    <h4 id="totalProducts">0</h4>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm text-center">
                <div class="card-body">
                    <h6>Active</h6>
                    <h4 id="activeProducts">0</h4>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm text-center">
                <div class="card-body">
                    <h6>Inactive</h6>
                    <h4 id="inactiveProducts">0</h4>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm text-center">
                <div class="card-body">
                    <h6>Out of Stock</h6>
                    <h4 id="outStockProducts">0</h4>
                </div>
            </div>
        </div>

    </div>

    <div class="card shadow-sm mb-3">

        <div class="card-body d-flex flex-wrap gap-2 align-items-center">

            <button class="btn btn-dark btn-sm" onclick="setFilter('all')">All Products</button>

            <button class="btn btn-primary btn-sm" onclick="setFilter('recent')">Recently Added</button>

            <button class="btn btn-success btn-sm" onclick="setFilter('active')">Active</button>

            <button class="btn btn-warning btn-sm" onclick="setFilter('inactive')">Inactive</button>

            <button class="btn btn-danger btn-sm" onclick="setFilter('outofstock')">Out of Stock</button>

            <select id="sellerFilter" class="form-select form-select-sm w-auto ms-auto">
                <option value="">Filter by Seller</option>
            </select>

        </div>

    </div>

    <div class="card shadow-sm">

        <div class="card-header bg-dark text-white">
            All Products (Admin Control Panel)
        </div>

        <div class="card-body table-responsive">

            <table class="table table-bordered table-hover align-middle">

                <thead class="table-light">
                    <tr>
                        
                        <th>Product</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Seller</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody id="adminProductTable">
                    <tr>
                        <td colspan="8" class="text-center text-muted">
                            Loading products...
                        </td>
                    </tr>
                </tbody>

            </table>

        </div>

    </div>

</div>

<script>
let currentFilter = "all";
let currentSeller = "";


function loadSellers(){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getSellers",
        type: "GET",
        dataType: "json",

        success: function(res){

            console.log("SELLERS API RESPONSE:", res);

            if(!res.STATUS){
                console.log("Seller API failed");
                return;
            }

            let options = `<option value="">Filter by Seller</option>`;

            res.DATA.forEach(function(s){
                console.log("SELLER:", s);

                options += `<option value="${s.user_ID}">${s.USERNAME}</option>`;
            });

            $("#sellerFilter").html(options);

            console.log("Seller dropdown loaded successfully");
        }
    });
}

function loadProducts() {

    console.log("FILTER DEBUG:");
    console.log("currentFilter:", currentFilter);
    console.log("currentSeller:", currentSeller);

    $("#adminProductTable").html(`
        <tr><td colspan="8" class="text-center">Loading...</td></tr>
    `);

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getAdminProducts",
        type: "GET",
        data: {
            filter: currentFilter,
            seller_id: currentSeller
        },
        dataType: "json",

        success: function(res) {

            console.log("RAW RESPONSE:");
            console.log(res);

            console.log("STATUS TYPE:", typeof res.STATUS);
            console.log("DATA TYPE:", typeof res.DATA);
            console.log("DATA:", res.DATA);

            if (!res.STATUS) {
                console.log("API ERROR MESSAGE:", res.MESSAGE);
                Swal.fire("Error", res.MESSAGE || "Failed loading products", "error");
                return;
            }

            let data = res.DATA;

            console.log("FINAL PRODUCT LIST:", data);

            if (!data || data.length === 0) {
                console.log("NO PRODUCTS AFTER FILTER");
                $("#adminProductTable").html(`
                    <tr><td colspan="8" class="text-center">No products found</td></tr>
                `);
                return;
            }

            let rows = "";

            data.forEach(function(item) {

                console.log("ROW ITEM:", item);

                let btn = "";

                if (item.STATUS === "active") {
                    btn = `<button class="btn btn-warning btn-sm" onclick="toggleStatus(${item.PRODUCT_ID})">Disable</button>`;
                } else {
                    btn = `<button class="btn btn-success btn-sm" onclick="toggleStatus(${item.PRODUCT_ID})">Enable</button>`;
                }

                rows += `
                    <tr>
                        <td>${item.PRODUCT_NAME}</td>
                        <td>${item.CATEGORY}</td>
                        <td>${item.PRICE}</td>
                        <td>${item.STOCK}</td>
                        <td>${item.SELLER_NAME}</td>
                        <td>${item.STATUS}</td>
                        <td>${btn}</td>
                    </tr>
                `;
            });

            $("#adminProductTable").html(rows);
        },

        error: function(xhr) {
            console.log("AJAX ERROR:");
            console.log(xhr.responseText);
            console.log(xhr.status);

            Swal.fire("Error", "Server error while loading products", "error");
        }
    });
}


function setFilter(filter){
    currentFilter = filter;
    loadProducts(); 
}

$("#sellerFilter").on("change", function(){

    console.log("DROPDOWN CHANGE EVENT FIRED");

    let val = $(this).val();

    console.log("RAW SELECT VALUE:", val);

    currentSeller = val;

    console.log("currentSeller UPDATED TO:", currentSeller);

    loadProducts(); 
});


function toggleStatus(id){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=toggleStatus",
        type: "POST",
        data: { product_id: id },
        dataType: "json",

        success: function(res){

            console.log("TOGGLE RESPONSE:", res);

            let status = res.STATUS;  
            let message = res.MESSAGE;

            if(status === true || status === "true"){

                Swal.fire({
                    icon: "success",
                    title: "Success",
                    text: message
                });

                loadProducts();
                loadStats();

            } else {

                Swal.fire({
                    icon: "error",
                    title: "Failed",
                    text: message || "Something went wrong"
                });
            }
        },

        error: function(){
            Swal.fire("Error", "Failed to update status", "error");
        }
    });
}

function loadStats(){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getAdminStats",
        type: "GET",
        dataType: "json",

        success: function(res){

            console.log("STATS RESPONSE:", res);

            let data = res.DATA || res.data;

            if(!data){
                console.log("No stats data found");
                return;
            }

            $("#totalProducts").text(data.TOTAL || 0);
            $("#activeProducts").text(data.ACTIVE || 0);
            $("#inactiveProducts").text(data.INACTIVE || 0);
            $("#outStockProducts").text(data.OUTOFSTOCK || 0);
        },

        error: function(xhr){
            console.log("Stats API error:", xhr.responseText);
        }
    });
}

$(document).ready(function(){
    loadSellers();
    loadProducts(); 
    loadStats();
});


</script>

</body>
</html>