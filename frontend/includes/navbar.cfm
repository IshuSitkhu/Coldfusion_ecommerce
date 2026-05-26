<cfif NOT structKeyExists(session, "role")>
    <cflocation url="../login.cfm" addToken="false">
</cfif>

<nav class="navbar navbar-expand-lg navbar-light  shadow-sm border-bottom sticky-top py-3">
    <div class="container-fluid px-4">

        <a class="navbar-brand fw-bold text-primary" href="##">
            Ecommerce
        </a>

        <button class="navbar-toggler"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="##mainNavbar">

            <span class="navbar-toggler-icon"></span>

        </button>

        <div class="collapse navbar-collapse" id="mainNavbar">

            <ul class="navbar-nav me-auto gap-2">

                <cfif session.role EQ "admin">

                    <li class="nav-item">
                        <a class="nav-link" href="../admin/dashboard.cfm">
                            Dashboard
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../admin/products.cfm">
                            Products
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../admin/users.cfm">
                            Users
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../admin/bills.cfm">
                            Bills
                        </a>
                    </li>

                </cfif>


                <cfif session.role EQ "seller">

                    <li class="nav-item">
                        <a class="nav-link" href="../seller/dashboard.cfm">
                            Dashboard
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../seller/products.cfm">
                            Products
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../seller/filter.cfm">
                            Filter
                        </a>
                    </li>

                </cfif>


                <cfif session.role EQ "customer">

                    <li class="nav-item">
                        <a class="nav-link" href="../customer/dashboard.cfm">
                            Dashboard
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../customer/products.cfm">
                            Products
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../customer/categories.cfm">
                            Categories
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../customer/sellers.cfm">
                            Sellers
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link" href="../customer/purchaseHistory.cfm">
                            Purchase History
                        </a>
                    </li>

                </cfif>

            </ul>


            <ul class="navbar-nav ms-auto">

                <li class="nav-item dropdown">

                    <a class="nav-link dropdown-toggle "
                       href="#"
                       role="button"
                       data-bs-toggle="dropdown">

                        <cfoutput>#session.username#</cfoutput>

                    </a>

                    <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-4">

                        <li>
                            <span class="dropdown-item-text text-muted">

                                Role :
                                <b>
                                    <cfoutput>#session.role#</cfoutput>
                                </b>

                            </span>
                        </li>

                        <li>
                            <hr class="dropdown-divider">
                        </li>

                        <li>
                            <a class="dropdown-item text-danger bg-light"
                               href="../logout.cfm">

                                Logout

                            </a>
                        </li>

                    </ul>

                </li>

            </ul>

        </div>

    </div>
</nav>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>