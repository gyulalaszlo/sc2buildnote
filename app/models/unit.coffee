# an item in a slot's queue
class SlotQueueItem extends Backbone.Model
  defaults:
    buildable: null
    starts_at: 0
    ends_at: 0
    can_be_built: false

  initialize: ()->
    @set
      ends_at: @attributes.starts_at + @attributes.buildable.time

  log: ()->
    "< #{@attributes.buildable.name} | #{@attributes.starts_at}s-#{@attributes.ends_at}s >"


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

  # get the SlotType object of this slot
  getType: -> SlotTypes.all[ @attributes.type ]





# all the available slots
class Slots extends Backbone.Collection
  model: Slot




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

root = exports ? this
root.SlotQueueItem = SlotQueueItem
root.SlotQueue = SlotQueue
root.Slot = Slot
root.Slots = Slots
