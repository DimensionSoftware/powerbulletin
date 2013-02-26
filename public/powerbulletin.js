(function(){
var require = function (file, cwd) {
    var resolved = require.resolve(file, cwd || '/');
    var mod = require.modules[resolved];
    if (!mod) throw new Error(
        'Failed to resolve module ' + file + ', tried ' + resolved
    );
    var cached = require.cache[resolved];
    var res = cached? cached.exports : mod();
    return res;
};

require.paths = [];
require.modules = {};
require.cache = {};
require.extensions = [".js",".coffee",".json",".ls"];

require._core = {
    'assert': true,
    'events': true,
    'fs': true,
    'path': true,
    'vm': true
};

require.resolve = (function () {
    return function (x, cwd) {
        if (!cwd) cwd = '/';
        
        if (require._core[x]) return x;
        var path = require.modules.path();
        cwd = path.resolve('/', cwd);
        var y = cwd || '/';
        
        if (x.match(/^(?:\.\.?\/|\/)/)) {
            var m = loadAsFileSync(path.resolve(y, x))
                || loadAsDirectorySync(path.resolve(y, x));
            if (m) return m;
        }
        
        var n = loadNodeModulesSync(x, y);
        if (n) return n;
        
        throw new Error("Cannot find module '" + x + "'");
        
        function loadAsFileSync (x) {
            x = path.normalize(x);
            if (require.modules[x]) {
                return x;
            }
            
            for (var i = 0; i < require.extensions.length; i++) {
                var ext = require.extensions[i];
                if (require.modules[x + ext]) return x + ext;
            }
        }
        
        function loadAsDirectorySync (x) {
            x = x.replace(/\/+$/, '');
            var pkgfile = path.normalize(x + '/package.json');
            if (require.modules[pkgfile]) {
                var pkg = require.modules[pkgfile]();
                var b = pkg.browserify;
                if (typeof b === 'object' && b.main) {
                    var m = loadAsFileSync(path.resolve(x, b.main));
                    if (m) return m;
                }
                else if (typeof b === 'string') {
                    var m = loadAsFileSync(path.resolve(x, b));
                    if (m) return m;
                }
                else if (pkg.main) {
                    var m = loadAsFileSync(path.resolve(x, pkg.main));
                    if (m) return m;
                }
            }
            
            return loadAsFileSync(x + '/index');
        }
        
        function loadNodeModulesSync (x, start) {
            var dirs = nodeModulesPathsSync(start);
            for (var i = 0; i < dirs.length; i++) {
                var dir = dirs[i];
                var m = loadAsFileSync(dir + '/' + x);
                if (m) return m;
                var n = loadAsDirectorySync(dir + '/' + x);
                if (n) return n;
            }
            
            var m = loadAsFileSync(x);
            if (m) return m;
        }
        
        function nodeModulesPathsSync (start) {
            var parts;
            if (start === '/') parts = [ '' ];
            else parts = path.normalize(start).split('/');
            
            var dirs = [];
            for (var i = parts.length - 1; i >= 0; i--) {
                if (parts[i] === 'node_modules') continue;
                var dir = parts.slice(0, i + 1).join('/') + '/node_modules';
                dirs.push(dir);
            }
            
            return dirs;
        }
    };
})();

require.alias = function (from, to) {
    var path = require.modules.path();
    var res = null;
    try {
        res = require.resolve(from + '/package.json', '/');
    }
    catch (err) {
        res = require.resolve(from, '/');
    }
    var basedir = path.dirname(res);
    
    var keys = (Object.keys || function (obj) {
        var res = [];
        for (var key in obj) res.push(key);
        return res;
    })(require.modules);
    
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (key.slice(0, basedir.length + 1) === basedir + '/') {
            var f = key.slice(basedir.length);
            require.modules[to + f] = require.modules[basedir + f];
        }
        else if (key === basedir) {
            require.modules[to] = require.modules[basedir];
        }
    }
};

(function () {
    var process = {};
    var global = typeof window !== 'undefined' ? window : {};
    var definedProcess = false;
    
    require.define = function (filename, fn) {
        if (!definedProcess && require.modules.__browserify_process) {
            process = require.modules.__browserify_process();
            definedProcess = true;
        }
        
        var dirname = require._core[filename]
            ? ''
            : require.modules.path().dirname(filename)
        ;
        
        var require_ = function (file) {
            var requiredModule = require(file, dirname);
            var cached = require.cache[require.resolve(file, dirname)];

            if (cached && cached.parent === null) {
                cached.parent = module_;
            }

            return requiredModule;
        };
        require_.resolve = function (name) {
            return require.resolve(name, dirname);
        };
        require_.modules = require.modules;
        require_.define = require.define;
        require_.cache = require.cache;
        var module_ = {
            id : filename,
            filename: filename,
            exports : {},
            loaded : false,
            parent: null
        };
        
        require.modules[filename] = function () {
            require.cache[filename] = module_;
            fn.call(
                module_.exports,
                require_,
                module_,
                module_.exports,
                dirname,
                filename,
                process,
                global
            );
            module_.loaded = true;
            return module_.exports;
        };
    };
})();


require.define("path",function(require,module,exports,__dirname,__filename,process,global){function filter (xs, fn) {
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (fn(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length; i >= 0; i--) {
    var last = parts[i];
    if (last == '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Regex to split a filename into [*, dir, basename, ext]
// posix version
var splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
var resolvedPath = '',
    resolvedAbsolute = false;

for (var i = arguments.length; i >= -1 && !resolvedAbsolute; i--) {
  var path = (i >= 0)
      ? arguments[i]
      : process.cwd();

  // Skip empty and invalid entries
  if (typeof path !== 'string' || !path) {
    continue;
  }

  resolvedPath = path + '/' + resolvedPath;
  resolvedAbsolute = path.charAt(0) === '/';
}

// At this point the path should be resolved to a full absolute path, but
// handle relative paths to be safe (might happen when process.cwd() fails)

// Normalize the path
resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
var isAbsolute = path.charAt(0) === '/',
    trailingSlash = path.slice(-1) === '/';

// Normalize the path
path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }
  
  return (isAbsolute ? '/' : '') + path;
};


// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    return p && typeof p === 'string';
  }).join('/'));
};


exports.dirname = function(path) {
  var dir = splitPathRe.exec(path)[1] || '';
  var isWindows = false;
  if (!dir) {
    // No dirname
    return '.';
  } else if (dir.length === 1 ||
      (isWindows && dir.length <= 3 && dir.charAt(1) === ':')) {
    // It is just a slash or a drive letter with a slash
    return dir;
  } else {
    // It is a full dirname, strip trailing slash
    return dir.substring(0, dir.length - 1);
  }
};


exports.basename = function(path, ext) {
  var f = splitPathRe.exec(path)[2] || '';
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPathRe.exec(path)[3] || '';
};

});

