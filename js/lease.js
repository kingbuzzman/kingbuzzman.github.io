var residualAmount = function() {
  var price = accounting.unformat($("#sticker_price").val());
  var residual = accounting.unformat($("#residual").val());

  $("#residual_amount").val(accounting.formatNumber(price * (residual / 100), 2)).change();
};

var depreciationAmount = function() {
  var invoice = accounting.unformat($("#invoice_price").val());
  var residual = accounting.unformat($("#residual_amount").val());

  $("#depreciation").val(accounting.formatNumber(invoice - residual, 2)).change();
};

var depreciationPayment = function() {
  var terms = accounting.unformat($("#lease_terms").val());
  var depreciation = accounting.unformat($("#depreciation").val());

  $("#depreciation_payment").val(accounting.formatNumber(depreciation / terms, 2)).change();
};

var moneyFactorFees = function() {
  var residual = accounting.unformat($("#residual_amount").val());
  var invoice = accounting.unformat($("#invoice_price").val());
  var money_factor = accounting.unformat($("#money_factor").val());

  $("#apr").val(accounting.formatNumber(money_factor * 2400));
  $("#money_factor_fees").val(accounting.formatNumber((residual + invoice) * money_factor, 2)).change();
};

var monthlyPayment = function() {
  var depreciation = accounting.unformat($("#depreciation_payment").val());
  var money_factor = accounting.unformat($("#money_factor_fees").val());
  var tax = accounting.unformat($("#tax").val());
  var total_ = accounting.formatNumber(depreciation + money_factor, 2);
  var total = accounting.unformat(total_);

  $("#monthly_payment").val(total_).change();
  $("#monthly_taxes").val(accounting.formatNumber(total * (tax /100), 2)).change();
  $("#monthly_payment_total").val(accounting.formatNumber(total * (tax /100 + 1), 2)).change();
};

var TotalPayments = function() {
  var monthly_payment = accounting.unformat($("#monthly_payment").val());
  var monthly_total = accounting.unformat($("#monthly_payment_total").val());
  var terms = accounting.unformat($("#lease_terms").val());

  $("#total_payments").val(accounting.formatNumber(monthly_payment * terms, 2)).change();
  $("#total_taxes").val(accounting.formatNumber(monthly_total * terms, 2)).change();
}

$(document).ready(function(){
  $("#sticker_price, #residual").change(residualAmount);
  $("#invoice_price, #residual_amount").change(depreciationAmount);
  $("#depreciation, #lease_terms").change(depreciationPayment);
  $("#invoice_price, #residual_amount, #money_factor").change(moneyFactorFees);
  $("#depreciation_payment, #money_factor_fees, #tax").change(monthlyPayment);
  $("#monthly_payment, #monthly_payment_total").change(TotalPayments);

  $("#calculate").click(function() {
    residualAmount();
    depreciationAmount();
    depreciationPayment();
    moneyFactorFees();
    monthlyPayment();
    TotalPayments();
  })

  // formatting
  $("#sticker_price, #invoice_price").blur(function() {
    var el = $(this);

    el.val(accounting.formatNumber(el.val(), 2));
  });

  $("#tax, #residual").blur(function() {
    var el = $(this);

    el.val(accounting.formatNumber(el.val(), 1) + "%");
  });

});
