function reviewProduct(product_id, btn){

    $(btn).prop("disabled", true);

    $.ajax({
        url: "/ecommerce/api/Product.cfc?method=addReview",
        type: "POST",
        dataType: "json",
        data: {
            product_id: product_id
        },

        success: function(res){

            Swal.fire({
                icon: res.STATUS ? "success" : "info",
                title: res.STATUS ? "Thank you!" : "Notice",
                text: res.MESSAGE
            });

        },

        complete: function(){
            $(btn).prop("disabled", false);
        }
    });
}