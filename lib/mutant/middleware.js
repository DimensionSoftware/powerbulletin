(function(){
  var __, mutant, unpick, mutantLayout, out$ = typeof exports != 'undefined' && exports || this;
  __ = require('underscore');
  mutant = require('./mutant');
  unpick = function(obj, keys){
    var locals, i$, len$, key;
    locals = __.clone(obj);
    for (i$ = 0, len$ = keys.length; i$ < len$; ++i$) {
      key = keys[i$];
      delete locals[key];
    }
    return locals;
  };
  out$.mutantLayout = mutantLayout = function(jadeLayout, mutants){
    var fn;
    fn = function(req, res, next){
      if (req.query._surf) {
        req.surfing = true;
      }
      res.local('q', req.param('q')) || '';
      res.mutant = function(template_nm, opts){
        var locals, data;
        opts == null && (opts = {});
        locals = opts.locals
          ? opts.locals
          : opts.pick
            ? __.pick(res._locals, opts.pick)
            : opts.unpick
              ? unpick(res._locals, opts.unpick)
              : res._locals;
        if (req.surfing) {
          data = {
            locals: locals,
            mutant: template_nm
          };
          delete data.locals.req;
          return res.json(data);
        } else {
          res.local('initial_mutant', template_nm);
          res.local('query', req.query);
          return res.render(jade_layout + ".jade", {
            locals: locals,
            layout: false
          }, function(err, base_html){
            if (err) {
              return next(err);
            }
            return mutant.run(mutants[template_nm], {
              locals: locals,
              html: base_html
            }, function(err, html){
              if (err) {
                return next(err);
              }
              res.contentType('html');
              return res.send(html);
            });
          });
        }
      };
      return next();
    };
    fn.surfable = true;
    return fn;
  };
}).call(this);
