<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Seller Products</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>

<body class="bg-light">

<div class="container mt-4">

    <div class="row">

        <div class="col-md-4">

            <div class="card shadow-sm">
                <div class="card-header bg-dark text-white">
                    Add Product
                </div>

                <div class="card-body">

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

                        <button type="submit" class="btn btn-primary w-100">
                            Add Product
                        </button>

                    </form>

               

                </div>
            </div>

        </div>

        <div class="col-md-8">

            <div class="card shadow-sm">

                <div class="card-header bg-dark text-white">
                    My Products
                </div>

                <div class="card-body">

                    <table class="table table-bordered table-hover">

                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>

                        <tbody id="productTable"></tbody>

                    </table>

                </div>

            </div>

        </div>

    </div>

</div>

<script>

function loadProducts(){

    $("#productTable").html(`
        <tr><td colspan="6">Loading...</td></tr>
    `);

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getMyProducts",
        type: "GET",
        dataType: "json",

        success: function(res){

            // FIX: ColdFusion returns uppercase keys
            let status = res.STATUS;
            let data = res.DATA;

            if(!status){
                Swal.fire("Error", "Failed loading products", "error");
                return;
            }

            if(!data || data.length === 0){
                $("#productTable").html(`
                    <tr><td colspan="6">No products found</td></tr>
                `);

                Swal.fire("Info", "No products found", "info");
                return;
            }

            let rows = "";

            data.forEach(function(item){

                rows += `
                    <tr>
                        <td>${item.PRODUCT_NAME}</td>
                        <td>${item.CATEGORY}</td>
                        <td>${item.PRICE}</td>
                        <td>${item.STOCK}</td>
                        <td>
                            <span class="badge bg-success">${item.STATUS}</span>
                        </td>
                        <td>
                            <button class="btn btn-danger btn-sm" onclick="deleteProduct(${item.PRODUCT_ID})">
                                Delete
                            </button>
                        </td>
                    </tr>
                `;
            });

            $("#productTable").html(rows);

        },

        error: function(){

            Swal.fire("Error", "Server error while loading products", "error");

            $("#productTable").html(`
                <tr><td colspan="6">Server error</td></tr>
            `);
        }
    });
}

$("#productForm").submit(function(e){

    e.preventDefault();

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=addProduct",
        type: "POST",
        data: $(this).serialize(),
        dataType: "json",
        success: function(res){

            if(res.STATUS || res.status){

                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: res.MESSAGE || res.message,
                    timer: 1500,
                    showConfirmButton: false
                });

                $("#productForm")[0].reset();
                loadProducts();

            } else {

                Swal.fire({
                    icon: 'error',
                    title: 'Failed',
                    text: res.MESSAGE || res.message || "Something went wrong"
                });
            }
        },
        error: function(){
            $("#msg").html(`<span class="text-danger">Error adding product</span>`);
        }
    });

});

function deleteProduct(id){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=deleteProduct",
        type: "POST",
        data: { product_id: id },
        dataType: "json",
        success: function(res){
            loadProducts();
        }
    });

}

loadProducts();

</script>

</body>
</html>