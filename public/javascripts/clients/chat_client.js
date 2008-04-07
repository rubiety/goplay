/***********************************************************
 * GoPlay!
 * 
 * Chat Client
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, jQuery.svg, Facebox
 * 
 * ChatClient Class
 * --------
 * 
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
    this.addEventListeners();
  },
  
  addEventListeners: function() {
    this.listener.on('MessageEvent', onMessage);
  },
  
  onMessage: function(data) {
    $('<div class="message"><span>' + data.sender.name + ':</span> ' + data.message + '</div>').appendTo('#messagelist');
    $('#' + this.chatbox).scrollTo('div:last');
  },
  
};
