class Asn1Integer
  let _ber: Array[U8]

  new from_ber(b: Array[U8]) =>
    _ber = b

  fun i64(): I64 =>
    var a: I64 = 0
    for (i, o) in _ber.pairs() do
      if i == 0 then
        a = (o and 0x7f).i64() - (o and 0x80).i64()
      else
        a = (a << 8) + o.i64()
      end
    end
    a

