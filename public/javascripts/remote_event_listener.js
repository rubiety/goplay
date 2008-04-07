/***********************************************************
 * GoPlay!
 * 
 * Remote Event Listener
 * 
 * Author: Ben Hughes, ben -yaYt- railsgarden -daht- com
 * 
 * Dependencies: jQuery, jQuery.svg, Facebox
 * 
 * RemoteEventListener Class
 * --------
 * 
 * 
 * Example Usage
 * --------
 * 
 * remoteEvents = new RemoteEventListener('/events', {frequency: '1s'});
 * 
 **********************************************************/

var RemoteEventListener = function(url, options) {
  this.initialize(url, options);
};

RemoteEventListener.prototype = {
  
  initialize: function(url, options) {
    this.url = url;
    this.frequency = options.frequency || '1s';
    this.events = {};
    
    this.startEventPoller();
  },
  
  on: function(eventType, callback) {
    this.events[eventType] ? this.events[eventType].push(callback) : this.events[eventType] = [callback];
  },
  
  off: function(eventType, callback) {
    
  },
  
  startEventPoller: function() {
    $(this).everyTime(this.frequency, 'eventpoller', this.pollEvent);
  },
  
  pollEvent: function() {
    $.getJSON(this.url, function(events) {
      $.each(events, function(i, event) {
        
        for (eventType in this.events) {
          if (event.type == eventType) {
            for (callback in this.events[eventType]) {
              callback.call(event);
            }
          }
        }
      });
    });
  },
  
}