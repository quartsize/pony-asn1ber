class Asn1OctetString is Stringable
  embed _s: String

  new from_ber(a: Array[U8] iso) =>
    _s = String.from_iso_array(consume a)

  fun string(): String iso^ =>
    recover _s.clone() end

