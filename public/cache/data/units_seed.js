// Generated by CoffeeScript 1.3.1
(function() {
  var TERRAN_BUILDINGS, TERRAN_SLOTS, TERRAN_UNITS, root;

  TERRAN_SLOTS = {
    "cc": {
      allows: ["SCV"]
    },
    "worker": {
      allows: ["Command Center", "Supply Depot", "Barracks"]
    },
    "barracks": {
      allows: ["Marine"]
    },
    "barracks techlab": {
      allows: ["Marine", "Marauder", "Reaper"]
    }
  };

  TERRAN_UNITS = {
    "SCV": {
      cost: [50, 0, 1],
      time: 17,
      slots: ["worker"],
      worker: true
    },
    "Marine": {
      cost: [50, 0, 1],
      time: 25
    },
    "Marauder": {
      cost: [100, 25, 2],
      time: 30
    }
  };

  TERRAN_BUILDINGS = {
    "Command Center": {
      cost: [400, 0, 0],
      time: 100,
      provides_supply: 11,
      slots: ["cc"]
    },
    "Supply Depot": {
      cost: [100, 0, 0],
      time: 30,
      provides_supply: 8
    },
    "Barracks": {
      cost: [150, 0, 0],
      time: 65,
      slots: ["barracks"]
    }
  };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.TERRAN_SLOTS = TERRAN_SLOTS;

  root.TERRAN_BUILDINGS = TERRAN_BUILDINGS;

  root.TERRAN_UNITS = TERRAN_UNITS;

}).call(this);
