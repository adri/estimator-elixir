import {Socket, Presence} from 'phoenix';

const cards = ['XS', 'S', 'M', 'L', 'XL'];
const funCards = ['?'];

class Estimation {

    constructor(estimationName, user, playerListElem, cardDeckElem, issues, issueElem, estimationElem) {
        this.estimationName = estimationName;
        this.user = user;
        this.issues = issues;
        this.issueElem = issueElem;
        this.currentIssueKey = null;
        this.votes = {};
        this.players = {};
        this.playerListElem = playerListElem;
        this.cardDeckElem = cardDeckElem;
        this.estimationElem = estimationElem;
        this.currentModeratorId = null;

        this.renderCardDeck = this.renderCardDeck.bind(this);
        this.renderPlayers = this.renderPlayers.bind(this);
        this.renderIssue = this.renderIssue.bind(this);
        this.formatPlayers = this.formatPlayers.bind(this);
        this.setCurrentIssueKey = this.setCurrentIssueKey.bind(this);
        this.setModerator = this.setModerator.bind(this);
        this.setVote = this.setVote.bind(this);
        this.getVoteOnCurrentIssue = this.getVoteOnCurrentIssue.bind(this);
        this.setSelectedEstimation = this.setSelectedEstimation.bind(this);
    }

    initialize() {
        this.socket = new Socket('/socket', { params: {
            user: this.user,
        } });
        this.socket.connect();

        this.estimation = this.socket.channel(this.estimationName);
        this.estimation.on('players_state', state => {
            this.players = Presence.syncState(this.players, state);
            this.renderPlayers(this.players);
        });
        this.estimation.on('presence_diff', state => {
            this.players = Presence.syncDiff(this.players, state);
            this.renderPlayers(this.players);
        });
        this.estimation.join();

        this.cardDeckElem.addEventListener('click', e => {
            if (!cards.concat(funCards).includes(e.target.innerHTML)) {
                return;
            }

            this.estimation.push('vote:new', {issue_key: this.currentIssueKey, vote: e.target.innerHTML});
        });

        this.estimation.on('vote:new', state => {
            this.setVote(state.user_id, state.issue_key, state.vote);
            this.renderPlayers(this.players);
            this.renderEstimation();
            this.renderCardDeck();
        });
        this.estimation.on('vote:current', state => {
            this.votes[state.issue_key] = state.votes;
            this.renderPlayers(this.players);
            this.renderEstimation();
            this.renderCardDeck();
        });
        this.estimation.on('issue:current', state => {
            if (state.issue_key) {
                console.log('Issue set from moderator');
                this.setCurrentIssueKey(state.issue_key, false);
            } else {
                console.log('no issue on server, selecting first');
                this.estimation.push('issue:set', {issue_key: this.selectFirstIssue()});
            }
        });
        this.estimation.on('issue:set', state => {
            console.log('Issue set from moderator');
            this.setCurrentIssueKey(state.issue_key, false);
        });
        this.estimation.on('moderator:set', state => this.setModerator(state.moderator_id));
        this.estimation.on('moderator:current', state => this.setModerator(state.moderator_id));
        this.estimation.on('estimation:set', state => {
            console.log('estimation set from moderator', state);
            $('.estimate-' + state.issue_key).html(state.estimation);
            $('.save-estimate').addClass('blink_me');
            setTimeout(() => $('.save-estimate').removeClass('blink_me'), 2000);

        });

        this.renderCardDeck();
    }

    setCurrentIssueKeyByUser(issueKey) {
        if (!this.isModerator(this.user.id)) {
            return;
        }

        this.setCurrentIssueKey(issueKey);
    }

    setCurrentIssueKey(issueKey, broadcast = true) {
        console.log('set issue', issueKey);
        this.currentIssueKey = issueKey;
        this.renderIssue(this.issues[this.currentIssueKey]);
        this.renderPlayers(this.players);
        this.renderEstimation();
        this.renderCardDeck();
        $(`:radio[value=${this.currentIssueKey}]`).click();
        if (broadcast) {
            this.estimation.push('issue:set', {issue_key: issueKey});
        }
    }

    setSelectedEstimation(e) {
        console.log('set estimation', this.currentIssueKey, this.getCurrentEstimation());
        this.estimation.push('estimation:set', {issue_key: this.currentIssueKey, estimation: this.getCurrentEstimation()});
    }

    getCurrentEstimation() {
        return $('select[name=estimation]').val();
    }

    nextIssue() {
        let found = false;
        const next = Object.keys(this.issues).find(issue => {
            if (found) { return true; }
            found = issue  === this.currentIssueKey;
            return false;
        });

        if (next) {
            this.setCurrentIssueKey(next);
        }
    }

    setVote(userId, issueKey, vote) {
        console.log('set vote', userId, issueKey, vote);
        this.votes[issueKey] = this.votes[issueKey] || {};
        this.votes[issueKey][userId] = vote;
    }

