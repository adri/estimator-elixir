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
if (window.current_user && playerList && cardDeck) {
    const estimation = new Estimation('estimation:ticketswap', window.current_user, playerList, cardDeck);
    estimation.initialize();
}


$(".card").on("touchstart", function(){
    $(this).addClass("mobileHoverFix");
});
$(".card").on("touchend", function(){
    $(this).removeClass("mobileHoverFix");
});
