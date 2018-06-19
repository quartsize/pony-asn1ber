class Vlq is Iterator[U64]
  let _inner: Iterator[U8]
  var _next: U64 = 0
  var _has_next: Bool = false

  new create(iter: Iterator[U8]) =>
    _inner = iter


  fun ref _reset_next(): U64 =>
    let r = _next
    _next = 0
    _has_next = false
    r


  fun ref _update_next() =>
    if not _has_next then
      try
        var o: U8
        repeat
          o = _inner.next()?
          _next = (_next << 7) + (o and 0x7f).u64()
        until (o and 0x80) == 0 end
        _has_next = true
      end
    end


  fun ref has_next(): Bool =>
    _update_next()
    _has_next
 

  fun ref next(): U64? =>
    _update_next()

    if _has_next then
      _reset_next()
    else
      error
    end

