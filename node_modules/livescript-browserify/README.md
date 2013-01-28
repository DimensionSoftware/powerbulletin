### What?

A browserify plugin for LiveScript.

### Why?

[browserify](http://github.com/substack/browserify) only supports `JavaScript` and `CoffeeScript` out-of-the-box.

Transpilers (other than `CoffeeScript`, for now) are supported via plugins.

### How?

#### Installation

```sh
cd ~/org/repo
npm i livescript-browserify
```

#### CLI

```sh
browserify --plugin livescript-browserify
```

#### API

```coffee
bundle = browserify "#{__dirname}/entry.ls"
bundle.use require 'livescript-browserify'
```

### Testing

Not just yet. Please lodge any issues you find :)