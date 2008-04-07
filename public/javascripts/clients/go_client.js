/***********************************************************
 * GoPlay!
 * 
 * Primary Game Board Controller
 * 
 * Author: Ben Hughes, http://www.railsgarden.com/
 * Dependencies: jQuery, RemoteEventsListener, jQuery.svg, Facebox
 * 
 * GoClient Class
 * ----------------------------------------
 * 
 * Implements an Ajax Go client with an SVG gameboard.  Meant 
 * to be used with RemoteEventListener.
 * 
 * Options for constructor:
 * - user: Details about the current user
 *   - id: Database ID of the current user
 *   - name
 *   - description
 * - game: An object of game details:
 *   - id: Database ID of the game
 *   - size: Number of the size of the square board
 *   - color: black or white (current user's player color)
 *   - opponent: Object representing the opponent
 *     - id
 *     - name
 *     - description
 *     - color
 * 
 * Example Usage
 * ----------------------------------------
 * 
 * events = new RemoteEventsListener('/users/current/events');
 * new GoClient('gameboard', events', {
 *   user: {
 *     id: 1,
 *     name: 'Ben Hughes',
 *     description: 'Developer of this application...'
 *   },
 *   game: {
 *     id: 3,
 *     size: 19,
 *     color: 'white',
 *     opponent: {
 *       id: 2,
 *       name: 'John Doe',
 *       description: 'Sample user of this application...',
 *       color: 'black'
 *     }
 *   }
 * });
 * 
 * NOTE: In the future much of the above data may be 
 * retrieved dynamically via Ajax rather than being specified
 * in-line.
 * 
 **********************************************************/

var GoClient = function(gamebox, listener, options) {
  options = options || {};
  this.board = { id: gamebox };
  this.listener = listener;
  this.user = options.user;
  this.game = options.game;
  
  this.board.size = this.game.size;
  
  this.initialize();
};

/*** Configuration ***/

GoClient.BOARD_HEIGHT = 440;
GoClient.BOARD_WIDTH = 440;
GoClient.BOARD_TOP = 30;
GoClient.BOARD_LEFT = 30;
GoClient.PIECE_RADIUS_DIVISOR = 2.4;


/*** Implementation ***/

GoClient.prototype = {
  
  initialize: function() {
    this.createGameBoard();
    this.registerEventListeners();
  },
  
  createGameBoard: function() {
    if (!this.game || !this.board || !this.board.id || this.svgboard) { return; }
    
    if (!this.board.width) { this.board.width = GoClient.BOARD_WIDTH; }
    if (!this.board.height) { this.board.height = GoClient.BOARD_HEIGHT; }
    if (!this.board.top) { this.board.top = GoClient.BOARD_TOP; }
    if (!this.board.left) { this.board.left = GoClient.BOARD_LEFT; }
    
    // Default rows and columns to size, could support non-square in future
    this.board.rows = this.board.size;
    this.board.columns = this.board.size;
    
    this.board.rowSize = this.board.height / (this.board.rows - 1);
    this.board.columnSize = this.board.width / (this.board.columns - 1);
    
    if (!this.board.pieceRadius) { this.board.pieceRadius = this.board.rowSize / GoClient.PIECE_RADIUS_DIVISOR; }
    
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
  
  registerEventListeners: function() {
    this.listener.on('GameInviteResponseEvent', this.onGameInviteResponse, this);
    this.listener.on('MoveEvent', this.onMove, this);
    this.listener.on('GameEndEvent', this.onGameEnd, this);
  },
  
  onGameInviteResponse: function(event) {
    data = event.payload;
    
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
  
  onMove: function(event) {
    data = event.payload;
    this.createPiece(parseInt(data.row), parseInt(data.column), this.game.opponent.color);
  },
  
  onGameEnd: function(event) {
    data = event.payload;
    $('<h3>Game Ended...</h3>').appendTo('#gameboard');
  },
  
  startGame: function(event) {
    data = event.payload;
    $('<h2>Player Accepted! Starting Game...</h2>').appendTo('#gameboard');
    
    this.createGameBoard();
  },
  
  onBoardClick: function(event) {
    tthis = event.data;
    
    var x = event.pageX - this.offsetLeft;
  	var y = event.pageY - this.offsetTop;
  	
  	row = Math.round((y - tthis.board.top) / tthis.board.rowSize);
  	column = Math.round((x - tthis.board.left) / tthis.board.columnSize);
  	
  	tthis.createPiece(row, column, tthis.game.color);
  	
  	$.post('/games/' + tthis.game.id + '/moves', { row: row, column: column });
  }
  
};
