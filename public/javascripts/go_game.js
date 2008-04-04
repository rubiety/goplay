/***********************************************************
 * GoPlay!
 * 
 * Primary Game Board Controller
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, jQuery.svg, Facebox
 * 
 * GoGame Class
 * --------
 * 
 * GoGame operates in two contexts:
 * - In Play - Currently playing a go game with a board and a 
 *   game-specific chat.  In this mode, chat messages are only 
 *   processed that are inside the game (not global messages).
 * - Out of Play - Not currently in a game but listening for all 
 *   global chat messages.  No game board.
 * 
 * Options for constructor:
 * - board: Reference to the board if currently in a game
 * - chatbox: Reference to the chat box
 * - console: A console logging action history
 * - user: Details about the current user
 * - game: An object of game details:
 *   - id: Database ID of the game
 *   - size: Number of the size of the square board
 *   - color: black or white (current user's player color)
 *   - opponent: Object representing the opponent
 * 
 **********************************************************/

var GoGame = function(options) {
  this.board = options.board;
  this.chatbox = options.chatbox;
  this.console = options.console;
  this.user = options.user;
  this.game = options.game;
  this.initialize();
};

/*** Configuration ***/

GoGame.POLL_FREQUENCY = '2s';
GoGame.BOARD_HEIGHT = 440;
GoGame.BOARD_WIDTH = 440;
GoGame.BOARD_TOP = 30;
GoGame.BOARD_LEFT = 30;
GoGame.PIECE_RADIUS_DIVISOR = 2.4;


/*** Implementation - Do not change! ***/

