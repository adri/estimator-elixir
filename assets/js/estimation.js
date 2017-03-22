import {Socket, Presence} from 'phoenix';

const cards = ['XS', 'S', 'M', 'L', 'XL'];

class Estimation {

    constructor(estimationName, user, playerListElem, cardDeckElem, issues, issueElem) {
        this.estimationName = estimationName;
        this.user = user;
        this.issues = issues;
        this.issueElem = issueElem;
        this.currentIssueKey = this.selectFirstIssue();
        this.players = {};
        this.playerListElem = playerListElem;
        this.cardDeckElem = cardDeckElem;
        this.currentModeratorId = null;

        this.renderCardDeck = this.renderCardDeck.bind(this);
        this.renderPlayers = this.renderPlayers.bind(this);
        this.renderIssue = this.renderIssue.bind(this);
        this.formatPlayers = this.formatPlayers.bind(this);
    }

    initialize() {
        // this.user.id = 'adri' + Math.ceil(Math.random() * 10);
        this.socket = new Socket('/socket', { params: {
            user: this.user,
        } });
        this.socket.connect();

        this.estimation = this.socket.channel(this.estimationName);
        this.estimation.on('players_state', state => {
            this.players = Presence.syncState(this.players, state);
            this.renderPlayers(this.players);
            if (!this.currentModeratorId && this.players.length === 1) {
                this.estimation.push('moderator:set', this.user.id);
            }
        });
        this.estimation.on('presence_diff', state => {
            this.players = Presence.syncDiff(this.players, state);
            this.renderPlayers(this.players)
        });
        this.estimation.join();

        this.cardDeckElem.addEventListener('click', e => {
            if (!cards.includes(e.target.innerHTML)) {
                return;
            }

            this.estimation.push('vote:new', e.target.innerHTML);
        });

        this.estimation.on('moderator:set', state => {
            this.currentModeratorId = state.moderatorId;
            this.renderPlayers(this.players);
            this.renderCardDeck();
        });

        this.renderCardDeck();

        if (this.currentIssueKey) {
            this.setCurrentIssueKey(this.currentIssueKey);
        }
    }

    setCurrentIssueKey(issueKey) {
        this.currentIssueKey = issueKey;
        this.renderIssue(this.issues[this.currentIssueKey]);
    }

    renderCardDeck() {
        const html = cards.map(card => `
           <div class="card estimator-card">
                <h3>${card}</h3>
            </div> 
        `).join('');

        this.cardDeckElem.innerHTML = !this.isModerator(this.user.id) ? html : '';
    }

    renderPlayers(players) {
        this.playerListElem.innerHTML = this.formatPlayers(players).map(player => `
            <li>
                <div class="media">
                  <div class="media-left">
                    <img src="${player.avatar || '/images/faces/face-0.jpg'}" alt="${player.name}" width="50" class="media-object img-circle img-no-padding">
                  </div>
                  <div class="media-body">
                    <h5 class="media-heading">${player.name}</h5>
                    ${this.isModerator(player.id) ? `<span class="text-danger"><small>Moderator</small></span>` : ''}
                    <span class="text-success"><small>Last action ${player.joinedAt}</small></span>
                  </div>
                  <div class="media-right">
                    <span class="vote">${!this.isModerator(player.id) ? player.lastVote || '-' : ''}</span>
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

    renderIssue(issue) {
        this.issueElem.innerHTML = `
            <div class="header">
                <a href="${issue.link}" target="_blank">${issue.key}</a>
                <h3 class="title">${issue.summary}</h3>
            </div>

            <div class="content all-icons jira-content">
                ${issue.description}
            </div>
         `;
    }

    isModerator(userId) {
        if (!this.currentModeratorId) {
            return false;
        }

        return userId === this.currentModeratorId;
    }

    allPlayersVoted(players) {
        // todo
    }

    resetVotes() {
        // todo
    }

    selectFirstIssue() {
        if (Object.keys(this.issues).length === 0) {
            return null;
        }

        return Object.keys(this.issues)[0];
    }
}

export default Estimation;
