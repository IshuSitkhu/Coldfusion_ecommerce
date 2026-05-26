<!DOCTYPE html>
<html>
<head>
    <title>Register</title>

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

        <div class="col-md-5">

            <div class="card shadow-lg">
                <div class="card-body p-4">

                    <h3 class="text-center mb-4">Register</h3>

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
                            <input 
                                type="text"
                                name="address" 
                                class="form-control"
                                placeholder="Address"
                                required>
                            </input>
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
                            Register
                        </button>

                    </form>
                    <div class="text-center mt-3">
                        <span class="text-muted">Already have an account?</span>
                        <a href="login.cfm" class="text-primary text-decoration-none fw-semibold">
                            Login
                        </a>
                    </div>

                    <p id="msg" class="text-center mt-3"></p>

                </div>
            </div>

        </div>

    </div>
</div>

<script>
$("#registerForm").submit(function(e){
    e.preventDefault();

    $.ajax({
        url: "../api/Auth.cfc?method=register",
        type: "POST",
        data: $(this).serialize(),
        dataType: "json",

        success: function(res){
            let status = res.status ?? res.STATUS;
            let message = res.message ?? res.MESSAGE;

            if(status === true){

                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: message,
                    timer: 1200,
                    showConfirmButton: false
                });

                setTimeout(function(){
                    window.location.href = "login.cfm";
                }, 1200);

            } else {

                Swal.fire({
                    icon: 'error',
                    title: 'Registration Failed',
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