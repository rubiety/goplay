/***********************************************************
 * GoPlay!
 * 
 * Chat Client
 * 
 * Author: Ben Hughes, http://www.railsgarden.com/
 * Dependencies: jQuery, RemoteEventsListener
 * 
 * ChatClient Class
 * ----------------------------------------
 * 
 * A basic implementation of a chat client that receives Ajax 
 * events to update the UI when a message is received.  Meant to be used 
 * with RemoteEventsListener.
 * 
 * Example Usage
 * ----------------------------------------
 * 
 * events = new RemoteEventsListener('/users/current/events');
 * new ChatClient('messageslist', events);
 * 
 **********************************************************/

var ChatClient = function(chatbox, listener, options) {
  options = options || {};
  this.chatbox = chatbox;
  this.listener = listener;
  this.initialize();
};

ChatClient.prototype = {
  
  initialize: function() {
    this.registerEventListeners();
  },
  
  registerEventListeners: function() {
    this.listener.on('MessageEvent', this.onMessage, this);
  },
  
  onMessage: function(event) {
    data = event.payload;
    $('<div class="message"><span>' + data.sender.name + ':</span> ' + data.message + '</div>').appendTo('#' + this.chatbox);
    $('#' + this.chatbox).scrollTo('div:last');
  }
  
};
