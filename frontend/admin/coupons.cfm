<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Coupons Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

</head>

<body class="bg-light">

<div class="container mt-4">

    <div class="card shadow">

        <div class="card-header bg-dark text-white">
            <h4 class="mb-0">Coupon Management</h4>
        </div>

        <div class="card-body">

            <!-- ADD COUPON FORM -->
            <div class="row mb-4">

                <div class="col-md-3">
                    <input type="text" id="title" class="form-control" placeholder="Coupon Code">
                </div>

                <div class="col-md-3">
                    <input type="number" id="min_amount" class="form-control" placeholder="Min Amount">
                </div>

                <div class="col-md-3">
                    <input type="number" id="discount_amount" class="form-control" placeholder="Discount">
                </div>

                <div class="col-md-3">
                    <button class="btn btn-success w-100" onclick="addCoupon()">
                        Add Coupon
                    </button>
                </div>

            </div>

            <!-- TABLE -->
            <table class="table table-bordered table-hover">

                <thead class="table-dark">
                    <tr>
                        <th>ID</th>
                        <th>Code</th>
                        <th>Min Amount</th>
                        <th>Discount</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody id="couponTable">
                </tbody>

            </table>

        </div>
    </div>

</div>

<script>

$(document).ready(function(){
    loadCoupons();
});

function loadCoupons(){

    $.ajax({
        url: "/ecommerce/api/Coupon.cfc?method=getCoupons",
        type: "GET",
        dataType: "json",
        success: function(res){

            console.log("GETCOUPONS RESPONSE:", res);

            let coupons = res.DATA || res.data || [];

            let html = "";

            coupons.forEach(c => {

                html += `
                <tr>


                    <td>${c.TITLE}</td>

                    <td>Rs ${c.MIN_AMOUNT}</td>

                    <td>Rs ${c.DISCOUNT_AMOUNT}</td>

                    <td>
                        ${c.IS_ACTIVE == 1
                            ? '<span class="badge bg-success">Active</span>'
                            : '<span class="badge bg-danger">Inactive</span>'}
                    </td>

                    <td>

                        <button
                            class="btn btn-sm btn-warning"
                            onclick="toggleStatus(${c.COUPON_ID})">

                            Toggle

                        </button>

                        <button
                            class="btn btn-sm btn-danger"
                            onclick="deleteCoupon(${c.COUPON_ID})">

                            Delete

                        </button>

                    </td>

                </tr>
                `;

            });

            $("#couponTable").html(html);

        }
    });
}

function addCoupon(){

    $.ajax({
        url: "/ecommerce/api/Coupon.cfc?method=addCoupon",
        type: "POST",
        dataType: "json",
        data: {
            title: $("#title").val(),
            min_amount: $("#min_amount").val(),
            discount_amount: $("#discount_amount").val()
        },
        success: function(res){

            Swal.fire("Success", res.message, "success");
            loadCoupons();

        }
    });
}

function deleteCoupon(id){

    $.ajax({
        url: "/ecommerce/api/Coupon.cfc?method=deleteCoupon",
        type: "POST",
        dataType: "json",
        data: { coupon_id: id },
        success: function(res){

            Swal.fire("Deleted", res.message, "success");
            loadCoupons();

        }
    });
}

function toggleStatus(id){

    $.ajax({
        url: "/ecommerce/api/Coupon.cfc?method=toggleStatus",
        type: "POST",
        dataType: "json",
        data: { coupon_id: id },
        success: function(res){

            Swal.fire("Updated", res.message, "success");
            loadCoupons();

        }
    });
}

</script>

</body>
</html>