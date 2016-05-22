require "defines"
require "common.helpers"

local debug_mode = false
local timed_coroutines = {}
local timed_sequences = {}
local tick_handlers = {}
local one_time_tick_handlers = {}
local named_gui_click_handlers = {}
local other_handlers = {}

---
--- Performs subscription of 'handlers' array to the 'event' notifications
---
local function subscribe( event, handlers )
  script.on_event(
    event,
    function ( event )
      for _, handler in ipairs( handlers ) do
        local result, error = pcall( handler, event )
        if not result then
          prnt( error )
        end
      end
    end
  )
end

---
--- Performs subscription to 'on_gui_click' event
---
local function subscribe_gui_click_event()
  script.on_event(
    defines.events.on_gui_click,
    function ( event )
      local named_handler = named_gui_click_handlers[ event.element.name ]
      if named_handler then
          named_handler( event )
      end
    end
  )
end

---
--- Performs subscription to 'on_tick' event
---
local function subscribe_tick_event()
  script.on_event(
    defines.events.on_tick,
    function ( event )

      --  Process recurrent handlers
      for _, tick_handler in ipairs( tick_handlers ) do
        tick_handler.countdown = tick_handler.countdown - 1
        if tick_handler.countdown <= 0 then
          tick_handler.handler( event )
          tick_handler.countdown = tick_handler.interval
        end
      end

      --  Process one_time handlers
      local expired_indices = {}
      for index, tick_handler in ipairs( one_time_tick_handlers ) do
        tick_handler.countdown = tick_handler.countdown - 1
        if tick_handler.countdown <= 0 then
          tick_handler.handler( event )
          table.insert( expired_indices, index )
        end
      end
      --  Remove expired one-time handlers
      for i = #expired_indices, 1, -1 do
        table.remove( one_time_tick_handlers, expired_indices[i] )
      end

      --  Process timed sequences
      expired_indices = {}
      for index, sequence in ipairs( timed_sequences ) do
        sequence.countdown = sequence.countdown - 1
        if sequence.countdown <= 0 then
          local result = sequence[sequence.current].handler( event )
          if type( result ) == "number" then
            sequence.countdown = result
          elseif result == false then
            table.insert( expired_indices, index )
          elseif result == nil then
            if sequence.current < #sequence then
              sequence.current = sequence.current + 1
              sequence.countdown = sequence[sequence.current].interval
            else
              table.insert( expired_indices, index )
            end
          end
        end
      end
      --  Remove expired sequences
      for i = #expired_indices, 1, -1 do
        table.remove( timed_sequences, expired_indices[i] )
      end

      --  Process coroutines
      expired_indices = {}
      for index, handler in ipairs( timed_coroutines ) do
        handler.countdown = handler.countdown - 1
        if ( handler.countdown <= 0 ) then
          local thread = handler.thread
          if debug_mode then prnt( "[EM]: Executing coroutine " .. tostring( thread ) ) end
          local result, cowntdown = coroutine.resume(thread)
          if result and coroutine.status( thread ) ~= "dead" then
            handler.countdown = cowntdown or 1
            if debug_mode then prnt( "[EM]: Coroutine " .. tostring( thread ) .. " will be resumed in " .. tostring( countdown ) .. " ticks") end
          else
            table.insert( expired_indices, index )
            if debug_mode then prnt( "[EM]: Coroutine " .. tostring( thread ) .. " has finished execution" ) end
          end
        end
      end
      --  Remove expired sequences
      for i = #expired_indices, 1, -1 do
        table.remove( timed_coroutines, expired_indices[i] )
      end

    end
  )
end

