import {Socket, Presence} from 'phoenix';

const cards = ['XS', 'S', 'M', 'L', 'XL'];

class Estimation {

    constructor(estimationName) {
        this.players = {};
        this.estimationName = estimationName;
        this.playerList = document.getElementById('player-list');
        this.cardDeck = document.getElementById('card-deck');

        this.renderCardDeck = this.renderCardDeck.bind(this);
        this.renderPlayers = this.renderPlayers.bind(this);
        this.formatPlayers = this.formatPlayers.bind(this);
    }

    initialize() {
        // this.user = window.prompt('What is your name?') || 'Anonymous';
        this.user = 'Adrian' + Math.random();

        this.socket = new Socket('/socket', { params: { user: this.user } });
        this.socket.connect();

        this.estimation = this.socket.channel(this.estimationName);
        this.estimation.on('players_state', state => {
            this.players = Presence.syncState(this.players, state);
            this.renderPlayers(this.players)
        });
        this.estimation.on('presence_diff', state => {
            this.players = Presence.syncDiff(this.players, state);
            this.renderPlayers(this.players)
        });
        this.estimation.join();

        this.renderCardDeck();
        this.cardDeck.addEventListener('click', e => {
            if (!cards.includes(e.target.innerHTML)) {
                return;
            }

            console.log('vote', e.target.innerHTML, cards);
            this.estimation.push('vote:new', e.target.innerHTML);
        })
    }

    renderCardDeck() {
        this.cardDeck.innerHTML = cards.map(card => `
           <div class="card estimator-card">
                <h3>${card}</h3>
            </div> 
        `).join('');
    }

    renderPlayers(players) {
        this.playerList.innerHTML = this.formatPlayers(players).map(player => `
          <li>
            <div class="row">
              <div class="col-xs-3">
                <div class="avatar">
                  <img src="/images/faces/face-0.jpg" alt="Circle Image" class="img-circle img-no-padding img-responsive">
                </div>
              </div>
              <div class="col-xs-6">
                ${player.name}
                <br>
                <span class="text-success"><small>Joined ${player.joinedAt}</small></span>
              </div>
              <div class="col-xs-3 text-right">
                <span class="vote">${player.lastVote || '-'}</span>
              </div>
            </div>
          </li>
        `).join('');
    }

    formatPlayers(players) {
        console.log('players: ', players);
        return Presence.list(players, (user, { metas }) => ({
            name: user,
            joinedAt: (new Date(metas[0].online_at)).toLocaleTimeString(),
            lastVote: metas[0].last_vote,
        }))
    }
}

export default Estimation;