    getVoteOnCurrentIssue(userId) {
        this.votes[this.currentIssueKey] = this.votes[this.currentIssueKey] || {};
        return this.votes[this.currentIssueKey][userId];
    }

    isModerator(userId) {
        if (!this.currentModeratorId) {
            return false;
        }

        return userId === this.currentModeratorId;
    }

    setModerator(userId, broadcast = false) {
        console.log('set moderator', userId);
        this.currentModeratorId = userId;
        this.renderPlayers(this.players);
        this.renderCardDeck();
        this.renderEstimation();
        if (broadcast) {
            this.estimation.push('moderator:set', userId);
        }
    }

    allPlayersVoted(players) {
        const waitingFor = this.formatPlayers(players).filter(player => {
            if (this.isModerator(player.id)) {
                return false;
            }

            return !this.getVoteOnCurrentIssue(player.id);
        });

        console.log('waiting for players ', waitingFor.length);
        return waitingFor.length === 0;
    }

    selectFirstIssue() {
        if (Object.keys(this.issues).length === 0) {
            return null;
        }

        return Object.keys(this.issues)[0];
    }

    renderCardDeck() {
        const html = cards.concat(funCards).map(card => `
           <div class="card estimator-card ${this.getVoteOnCurrentIssue(this.user.id) === card ? 'selected' : ''}">
               <h3>${card}</h3>
            </div> 
        `).join('');

        this.cardDeckElem.innerHTML = !this.isModerator(this.user.id) ? html : '';
    }

    renderPlayers(players) {
        this.playerListElem.innerHTML = this.formatPlayers(players).map(player => {
            const setModerator = this.isModerator(this.user.id) ? `
                <button 
                    class="btn btn-sm btn-success set_moderator" 
                    onclick="estimation.setModerator('${player.id}', true); return false">
                    <small>Set as moderator</small>
                </button>` : '';
            return `
                <li>
                    <div class="media player">
                      <div class="media-left">
                        <img src="${player.avatar || '/images/faces/face-0.jpg'}" alt="${player.name}" width="50" class="media-object img-circle img-no-padding">
                      </div>
                      <div class="media-body">
                        <h5 class="media-heading">${player.name}</h5>
                        ${this.isModerator(player.id) ? `<span class="text-danger"><small>Moderator</small></span>` : ''}
                        <span class="text-success"><small>Last action ${player.joinedAt}</small></span>
                        ${setModerator}
                      </div>
                      <div class="media-right vote-container">
                        <span class="vote">${this.renderVote(player)}</span>
                      </div>
                    </div>
                </li>
             `;
        }).join('');
    }

    renderVote(player) {
        if (this.isModerator(player.id)) {
            return '';
        }
        const currentVote = this.getVoteOnCurrentIssue(player.id);

        if (!this.allPlayersVoted(this.players) && currentVote) {
            return '✔';
        }

        return currentVote || '-';
    }

    renderEstimation() {
        if (!this.isModerator(this.user.id)) {
            this.estimationElem.innerHTML = `Currently logged in members.`;
            return;
        }

        if (!this.allPlayersVoted(this.players)) {
            this.estimationElem.innerHTML = `Waiting for players to vote.`;
            return;
        }

        const allVotes = this.formatPlayers(this.players)
            .map(player => this.getVoteOnCurrentIssue(player.id));
        const mostLikely = allVotes.reduce((counts, vote) => {
            const count = (counts[vote + ''] || 0) + 1;
            counts[vote + ''] = count;
            if (count > counts.max && vote) {
                counts.max = count;
                counts.vote = vote;
            }
            return counts;
        }, {max: 0, vote: ''});
        const mostLikelyVote = (mostLikely||{}).vote;

        // todo: get most likely estimation
        this.estimationElem.innerHTML = `
           Estimation
           <select name="estimation" class="form-control selectpicker"> 
              ${cards.map(card => `<option value="${card}" ${card === mostLikelyVote ? 'selected' : ''}>${card}</option>`)}
            </select>
            <button class="btn btn-fill btn-success save-estimate" onclick="estimation.setSelectedEstimation(); return false">Save</button>
            <button class="btn btn-success" onclick="estimation.nextIssue(); return false">Next issue</button>
         `;
    }

    formatPlayers(players) {
        return Presence.list(players, (id, {metas}) => {
            const meta = metas.reduce((prev, current) => (prev.online_at > current.online_at) ? prev : current);

            return {
                id: id,
                avatar: meta.user.avatar,
                name: meta.user.name,
                joinedAt: (new Date(meta.online_at)).toLocaleTimeString(),
                device: meta.user.device,
                lastVote: meta.last_vote,
            };
        })
    }

    renderIssue(issue) {
        this.issueElem.innerHTML = `
            <div class="header">
                <a href="${issue.link}" target="_blank">
                    <img src="${issue.type.iconUrl}" title="${issue.type.name}"/> ${issue.key}
                </a>
                <h3 class="title">${issue.summary}</h3>
            </div>

            <div class="content all-icons jira-content">
                ${issue.description}
            </div>
         `;
    }
}

export default Estimation;
