// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.
// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import Estimation from "./estimation"
const playerList = document.getElementById('player-list');
const cardDeck = document.getElementById('card-deck');
const issue = document.getElementById('issue');
let estimation;
if (window.current_user && window.issues && playerList && cardDeck) {
    estimation = new Estimation('estimation:ticketswap', window.current_user, playerList, cardDeck, window.issues, issue);
    estimation.initialize();
}

$("#card-deck .card").on("touchstart", function(){
    $(this).addClass("mobileHoverFix");
});
$("#card-deck .card").on("touchend", function(){
    $(this).removeClass("mobileHoverFix");
});

$(document).ready(function() {
    $('.backlog-table tbody tr').click(function(event) {
        if (event.target.type !== 'checkbox') {
            $(':checkbox', this).trigger('click');
        }
    });
});
$("input[type='checkbox']").change(function (e) {
    if ($(this).is(":checked")) { //If the checkbox is checked
        $(this).closest('tr').addClass("ui-state-highlight");
    } else {
        $(this).closest('tr').removeClass("ui-state-highlight");
    }
});

$(document).ready(function() {
    $('.estimate-table tbody tr').click(function(event) {
        $('.estimate-table tr').removeClass("ui-state-highlight");

        if (event.target.type !== 'radio') {
            $(':radio', this).trigger('click');
            $(':radio', this).addClass("ui-state-highlight");
            if (typeof estimation !== 'undefined') {
                estimation.setCurrentIssueKeyByUser($(':radio', this).val());
            }
        }
    });
});

$("input[type='radio']").change(function (e) {
    if ($(this).is(":checked")) {
        $(this).closest('tr').addClass("ui-state-highlight");
    } else {
        $(this).closest('tr').removeClass("ui-state-highlight");
    }
});
