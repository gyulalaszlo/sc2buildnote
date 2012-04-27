# an item in a slot's queue
class SlotQueueItem extends Backbone.Model
  defaults:
    buildable: null
    starts_at: 0
    ends_at: 0
    can_be_built: false
    slots_created: false

  initialize: (attributes)->
    if attributes.starts_at
      @set
        ends_at: @attributes.starts_at + @attributes.buildable.time
    else
      # else they are already here
      @set starts_at: -1, ends_at: -1

  log: ()->
    "< #{@attributes.buildable.name}[#{@cid}] | #{@attributes.starts_at}s-#{@attributes.ends_at}s" +
      "#{ if !@attributes.can_be_built then ' | CANNOT BE BUILT!' else ''} >"


  create_slots: ()->
    return @slots if @attributes.slots_created

    self = @
    @slots = _( @attributes.buildable.slots() ).map (slot_key)->
      new Slot
        type: slot_key
        created_at: self.attributes.starts_at
        available_at: self.attributes.ends_at

    @set slots_created: true
    @slots



# the queue of a given slot, containing the production runs
class SlotQueue extends Backbone.Collection
  model: SlotQueueItem




# Production happens in slots
class Slot extends Backbone.Model
  defaults:
    type: null
    tags: []
    # time of putting this slot down
    created_at: 0
    # time this slot gets finished (is available to produce)
    available_at: 0

  initialize: (attrs)->
    @queue = new SlotQueue


  # is this Slot available at a given time? (has it
  # been created?)
  isAvailableAt: (time)->
    # has been created?
    return false if @attributes.available_at > time
    true

  # can this Slot produce at a given time? 
  # (has it been created?, is available & free)
  canProduceAt: (time)->
    return false unless @isAvailableAt( time )

    # is this slot currently producing
    for item in @queue.models
      return false if item.get('starts_at') < time < item.get('ends_at')

    true

  # get the SlotType object of this slot
  getType: -> SlotTypes.all.types[ @attributes.type ]

  queueBuild: (buildable, start_time)->
    @queue.add( new SlotQueueItem
      buildable: buildable
      starts_at: start_time
    )






# all the available slots
class Slots extends Backbone.Collection
  model: Slot



  queueBuild: (buildable, time)->
    for slot, i in @models
      slotType = slot.getType()

      if slotType.can_build(buildable) and slot.canProduceAt(time)
        slot.queueBuild buildable, time
        return true

    false

  # get the time the last production is finished
  # (the time of the build)
  lastProductionEnds: (buildable)->
    last = 1
    # the new production needs to happen at the time
    # or after the previous production started
    # globally, and must start at the first available moment
    slot_end_time = 1
    global_last_start_time = 1

    for slot, i in @models
      slotType = slot.getType()
      for item in slot.queue.models
        # get the start time
        start_time = item.get 'starts_at'
        global_last_start_time = start_time if global_last_start_time < start_time
        # get the end time
        if slotType.can_build(buildable)
          finish_time = item.get 'ends_at'
          slot_end_time = finish_time if slot_end_time < finish_time

    console.log "Last #{buildable.name} >> slot_end_time: @#{slot_end_time}s >> global_last_start_time: #{global_last_start_time}s"
    Math.max slot_end_time, global_last_start_time
    # Math.min slot_end_time, global_last_start_time + 1
    # slot_end_time







# PROTOTYPES FOR SLOTS AND PRODUCTION
# -----------------------------------

# a slot type prototype.
# Controls production
class SlotType
  constructor: (@name, @attributes)->
    @allows = @attributes.allows

  # can this slot type build the given Buildable?
  can_build: (buildable)->
    _(@allows).indexOf( buildable.key ) != -1


# a list of all the slot types
# get them via SlotTypes.all
class SlotTypes
  @all = new SlotTypes
  constructor: -> @types = {}
  add: (name, attributes)-> @types[name] =new SlotType name, attributes 




# Preload slots

for k,v of TERRAN_SLOTS
  SlotTypes.all.add k, v


# Preload buildables

Buildables.add_group 'units', TERRAN_UNITS
Buildables.add_group 'buildings', TERRAN_BUILDINGS

root = exports ? this
root.SlotQueueItem = SlotQueueItem
root.SlotQueue = SlotQueue
root.Slot = Slot
root.Slots = Slots
