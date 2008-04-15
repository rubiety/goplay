/***********************************************************
 * GoPlay!
 * 
 * User List Client
 * 
 * Author: Ben Hughes, http://www.railsgarden.com/
 * Dependencies: jQuery, RemoteEventsListener, Facebox
 * 
 * UserListClient Class
 * ----------------------------------------
 * 
 * Handles updating of the list of active users through Ajax events.
 * Expected to be used with RemoteEventsListener.
 * 
 * Example Usage
 * ----------------------------------------
 * 
 * events = new RemoteEventsListener('/users/current/events');
 * new UserListClient('userslist', events);
 * 
 **********************************************************/

var UserListClient = function(usersbox, listener, options) {
  options = options || {};
  this.usersbox = usersbox;
  this.listener = listener;
  this.initialize();
};

UserListClient.prototype = {
  
  initialize: function() {
    this.registerEventListeners();
  },
  
  registerEventListeners: function() {
    this.listener.on('UserEnteredEvent', this.onUserEntered, this);
    this.listener.on('UserLeftEvent', this.onUserLeft, this);
  },
  
  onUserEntered: function(event) {
    data = event.payload;
    
    $('#' + this.usersbox).append($(
      '<div class="user" style="display: none" id="user_list_entry_' + data.source_user.id + '">' + 
      '  <img src="' + data.source_user.gravatar_url +' " />' +
      '  <span>' + data.source_user.name + '</span>' +
      '  ' + data.source_user.description +
      '  ' + '<br />' + 
      '  <a href="/games/new?height=400&width=600&opponent_id=' + data.source_user.id + '" title="Challenge ' + data.source_user.name + ' to Game" class="thickbox">Challenge to Game</a>' + 
      '  <br style="clear: both" />' + 
      '</div>'
    ));
    
    $("a[rel*=facebox]").facebox();
    
    $('#' + this.usersbox + ' #user_list_entry_' + data.source_user.id).fadeIn();
  },
  
  onUserLeft: function(event) {
    data = event.payload;
    
    $('#' + this.usersbox + ' #user_list_entry_' + data.source_user.id).fadeOut();
  }
  
};

