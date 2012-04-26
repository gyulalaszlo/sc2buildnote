# The gameplay reactor class.
# This keeps spinning, processing events, one sec at a time.
class GameReactor

  # create a new GameReactor from the given Game
  constructor: (@game, @events, @time = 0)->
    @workers = []
    @slots = @events

    # every built item
    @items = []

    @resources = @game.resources # new ResourceState( minerals: 50, gas: 0, supply: 6, max_supply: 11 ) 
    @mining = new MiningReactor this

  # move to a given time, and process everything in between
  moveTo: (time)->
    @time = 0
    @running_production = []
    @nextTick() while @time < time



  # step forward one second
  nextTick: ->
    # @log "----- #{@time}s | ", @resources.log()
    @process_events_ending_at @time
    @process_events_starting_at @time

    # aggregate the mineral production
    @mining.mine @workers, @resources

    # advance the time
    @time += 1


  # add a completed item to the current state
  addCompleted: (item)->
    @items.push item

    # if its a buildable
    buildable = item.get 'buildable'
    console.log buildable
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
    starting_production = []

    # check if any slots have stuff started right now
    for slot in @slots.models
      # skip if the slot does not exists at the current time
      continue unless slot.isAvailableAt time
      starting_production.push slot.queue.where(starts_at: time)...

    # iterate over the started items
    for started_item in starting_production
      @process_buildable_event_start started_item



  # process a buildable's event
  # checks if costs & supply can be covered
  # then queues the production in the first available slot
  process_buildable_event_start: (started_item)->
    buildable = started_item.get 'buildable'
    can_build = false

    # stop if not enough resources
    unless @resources.can_cover buildable.cost
      @error "Not enough resources for ", started_item.log(), @resources.log()
      started_item.set can_be_built: false
      return false

    # deduct from the available resources
    @resources.deduct buildable.cost
    # signal that it's ok to build it
    started_item.set can_be_built: true

    # add to the running production collection
    @running_production.push started_item.cid
    @log "STARTING PRODUCTION | ", started_item.log()



  # process events helper
  process_events_ending_at: (time)->

    ending_production = []

    # check if any slots have stuff ended right now
    for slot in @slots.models
      # skip if the slot does not exists at the current time
      continue unless slot.isAvailableAt time
      ending_production.push slot.queue.where(ends_at: time)...


    # iterate over the ended items
    for ended_item in ending_production

      # skip the production ending if the item is not running
      if _(@running_production).indexOf( ended_item.cid ) == -1
        @error "cannot end production of not-queued #{ ended_item.log() }"
        return false

      @log "ENDING: ", ended_item.log()
      @addCompleted ended_item




  log: (message...)-> console.log "[GameReactor] ", message...

  error: (message...)-> console.error "[GameReactor] ", message...






exp = exports ? this
exp.GameReactor = GameReactor
