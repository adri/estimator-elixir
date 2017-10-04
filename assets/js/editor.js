import {Socket, Presence} from 'phoenix';

class Editor {

    constructor(socket, issueKey, selector) {
      this.socket = socket;
      this.issueKey = issueKey;
      this.selector = selector;
      this.presences = {};
      this.initialize = this.initialize.bind(this);
      this.documentInit = this.documentInit.bind(this);
      this.documentChange = this.documentChange.bind(this);
      this.localChange = this.localChange.bind(this);
      this.sendTextChange = this.sendTextChange.bind(this);
      this.sendCursor = this.sendCursor.bind(this);
    }

    initialize() {
      this.channel = this.socket.channel("document:" + this.issueKey);
      this.channel.join()
        .receive("ok", resp => console.log("joined"))
        .receive("error", reason => console.log("join failed ", reason));
      this.channel.on("init", this.documentInit);
      this.channel.on("text_change", this.documentChange);

      this.quill = new Quill(this.selector, {
        modules: {
          toolbar: '.toolbar'
        },
        formats: [],
        theme: 'snow'
      });
      this.quill.on('text-change', this.localChange);
      // this.quill.on('selection-change', (range, oldRange, source) => this.localCursorChange(range));
    }

    documentInit(doc) {
      console.log(doc);
      this.crdt = Crdt.init(doc.state);
      this.site = doc.site;
      this.lamport = 0;
      this.quill.setText(Crdt.to_string(this.crdt));
    }

    documentChange({delta}) {
      this.quill.updateContents(delta)
    }

    localChange(delta, oldDelta, source) {
      if (source !== "user") return;

      this.sendTextChange(delta)
    }

    sendTextChange(delta) {
      this.channel.push("text_change", {delta}).receive("error", e => { throw e; });
    }

    sendCursor(cursor) {
      this.channel.push("cursor", cursor).receive("error", e => { throw e; });
    }
}

export default Editor;
