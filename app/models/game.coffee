class Game
  constructor: (@resources, @slots)->
    @reactor = new GameReactor @, @slots



exp = exports ? this
exp.Game = Game
