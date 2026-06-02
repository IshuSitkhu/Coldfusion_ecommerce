<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Admin Products</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
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
            <div>
                <button type="button" class="btn btn-dark" id="AddProduct" data-bs-toggle="modal" data-bs-target="#productModal">
                    Add Products
                </button>
            </div>

        </div>

    </div>

    <div class="card shadow-sm">

        <div class="card-header bg-dark text-white" id="tableTitle">
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

        success:function(res){

            console.log("SELLERS API RESPONSE:",res);

            if(!res.STATUS){
                console.log("Seller API failed");
                return;
            }

            let options=`<option value="">Filter by Seller</option>`;

            res.DATA.forEach(function(s){

                console.log("USER_ID:",s.USER_ID);
                console.log("USERNAME:",s.USERNAME);

                options += `
                    <option value="${s.USER_ID}">
                        ${s.USERNAME}
                    </option>
                `;
            });

            $("#sellerFilter").html(options);

            console.log("Seller dropdown loaded successfully");
        }
    });
}

function updateTableTitle(){

    let title = "All Products";

    // Filter title
    switch(currentFilter){

        case "recent":
            title = "Recently Added Products";
            break;

        case "active":
            title = "Active Products";
            break;

        case "inactive":
            title = "Inactive Products";
            break;

        case "outofstock":
            title = "Out of Stock Products";
            break;
    }

    // Add seller name if selected
    if(currentSeller){

        let sellerName = $("#sellerFilter option:selected").text();

        title += ` - ${sellerName}`;
    }

    $("#tableTitle").text(title + " (Admin Control Panel)");
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

                let statusBtn = "";

                if (item.STATUS === "active") {
                    statusBtn = `<button class="btn btn-warning btn-sm" onclick="toggleStatus(${item.PRODUCT_ID})">Disable</button>`;
                } else {
                    statusBtn = `<button class="btn btn-success btn-sm" onclick="toggleStatus(${item.PRODUCT_ID})">Enable</button>`;
                }

                let btn = `
                    <button class="btn btn-sm btn-primary" onclick="editProduct(
                                ${item.PRODUCT_ID},
                                '${item.PRODUCT_NAME}',
                                '${item.CATEGORY}',
                                ${item.PRICE},
                                ${item.STOCK},
                                '${item.DESCRIPTION || ""}'
                            )">Edit</button>
                    <button class="btn btn-sm btn-danger" onclick="deleteProduct(${item.PRODUCT_ID})">Delete</button>
                    ${statusBtn}
                `;

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


$("#AddProduct").on("click", function () {
    console.log("Added Button CLiclked");

    $("#productForm")[0].reset();
    $("#product_id").val("");
    $("#formBtn").text("Add Product");

});

function setFilter(filter){
    currentFilter = filter;
    updateTableTitle();
    loadProducts(); 
}

$("#sellerFilter").on("select2:select select2:clear", function () {

    console.log("SELECT2 EVENT FIRED");

    currentSeller = $(this).val();

    console.log("RAW SELECT VALUE:", currentSeller);

    updateTableTitle();
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

function editProduct(id, name, category, price, stock, description){

    $("#product_id").val(id);
    $("input[name='name']").val(name);
    $("select[name='category']").val(category);
    $("input[name='price']").val(price);
    $("input[name='stock']").val(stock);
    $("textarea[name='description']").val(description);

    $("#formBtn").text("Update Product");
}

function deleteProduct(id){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=deleteProduct",
        type: "POST",
        data: { product_id: id },
        dataType: "json",

        success: function(res){

            if(res.STATUS || res.status){
                Swal.fire({
                    icon:'success',
                    title:'Success',
                    text: res.MESSAGE || res.message,
                    timer: 1500,
                    showConfirmButton: false
                })
            }
            loadProducts();
            loadStats();
        },
        error: function(){

            Swal.fire({
                    icon: 'error',
                    title: 'Failed',
                    text: res.MESSAGE || res.message
                });

        }
    });

}

$(document).ready(function(){

    $("#productForm").submit(function(e){
    e.preventDefault();
    console.log("FORM SUBMIT FIRED ");

    let id = $("#product_id").val();

    let url = (id === "" || id === null)
        ? "/ecommerce/api/Product.cfc?method=addProduct"
        : "/ecommerce/api/Product.cfc?method=updateProduct";

    $.ajax({
        url: url,
        type: "POST",
        data: $(this).serialize(),
        dataType: "json",

        success: function(res){

            console.log("ADD/UPDATE RESPONSE:", res);

            let status = res.status ?? res.STATUS;
            let message = res.message ?? res.MESSAGE;

            if(status){

            Swal.fire({
                icon: 'success',
                title: 'Success',
                text: message || "Saved successfully",
                timer: 1500,
                showConfirmButton: false
            });

            let modalEl = document.getElementById('productModal');
            let modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.hide();

            setTimeout(function () {
                document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                document.body.classList.remove('modal-open');
                document.body.style.removeProperty('padding-right');
            }, 300);

            $("#productForm")[0].reset();
            $("#product_id").val("");
            $("#formBtn").text("Add Product");

            loadProducts();
            loadStats();

                        } else {

                            Swal.fire({
                                icon: 'error',
                                title: 'Failed',
                                text: message || "Something went wrong"
                            });
                        }
                    },

                    error: function(xhr){
                        console.log("AJAX ERROR:", xhr.responseText);

                        Swal.fire({
                            icon: 'error',
                            title: 'Server Error',
                            text: 'Check console for details'
                        });
                    }
                });
            });

    loadSellers();
    updateTableTitle();
    loadProducts(); 
    loadStats();

     $("#sellerFilter").select2({
        placeholder: "Filter by Seller",
        allowClear: true,
        width: "200px"
    });
});




</script>

<div class="modal fade" id="productModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header bg-dark text-white">
        <h5 class="modal-title">Add Product</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <form id="productForm">

            <input type="text" name="name" class="form-control mb-2" placeholder="Product Name" required>

            <select name="category" class="form-control mb-2" required>
                <option value="">Select Category</option>
                <option value="accessories">Accessories</option>
                <option value="electronic">Electronic</option>
                <option value="cloth">Cloth</option>
            </select>

            <input type="number" name="price" class="form-control mb-2" placeholder="Price" required>

            <input type="number" name="stock" class="form-control mb-2" placeholder="Stock" required>

            <textarea name="description" class="form-control mb-2" placeholder="Description"></textarea>

            <input type="hidden" id="product_id" name="product_id">

            <button type="submit" id="formBtn" class="btn btn-primary w-100">
                Add Product
            </button>

        </form>

      </div>

    </div>
  </div>
</div>

</body>
</html>