require.define("__browserify_process",function(require,module,exports,__dirname,__filename,process,global){var process = module.exports = {};

process.nextTick = (function () {
    var canSetImmediate = typeof window !== 'undefined'
        && window.setImmediate;
    var canPost = typeof window !== 'undefined'
        && window.postMessage && window.addEventListener
    ;

    if (canSetImmediate) {
        return function (f) { return window.setImmediate(f) };
    }

    if (canPost) {
        var queue = [];
        window.addEventListener('message', function (ev) {
            if (ev.source === window && ev.data === 'browserify-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);

        return function nextTick(fn) {
            queue.push(fn);
            window.postMessage('browserify-tick', '*');
        };
    }

    return function nextTick(fn) {
        setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

process.binding = function (name) {
    if (name === 'evals') return (require)('vm')
    else throw new Error('No such module. (Possibly not yet loaded)')
};

(function () {
    var cwd = '/';
    var path;
    process.cwd = function () { return cwd };
    process.chdir = function (dir) {
        if (!path) path = require('path');
        cwd = path.resolve(dir, cwd);
    };
})();

});

require.define("/lib/mutant/package.json",function(require,module,exports,__dirname,__filename,process,global){module.exports = {"main":"index.js"}
});

require.define("/lib/mutant/mutant.ls",function(require,module,exports,__dirname,__filename,process,global){(function(){
  var jsdom, gen_dom_window, isSurfable;
  if (typeof window != 'undefined' && window !== null) {
    true;
  } else {
    jsdom = require('jsdom');
    gen_dom_window = function(html, cb){
      var scripts, jsdom_opts, jsdom_done, this$ = this;
      scripts = ['../../public/local/jquery-1.8.3.min.js'];
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
    require('../../app/views/mutants.js');
    if (typeof window != 'undefined' && window !== null) {
      if (initial_run) {
        return onLoad.call(params, window, function(err){
          if (err) {
            return cb(err);
          }
          return onInitial.call(params, window, cb);
        });
      } else {
        window.renderJade = function(target, tmpl){
          return cb(null, jade.render(window.document.getElementById(target), tmpl, params));
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
        window.renderJade = function(target, tmpl){
          return jade.render(window.document.getElementById(target), tmpl, params);
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
          return cb(null, "<!doctype html>" + window.document.outerHTML);
        });
      });
    } else {
      throw new Error("need html for serverside");
    }
  };
  isSurfable = function(r){
    return r.callbacks.some(function(m){
      return m.surfable;
    });
  };
  this.surfableRoutes = function(app){
    var i$, ref$, len$, r, results$ = [];
    for (i$ = 0, len$ = (ref$ = app.routes.get).length; i$ < len$; ++i$) {
      r = ref$[i$];
      if (isSurfable(r)) {
        results$.push(r.regexp.toString());
      }
    }
    return results$;
  };
}).call(this);

});

require.define("/app/views/mutants.js",function(require,module,exports,__dirname,__filename,process,global){jade=function(e){function t(e){return e!=null}return Array.isArray||(Array.isArray=function(e){return"[object Array]"==Object.prototype.toString.call(e)}),Object.keys||(Object.keys=function(e){var t=[];for(var n in e)e.hasOwnProperty(n)&&t.push(n);return t}),e.merge=function(n,r){var i=n["class"],s=r["class"];if(i||s)i=i||[],s=s||[],Array.isArray(i)||(i=[i]),Array.isArray(s)||(s=[s]),i=i.filter(t),s=s.filter(t),n["class"]=i.concat(s).join(" ");for(var o in r)o!="class"&&(n[o]=r[o]);return n},e.attrs=function(n,r){var i=[],s=n.terse;delete n.terse;var o=Object.keys(n),u=o.length;if(u){i.push("");for(var a=0;a<u;++a){var f=o[a],l=n[f];"boolean"==typeof l||null==l?l&&(s?i.push(f):i.push(f+'="'+f+'"')):0==f.indexOf("data")&&"string"!=typeof l?i.push(f+"='"+JSON.stringify(l)+"'"):"class"==f&&Array.isArray(l)?i.push(f+'="'+e.escape(l.join(" "))+'"'):r&&r[f]?i.push(f+'="'+e.escape(l)+'"'):i.push(f+'="'+l+'"')}}return i.join(" ")},e.escape=function(t){return String(t).replace(/&(?!(\w+|\#\d+);)/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")},e.rethrow=function(t,n,r){if(!n)throw t;var i=3,s=require("fs").readFileSync(n,"utf8"),o=s.split("\n"),u=Math.max(r-i,0),a=Math.min(o.length,r+i),i=o.slice(u,a).map(function(e,t){var n=t+u+1;return(n==r?"  > ":"    ")+n+"| "+e}).join("\n");throw t.path=n,t.message=(n||"Jade")+":"+r+"\n"+i+"\n\n"+t.message,t},e}({}),jade.templates={},jade.render=function(e,t,n){var r=jade.templates[t](n);e.innerHTML=r},jade.templates.homepage=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,forum_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push("<img"),buf.push(attrs({id:"forum_bg_"+e.id+"",src:""+cache_url+"/images/bg_"+e.id+".jpg","class":"bg initial"},{"class":!0,id:!0,src:!0})),buf.push("/><div"),buf.push(attrs({id:"forum_"+e.id+"","class":"forum "+(""+(e.classes||"")+" "+(t%2?"odd":"even")+"")},{"class":!0,id:!0})),buf.push("><a"),buf.push(attrs({name:"forum_"+e.id+""},{name:!0})),buf.push('></a><div class="header"><div class="description"><a'),buf.push(attrs({href:e.uri,"class":"mutant"},{href:!0})),buf.push(">");var s=e.description;buf.push(escape(null==s?"":s)),buf.push('</a></div></div><div class="container">'),e.posts&&(function(){if("number"==typeof e.posts.length)for(var t=0,n=e.posts.length;t<n;t++){var r=e.posts[t];post_mixin(e,r,t)}else for(var t in e.posts){var r=e.posts[t];post_mixin(e,r,t)}}.call(this),buf.push("<div"),buf.push(attrs({"data-scroll-to":"#forum_"+e.id+"",title:"Scroll top of "+e.title+"!","class":"up scroll-to"},{"class":!0,"data-scroll-to":!0,title:!0})),buf.push("></div>")),buf.push("</div></div>")},post_mixin=function(e,t,n){var r=this.block,i=this.attributes||{},s=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"post_"+t.id+"","class":"post "+("col"+Math.ceil(Math.random()*2)+"")},{"class":!0,id:!0})),buf.push("><a"),buf.push(attrs({href:t.uri,"class":"mutant"},{href:!0})),buf.push('><h5 class="title">');var o=t.title;buf.push(null==o?"":o),buf.push('<span class="date">'+escape((interp=t.date)==null?"":interp)+'</span></h5></a><p class="body">');var o=t.body;buf.push(null==o?"":o),buf.push("</p>"),t.posts&&function(){if("number"==typeof t.posts.length)for(var e=0,n=t.posts.length;e<n;e++){var r=t.posts[e];subpost_mixin(r,e)}else for(var e in t.posts){var r=t.posts[e];subpost_mixin(r,e)}}.call(this),buf.push('<div class="comment"><div class="photo"><img'),buf.push(attrs({src:""+cache_url+"/images/profile.jpg"},{src:!0})),buf.push('/></div><input type="text" placeholder="Say it ..." class="msg"/></div></div>')},subpost_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"subpost_"+e.id+"","class":"subpost "+(t%2?"odd":"even")},{"class":!0,id:!0})),buf.push('><div class="photo"><img'),buf.push(attrs({src:""+cache_url+"/images/profile.jpg"},{src:!0})),buf.push('/></div><p class="body">');var s=e.body;buf.push(null==s?"":s),buf.push('</p><div class="signature"><span class="username">- '+escape((interp=e.user_name)==null?"":interp)+'</span><span class="date">');var s=e.date;buf.push(escape(null==s?"":s)),buf.push("</span></div></div>")};forums?function(){if("number"==typeof forums.length)for(var e=0,t=forums.length;e<t;e++){var n=forums[e];forum_mixin(n,e)}else for(var e in forums){var n=forums[e];forum_mixin(n,e)}}.call(this):buf.push("<p>Create a forum first<i>!</i></p>")}return buf.join("")},jade.templates.nav=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,forum_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push('<h3 class="title">Forums</h3>'),e.forums&&(buf.push("<ul"),buf.push(attrs({"class":"forum "+(""+(e.classes||"")+" forum-"+activeForumId+"")},{"class":!0})),buf.push(">"),function(){if("number"==typeof e.forums.length)for(var t=0,n=e.forums.length;t<n;t++){var r=e.forums[t];subforum_mixin(e,r,t)}else for(var t in e.forums){var r=e.forums[t];subforum_mixin(e,r,t)}}.call(this),buf.push("</ul>"))},subforum_mixin=function(e,t,n){var r=this.block,i=this.attributes||{},s=this.escaped||{};buf.push("<li><a"),buf.push(attrs({href:t.uri,"class":"mutant title"},{href:!0})),buf.push(">");var o=t.title;buf.push(escape(null==o?"":o)),buf.push("</a></li>")},thread_mixin=function(e){var t=this.block,n=this.attributes||{},r=this.escaped||{};buf.push('<li><h4 class="title"><a'),buf.push(attrs({href:e.uri,"class":"mutant"},{href:!0})),buf.push(">");var i=e.title;buf.push(escape(null==i?"":i)),buf.push("</a></h4></li>")};buf.push('<div id="handle" class="handle"></div><div class="create"><a class="button onclick-add-post-dialog">Create Thread</a></div><ul class="threads">'),function(){if("number"==typeof topThreads.length)for(var e=0,t=topThreads.length;e<t;e++){var n=topThreads[e];thread_mixin(n)}else for(var e in topThreads){var n=topThreads[e];thread_mixin(n)}}.call(this),buf.push("</ul>")}return buf.join("")},jade.templates.posts=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,breadcrumb_mixin=function(e){var t=this.block,n=this.attributes||{},r=this.escaped||{},i="",s=e.uri.split("/"),s=s.splice(1,s.length-2);(function(){if("number"==typeof s.length)for(var e=0,t=s.length;e<t;e++){var n=s[e];if(n!="t"){buf.push("<a"),buf.push(attrs({href:""+i+""+n+"","class":"mutant"},{href:!0})),buf.push(">");var r=n.replace("-"," ");buf.push(escape(null==r?"":r)),buf.push("</a>")}i=i+n+"/"}else for(var e in s){var n=s[e];if(n!="t"){buf.push("<a"),buf.push(attrs({href:""+i+""+n+"","class":"mutant"},{href:!0})),buf.push(">");var r=n.replace("-"," ");buf.push(escape(null==r?"":r)),buf.push("</a>")}i=i+n+"/"}}).call(this);var o=e.title;buf.push(null==o?"":o)},post_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push('<div class="post"><a'),buf.push(attrs({href:e.uri,"class":"mutant"},{href:!0})),buf.push(">");var s=e.title;buf.push(null==s?"":s),buf.push('</a><p class="body">');var s=e.body;buf.push(null==s?"":s),buf.push("</p>"),e.subposts&&function(){if("number"==typeof e.subposts.length)for(var t=0,n=e.subposts.length;t<n;t++){var r=e.subposts[t];subpost_mixin(e,r,t)}else for(var t in e.subposts){var r=e.subposts[t];subpost_mixin(e,r,t)}}.call(this),buf.push("</div>")},subpost_mixin=function(e,t,n){var r=this.block,i=this.attributes||{},s=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"subpost"+t.id+"","data-post-id":""+t.id+"","class":"subpost "+(n%2?"odd":"even")},{"class":!0,id:!0,"data-post-id":!0})),buf.push('><h4 class="title">');var o=t.title;buf.push(null==o?"":o),buf.push('</h4><div class="user">');var o=t.user_name;buf.push(escape(null==o?"":o)),buf.push('</div><div class="date">');var o=t.created;buf.push(escape(null==o?"":o)),buf.push('</div><p class="body">');var o=t.body;buf.push(null==o?"":o),buf.push('</p><div class="actions"><a class="reply onclick-append-reply-ui">Reply</a></div><div class="reply"></div>'),t.posts&&(buf.push('<div class="children">'),function(){if("number"==typeof t.posts.length)for(var e=0,n=t.posts.length;e<n;e++){var r=t.posts[e];subpost_mixin(t,r,e)}else for(var e in t.posts){var r=t.posts[e];subpost_mixin(t,r,e)}}.call(this),buf.push("</div>")),buf.push("</div>")};if(typeof subPost!="undefined"){buf.push('<div class="forum"><h2>');var __val__=subPost.title;buf.push(escape(null==__val__?"":__val__)),buf.push("</h2>");if(subPost.body){buf.push("<p>");var __val__=subPost.body;buf.push(escape(null==__val__?"":__val__)),buf.push("</p>")}buf.push('<div class="breadcrumb">'),breadcrumb_mixin(subPost),buf.push("</div>"),function(){if("number"==typeof subPost.posts.length)for(var e=0,t=subPost.posts.length;e<t;e++){var n=subPost.posts[e];subpost_mixin(subPost,n,e)}else for(var e in subPost.posts){var n=subPost.posts[e];subpost_mixin(subPost,n,e)}}.call(this),buf.push("</div>")}}return buf.join("")}
});

require.define("fs",function(require,module,exports,__dirname,__filename,process,global){// nothing to see here... no file methods for the browser

});

require.define("/app/mutants.ls",function(require,module,exports,__dirname,__filename,process,global){(function(){
  var layoutStatic, flipBackground;
  layoutStatic = function(w, mutator, id){
    var forumClass;
    forumClass = id ? " forum-" + id : '';
    w.$('html').attr('class', mutator + "" + forumClass);
    w.marshal('mutator', mutator);
    w.$('.bg-set').remove();
    w.$('.bg').each(function(){
      return w.$(this).addClass('bg-set').remove().prependTo(w.$('body'));
    });
    w.$('header .menu').find('.active').removeClass('active');
    return w.$('menu .row').has(".forum-" + id).find('.title').addClass('active');
  };
  flipBackground = function(w, cur, direction){
    var last, next;
    direction == null && (direction = 'down');
    if (w.bgAnim) {
      clearTimeout(w.bgAnim);
    }
    last = w.$('.bg.active');
    next = w.$('#forum' + ("_bg_" + cur.data('id')));
    next.css('display', 'block');
    if (!last.length) {
      return next.addClass('active');
    } else {
      return w.bgAnim = setTimeout(function(){
        last.css('top', direction === 'down' ? -300 : 300);
        last.removeClass('active');
        next.addClass('active');
        return w.bgAnim = 0;
      }, 100);
    }
  };
  this.homepage = {
    'static': function(window, next){
      window.renderJade('main_content', 'homepage');
      layoutStatic(window, 'homepage', this.activeForumId);
      return next();
    },
    onLoad: function(window, next){
      window.$('.forum .container').masonry({
        itemSelector: '.post',
        isAnimated: true,
        isFitWidth: true,
        isResizable: true
      });
      setTimeout(function(){
        var $;
        $ = window.$;
        $('.forum .header').waypoint('sticky', {
          offset: -70
        });
        return $('.forum').waypoint({
          offset: '25%',
          handler: function(direction){
            var e, eid, id, cur;
            e = $(this);
            eid = e.attr('id');
            id = direction === 'down'
              ? eid
              : $('#' + eid).prevAll('.forum:first').attr('id');
            if (!id) {
              return;
            }
            $('header .menu').find('.active').removeClass('active');
            cur = $('header .menu').find("." + id.replace(/_/, '-')).addClass('active');
            $('.forum .stuck').removeClass('stuck');
            return flipBackground(window, cur, direction);
          }
        });
      }, 100);
      return next();
    },
    onUnload: function(window, next){
      window.$('.forum .container').masonry('destroy');
      window.$('.forum .header').waypoint('destroy');
      window.$('.forum').waypoint('destroy');
      return next();
    }
  };
  this.forum = {
    'static': function(window, next){
      window.renderJade('left_content', 'nav');
      window.renderJade('main_content', 'posts');
      window.marshal('activeForumId', this.activeForumId);
      window.marshal('activePostId', this.activePostId);
      layoutStatic(window, 'forum', this.activeForumId);
      return next();
    },
    onLoad: function(window, next){
      var cur, $;
      cur = window.$("header .menu .forum-" + window.activeForumId);
      flipBackground(window, cur);
      $ = window.$;
      $('.forum .breadcrumb').waypoint('sticky', {
        offset: -70
      });
      return next();
    },
    onMutate: function(window, next){
      window.scrollToTop();
      window.s;
      return next();
    },
    onUnload: function(window, next){
      window.$('.forum .breadcrumb').waypoint('destroy');
      return next();
    }
  };
  this.search = {
    'static': function(window, next){
      return next();
    },
    onLoad: function(window, next){
      return next();
    },
    onInitial: function(window, next){
      return next();
    },
    onMutate: function(window, next){
      return next();
    }
  };
  this.admin = {
    'static': function(window, next){
      return next();
    }
  };
}).call(this);

});

require.define("/app/layout.ls",function(require,module,exports,__dirname,__filename,process,global){(function(){
  var $w, $d, isIe, isMoz, isOpera, threshold, onLoad, ref$;
  $w = $(window);
  $d = $(document);
  isIe = false || in$('msTransform', document.documentElement.style);
  isMoz = false || in$('MozBoxSizing', document.documentElement.style);
  isOpera = !!(window.opera && window.opera.version);
  threshold = 10;
  window.mutant = require('../lib/mutant/mutant');
  window.mutants = require('./mutants');
  window.mutate = function(e){
    var href, searchParams;
    href = $(this).attr('href');
    if (!href) {
      return false;
    }
    if (href != null && href.match(/#/)) {
      return true;
    }
    searchParams = {};
    History.pushState({
      searchParams: searchParams
    }, '', href);
    return false;
  };
  onLoad = ((ref$ = window.mutants[window.mutator]) != null ? ref$.onLoad : void 8) || function(window, next){
    return next();
  };
  onLoad.call(this, window, function(){
    var hasScrolled;
    $('#query').focus();
    $d.on('click', 'a.mutant', window.mutate);
    History.Adapter.bind(window, 'statechange', function(e){
      var url;
      url = History.getPageUrl().replace(/\/$/, '');
      $.get(url, {
        _surf: 1
      }, function(r){
        var ref$, onUnload;
        if ((ref$ = r.locals) != null && ref$.title) {
          $d.attr('title', r.locals.title);
        }
        onUnload = window.mutants[window.mutator].onUnload || function(w, cb){
          return cb(null);
        };
        return onUnload(window, function(){
          var e;
          try {
            return window.mutant.run(window.mutants[r.mutant], {
              locals: r.locals
            });
          } catch (e$) {
            return e = e$;
          }
        });
      });
      return false;
    });
    window.scrollToTop = function(){
      var $e;
      if ($(window).scrollTop() === 0) {
        return;
      }
      $e = $('html,body');
      return $e.animate({
        scrollTop: $('body').offset().top
      }, 140, function(){
        return $e.animate({
          scrollTop: $('body').offset().top + threshold
        }, 110, function(){
          return $e.animate({
            scrollTop: $('body').offset().top
          }, 75, function(){});
        });
      });
    };
    hasScrolled = function(){
      var st;
      st = $w.scrollTop();
      return $('body').toggleClass('scrolled', st > threshold);
    };
    setTimeout(function(){
      $w.on('scroll', function(){
        return hasScrolled();
      });
      return hasScrolled();
    }, 1300);
    window.awesomeScrollTo = function(e, duration, onComplete){
      var ms, offset, dstScroll, curScroll;
      onComplete = function(){
        var noop;
        if (!onComplete) {
          return noop = 1;
        }
      };
      e = $(e);
      ms = duration || 600;
      offset = 100;
      if (!e.length) {
        return;
      }
      if (isIe || isOpera) {
        e[0].scrollIntoView();
        onComplete();
      } else {
        dstScroll = Math.round(e.position().top) - offset;
        curScroll = window.scrollY;
        if (Math.abs(dstScroll - curScroll) > 30) {
          $('html,body').animate({
            scrollTop: dstScroll
          }, ms, function(){});
        } else {
          onComplete();
        }
      }
      return e;
    };
    $d.on('click', '.scroll-to', function(){
      awesomeScrollTo($(this).data('scroll-to'));
      return false;
    });
    $d.on('mousedown', '.scroll-to-top', function(){
      $(this).attr('title', 'Scroll to Top!');
      window.scrollToTop();
      return false;
    });
    $d.on('click', 'header', function(e){
      if (e.target.className.indexOf('toggler') > -1) {
        $('body').removeClass('expanded');
      }
      return $('#query').focus();
    });
    return $d.on('keypress', '#query', function(){
      return $('body').addClass('expanded');
    });
  });
  function in$(x, arr){
    var i = -1, l = arr.length >>> 0;
    while (++i < l) if (x === arr[i] && i in arr) return true;
    return false;
  }
}).call(this);

});
require("/app/layout.ls");

require.define("/app/entry.ls",function(require,module,exports,__dirname,__filename,process,global){(function(){
  var $w, $d, addPostDialog, addPost, appendReplyUi, showLoginDialog, login, requireLogin;
  $w = $(window);
  $d = $(document);
  $w.resize(function(){
    return setTimeout(function(){
      return $.waypoints('refresh');
    }, 800);
  });
  setTimeout(function(){
    return $('#sort li').waypoint({
      context: 'ul',
      offset: 30,
      handler: function(direction){
        var e;
        e = $(this);
        if (direction === 'up') {
          e = e.prev();
        }
        if (!e.length) {
          e = $(this);
        }
        $('#sort li.active').removeClass('active');
        return e.addClass('active');
      }
    });
  }, 100);
  $d.on('click', 'html.homepage header .menu a.title', function(){
    awesomeScrollTo($(this).data('scroll-to'));
    return false;
  });
  $d.on('click', 'html.forum header .menu a.title', window.mutate);
  addPostDialog = function(){
    var query;
    query = {
      fid: window.activeForumId
    };
    return $.get('/resources/posts', query, function(html){
      $(html).dialog({
        modal: true
      });
      return false;
    });
  };
  addPost = function(){
    var form;
    form = $('#add-post-form');
    $.post('/resources/posts', form.serialize(), function(_r1, _r2, res){
      console.log('success! post added', res);
      return console.log('stub: do something fancy to confirm submission');
    });
    return false;
  };
  appendReplyUi = function(){
    var $subpost, postId, replyUiHtml;
    $subpost = $(this).parents('.subpost:first');
    postId = $subpost.data('post-id');
    replyUiHtml = "<form method=\"post\" action=\"/resources/posts\">\n  <textarea name=\"body\"></textarea>\n  <input type=\"hidden\" name=\"forum_id\" value=\"" + window.activeForumId + "\">\n  <input type=\"hidden\" name=\"parent_id\" value=\"" + postId + "\">\n  <div>\n    <input type=\"submit\" value=\"Post\">\n  </div>\n</form>";
    if ($subpost.find('.reply form').length === 0) {
      return $subpost.find('.reply:first').append(replyUiHtml);
    } else {
      return $subpost.find('.reply:first form').remove();
    }
  };
  showLoginDialog = function(){
    return $.fancybox.open('#auth');
  };
  login = function(){
    var $form, params;
    $form = $(this);
    params = {
      username: $form.find('input[name=username]').val(),
      password: $form.find('input[name=password]').val()
    };
    $.post($form.attr('action'), params, function(r){
      var $fancybox;
      if (r.success) {
        return window.location.reload();
      } else {
        $fancybox = $form.parents('.fancybox-wrap:first');
        $fancybox.removeClass('shake');
        return setTimeout(function(){
          return $fancybox.addClass('shake');
        }, 100);
      }
    });
    return false;
  };
  requireLogin = function(fn){
    return function(){
      if (window.user) {
        return fn.apply(this, arguments);
      } else {
        return showLoginDialog();
      }
    };
  };
  $d.on('click', '#add-post-submit', addPost);
  $d.on('click', '.onclick-add-post-dialog', addPostDialog);
  $d.on('click', '.onclick-append-reply-ui', appendReplyUi);
  $d.on('submit', '.login form', login);
  $.getJSON('/auth/user', function(user){
    window.user = user;
  });
}).call(this);

});
require("/app/entry.ls");

})();
