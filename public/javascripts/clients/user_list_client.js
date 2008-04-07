/***********************************************************
 * GoPlay!
 * 
 * User List Client
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, jQuery.svg, Facebox
 * 
 * UserListClient Class
 * --------
 * 
 * 
 **********************************************************/

var UserListClient = function(usersbox, listener, options) {
  options = options || {};
  this.usersbox = usersbox;
  this.listener = listener;
};

UserListClient.prototype = {
  
  initialize: function() {
    this.addEventListeners();
  },
  
  addEventListeners: function() {
    this.listener.on('UserEnteredEvent', onUserEntered);
    this.listener.on('UserLeftEvent', onUserLeft);
  },
  
  onUserEntered: function(data) {
    
    // TODO: Refactor into something better:
    $('#' + this.usersbox).append($(
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
    
    $('#' + this.usersbox + ' #user_list_entry_' + data.source_user.id).fadeIn();
  },
  
  onUserLeft: function(data) {
    $('#' + this.usersbox + ' #user_list_entry_' + data.source_user.id).fadeOut();
  }
  
};

