var Money = function(value, opts) {
  this.value = value;
  this.opts = opts || {};
};

(function(Money) {
  function round(self, value) {
    var ret = value;
    if (self.opts.round === 'down') {
      ret = Math.floor(ret);
    }
    if (self.opts.round === 'up') {
      ret = Math.ceil(ret);
    }
    return ret;
  }

  function precision(self) {
    if (self.opts.round === 'down') {
      return 0;
    }
    if (self.opts.round === 'up') {
      return 0;
    }
    return 2;
  }

  Money.prototype = {
    cleanString: function() {
      return (this.value+'').replace(/,/g, '');
    },

    toFloat: function() {
      var floatValue = parseFloat(this.cleanString());
      floatValue = round(this, floatValue);
      return isNaN(floatValue) ? 0.0 : floatValue;
    },

    toString: function() {
      return this.toFloat().toFixed(precision(this)).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  };
})(Money);
