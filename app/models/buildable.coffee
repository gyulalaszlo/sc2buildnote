
class Cost
  constructor: (@minerals, @gas=0, @supply=0)->


  # set the costs (or reset it if called without parameters)
  set: (@minerals=0, @gas=0, @supply=0)->

  toString: ->
    "M:#{@minerals} | G:#{@gas} | Supply: #{@supply}"

# A prototype for anything that can be built
class Buildable

  # create a new buildable
  # @name : name of this buildable
  constructor: (@name, @attributes={})->
    @provides_supply = 0
    # set the key to the name by default
    @key = @name
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
        # when 'slots'
        #   @add_slot( slot_name, slot_attribtues) for slot_name, slot_attribtues of v

  slots: -> @attributes.slots ? {}


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


exp = exports ? this
exp.Cost = Cost
# exp.BuiltItem = BuiltItem
exp.Buildable = Buildable
exp.Buildables = Buildables
