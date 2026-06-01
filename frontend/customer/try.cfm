function confirmBuy(){

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=buyNow",
        type: "POST",
        data: {
            product_id: SELECTED_PRODUCT_ID,
            discount: DISCOUNT,
            final_price: FINAL_PRICE
        },

        success: function(res){

            $("#buyModal").modal("hide");

            if(res.STATUS){
                alert("Purchase successful!");
                window.location = "../customer/purchaseHistory.cfm";
            } else {
                alert("Failed");
            }
        }
    });
}

function openCouponModal(){

    $("#couponModal").modal("show");

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=getCouponsForProduct",
        data: { product_id: SELECTED_PRODUCT_ID },
        dataType: "json",

        success: function(res){

            let data = res.DATA;

            let html = "";

            data.forEach(c => {

                html += `
                    <div class="border p-2 mb-2">
                        <b>${c.TITLE}</b><br>
                        Discount: ${c.DISCOUNT_AMOUNT}

                        <br><br>

                        <button class="btn btn-sm btn-primary"
                        onclick="applyCoupon(${c.DISCOUNT_AMOUNT}, ${c.MIN_AMOUNT})">
                        Apply
                        </button>
                    </div>
                `;
            });

            $("#couponList").html(html);
        }
    });
}

function applyCoupon(discount, minAmount){

    if(PRODUCT_PRICE < minAmount){
        alert("Not eligible for this coupon");
        return;
    }

    DISCOUNT = discount;
    FINAL_PRICE = PRODUCT_PRICE - DISCOUNT;

    $("#mDiscount").text(DISCOUNT);
    $("#mFinal").text(FINAL_PRICE);

    $("#couponModal").modal("hide");
}