<cfinclude template="../includes/authCheck.cfm">
<cfinclude template="../includes/navbar.cfm">

<!DOCTYPE html>
<html>
<head>
    <title>Admin Users</title>

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

    </div>

    <div class="card shadow-sm mb-3">
        <div class="card-header bg-dark text-white">
            All Users (Admin Control Panel)
        </div>

        <div class="card-body table-responsive">

            <table class="table table-bordered table-hover">
                <thead class="table-light">
                    <tr>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Address</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody id="adminUserTable">
                    <tr>
                        <td colspan="5" class="text-center">Loading...</td>
                    </tr>
                </tbody>

            </table>

        </div>
    </div>

</div>

<script>

function loadUsers() {

    $.ajax({
    url: "/ecommerce/api/User.cfc?method=getUsers",
    type: "GET",
    dataType: "json",

    success: function(res) {

        if (typeof res === "string") {
            res = JSON.parse(res);
        }

        console.log("PARSED:", res);

        if (!res.STATUS) {
            Swal.fire("Error", "API failed", "error");
            return;
        }

        if (!res.DATA || !Array.isArray(res.DATA)) {
            Swal.fire("Error", "No user data found", "error");
            return;
        }

        let rows = "";

        res.DATA.forEach(function(u) {

            rows += `
                <tr>
                    <td>${u.USERNAME}</td>
                    <td>${u.EMAIL}</td>
                    <td>${u.ROLE}</td>
                    <td>${u.ADDRESS}</td>
                    <td>${u.STATUS}</td>
                </tr>
            `;
        });

        $("#adminUserTable").html(rows);
    },

    error: function(xhr) {
        console.log(xhr.responseText);
        Swal.fire("Error", "AJAX failed", "error");
    }
});
}

$(document).ready(function() {
    loadUsers();
});

</script>

</body>
</html>