/***********************************************************
 * GoPlay!
 * 
 * Remote Event Listener
 * 
 * Author: Ben Hughes, http://www.railsgarden.com/
 * Dependencies: jQuery
 * 
 * RemoteEventsListener Class
 * ----------------------------------------
 * 
 * Implements the "Observable" pattern for observing remote (Ajax) events.  
 * Masks the request-response nature of HTTP by polling for remote events 
 * at a predefined interval and handing invoking one or more callbacks 
 * for each event registered with the "on" method. 
 * 
 * Takes a URL that is expected to return a JSON array, each element of which 
 * must have a "type" attribute representing the type of event being returned.
 * The entire event object is handed off to the callback, so any other data 
 * is simply passed on.
 * 
 * Each type can support more than one handler, so multiple objects can listen
 * for the same event and be executed in the sequence that the handler was 
 * specified.
 * 
 * Note that for now adding an event listener requires specifying a context 
 * as the third argument (typically this from the caller).  In the future 
 * this will support function encapsulation with closures ala 
 * bindAsEventListener from Prototype.
 * 
 * Example Usage
 * ----------------------------------------
 * 
 * function onMessage(event) {
 *   
 * }
 * 
 * events = new RemoteEventsListener('/events', {frequency: '1s'});
 * events.on('MessageEvent', onMessage, this);
 * 
 **********************************************************/

var RemoteEventsListener = function(url, options) {
  this.initialize(url, options);
};

RemoteEventsListener.prototype = {
  
  initialize: function(url, options) {
    options = options || {};
    this.url = url;
    this.frequency = options.frequency || '3s';
    this.listeners = {};
    this.logEvents = options.logEvents || true;
    this.events = [];
    
    this.startEventPoller();
  },
  
  on: function(eventType, callback, context) {
    context = context || window;
    
    if (!this.listeners[eventType]) { this.listeners[eventType] = new Array(); }
    
    this.listeners[eventType].push({callback: callback, context: context});
  },
  
  startEventPoller: function() {
    $(this).everyTime(this.frequency, 'eventpoller', this.pollEvent);
  },
  
  pollEvent: function() {
    thisobj = this;
    
    // Get JSON array from URL...
    $.getJSON(this.url, function(events) {
      $.each(events, function(i, event) {
        // Log Event
        if (thisobj.logEvents) {
          thisobj.events.push(event);
        }
        
        // For each event type...
        for (eventType in thisobj.listeners) {
          if (event.type == eventType) {
            
            // For each event handler...
            for (i = 0; i < thisobj.listeners[eventType].length; i++) {
              entry = thisobj.listeners[eventType][i];
              entry.callback.call(entry.context, event);
            }
          }
        }
        
      });
    });
  }
  
}