/***********************************************************
 * GoPlay!
 * 
 * Ping Client
 * 
 * Author: Ben Hughes, http://www.railsgarden.com/
 * Dependencies: jQuery, RemoteEventsListener
 * 
 * PingClient Class
 * ----------------------------------------
 * 
 * A basic implementation of a "ping client" which will ping the 
 * server at regular intervals to notify the server of alive status. 
 * This is useful on pages where event polling is not done so that 
 * the server is still aware we are "connected".
 * 
 * Example Usage
 * ----------------------------------------
 * 
 * new PingClient('/users/current/ping', '20s');
 * 
 **********************************************************/

var PingClient = function(url, frequency) {
  this.initialize(url, frequency);
}

PingClient.prototype = {
  
  initialize: function(url, frequency) {
    this.url = url;
    this.frequency = frequency || '20s';
    
    $(this).everyTime(this.frequency, 'pinger', this.ping);
  },
  
  ping: function() {
    $.post(this.url, {});
  }
  
}