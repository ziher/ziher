function showOrHideLinkedEntry(){
  console.log("show");
  if(jQuery("#is_linked").is(":checked")){
    jQuery("#linked_entry_div").show();
  }else{
    jQuery("#linked_entry_div").hide();
  }
}

$(function () {
    var year = $('#journal-year').data('source');
    var journal_blocked_to = $('#journal_blocked_to').val();

    var minDate;

    if (journal_blocked_to) {
        var blocked_to_date = new Date(journal_blocked_to);

        var day = blocked_to_date.getDate();
        var month = blocked_to_date.getMonth();
        var year = blocked_to_date.getFullYear();

        minDate = new Date(year, month, day + 1);
    } else {
        minDate = new Date(year, 1 - 1, 1)
    }

    $("#entry_date").datepicker({
        minDate: minDate,
        maxDate: new Date(year, 12 - 1, 31),
        numberOfMonths: 3,
        setCurrentAtPos: 1
    });

    // Uniwersalna funkcja do sumowania kwot
    function updateTotalSum(inputSelector, outputId) {
        var total = 0;
        $(inputSelector).each(function() {
            var value = parseFloat($(this).val()) || 0;
            total += value;
        });
        $(outputId).val(total.toFixed(2));
    }

    $('.amount-input').on('input', function() {
        updateTotalSum('.amount-input', '#total-sum');
    });

    $('.amount-input-one-percent').on('input', function() {
        updateTotalSum('.amount-input-one-percent', '#total-sum-one-percent');
    });

    $('.amount-input-grants').on('input', function() {
        updateTotalSum('.amount-input-grants', '#total-sum-grants');
    });

});