import {Socket, Presence} from 'phoenix';
import Editor from './editor';

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
        this.awayUsers = {};
        this.playerListElem = playerListElem;
        this.cardDeckElem = cardDeckElem;
        this.estimationElem = estimationElem;
        this.currentModeratorId = null;

        this.renderCardDeck = this.renderCardDeck.bind(this);
        this.renderPlayers = this.renderPlayers.bind(this);
        this.renderIssue = this.renderIssue.bind(this);
        this.renderIssueEditor = this.renderIssueEditor.bind(this);
        this.formatPlayers = this.formatPlayers.bind(this);
        this.setCurrentIssueKey = this.setCurrentIssueKey.bind(this);
        this.setModerator = this.setModerator.bind(this);
        this.setVote = this.setVote.bind(this);
        this.getVoteOnCurrentIssue = this.getVoteOnCurrentIssue.bind(this);
        this.setSelectedEstimation = this.setSelectedEstimation.bind(this);
        this.onEstimationStored = this.onEstimationStored.bind(this);
        this.onUserAway = this.onUserAway.bind(this);
        this.getAwayUsers = this.getAwayUsers.bind(this);
        this.startEditIssue = this.startEditIssue.bind(this);
        this.stopEditIssue = this.stopEditIssue.bind(this);
    }

    initialize() {
        this.socket = new Socket('/socket', { params: {
            user: this.user,
            guardian_token: $('meta[name="guardian_token"]').attr('content'),
        } });
        this.socket.connect();

        this.estimation = this.socket.channel(this.estimationName);
        this.estimation.on('players_state', state => {
            this.players = Presence.syncState(this.players, state);
            this.renderPlayers(this.players, this.getAwayUsers());
        });
        this.estimation.on('presence_diff', state => {
            this.players = Presence.syncDiff(this.players, state);
            this.renderPlayers(this.players, this.getAwayUsers());
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
            this.renderPlayers(this.players, this.getAwayUsers());
            this.renderEstimation();
            this.renderCardDeck();
        });
        this.estimation.on('vote:current', state => {
            this.votes[state.issue_key] = state.votes;
            this.renderPlayers(this.players, this.getAwayUsers());
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
        this.estimation.on('issue:start_edit', state => {
            this.renderIssueEditor(this.currentIssueKey);
        });
        this.estimation.on('issue:stop_edit', state => {
          this.editor = null;
        });
        this.estimation.on('moderator:set', state => this.setModerator(state.moderator_id));
        this.estimation.on('moderator:current', state => this.setModerator(state.moderator_id));
        this.estimation.on('estimation:set', state => {
            console.log('estimation set from moderator', state);
            $('.estimate-' + state.issue_key).html(state.estimation);
        });
        this.estimation.on('estimation:stored', state => this.onEstimationStored(state.issue_key));

        this.estimation.on('user:away', user => this.onUserAway(user));
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
        this.renderPlayers(this.players, this.getAwayUsers());
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
        $('.save-estimate').prop('disabled', true).addClass('loading');
        setTimeout(() => $('.save-estimate').removeClass('loading').prop('disabled', false), 2000);
    }

    getCurrentEstimation() {
        return $('select[name=estimation]').val();
    }

    onEstimationStored(issueKey) {
        console.log('stored estimation', issueKey);
        if (this.currentIssueKey !== issueKey) {
           return;
        }

        $('.save-estimate').removeClass('loading').prop('disabled', false);
        this.nextIssue();
    }

    onUserAway(state) {
        console.log('User went away', state);
        this.awayUsers[state.user.id] = {metas: [state]};
    }

    getAwayUsers() {
        const players = Object.keys(this.players);
        return Object.keys(this.awayUsers)
            .filter(id => !players.includes(id))
            .reduce((obj, key) => {
                obj[key] = this.awayUsers[key];
                return obj;
            }, {});
    }

    skipIssue() {
        console.log('skip estimation', this.currentIssueKey);
        this.estimation.push('estimation:skip', {issue_key: this.currentIssueKey});
        this.nextIssue();
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
        this.renderPlayers(this.players, this.getAwayUsers());
        this.renderCardDeck();
        this.renderEstimation();
        this.setBodyClass(userId);
        if (broadcast) {
            this.estimation.push('moderator:set', userId);
        }
    }

    setBodyClass() {
        document.getElementsByTagName('body')[0]
            .setAttribute('class', this.isModerator(this.user.id) ? 'is-moderator' : '');
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

    renderPlayers(players, away) {
        const renderPlayer = player => {
            const setModerator = this.isModerator(this.user.id) ? `
                <button
                    class="btn btn-sm btn-success set_moderator"
                    onclick="estimation.setModerator('${player.id}', true); return false">
                    <small>Set as moderator</small>
                </button>` : '';
            return `
                <li>
                    <div class="media player ${player.status}">
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
        };

        this.playerListElem.innerHTML = this.formatPlayers(players).map(renderPlayer).join('');
        this.playerListElem.innerHTML += this.formatPlayers(away).map(renderPlayer).join('');
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
        if (!this.allPlayersVoted(this.players)) {
            const skipButton = this.isModerator(this.user.id) ? `<button class="btn btn-success" onclick="estimation.skipIssue(); return false">Skip</button>` : '';

            this.estimationElem.innerHTML = `
                Waiting for team members to vote.<br />
                ${skipButton}
            `;
            return;
        }

        if (!this.isModerator(this.user.id)) {
            this.estimationElem.innerHTML = `Waiting for moderator.`;
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
            <button class="btn btn-fill btn-success save-estimate" onclick="estimation.setSelectedEstimation(); return false">Save and next</button>
            <button class="btn btn-success" onclick="estimation.skipIssue(); return false">Skip</button>
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
                status: meta.status,
            };
        })
    }

    renderIssue(issue) {
        if (!issue) {
            return;
        }

        this.issueElem.innerHTML = `
            <div class="header">
                <a href="${issue.link}" target="_blank">
                    <img src="${issue.type.iconUrl}" title="${issue.type.name}"/> ${issue.key}
                </a>
                <h3 class="title">${issue.summary}</h3>
            </div>

            <div class="toolbar">
              <button class="btn btn-sm btn-success">Save to Jira</button>
            </div>
            <div class="content all-icons jira-content" onclick="estimation.startEditIssue()">
                ${issue.description}
            </div>
         `;
    }

    renderIssueEditor(issueKey) {
      if (this.editor) return;

      this.editor = new Editor(this.socket, issueKey, '.jira-content');
      this.editor.initialize();
    }

    startEditIssue() {
      this.estimation.push('issue:start_edit', {issue_key: this.selectFirstIssue()});
    }

    stopEditIssue() {
      this.estimation.push('issue:stop_edit', {issue_key: this.selectFirstIssue()});
    }
}

export default Estimation;
