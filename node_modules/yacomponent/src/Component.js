(function(){
  var define;
  define = (typeof window != 'undefined' && window !== null ? window.define : void 8) || require('amdefine')(module, require);
  define(function(require){
    var reactivejs, dollarish, Component;
    reactivejs = require('reactivejs');
    dollarish = typeof window != 'undefined' && window !== null
      ? window.$
      : require('cheerio');
    return Component = (function(){
      Component.displayName = 'Component';
      var prototype = Component.prototype, constructor = Component;
      Component.$ = dollarish;
      Component.$R = reactivejs;
      function Component(arg$, selector, parent){
        var ref$, locals, ref1$, autoRender, autoAttach, res$, k, v;
        ref$ = arg$ != null
          ? arg$
          : {}, locals = (ref1$ = ref$.locals) != null
          ? ref1$
          : {}, autoRender = (ref1$ = ref$.autoRender) != null ? ref1$ : true, autoAttach = (ref1$ = ref$.autoAttach) != null ? ref1$ : true;
        this.selector = selector;
        this.parent = parent;
        res$ = {};
        for (k in locals) {
          v = locals[k];
          res$[k] = v != null && v._isReactive
            ? v
            : constructor.$R.state(v === void 8 ? null : v);
        }
        this.state = res$;
        if (this.selector) {
          if (this.parent) {
            this.$ = this.parent.$.find(this.selector);
          } else {
            this.$ = constructor.$(this.selector);
          }
        } else {
          this.$top = constructor.$('<div><div/></div>');
          this.$ = this.$top.find('div');
        }
        if (this.init) {
          this.init();
        }
        if (!this.parent) {
          if (autoRender) {
            this.render();
          }
          if (autoAttach) {
            this.attach();
          }
        }
      }
      prototype.isClient = typeof window != 'undefined' && window !== null;
      prototype.template = function(){
        return '';
      };
      prototype.attach = function(){
        var i$, ref$, child;
        if (!this.isClient) {
          return this;
        }
        if (this.isAttached) {
          return this;
        }
        if (this.children) {
          for (i$ in ref$ = this.children) {
            child = ref$[i$];
            child.attach();
          }
        }
        if (this.onAttach) {
          this.onAttach();
        }
        this.isAttached = true;
        return this;
      };
      prototype.detach = function(){
        var i$, ref$, child;
        if (!this.isClient) {
          return this;
        }
        if (!this.isAttached) {
          return this;
        }
        if (this.children) {
          for (i$ in ref$ = this.children) {
            child = ref$[i$];
            child.detach();
          }
        }
        if (this.onDetach) {
          this.onDetach();
        }
        this.isAttached = false;
        return this;
      };
      prototype.render = function(){
        var locals, templateOut, $dom, i$, ref$, child;
        this.$.addClass(this.constructor.displayName);
        locals = this.locals();
        templateOut = this.template(locals);
        if (this.mutate || this.children) {
          $dom = constructor.$('<div class="render-wrapper">' + templateOut + '</div>');
          if (this.mutate) {
            this.mutate($dom);
          }
          this.$.html($dom.html());
          if (this.children) {
            for (i$ in ref$ = this.children) {
              child = ref$[i$];
              child.$ = this.$.find(child.selector);
              child.render();
            }
          }
        } else {
          this.$.html(templateOut);
        }
        return this;
      };
      prototype.reload = function(){
        return this.detach().render().attach();
      };
      prototype.locals = function(newLocals){
        var k, v, ref$, s, results$ = {};
        if (newLocals) {
          for (k in newLocals) {
            v = newLocals[k];
            this.local(k, v);
          }
        }
        for (k in ref$ = this.state) {
          s = ref$[k];
          results$[k] = s();
        }
        return results$;
      };
      prototype.local = function(k, v){
        var existingR;
        existingR = this.state[k];
        if (v === void 8) {
          if (existingR) {
            return existingR();
          }
        } else {
          if (existingR) {
            if (existingR.val === void 8) {
              throw new Error("'" + k + "' is not reactive state, you can only set reactive state");
            } else {
              return existingR(v === void 8 ? null : v);
            }
          } else {
            this.state[k] = constructor.$R.state(v === void 8 ? null : v);
            return v;
          }
        }
      };
      prototype.html = function(wrapped){
        wrapped == null && (wrapped = true);
        return ((wrapped && this.$top) || this.$).html();
      };
      return Component;
    }());
  });
}).call(this);
