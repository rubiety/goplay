/***********************************************************
 * GoPlay!
 * 
 * Game Invites Client
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, jQuery.svg, Facebox
 * 
 * GameInvitesClient Class
 * --------
 * 
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
    this.addEventListeners();
  },
  
  addEventListeners: function() {
    this.listener.on('GameInviteEvent', onUserEntered);
  },
  
  onGameInvite: function(data) {
    
    // TODO: Refactor into something better:
    $('#' + invitesbox).append($(
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