GoGame.prototype = {
  
  initialize: function() {
    this.createGameBoard();
    this.startEventPoller();
  },
  
  createGameBoard: function() {
    if (!this.game || !this.board || !this.board.id || this.svgboard) { return; }
    
    if (!this.board.width) { this.board.width = GoGame.BOARD_WIDTH; }
    if (!this.board.height) { this.board.height = GoGame.BOARD_HEIGHT; }
    if (!this.board.top) { this.board.top = GoGame.BOARD_TOP; }
    if (!this.board.left) { this.board.left = GoGame.BOARD_LEFT; }
    
    // Default rows and columns to size, could support non-square in future
    this.board.rows = this.board.size;
    this.board.columns = this.board.size;
    
    this.board.rowSize = this.board.height / (this.board.rows - 1);
    this.board.columnSize = this.board.width / (this.board.columns - 1);
    
    if (!this.board.pieceRadius) { this.board.pieceRadius = this.board.rowSize / GoGame.PIECE_RADIUS_DIVISOR; }
    
    $('#' + this.board.id + ' #svgboard').svg();
    this.svgboard = svgManager.getSVGFor('#' + this.board.id + ' #svgboard');
    
    // Construct Row & Column Lines
    for (i = 0; i < this.board.rows; i++) {
      this.svgboard.line(null, this.board.top, this.board.top + this.board.rowSize * i, this.board.top + this.board.width, this.board.top + this.board.rowSize * i, {stroke: 'black', stroke_width: 1});
    }
    
    for (i = 0; i < this.board.columns; i++) {
      this.svgboard.line(null, this.board.left + this.board.columnSize * i, this.board.left, this.board.left + this.board.columnSize * i, this.board.left + this.board.height, {stroke: 'black', stroke_width: 1});
    }
    
    // Create some example pieces
    for (i = 0; i < 9; i++) {
      this.createPiece(i, i, (i % 2) ? 'white' : 'black');
    }
    
    // Initialize Click Listener
    $('#' + this.board.id + ' #svgboard').bind('click', this, this.onBoardClick);
  },
  
  // TODO: Refactor
  createPiece: function(row, column, color) {
    this.svgboard.circle(null, this.board.left + this.board.columnSize * column, this.board.top + this.board.rowSize * row, this.board.pieceRadius, {fill: color, stroke: 'black', stroke_width: 2});
  },
  
  // TODO: Refactor
  removePiece: function(row, column) {
    
  },
  
  startEventPoller: function() {
    $(this).everyTime(GoGame.POLL_FREQUENCY, 'eventpoller', this.pollEvent);
  },
  
  pollEvent: function() {
    tthis = this;
    
    $.getJSON('/users/current/events', function(events) {
      $.each(events, function(i, event) {
        switch (event.type) {
          case 'UserEnteredEvent':
            tthis.onUserEntered(event.payload);
            break;
          case 'UserLeftEvent':
            tthis.onUserLeft(event.payload);
            break;
          case 'MessageEvent':
            tthis.onMessage(event.payload);
            break;
          case 'GameInviteEvent':
            tthis.onGameInvite(event.payload);
            break;
          case 'GameInviteResponseEvent':
            tthis.onGameInviteResponse(event.payload);
            break;
          case 'MoveEvent':
            tthis.onMove(event.payload);
            break;
          case 'GameEndEvent':
            tthis.onGameEnd(event.payload);
            break;
        }
      });
    });
  },
  
  onUserEntered: function(data) {
    
    // TODO: Refactor into something better:
    $('#userslist').append($(
      '<div class="user" style="display: none" id="user_list_entry_' + data.source_user.id + '">' + 
      '  <img src="/images/avatars/bhughes.jpg" />' +
      '  <span>' + data.source_user.name + '</span>' +
      '  ' + data.source_user.description +
      '  ' + '<br />' + 
      '  <a href="/games/new?height=400&width=600&opponent_id=' + data.source_user.id + '" title="Challenge ' + data.source_user.name + ' to Game" class="thickbox">Challenge to Game</a>' + 
      '  <br style="clear: both" />' + 
      '  <script language="JavaScript">$("a[rel*=facebox]").facebox();</script>' +
      '</div>'
    ));
    
    $('#user_list_entry_' + data.source_user.id).fadeIn();
  },
  
  onUserLeft: function(data) {
    $('#userslist #user_list_entry_' + data.source_user.id).fadeOut();
  },
  
  onMessage: function(data) {
    $('<div class="message"><span>' + data.sender.name + ':</span> ' + data.message + '</div>').appendTo('#messagelist');
    $('#messagelist').scrollTo('div:last');
  },
  
  onGameInvite: function(data) {
    
    // TODO: Refactor into something better:
    $('#inviteslist').append($(
      '<div class="invite" style="display: none" id="invites_list_entry_' + data.source_user.id + '">' + 
      '  <img src="/images/avatars/bhughes.jpg" />' +
      '  <h4>New Game Invitation</h4>' +
      '  <span>' + data.source_user.name + '</span>' +
      '  ' + data.source_user.description +
      '  ' + '<br />' + 
      '  <a href="/games/' + data.game.id + '/accept">Accept Invite</a> | <a href="/games/' + data.game.id + '/reject">Reject Invite</a>' + 
      '  <br style="clear: both" />' + 
      '</div>'
    ));
    
    $('#invites_list_entry_' + data.source_user.id).fadeIn();
  },
  
  onGameInviteResponse: function(data) {
    switch (data.response) {
      case 'Accepted':
        $('#invitee').fadeOut();
        this.startGame();
        break;
        
      case 'Rejected':
        $('#invitee').fadeOut();
        $('#rejectedinvite').fadeIn();
        break;
    }
  },
  
  onMove: function(data) {
    this.createPiece(parseInt(data.row), parseInt(data.column), this.game.opponent.color);
  },
  
  onGameEnd: function(data) {
    $('<h3>Game Ended...</h3>').appendTo('#gameboard');
  },
  
  startGame: function() {
    $('<h2>Player Accepted! Starting Game...</h2>').appendTo('#gameboard');
    
    this.createGameBoard();
  },
  
  onBoardClick: function(e) {
    tthis = e.data;
    
    var x = e.pageX - this.offsetLeft;
  	var y = e.pageY - this.offsetTop;
  	
  	row = Math.round((y - tthis.board.top) / tthis.board.rowSize);
  	column = Math.round((x - tthis.board.left) / tthis.board.columnSize);
  	
  	tthis.createPiece(row, column, tthis.game.color);
  	
  	$.post('/games/' + tthis.game.id + '/moves', { row: row, column: column });
  }
  
};
