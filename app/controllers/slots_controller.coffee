# A single item in a slot (something building at a certain time)
class SlotItemView extends Backbone.View
  tagName:  "li"
  template: _.template $('#slot-item-template').html()

  initialize: ->

  render: ->
    @$el.html @template(@model.toJSON())
    @$el.css
      position: 'absolute'
      top: @model.get 'starts_at'
      height: @model.get('ends_at')- @model.get('starts_at')
    @


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
      console.log ("has slots")
    else
      console.log("has no slots")

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

  wslot =  new Slot type: "cc" 
  slots.add wslot

  bslot =  new Slot type: "barracks" 
  slots.add bslot
  slots.add( new Slot type: "worker" )


  for i in [1..6]
    wslot.queue.add( new SlotQueueItem 
      buildable: Buildables.units.SCV
      starts_at: i * 18
    )

  # for i in [1..6]
  #   bslot.queue.add( new SlotQueueItem 
  #     buildable: Buildables.units.Marine
  #     starts_at: i * 26
  #   )





  # game = new Game( new ResourceState, new GameEvents)
  game = new Game(
    new ResourceState( minerals: 250, gas: 0, supply: 6, max_supply: 11 ),
    slots
  )

  game.reactor.moveTo 120

)