---
--- The event_manager itself
---
event_manager = {

  ---
  --- Constructs an EventManager singleton
  ---
  init = function ()
    subscribe_gui_click_event()
    subscribe_tick_event()
  end,

  ---
  --- Subscribes 'handler' to receive notifications about the 'event'
  --- TODO: Prevent multiple subscriptions of the same handler
  ---
  on = function ( event, handler )

--    prnt( "Subscribing to event " .. tostring( event ) .. ", handler: " .. tostring( handler ) )

    --  Perform checks

    if not event then
      prnt( "No event to subscribe to" )
      return
    end

    if event == defines.events.on_tick then
      prnt( "Use on_tick() to subscribe to 'on_tick' event" )
      return
    end

    if event == defines.events.on_gui_click then
      prnt( "Use on_gui_click() to subscribe to 'on_gui_click' event" )
      return
    end

    if not handler then
      prnt( "No handler to subscribe to an event" )
      return
    end

    --  Perform subscription

    local handlers = other_handlers[event]
    if not handlers then
      handlers = {}
      subscribe( event, handlers )
      other_handlers[event] = handlers
    end

    table.insert( handlers, handler )
    return handler
  end,

  ---
  --- Subscribes 'handler' to receive notifications about the 'on_tick'
  ---
  on_tick = function( interval, handler )
--    prnt( "Subscribing to on_tick, handler: " .. tostring( handler ) .. ", interval: " .. tostring( interval ) )
    if type (interval) == "function" then
      handler = interval
      interval = 1
    end
    if not handler then
      prnt( "No handler to subscribe to an event" )
      return
    end
    table.insert( tick_handlers, { handler = handler, interval = interval, countdown = interval } )
    return handler
  end,

  ---
  --- Subscribes 'handler' to receive notifications about the 'on_tick'
  ---
  execute_later = function( interval, handler )
    if type( interval ) == "function" then
      handler = interval
      interval = 1
    end
    if not handler then
      prnt( "No handler to subscribe to an event" )
      return
    end
    table.insert( one_time_tick_handlers, { handler = handler, interval = interval, countdown = interval } )
    return handler
  end,

  ---
  --- Subscribes 'handler' to receive notifications about the 'on_tick'
  ---
  execute_sequence = function( sequence )
    --  Initialize actions sequence
    local timed_sequence = { current = 1 }
    local interval = 0
    for _, item in ipairs( sequence ) do
      local item_type = type( item )
      if item_type == "function" then
        table.insert( timed_sequence, { interval = (interval > 0) and interval or 1, handler = item } )
        interval = 0
      elseif item_type == "number" then
        interval = interval + item
      end
    end

    --  Add sequence for execution
    if #timed_sequence > 0 then
      timed_sequence.countdown = timed_sequence[1].interval
      timed_sequence.current = 1
      table.insert( timed_sequences, timed_sequence )
    end
  end,

  ---
  --- Executes a coroutine. Each 'yield <interval>' postpones the coroutine execution to <interval> ticks.
  ---
  execute_coroutine = function( handler )
    table.insert( timed_coroutines, { thread = coroutine.create( handler ), countdown = 1 } )
  end,

  ---
  --- Subscribes 'handler' to receive notifications about the 'on_gui_click'
  ---
  on_gui_click = function( element_name, handler )
--    prnt( "Subscribing to 'on_gui_click', element_name: " .. element_name .. ", handler: " .. tostring( handler ) )
    if not element_name then
      prnt( "No element_name to subscribe to" )
      return
    end
    if not handler then
      prnt( "No handler to subscribe to an event" )
      return
    end
    named_gui_click_handlers[element_name] = handler
  end,

  ---------------------------------------------------------------------------

  ---
  --- Unsubscribes previously registered 'handler' from 'event' notifications
  ---
  clear = function ( event, handler )
--    prnt( "Unsubscribing from event " .. tostring( event ) .. ", handler: " .. tostring( handler ) )
    local handlers = other_handlers[event]
    if handlers then
      array_remove( handlers, handler )
    end
  end,

  ---
  --- Unsubscribes previously registered 'handler' from 'on_tick' notifications
  ---
  clear_on_tick = function ( handler )
--    prnt( "Unsubscribing from 'on_tick', handler: " .. tostring( handler ) )
    for index, tick_handler in ipairs( tick_handlers ) do
      if tick_handler.handler == handler then
        table.remove( tick_handlers, index )
      end
    end
  end,

  ---
  --- Unsubscribes previously registered 'handler' from 'on_gui_click' notifications
  ---
  clear_on_gui_click = function ( element_name )
--    prnt( "Unsubscribing from 'on_gui_click', element_name: " .. tostring( element_name ) )
    named_gui_click_handlers[ element_name ] = nil
  end,

}
