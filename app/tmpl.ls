require! {
  \fs
  \jade
  __: \lodash
}

@build = (path = "./app/views", ignore = [/add-post/, /layout/]) ->
  templates = {}
  jades = fs.readdir-sync(path).filter (p) -> p.match(/\.jade$/)
  jades.for-each (j) ->
    j1   = j.replace(/\.jade$/, '')
    j2   = j1.split('/')
    name = j2[j2.length - 1]
    templates[name] = jade.compile(fs.read-file-sync("#{path}/#{j}", 'utf8'), {client:true, compile-debug:false, filename: "#{path}/#{j}"})
  templates
