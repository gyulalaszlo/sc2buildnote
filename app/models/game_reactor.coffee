# The gameplay reactor class.
# This keeps spinning, processing events, one sec at a time.
class GameReactor

  # create a new GameReactor from the given Game
  constructor: (@game, @events, @time = 0)->
    @workers = []

    # every built item
    @items = []

    @resources = @game.resources # new ResourceState( minerals: 50, gas: 0, supply: 6, max_supply: 11 ) 
    @mining = new MiningReactor this

  # move to a given time, and process everything in between
  moveTo: (time)->
    @time = 0
    @nextTick() while @time < time



  # step forward one second
  nextTick: ->
    @log "----- #{@time}s | ", @resources.log()

    # check all the production
    for item in @items
      if item.builder().has_production_finishing_at @time
        products = item.builder().get_finished_product @time
        # add the finished products to the list of items
        for product in products
          @addCompleted product 
          @log "PRODUCTION FINISHED -- #{product.log()}"

    # @process_events_ending_at @time
    @process_events_starting_at @time

    # aggregate the mineral production
    @mining.mine @workers, @resources
    
    console.log ''

    # advance the time
    @time += 1


  # add a completed item to the current state
  addCompleted: (item)->
    @items.push item

    # if its a buildable
    buildable = item.get 'buildable'
    if buildable != null
      # add it to the workers if necessary
      if buildable.attributes.worker
        @addWorker item

      # add the provided supply if necessary
      @resources.add_max_supply buildable.provides_supply



  # add a simple worker.
  # this function simply adds the worker, ignoring the resources.
  addWorker: (worker)->
    @workers.push worker
    @log "added worker", worker.log()


  # PRIVATE 
  # -------------------------------------------------

  # process events helper
  process_events_starting_at: (time)->
    # check if any events start at the current time
    starting = @game.events.where start_time: time
    # iterate over them
    for e in starting
      @process_buildable_event_start e if e.get('type') == GameEvent.BUILD



  # process a buildable's event
  # checks if costs & supply can be covered
  # then queues the production in the first available slot
  process_buildable_event_start: (e)->
    buildable = e.get 'buildable'
    can_build = false

    # stop if not enough resources
    unless @resources.can_cover buildable.cost
      @error "Not enough resources for ", e.log(), @resources.log()
      return false

    # deduct from the available resources
    @resources.deduct buildable.cost

    # can any builder build this right now?
    for item in @items
      builder = item.get 'builder'
      can_build = builder.queue_production @time, buildable
      # if we have queued it successfully
      break if can_build

    if can_build
      @log "STARTING PRODUCTION | ", e.log()
      return true
    else
      @error "No slots available for the production of", e.log()
      return false



  # process events helper
  process_events_ending_at: (time)->
    # check for events ending right now
    ending = @game.events.where end_time: time
    # iterate over them
    for e in ending
      @process_buildable_event_end e if e.get('type') == GameEvent.BUILD
      @log "ending: ", e.log()



  # process a buildable's completition
  process_buildable_event_end: (e)->
    # get the buildable
    buildable = e.get 'buildable'

    # create the built item
    built_item = new BuiltItem
      start_time: e.get('start_time')
      end_time: e.get('end_time')
      buildable: buildable

    # add it to the completed items
    @addCompleted built_item



  log: (message...)-> console.log "[GameReactor] ", message...

  error: (message...)-> console.error "[GameReactor] ", message...






exp = exports ? this
exp.GameReactor = GameReactor
