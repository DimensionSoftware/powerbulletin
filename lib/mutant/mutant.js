(function(){
  var jsdom, jade, gen_dom_window;
  if (typeof window != 'undefined' && window !== null) {
    true;
  } else {
    jsdom = require('jsdom');
    jade = require('jade');
    gen_dom_window = function(html, cb){
      var scripts, jsdom_opts, jsdom_done, this$ = this;
      scripts = ["cache/web/js/jquery-1.7.1.min.js"];
      jsdom_opts = {
        html: html,
        scripts: scripts
      };
      jsdom_done = function(err, window){
        if (err) {
          return cb(err);
        }
        window.$ = window.jQuery;
        return cb(null, window);
      };
      return jsdom.env(jsdom_opts, jsdom_done);
    };
  }
  this.run = function(template, opts, cb){
    /*
    run returns void because it mutates the window object
    
    on the server side we need to know the base html before we can mutate it
    
    on the client side the callback returns nothing because the dom has been mutated already
    on the server side the callback will return html
    
    templates are objects with up to four methods:
    static, onLoad, onInitial, onMutate
    
    static is client or serverside and this phase is purely for html dom tree creation/manipulation
    
    onLoad happens when a mutant template is run, regardless of whether it is the initial pageload, or a mutation
    
    onInitial only happens on an initial pageload (not on mutation)
    
    onMutate only happens on a mutation (not on an initial pageload)
    */
    var initial_run, params, html, onLoad, onInitial, onMutate;
    cb == null && (cb = function(){});
    initial_run = opts.initial;
    params = opts.locals || {};
    html = opts.html;
    onLoad = template.onLoad || function(w, cb){
      return cb(null);
    };
    onInitial = template.onInitial || function(w, cb){
      return cb(null);
    };
    onMutate = template.onMutate || function(w, cb){
      return cb(null);
    };
    if (typeof window != 'undefined' && window !== null) {
      if (initial_run) {
        return onLoad.call(params, window, function(err){
          if (err) {
            return cb(err);
          }
          return onInitial.call(params, window, cb);
        });
      } else {
        window.renderJade = function(tmpl_name, cb){
          return $.get("/templates/" + tmpl_name, function(funtxt){
            var jade, jade_tmpl;
            jade = window.jade;
            jade_tmpl = eval(funtxt + " anonymous");
            return cb(null, jade_tmpl(params));
          });
        };
        window.marshal = function(key, val){
          return window[key] = val;
        };
        return template['static'].call(params, window, function(err){
          if (err) {
            return cb(err);
          }
          return onLoad.call(params, window, function(err){
            if (err) {
              return cb(err);
            }
            return onMutate.call(params, window, cb);
          });
        });
      }
    } else if (html) {
      return gen_dom_window(html, function(err, window){
        if (err) {
          return cb(err);
        }
        window.renderJade = function(tmpl_name, cb){
          return jade.renderFile("./views/" + tmpl_name + ".jade", params, cb);
        };
        window.marshal = function(key, val){
          var s;
          s = window.document.createElement('script');
          window.$(s).attr('type', 'text/javascript');
          window.$(s).text("window['" + key + "'] = " + JSON.stringify(val) + ";");
          return window.document.body.appendChild(s);
        };
        return template['static'].call(params, window, function(err){
          if (err) {
            return cb(err);
          }
          window.$('script.jsdom').remove();
          return cb(null, "<!doctype html>\n" + window.document.outerHTML);
        });
      });
    } else {
      throw new Error("need html for serverside");
    }
  };
}).call(this);
