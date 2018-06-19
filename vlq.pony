class Vlq is Iterator[U64]
  let _inner: Iterator[U8]
  var _next: U64 = 0
  var _has_next: Bool = false

  new create(iter: Iterator[U8]) => _inner = iter

  fun ref _find_next() =>
    if _has_next then
      _next = 0
      _has_next = false
    end

    _has_next = try
      var o: U8
      repeat
        o = _inner.next()?
        _next = (_next << 7) + (o and 0x7f).u64()
      until (o and 0x80) == 0 end
      true
    else
      false
    end


  fun ref has_next(): Bool =>
    if not _has_next then
      _find_next()
    end
    _has_next
 

  fun ref next(): U64? =>
    if not _has_next then
      _find_next()
    end
    if _has_next then
      let r = _next
      _find_next()
      r
    else
      error
    end

