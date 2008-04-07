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
  },
  
  registerEventListeners: function() {
    this.listener.on('GameInviteEvent', this.onGameInvite, this);
  },
  
  onGameInvite: function(event) {
    data = event.payload;
    
    $('#' + this.invitesbox).append($(
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
    
    $('#' + this.invitesbox + ' #invites_list_entry_' + data.source_user.id).fadeIn();
  }
  
};

