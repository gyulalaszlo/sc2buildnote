// Generated by CoffeeScript 1.3.1
(function() {
  var App, SlotItemView, SlotView, SlotsView, bslot, i, slots, wslot, _i, _j,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  SlotItemView = (function(_super) {

    __extends(SlotItemView, _super);

    SlotItemView.name = 'SlotItemView';

    function SlotItemView() {
      return SlotItemView.__super__.constructor.apply(this, arguments);
    }

    SlotItemView.prototype.tagName = "li";

    SlotItemView.prototype.template = _.template($('#slot-item-template').html());

    SlotItemView.prototype.initialize = function() {};

    SlotItemView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.css({
        position: 'absolute',
        top: this.model.get('starts_at'),
        height: this.model.get('ends_at') - this.model.get('starts_at')
      });
      return this;
    };

    return SlotItemView;

  })(Backbone.View);

  SlotView = (function(_super) {

    __extends(SlotView, _super);

    SlotView.name = 'SlotView';

    function SlotView() {
      return SlotView.__super__.constructor.apply(this, arguments);
    }

    SlotView.prototype.tagName = "div";

    SlotView.prototype.slotItems = function() {
      console.log($('.slot-items', this.el));
      return $('.slot-items', this.$el);
    };

    SlotView.prototype.template = _.template($('#slot-template').html());

    SlotView.prototype.initialize = function() {
      this.model.bind('change', this.render, this);
      this.model.bind('destroy', this.remove, this);
      this.model.queue.bind('add', this.addOne, this);
      this.model.queue.bind('reset', this.addAll, this);
      return this.model.queue.bind('all', this.render, this);
    };

    SlotView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.addAll();
      return this;
    };

    SlotView.prototype.addOne = function(item) {
      var view;
      view = new SlotItemView({
        model: item
      });
      return this.slotItems().append(view.render().el);
    };

    SlotView.prototype.addAll = function() {
      return this.model.queue.each(this.addOne, this);
    };

    return SlotView;

  })(Backbone.View);

  SlotsView = (function(_super) {

    __extends(SlotsView, _super);

    SlotsView.name = 'SlotsView';

    function SlotsView() {
      return SlotsView.__super__.constructor.apply(this, arguments);
    }

    SlotsView.prototype.el = $('#main');

    SlotsView.prototype.slotlist = function() {
      return $('#slot-list');
    };

    SlotsView.prototype.initialize = function(slots) {
      this.slots = slots;
      this.slots.bind('add', this.addOne, this);
      this.slots.bind('reset', this.addAll, this);
      return this.slots.bind('all', this.render, this);
    };

    SlotsView.prototype.render = function() {
      if (this.slots.length) {
        return console.log("has slots");
      } else {
        return console.log("has no slots");
      }
    };

    SlotsView.prototype.addOne = function(slot) {
      var view;
      view = new SlotView({
        model: slot
      });
      return this.slotlist().append(view.render().el);
    };

    SlotsView.prototype.addAll = function() {
      return this.slots.each(this.addOne);
    };

    return SlotsView;

  })(Backbone.View);

  slots = new Slots;

  App = new SlotsView(slots);

  wslot = new Slot({
    type: "worker"
  });

  slots.add(wslot);

  bslot = new Slot({
    type: "barracks"
  });

  slots.add(bslot);

  slots.add(new Slot({
    type: "barracks"
  }));

  for (i = _i = 1; _i <= 6; i = ++_i) {
    wslot.queue.add(new SlotQueueItem({
      object: Buildables.units.SCV,
      starts_at: i * 18
    }));
  }

  for (i = _j = 1; _j <= 6; i = ++_j) {
    bslot.queue.add(new SlotQueueItem({
      object: Buildables.units.Marine,
      starts_at: i * 26
    }));
  }

}).call(this);