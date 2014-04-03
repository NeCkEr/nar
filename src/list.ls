require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}

module.exports = list =

  (options) ->
    { file, gzip } = options
    emitter = new EventEmitter
    ended = no
    error = no
    files = []

    on-error = ->
      error := it
      emitter.emit 'error', it

    on-end = ->
      ended := yes
      emitter.emit 'end', files

    on-entry = ->
      it.props |> files.push
      emitter.emit 'entry', it.props

    on-listener = (ev, fn) ->
      if error
        if ev is 'error'
          fn error
        else
          emitter.emit 'error', error
      else if ended
        if ev is 'end'
          fn files
        else
          emitter.emit 'end', files

    parse = ->
      parse = tar.Parse!

      stream = file |> fs.create-read-stream
      stream.on 'error', on-error
      stream = stream.pipe create-gunzip! if gzip
      stream.pipe parse

      parse.on 'error', on-error
      parse.on 'entry', on-entry
      parse.on 'end', on-end

    emitter.on 'newListener', on-listener

    process.next-tick parse

    emitter