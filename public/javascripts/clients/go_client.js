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
 * new GoClient('gameboard', events', { game_id: 1 });
 * 
 **********************************************************/

var GoClient = function(gamebox, listener, options) {
  this.initialize(gamebox, listener, options);
};

/*** Configuration ***/

GoClient.BOARD_HEIGHT = 440;
GoClient.BOARD_WIDTH = 440;
GoClient.BOARD_TOP = 30;
GoClient.BOARD_LEFT = 30;
GoClient.PIECE_RADIUS_DIVISOR = 2.4;


/*** Implementation ***/

GoClient.prototype = {
  
  initialize: function(gamebox, listener, options) {
    options = options || {};
    this.game_id = options.game_id;
    this.board_id = options.board_id;
    this.color = options.color;
    this.board = { id: gamebox };
    this.listener = listener;
    
    this.active = true;
    this.captures = 0;
    
    thisobj = this;
    
    $.getJSON(this.gameUrl(), function(info) {
      thisobj.game = info.game;
      thisobj.user = info.user;
      thisobj.opponent = info.opponent;
      thisobj.myTurn = info.my_turn;
      
      thisobj.registerEventListeners();
      
      if (info.status != 'Created') {
        thisobj.createGameBoard();
      }
    });
  },
  
  gameUrl: function() {
    return '/games/' + this.game_id;
  },
  
  registerEventListeners: function() {
    this.listener.on('GameInviteResponseEvent', this.onGameInviteResponse, this);
    this.listener.on('MoveEvent', this.onMove, this);
    this.listener.on('GameEndEvent', this.onGameEnd, this);
    
    $(window).bind('unload', this.game_id, this.onUnload);
  },
  
  createGameBoard: function() {
    if (!this.game || !this.board_id || this.svgboard) { return false; }
    
    this.board = {};
    
    if (!this.board.width) { this.board.width = GoClient.BOARD_WIDTH; }
    if (!this.board.height) { this.board.height = GoClient.BOARD_HEIGHT; }
    if (!this.board.top) { this.board.top = GoClient.BOARD_TOP; }
    if (!this.board.left) { this.board.left = GoClient.BOARD_LEFT; }
    
    // Default rows and columns to size, could support non-square in future
    this.board.rows = this.game.board_size;
    this.board.columns = this.game.board_size;
    
    this.board.rowSize = this.board.height / (this.board.rows - 1);
    this.board.columnSize = this.board.width / (this.board.columns - 1);
    
    if (!this.board.pieceRadius) { this.board.pieceRadius = this.board.rowSize / GoClient.PIECE_RADIUS_DIVISOR; }
    
    $('#' + this.board_id + ' #svgboard').svg();
    this.svgboard = svgManager.getSVGFor('#' + this.board_id + ' #svgboard');
    
    // Construct Row & Column Lines
    for (i = 0; i < this.board.rows; i++) {
      this.svgboard.line(null, this.board.top, this.board.top + this.board.rowSize * i, this.board.top + this.board.width, this.board.top + this.board.rowSize * i, {stroke: 'black', stroke_width: 1});
    }
    
    for (i = 0; i < this.board.columns; i++) {
      this.svgboard.line(null, this.board.left + this.board.columnSize * i, this.board.left, this.board.left + this.board.columnSize * i, this.board.left + this.board.height, {stroke: 'black', stroke_width: 1});
    }
    
    // Initialize Click Listener
    $('#' + this.board_id + ' #svgboard').bind('click', this, this.onBoardClick);
    
    // Show Turn Status
    this.updateTurn();
    
    // Initialize Game Board from Piece Information
    for (i = 0; i < this.game.grid.length; i++) {
      row = this.game.grid[i];
      
      for (j = 0; j < row.length; j++) {
        cell = row[j];
        if (cell) {
          this.createPiece(i, j, cell);
        }
      }
    }
  },
  
  createPiece: function(row, column, color) {
    this.svgboard.circle(null, this.board.left + this.board.columnSize * column, this.board.top + this.board.rowSize * row, this.board.pieceRadius, {id: 'stone_' + row + '_' + column, fill: color, stroke: 'black', stroke_width: 2});
  },
  
  removePiece: function(row, column) {
    $('#' + this.board_id + ' #svgboard #stone_' + row + '_' + column).remove();
  },
  
  onGameInviteResponse: function(e) {
    data = e.payload;
    
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
  
  onMove: function(e) {
    data = e.payload;
    
    this.createPiece(parseInt(data.row), parseInt(data.column), this.opponent.color);
    
    this.toggleTurn();
    this.updateTurn();
  },
  
  onGameEnd: function(e) {
    data = e.payload;
    
    $('#' + this.board_id + ' #controls #status').text("Game Ended: " + data.completed_status);
    this.active = false;
  },
  
  startGame: function(e) {
    this.createGameBoard();
    this.active = true;
  },
  
  onBoardClick: function(e) {
    thisobj = e.data;
    
    // Only allow click if game is active and it is my turn
    if (!thisobj.active || !thisobj.myTurn) { return; }
    
    // Find the column and row clicked
    var x = e.pageX - this.offsetLeft;
  	var y = e.pageY - this.offsetTop;
  	row = Math.round((y - thisobj.board.top) / thisobj.board.rowSize);
  	column = Math.round((x - thisobj.board.left) / thisobj.board.columnSize);
  	
  	// Return if row or column is out of bounds
  	if (row >= thisobj.game.rowSize || column >= thisobj.game.columnSize) { return true; }
  	
  	$.post('/games/' + thisobj.game_id + '/moves', { row: row, column: column }, function(data) {
  	  
  	  if (data.errors.length == 0) {
  	    thisobj.createPiece(row, column, thisobj.color);
  	    
  	    thisobj.toggleTurn();
    	  thisobj.updateTurn();
    	  
    	  for (i = 0; i < data.captures.length; i++) {
    	    capture = data.captures[i];
    	    thisobj.pieceCaptured(capture.row, capture.column)
    	  }
    	  
    	  thisobj.flash();
    	  
    	} else {
    	  thisobj.flash(data.errors);
    	}
    	
  	}, 'json');
  },
  
  pieceCaptured: function(row, column) {
    thisobj.removePiece(row, column);
    this.captures++;
    
    $('#' + this.board_id + ' #controls #captures').text('Captures: ' + this.captures);
  },
  
  flash: function(errors) {
    $('#message_block > div').remove();
    
    if (errors && errors.length > 0) {
      $('#message_block').append('<div style="display: none" class="container error" />');
      $('#message_block > div.error').append('<ul />');
      
      for (i = 0; i < errors.length; i++) {
        $('#message_block > div.error > ul').append('<li>' + errors[0] + '</li>')
      }
      
      $('#message_block > div.error').fadeIn();
    }
  },
  
  toggleTurn: function() {
    this.myTurn = (this.myTurn) ? false : true;
  },
  
  updateTurn: function() {
    if (this.myTurn) {
      $('#' + this.board_id + ' #controls #status').text("Your Turn!");
    } else {
      $('#' + this.board_id + ' #controls #status').text("Opponent's Turn");
    }
  },
  
  onUnload: function(e) {
    return true;
    
    if (confirm('You are about to leave this game.  This will cause you to forfeit to your opponent.  Are you sure you want to do this?')) {
      $.post('/games/' + e.data + '/leave', {});
      return true;
    } else {
      e.stopPropagation();
      e.preventDefault();
      return false;
    }
  }
  
};
