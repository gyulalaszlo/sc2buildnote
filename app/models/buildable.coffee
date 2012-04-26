
class Cost
  constructor: (@minerals, @gas=0, @supply=0)->

# A prototype for anything that can be built
class Buildable

  # create a new buildable
  # @name : name of this buildable
  constructor: (@name, @attributes={})->
    @provides_supply = 0
    # set the key to the name by default
    @key = @name
    @builder = new BuilderProto @
    @parse @attributes


  # parse the attributes of the buildable from the seed
  parse: (attributes)->
    for k, v of attributes
      switch k

        # update the attributes
        when 'name' then @name = v
        when 'cost' then @cost = new Cost v[0], v[1], v[2]
        when 'time' then @time = parseInt v
        when 'provides_supply' then @provides_supply = parseInt v

        # add building slots
        when 'slots'
          @add_slot( slot_name, slot_attribtues) for slot_name, slot_attribtues of v

  # add a builder slot to this buildable
  # (slots build stuff)
  add_slot: (name, attributes)->
    slot = BuilderSlotProto.parse @, name, attributes
    @builder.push slot

  log: (msg...)->
    console.log "[Buildable]", msg...








# helpers class for storing any kind of buildable
class Buildables

  # append all the data from the given seed group (buildings, units, etc)
  @add_group: (group_name, group_data)->
    # create the new group
    Buildables[group_name] = {}

    group = Buildables[group_name]
    # iterate over all items
    for k, data of group_data
      buildable = new Buildable( k,  data )
      group[k] = buildable









# the Builder builds stuff
# it holds the list of slots for a Buildable
class BuilderProto
  # create a new Builder by specifying the parent Buildable
  constructor: (@buildable)->
    @slots = []

  # add a slot to this builder
  push: (slot)->
    @slots.push slot

  # can this builder build the given object?
  can_build: (buildable_key)->
    for slot in @slots
      return true if slot.can_build buildable_key
    false

  # check if anyhing is coming out of this Builders Slots
  # at the given time
  has_production_finishing_at: (time)->
    for slot in @slots
      return true if slot.has_production_finishing_at time
    false





# Builder Slots build anything
class BuilderSlotProto
  constructor: (@parent, @name, @allowed_units)->

  # can this slot build the given buildable?
  can_build: (buildable_key)->
    return false if @occupied
    _( @allowed_units ).indexOf( buildable_key ) != -1

  # parse the attributes and create a new slot
  @parse: (buildable, slot_name, attributes)->
    new BuilderSlotProto buildable, slot_name, attributes.builds







class BuilderInstance
  # create a new Builder by specifying the parent Buildable
  constructor: (@builder)->
    @slots = []
    for slot in @builder.slots
      @slots.push new BuilderSlotInstance slot, this

  # add a slot instance to this builder instance
  push: (slot_instance)->
    @slots.push slot_instance

  # can this builder build the given object?
  can_build: (buildable_key)->
    for slot in @slots
      return true if slot.can_build buildable_key
    false


  # try to queue the production into the given slot
  queue_production: (time, buildable)->
    for slot in @slots
      continue unless slot.can_build buildable.key
      slot.start_building time, buildable
      return true
    false


  # check if anyhing is coming out of this Builders Slots
  # at the given time
  has_production_finishing_at: (time)->
    for slot in @slots
      return true if slot.has_production_finishing_at time
    false


  # get all the finished products of this builder
  # as an array
  get_finished_product: (time)->
    results = []
    for slot in @slots
      # skip not yet finished production
      continue unless slot.has_production_finishing_at time
      # add the finished product to the results
      results.push slot.get_product( time )

    results








# The instance of a slot built to produce.
# (BuilderSlot is the prototype, that's shared across the instances)
class BuilderSlotInstance

  constructor: (@builder_slot, @builder_instance)->
    @occupied = false
    # the time the current production cycle comes to an end
    @production_started_at = 0
    @production_ends_at = 0
    # the stuff currently getting built in this slot
    @currently_building = null


  # can this slot build the given buildable?
  can_build: (buildable_key)->
    return false if @occupied
    _( @builder_slot.allowed_units ).indexOf( buildable_key ) != -1

  # start building a buildable
  # the function checks if the buildable can be built,
  # and ignores the build order if it cannot build
  start_building: (time, buildable)->
    # return if cannot build right now
    return unless @can_build buildable.key
    # schedule production
    @currently_building = buildable
    @production_started_at = time
    @production_ends_at = time + buildable.time

  # check if anyhing is coming out of this Slot
  # at the given time
  has_production_finishing_at: (time)->
    return false if @currently_building == null
    return false if @production_ends_at != time
    true

  # get the product at a given time
  get_product: (time)->
    return null unless @currently_building and @production_ends_at = time
    return new BuiltItem
      start_time: @production_started_at
      end_time: @production_ends_at
      buildable: @currently_building










# any item that's already built is represented by a BuiltItem
class BuiltItem extends Backbone.Model

  defaults:
    start_time: 0
    end_time: 0
    buildable: null
    builder: null

  # buildable: the buildable
  # start_time: start time in secs
  initialize: (attributes)->
    buildable = @get 'buildable'
    @set
      buildable: buildable
      # set the end time from the Buildable
      end_time: @attributes.start_time + buildable.time
      # create the slot instances
      builder: new BuilderInstance( buildable.builder )

  builder: -> @get 'builder'

  log: ->
    "[B] #{ @attributes.buildable.name } | #{ @attributes.start_time }s - #{@attributes.end_time} s"


exp = exports ? this
exp.Cost = Cost
exp.BuiltItem = BuiltItem
exp.Buildable = Buildable
exp.Buildables = Buildables
