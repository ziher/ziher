function journalChanged(){
  hideAll();
  showJournalsSelect();
  showSelectedJournal();
}

function isLinkedChanged(input){
  hideAll();
  if(input.checked){
    showJournalsSelect();
    showSelectedJournal();
  }
}

function hideAll(){
  jQuery("#journals").hide();
  jQuery(".journal-categories").hide();
}

function showSelectedJournal(){
  var selectedJournal = jQuery("select#journals option:selected").val();
  jQuery("#journal-" + selectedJournal).show();
}

function showJournalsSelect(){
  jQuery("#journals").show();
}
