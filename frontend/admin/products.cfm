<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Admin Products</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>

<body class="bg-light">

<div class="container mt-4">

    <div class="card shadow-sm">

        <div class="card-header bg-dark text-white">
            All Products (Admin Control Panel)
        </div>

        <div class="card-body">

            <table class="table table-bordered table-hover">

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Product</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Seller</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody id="adminProductTable"></tbody>

            </table>

        </div>

    </div>

</div>

<script>

function loadAllProducts(){

    $.ajax({
        url: "../api/Product.cfc?method=getAllProducts",
        type: "GET",
        dataType: "json",
        success: function(res){

            let rows = "";

            res.DATA.forEach(function(item){

                let statusBtn = "";

                if(item[7] == "active"){
                    statusBtn = `<button class="btn btn-warning btn-sm" onclick="toggleStatus(${item[0]})">Disable</button>`;
                } else {
                    statusBtn = `<button class="btn btn-success btn-sm" onclick="toggleStatus(${item[0]})">Enable</button>`;
                }

                rows += `
                    <tr>
                        <td>${item[0]}</td>
                        <td>${item[2]}</td>
                        <td>${item[3]}</td>
                        <td>${item[4]}</td>
                        <td>${item[5]}</td>
                        <td>${item[9]}</td>
                        <td>${item[7]}</td>
                        <td>${statusBtn}</td>
                    </tr>
                `;

            });

            $("#adminProductTable").html(rows);

        }
    });

}


function toggleStatus(id){

    $.ajax({
        url: "../api/Product.cfc?method=toggleStatus",
        type: "POST",
        data: { product_id: id },
        dataType: "json",
        success: function(res){

            loadAllProducts();

        }
    });

}


loadAllProducts();

</script>

</body>
</html>