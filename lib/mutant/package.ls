#!/usr/bin/env lsc -cj
name: 'mutant'
version: '0.0.1'
main: 'index.js'
description: 'The Holy Grail'
keywords: <[ express middleware history seo dom ]>
author:
  name: 'Matt Elder'
  email: 'matt@mattelder.org'
homepage: 'https://github.com/WeedMaps/mutant.js'
bugs:
  url: 'http://github.com/WeedMaps/mutant.js/issues'
  email: 'matt@mattelder.org'
license: 'MIT'
repository:
  type: 'git'
  url: 'http://github.com/WeedMaps/mutant.js.git'
scripts:
  prepublish: 'lsc -cj package.ls && lsc -c middleware.ls && lsc -c mutant.ls || echo'
dependencies:
  jsdom: "*"
  jade: "*"
  underscore: "*"
engines: { node: '>= 0.8.0' }

