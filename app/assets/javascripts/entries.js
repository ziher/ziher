function showOrHideLinkedEntry(){
  console.log("show");
  if(jQuery("#is_linked").is(":checked")){
    jQuery("#linked_entry_div").show();
  }else{
    jQuery("#linked_entry_div").hide();
  }
}
