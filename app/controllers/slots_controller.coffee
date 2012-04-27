# A single item in a slot (something building at a certain time)
class SlotItemView extends Backbone.View
  tagName:  "li"
  template: _.template $('#slot-item-template').html()

  events:
    click: 'displayTooltip'

  initialize: ->

  # render this item
  render: ->
    @$el.html @template(@model.toJSON())
    @$el.css
      position: 'absolute'
      top: @model.get 'starts_at'
      height: @model.get('ends_at')- @model.get('starts_at')

    if !@model.get 'can_be_built'
      @$el.addClass 'error'
    @

  # show the build data of this SlotItem
  displayTooltip: ->
    console.log @model.log()


# The view of a slot in the timeline
class SlotView extends Backbone.View
  tagName:  "div"

  slotItems: ->
    $('.slot-items', @$el)

  template: _.template $('#slot-template').html()


  initialize: ->
    @model.bind 'change', @render, this
    @model.bind 'destroy', @remove, this


    @model.queue.bind('add', @addOne, this)
    @model.queue.bind('reset', @addAll, this)
    @model.queue.bind('all', @render, this)


  render: ->
    @$el.html @template(@model.toJSON())
    @$el.addClass 'slot-block'
    @addAll()
    @
    # this.$el.toggleClass('done', this.model.get('done'));
    # this.input = this.$('.edit');
    # return this;

  addOne: (item)->
    view = new SlotItemView model: item
    @slotItems().append( view.render().el )

  # add all the slot builds to this queue
  addAll: ()->
    # call the update function in the context of this
    # object
    @model.queue.each( @addOne, @ )






# All the slots in the timeline
class SlotsView extends Backbone.View
  el: $('#main')

  slotlist: -> $('#slot-list')

  initialize: (@slots)->
    @slots.bind('add', this.addOne, this)
    @slots.bind('reset', this.addAll, this)
    @slots.bind('all', this.render, this)

  # render all slots
  render: ->
    if @slots.length
      # console.log ("has slots")
    else
      # console.log("has no slots")

  addOne: (slot)->
    view = new SlotView model: slot
    @slotlist().append( view.render().el )

  addAll: ()->
    @slots.each( @addOne )




# init code
#

$(->
  slots = new Slots

  App = new SlotsView(slots)


  game = new Game(
    new ResourceState( minerals: 50, gas: 0, supply: 0, max_supply: 0 ),
    slots
  )

  game.reactor.setDefaultItems [
    new SlotQueueItem( buildable: Buildables.buildings[ "Command Center"] ),
    new SlotQueueItem( buildable: Buildables.units.SCV ),
    new SlotQueueItem( buildable: Buildables.units.SCV ),
    new SlotQueueItem( buildable: Buildables.units.SCV ),
    new SlotQueueItem( buildable: Buildables.units.SCV ),
    new SlotQueueItem( buildable: Buildables.units.SCV ),
    new SlotQueueItem( buildable: Buildables.units.SCV )
  ]

  game.reactor.reset()

  depot = Buildables.buildings[ "Supply Depot" ]
  barracks = Buildables.buildings[ "Barracks" ]
  scv = Buildables.units.SCV
  marine = Buildables.units.Marine
  # slots.queueBuild Buildables.buildings[ "Supply Depot" ], 80

  for item,i in [ scv, scv, scv, depot, scv, scv, scv, barracks, scv, scv, scv, marine, scv, scv   ]
    game.reactor.tryToQueue item

  # for i in [0..6]
  #   game.reactor.tryToQueue Buildables.units.SCV, 10 + i

  # for i in [0..6]
  #   game.reactor.tryToQueue Buildables.units.SCV, 10 + i

  # game.reactor.tryToQueue depot, 60

  game.reactor.debug = true
  game.reactor.reset()
  game.reactor.moveTo 200

)
