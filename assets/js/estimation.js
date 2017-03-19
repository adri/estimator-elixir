import {Socket, Presence} from 'phoenix';

const cards = ['XS', 'S', 'M', 'L', 'XL'];

class Estimation {

    constructor(estimationName, user) {
        this.players = {};
        this.estimationName = estimationName;
        this.user = user;
        this.playerList = document.getElementById('player-list');
        this.cardDeck = document.getElementById('card-deck');

        this.renderCardDeck = this.renderCardDeck.bind(this);
        this.renderPlayers = this.renderPlayers.bind(this);
        this.formatPlayers = this.formatPlayers.bind(this);
    }

    initialize() {
        // this.user = window.prompt('What is your name?') || 'Anonymous';
        this.socket = new Socket('/socket', { params: {
            user: this.user,
        } });
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
                <div class="media">
                  <div class="media-left">
                    <img src="${player.avatar || '/images/faces/face-0.jpg'}" alt="${player.name}" width="50" class="media-object img-circle img-no-padding">
                  </div>
                  <div class="media-body">
                    <h5 class="media-heading">${player.name}</h5>
                    <span class="text-success"><small>Last action ${player.joinedAt}</small></span>
                  </div>
                  <div class="media-right">
                    <span class="vote">${player.lastVote || '-'}</span>
                  </div>
                </div>
            </li>
         `).join('');
    }

    formatPlayers(players) {
        return Presence.list(players, (id, {metas}) => {
            const meta = metas.reduce((prev, current) => (prev.online_at > current.online_at) ? prev : current);
            return {
                id: id,
                avatar: meta.user.avatar,
                name: meta.user.name,
                joinedAt: (new Date(meta.online_at)).toLocaleTimeString(),
                lastVote: meta.last_vote,
            };
        })
    }
}

export default Estimation;
