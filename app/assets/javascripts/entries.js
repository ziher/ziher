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
        numberOfMonths: 3
    });
});