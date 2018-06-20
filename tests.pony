use "ponytest"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestLengthShort)
    test(_TestLengthLong)
    test(_TestStrings)
    test(_TestAsn1Integers)
    test(_TestIntegers)
    test(_TestSeq)
    test(_TestVLQ)
    test(_TestOID)

class iso _TestLengthShort is UnitTest
  fun name(): String => "short form length"
  fun apply(h: TestHelper)? =>
    let rd: BerReader ref = BerReader
    rd.append(recover [0x42] end)
    h.assert_eq[USize](rd.read_length()?, 0x42)

class iso _TestLengthLong is UnitTest
  fun name(): String => "long form length"
  fun apply(h: TestHelper)? =>
    let rd: BerReader ref = BerReader
    rd.append(recover [0x83; 0x42; 0x41; 0x40] end)
    h.assert_eq[USize](rd.read_length()?, 0x424140)

class iso _TestStrings is UnitTest
  fun name(): String => "strings"
  fun apply(h: TestHelper)? =>
    let rd: BerReader ref = BerReader
    rd.append(recover [0x04; 0x06; 0x70; 0x75; 0x62; 0x6C; 0x69; 0x63] end)
    match rd.read_value()?
    | let s: Asn1OctetString => h.assert_eq[String](s.string(), "public")
    end
    rd.append(recover [0x04; 0x07; 0x70; 0x72; 0x69; 0x76; 0x61; 0x74; 0x65] end)
    match rd.read_value()?
    | let s: Asn1OctetString => h.assert_eq[String](s.string(), "private")
    end

class iso _TestAsn1Integers is UnitTest
  fun name(): String => "Asn1Integers"
  fun apply(h: TestHelper) =>
    let zero = Asn1Integer.from_ber(recover [0x00] end)
    let p128 = Asn1Integer.from_ber(recover [0x00; 0x80] end)
    let n129 = Asn1Integer.from_ber(recover [0xFF; 0x7F] end)
    h.assert_eq[I64](zero.i64(), 0)
    h.assert_eq[I64](p128.i64(), 128)
    h.assert_eq[I64](n129.i64(), -129)

class iso _TestIntegers is UnitTest
  fun name(): String => "integers"
  fun apply(h: TestHelper)? =>
    let rd: BerReader ref = BerReader
    rd.append(recover [0x02; 0x01; 0x00] end)
    match rd.read_value()?
    | let i: Asn1Integer => h.assert_eq[I64](i.i64(), 0)
    end
    rd.append(recover [0x02; 0x02; 0x00; 0x80] end)
    match rd.read_value()?
    | let i: Asn1Integer => h.assert_eq[I64](i.i64(), 128)
    end
    rd.append(recover [0x02; 0x02; 0xFF; 0x7F] end)
    match rd.read_value()?
    | let i: Asn1Integer => h.assert_eq[I64](i.i64(), -129)
    end

class iso _TestSeq is UnitTest
  fun name(): String => "sequence"
  fun apply(h: TestHelper)? =>
    let rd: BerReader ref = BerReader
    rd.append(recover [0x30; 0x0b; 0x02; 0x01; 0x00; 0x04; 0x06; 0x70; 0x75; 0x62; 0x6C; 0x69; 0x63] end)
    match rd.read_value()?
    | let v: BeginStruct => true
    else
      h.fail("Expected BeginStruct")
    end
    match rd.read_value()?
    | let i: Asn1Integer => h.assert_eq[I64](i.i64(), 0)
    else
      h.fail("Expected INTEGER: 0")
    end
    match rd.read_value()?
    | let s: Asn1OctetString => h.assert_eq[String](s.string(), "public")
    else
      h.fail("Expected OCTET STRING: public")
    end
    match rd.read_value()?
    | let v: EndStruct => h.assert_is[EndStruct](v, EndStruct)
    else
      h.fail("Expected EndStruct")
    end

class iso _TestVLQ is UnitTest
  fun name(): String => "vlq"
  fun apply(h: TestHelper)? =>
    // from the exercism tests:
    let v = Vlq([0xc0; 0x00; 0xc8; 0xe8; 0x56; 0xff; 0xff; 0xff; 0x7f; 0x00; 0xff; 0x7f; 0x81; 0x80; 0x00].values())
    h.assert_eq[U64](0x2000, v.next()?)
    h.assert_eq[U64](0x123456, v.next()?)
    h.assert_eq[U64](0x0fffffff, v.next()?)
    h.assert_eq[U64](0x00, v.next()?)
    h.assert_eq[U64](0x3fff, v.next()?)
    h.assert_eq[U64](0x4000, v.next()?)
  
class iso _TestOID is UnitTest
  fun name(): String => "oid"
  fun apply(h: TestHelper) =>
    // from the exercism tests:
    let oid = Asn1ObjectIdentifier.from_ber(
      recover [0x2b; 0x06; 0x01; 0x04; 0x01; 0x82; 0x3e
               0x01; 0x01; 0x0c; 0x01; 0x02; 0x00] end)
    h.assert_eq[String]("1.3.6.1.4.1.318.1.1.12.1.2.0", oid.string())
