class Game
  constructor: (@resources, @events)->
    @state = new GameState @
    @reactor = new GameReactor @, @events



exp = exports ? this
exp.Game = Game

$(->
  # game = new Game( new ResourceState, new GameEvents)
  game = new Game(
    new ResourceState( minerals: 50, gas: 0, supply: 6, max_supply: 0 ),
    new GameEvents
  )

  reactor = game.reactor

  cc = Buildables.buildings["Command Center"]
  reactor.addCompleted new BuiltItem( start_time: 0, end_time: 0, buildable: cc )

  sd = Buildables.buildings["Supply Depot"]

  scv = Buildables.units["SCV"]

  for i in [1..6]
    reactor.addCompleted new BuiltItem( start_time: 0, end_time: 0, buildable: scv )


  for i in [1..10]
    game.events.add( new GameEvent( start_time: i*17, buildable: scv) )

  game.events.add( new GameEvent( start_time: 70, buildable: sd) )

  game.reactor.moveTo 120
)
