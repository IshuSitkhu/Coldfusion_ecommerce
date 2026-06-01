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

    <div class="row">

        <div class="col-md-4">

            <div class="card shadow-sm">
                <div class="card-header bg-dark text-white">
                    Add Users
                </div>

                <div class="card-body p-4">

                    <form id="registerForm">

                        <div class="mb-3">
                            <input type="text" name="first_name" class="form-control" placeholder="First Name" required>
                        </div>

                        <div class="mb-3">
                            <input type="text" name="last_name" class="form-control" placeholder="Last Name" required>
                        </div>

                        <div class="mb-3">
                            <input type="text" name="username" class="form-control" placeholder="Username" required>
                        </div>

                        <div class="mb-3">
                            <input type="text" name="address" class="form-control" placeholder="Address" required>
                        </div>

                        <div class="mb-3">
                            <input type="email" name="email" class="form-control" placeholder="Email" required>
                        </div>

                        <div class="mb-3">
                            <input type="password" name="password" class="form-control" placeholder="Password" required>
                        </div>

                        <div class="mb-3">
                            <select name="role" class="form-select" required>
                                <option value="customer">Customer</option>
                                <option value="seller">Seller</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            Add user
                        </button>

                    </form>

                </div>
            </div>

        </div>

        <!-- RIGHT: TABLE -->
        <div class="col-md-8">

            <div class="card shadow-sm">
                <div class="card-header bg-dark text-white">
                    All Users
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
                                <th>Action</th>
                            </tr>
                        </thead>

                        <tbody id="adminUserTable">
                            <tr>
                                <td colspan="6" class="text-center">Loading...</td>
                            </tr>
                        </tbody>

                    </table>

                </div>
            </div>

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


                let btn = "";

            if (u.STATUS === "active") {
                btn = `<button class="btn btn-warning btn-sm" onclick="toggleStatus(${u.USER_ID})">Disable</button>`;
            } else {
                btn = `<button class="btn btn-success btn-sm" onclick="toggleStatus(${u.USER_ID})">Enable</button>`;
            }

            rows += `
                <tr>
                    <td>${u.USERNAME}</td>
                    <td>${u.EMAIL}</td>
                    <td>${u.ROLE}</td>
                    <td>${u.ADDRESS}</td>
                    <td>${u.STATUS}</td>
                    <td>${btn}</td>
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
function toggleStatus(userId) {

    $.ajax({
        url: "/ecommerce/api/User.cfc?method=toggleUserStatus",
        type: "POST",
        dataType: "json",
        data: {
            user_id: userId
        },

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

                loadUsers();

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

$("#registerForm").submit(function(e){

    e.preventDefault();

    $.ajax({

        url: "/ecommerce/api/User.cfc?method=addUsers",
        type: "POST",
        data: $(this).serialize(),
        dataType: "json",

        success: function(res){

            console.log("ADD USER RESPONSE:", res);

            if(res.STATUS){

                Swal.fire({
                    icon: "success",
                    title: "Success",
                    text: res.MESSAGE
                });

                $("#registerForm")[0].reset();

                loadUsers();

            } else {

                console.log("DETAIL:", res.DETAIL);

                Swal.fire({
                    icon: "error",
                    title: "Error",
                    text: res.MESSAGE + "\n" + (res.DETAIL || "")
                });

            }
        },

        error: function(xhr){

            console.log("AJAX ERROR");
            console.log(xhr.responseText);

            Swal.fire({
                icon: "error",
                title: "Server Error",
                text: "Check browser console for details"
            });
        }

    });

});

</script>

</body>
</html>