<!DOCTYPE html>
<html>
<head>
    <title>Login</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- SweetAlert -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body {
            background: #f4f6f9;
        }
    </style>
</head>

<body>

<div class="container">
    <div class="row justify-content-center mt-5">

        <div class="col-md-4">

            <div class="card shadow-lg">
                <div class="card-body p-4">

                    <h3 class="text-center mb-4">Login</h3>

                    <form id="loginForm">

                        <div class="mb-3">
                            <input type="email" name="email" class="form-control" placeholder="Email" required>
                        </div>

                        <div class="mb-3">
                            <input type="password" name="password" class="form-control" placeholder="Password" required>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            Login
                        </button>

                    </form>

                    <!-- Message (optional fallback) -->
                    <p id="msg" class="text-center mt-3"></p>

                    <!-- Register Link -->
                    <div class="text-center mt-3">
                        <span class="text-muted">Don't have an account?</span>
                        <a href="register.cfm" class="text-primary text-decoration-none fw-semibold">
                            Register
                        </a>
                    </div>

                </div>
            </div>

        </div>

    </div>
</div>

<script>
$("#loginForm").submit(function(e){
    e.preventDefault();

    $.ajax({
        url: "../api/Auth.cfc?method=login",
        type: "POST",
        data: $(this).serialize(),
        dataType: "json",

        success: function(res){

            let status = res.status ?? res.STATUS;
            let message = res.message ?? res.MESSAGE;
            let role = res.role;

            if(status === true){

                Swal.fire({
                    icon: 'success',
                    title: 'Login Successful',
                    text: message,
                    timer: 1200,
                    showConfirmButton: false
                });

                setTimeout(function(){

                    if(role == "admin"){
                        window.location.href = "admin/dashboard.cfm";
                    }
                    else if(role == "seller"){
                        window.location.href = "seller/dashboard.cfm";
                    }
                    else{
                        window.location.href = "customer/dashboard.cfm";
                    }

                }, 1200);

            } else {

                Swal.fire({
                    icon: 'error',
                    title: 'Login Failed',
                    text: message
                });

            }

        },

        error: function(){

            Swal.fire({
                icon: 'error',
                title: 'Server Error',
                text: 'Something went wrong. Please try again.'
            });

        }

    });

});
</script>

</body>
</html>