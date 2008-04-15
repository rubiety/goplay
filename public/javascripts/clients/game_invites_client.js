/***********************************************************
 * GoPlay!
 * 
 * Game Invites Client
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, RemoteEventsListener
 * 
 * GameInvitesClient Class
 * ----------------------------------------
 * 
 * Handles game invites by other users.  Dynamically fades in
 * dark boxes to notify the user that an invite has arrived.  Multiple 
 * invites at the same time are supported.  Meant to be used with GoClient 
 * and RemoteEventsListener.
 * 
 * Example Usage
 * ----------------------------------------
 * 
 * events = new RemoteEventsListener('/users/current/events');
 * new GameInvitesClient('inviteslist', events);
 * 
 **********************************************************/

var GameInvitesClient = function(invitesbox, listener, options) {
  options = options || {};
  this.invitesbox = invitesbox;
  this.listener = listener;
  this.initialize();
};

GameInvitesClient.prototype = {
  
  initialize: function() {
    this.registerEventListeners();
    this.rebindAcceptAndReject();
  },
  
  registerEventListeners: function() {
    this.listener.on('GameInviteEvent', this.onGameInvite, this);
  },
  
  rebindAcceptAndReject: function() {
    $('#' + this.invitesbox + ' .acceptlink').bind('click', this, this.onAcceptInvite);
    $('#' + this.invitesbox + ' .rejectlink').bind('click', this, this.onRejectInvite);
  },
  
  onGameInvite: function(event) {
    data = event.payload;
    
    $('#' + this.invitesbox).append($(
      '<div class="invite" style="display: none" id="invites_list_entry_' + data.source_user.id + '">' + 
      '  <img src="' + data.source_user.gravatar_url + '" />' +
      '  <h4>New Game Invitation</h4>' +
      '  <span>' + data.source_user.name + '</span>' +
      '  ' + data.source_user.description +
      '  ' + '<br />' + 
      '  <a class="acceptlink" id="accept_game_' + data.game.id + '" href="#">Accept Invite</a> | <a class="rejectlink" id="reject_game_' + data.game.id + '" href="#">Reject Invite</a>' + 
      '  <br style="clear: both" />' + 
      '</div>'
    ));
    
    $('#' + this.invitesbox + ' #invites_list_entry_' + data.game.id).fadeIn();
    
    this.rebindAcceptAndReject();
  },
  
  onAcceptInvite: function(e) {
    thisobj = e.data;
    game_id = this.id.replace('accept_game_', '');
    $.post('/games/' + game_id + '/accept');
    
    $('#' + thisobj.invitesbox + ' #invites_list_entry_' + game_id).fadeOut();
    $('#' + thisobj.invitesbox + ' #invites_list_entry_' + game_id).remove();
    
    window.open('/games/' + game_id)
  },
  
  onRejectInvite: function(e) {
    thisobj = e.data;
    game_id = this.id.replace('reject_game_', '');
    $.post('/games/' + game_id + '/reject');
    
    $('#invites_list_entry_' + game_id).fadeOut();
  }
  
};

