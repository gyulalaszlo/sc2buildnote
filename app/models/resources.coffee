class ResourceState extends Backbone.Model

  defaults:
    minerals: 0
    gas: 0
    supply: 0
    max_supply: 0

  initialize: ->
    #

  # deduct the costs of something from the
  # available resources
  deduct: (cost)->
    @set
      minerals: @attributes.minerals - cost.minerals
      gas: @attributes.gas - cost.gas
      supply: @attributes.supply + cost.supply

  # add the income from something to the
  # available resources
  add: (cost)->
    @set
      minerals: @attributes.minerals + cost.minerals
      gas: @attributes.gas + cost.gas

  # add to the available max supplies
  add_max_supply: (supply)->
    @set
      max_supply: @attributes.max_supply + supply


  # returns true if the given costs can be satisfied
  # with the resources available in this ResourceState
  can_cover: (cost)->
    return false if @attributes.minerals < cost.minerals 
    return false if @attributes.gas < cost.gas
    return false if @attributes.max_supply < (@attributes.supply + cost.supply)
    true


  log: ->
    "Minerals: #{@get 'minerals'} | Gas: #{@get 'gas' } | Supply: #{@get 'supply' } / #{@get 'max_supply'}"


exp = exports ? this
exp.ResourceState = ResourceState
