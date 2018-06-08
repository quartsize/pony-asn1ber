primitive Ber
  fun read_length(octets: Iterator[U8]): USize? =>
    let first_octet = octets.next()?

    if first_octet < 0x80 then
      first_octet.usize()
    elseif first_octet == 0x80 then
      error // unimplemented
    else
      var c = first_octet and 0x7f
      var a = USize(0)
      while c > 0 do
        c = c - 1
        a = (a << 8) + octets.next()?.usize()
      end
      a
    end

  fun read_value(octets: Iterator[U8]): (String | Signed)? =>
    match octets.next()?
    | 0x04 =>
      var c = read_length(octets)?
      var s = recover String(c) end
      while c > 0 do
        c = c - 1
        s.push(octets.next()?)
      end
      s
    | 0x02 =>
      var c = read_length(octets)? - 1
      let o = octets.next()?
      var a = (o and 0x7f).i64() - (o and 0x80).i64()
      while c > 0 do
        c = c - 1
        a = (a << 8) + octets.next()?.i64()
      end
      a
    else
      error
    end

