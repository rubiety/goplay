/***********************************************************
 * GoPlay!
 * 
 * Primary Game Board Controller
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, ThickBox
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
 * - game: An object of game details:
 *   - id: Database ID of the game
 *   - size: Number of the size of the square board
 * 
 **********************************************************/

var GoGame = function(options) {
  this.board = options.board;
  this.chatbox = options.chatbox;
  this.console = options.console;
  this.game = options.game;
  this.initialize();
};

GoGame.prototype = {
  
  initialize: function() {
    this.title = 'Go Game';
    this.author = 'Ben Hughes';
    
    this.startEventPoller();
  },
  
  startEventPoller: function() {
    $(this).everyTime('2s', 'eventpoller', this.pollEvent);
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
      '  <script language="JavaScript">tb_init("a.thickbox, area.thickbox, input.thickbox");</script>' +
      '</div>'
    ));
    
    $('#user_list_entry_' + data.source_user.id).fadeIn('normal');
  },
  
  onUserLeft: function(data) {
    $('#userslist #user_list_entry_' + data.source_user.id).fadeOut('normal');
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
    
    $('#invites_list_entry_' + data.source_user.id).fadeIn('normal');
  },
  
  onGameInviteResponse: function(data) {
    switch (data.response) {
      case 'Accepted':
        $('#invitee').fadeOut('normal');
        this.startGame();
        break;
        
      case 'Rejected':
        $('#invitee').fadeOut('fast');
        $('#rejectedinvite').fadeIn('fast');
        break;
    }
  },
  
  onMove: function(data) {
    $('<h3>Move Made...</h3>').appendTo('#gameboard');
  },
  
  onGameEnd: function(data) {
    $('<h3>Game Ended...</h3>').appendTo('#gameboard');
  },
  
  startGame: function() {
    $('<h2>Player Accepted! Starting Game...</h2>').appendTo('#gameboard');
  }
  
};
