function showOrHideLinkedEntry(){
  console.log("show");
  if(jQuery("#is_linked").is(":checked")){
    jQuery("#linked_entry_div").show();
  }else{
    jQuery("#linked_entry_div").hide();
  }
}

$(function () {
    year = $('#journal-year').data('source');
    $.datepicker.setDefaults({ minDate: new Date(year, 1 - 1, 1) });
    $.datepicker.setDefaults({ maxDate: new Date(year, 12 - 1, 31) });
});