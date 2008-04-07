/***********************************************************
 * GoPlay!
 * 
 * Remote Event Listener
 * 
 * Author: Ben Hughes, http://www.railsgarden.com/
 * Dependencies: jQuery, jQuery.svg, Facebox
 * 
 * RemoteEventsListener Class
 * --------
 * 
 * 
 * Example Usage
 * --------
 * 
 * remoteEvents = new RemoteEventsListener('/events', {frequency: '1s'});
 * 
 **********************************************************/

var RemoteEventsListener = function(url, options) {
  this.initialize(url, options);
};

RemoteEventsListener.prototype = {
  
  initialize: function(url, options) {
    options = options || {};
    this.url = url;
    this.frequency = options.frequency || '1s';
    this.events = {};
    
    this.startEventPoller();
  },
  
  on: function(eventType, callback) {
    if (!this.events[eventType]) { this.events[eventType] = new Array(); }
    
    this.events[eventType].push(callback);
  },
  
  startEventPoller: function() {
    $(this).everyTime(this.frequency, 'eventpoller', this.pollEvent);
  },
  
  pollEvent: function() {
    $.getJSON(this.url, function(events) {
      $.each(events, function(i, event) {
        
        for (eventType in this.events) {
          if (event.type == eventType) {
            for (i = 0; i < this.events[eventType].length; i++) {
              this.events[eventType][i](event);
            }
          }
        }
      });
    });
  }
  
}