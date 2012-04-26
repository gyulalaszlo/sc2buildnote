TERRAN_SLOTS =
  "worker":
    allows: ["Command Center", "Supply Depot"]

  "barracks":
    allows: ["Marine"]

  "barracks techlab":
    allows: ["Marine", "Marauder", "Reaper"]


TERRAN_UNITS =
  "SCV":
    cost: [50, 0, 1]
    time: 17
    slots: ["worker"]

  "Marine":
    cost: [50, 0, 1]
    time: 25

  "Marauder":
    cost: [100, 25, 2]
    time: 30


TERRAN_BUILDINGS =
  "Command Center":
    cost: [400, 0, 0]
    time: 100
    provides_supply: 11
    slots: ["worker"]

  "Supply Depot":
    cost: [100, 0, 0]
    time: 30
    provides_supply: 8

  "Barracks":
    cost: [150, 0, 0]
    time: 65
    slots: ["barracks"]


root = exports ? this
root.TERRAN_SLOTS = TERRAN_SLOTS
root.TERRAN_UNITS = TERRAN_UNITS
