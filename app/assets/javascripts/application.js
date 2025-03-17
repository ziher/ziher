// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-pl
//= require jquery-ui/widgets/sortable
//= require jquery-ui/effect
//= require bootstrap-sprockets
//= require_tree .

$(function () {
    $.datepicker.setDefaults($.datepicker.regional[ "pl" ]);
    $.datepicker.setDefaults({ dateFormat: "yy-mm-dd" });
    $.datepicker.setDefaults({ numberOfMonths: 3 });
    $.datepicker.setDefaults({ showCurrentAtPos: 1 })
    $("#inventory_entry_date").datepicker();
});

$(document).ready(function () {
    $('table').delegate('td, th', 'mouseover mouseleave', function (e) {
        if (e.type == 'mouseover') {
            if ($(this).is("td")) {
                $(this).parent().addClass("hover");
            }
            var className = $(this).attr('class');
            if (className) {
                var incomeOrExpense = className.match(/income_(\d+|all)|expense_(\d+|all)/);
                if (incomeOrExpense) {
                    className = incomeOrExpense[0];
                    $('.' + className).addClass("hover");
                    $(this).addClass("hover_dim");
                }
            }
        } else {
            $(this).removeClass("hover_dim");
            $(this).parent().removeClass("hover");
            var className = $(this).attr('class');
            if (className) {
                var incomeOrExpense = className.match(/income_(\d+|all)|expense_(\d+|all)/);
                if (incomeOrExpense) {
                    className = incomeOrExpense[0];
                    $('.' + className).removeClass("hover");
                }
            }
        }
    });
});
