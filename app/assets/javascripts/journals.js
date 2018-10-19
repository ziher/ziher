$(function () {
    var year = $('#journal-year').data('source');
    var journal_blocked_to = $('#journal_blocked_to_hidden_input').val();

    if (journal_blocked_to) {
        var selected_date = new Date(journal_blocked_to);
    } else {
        var d = new Date();
        var currentDay = d.getDate();
        var currentMonth = d.getMonth();
        var selected_date = new Date(year, currentMonth, currentDay);

        $('#journal_blocked_to_hidden_input').val(selected_date);
    }

    $("#journal_blocked_to_date").datepicker({
        defaultDate: selected_date,
        minDate: new Date(year, 1 - 1, 1),
        maxDate: new Date(year, 12 - 1, 31),
        numberOfMonths: [3, 4],
        onSelect: function(dateText, inst) {
            $("input[name='journal_blocked_to_hidden_input']").val(dateText);
        }
    })
});