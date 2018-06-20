use "itertools"

class Asn1ObjectIdentifier is Stringable
  let _ber: Array[U8]

  new from_ber(b: Array[U8]) =>
    _ber = b

  fun string(): String iso^ =>
    try
      let subids = Vlq(_ber.values())
      let subid0 = subids.next()?
      let first_components = [subid0 / 40; subid0 % 40].values()
      ".".join(
        Iter[U64].chain(
          [ first_components ; subids ].values()
        )
      )
    else
      recover String() end
    end
