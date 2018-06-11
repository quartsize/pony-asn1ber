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
    test(_TestIntegers)
    test(_TestSeq)

class iso _TestLengthShort is UnitTest
  fun name(): String => "short form length"
  fun apply(h: TestHelper)? =>
    h.assert_eq[USize](BER([0x42].values()).read_length()?, 0x42)

class iso _TestLengthLong is UnitTest
  fun name(): String => "long form length"
  fun apply(h: TestHelper)? =>
    h.assert_eq[USize](BER([0x83; 0x42; 0x41; 0x40].values()).read_length()?, 0x424140)

class iso _TestStrings is UnitTest
  fun name(): String => "strings"
  fun apply(h: TestHelper)? =>
    match BER([0x04; 0x06; 0x70; 0x75; 0x62; 0x6C; 0x69; 0x63].values()).read_value()?
    | let s: String => h.assert_eq[String](s, "public")
    end
    match BER([0x04; 0x07; 0x70; 0x72; 0x69; 0x76; 0x61; 0x74; 0x65].values()).read_value()?
    | let s: String => h.assert_eq[String](s, "private")
    end

class iso _TestIntegers is UnitTest
  fun name(): String => "integers"
  fun apply(h: TestHelper)? =>
    match BER([0x02; 0x01; 0x00].values()).read_value()?
    | let i: I64 => h.assert_eq[I64](i, 0)
    end
    match BER([0x02; 0x02; 0x00; 0x80].values()).read_value()?
    | let i: I64 => h.assert_eq[I64](i, 128)
    end
    match BER([0x02; 0x02; 0xFF; 0x7F].values()).read_value()?
    | let i: I64 => h.assert_eq[I64](i, -129)
    end

class iso _TestSeq is UnitTest
  fun name(): String => "sequence"
  fun apply(h: TestHelper)? =>
    var ber = BER([0x30; 0x0b; 0x02; 0x01; 0x00; 0x04; 0x06; 0x70; 0x75; 0x62; 0x6C; 0x69; 0x63].values())
    match ber.read_value()?
    | let v: BeginStruct => true
    else
      h.fail("Expected BeginStruct")
    end
    match ber.read_value()?
    | let i: I64 => h.assert_eq[I64](i, 0)
    else
      h.fail("Expected INTEGER: 0")
    end
    match ber.read_value()?
    | let s: String => h.assert_eq[String](s, "public")
    else
      h.fail("Expected OCTET STRING: public")
    end
    match ber.read_value()?
    | let v: EndStruct => h.assert_is[EndStruct](v, EndStruct)
    else
      h.fail("Expected EndStruct")
    end
