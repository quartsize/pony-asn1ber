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

class iso _TestLengthShort is UnitTest
  fun name(): String => "short form length"
  fun apply(h: TestHelper)? =>
    h.assert_eq[USize](Ber.read_length([0x42].values())?, 0x42)

class iso _TestLengthLong is UnitTest
  fun name(): String => "long form length"
  fun apply(h: TestHelper)? =>
    h.assert_eq[USize](Ber.read_length([0x83; 0x42; 0x41; 0x40].values())?, 0x424140)

class iso _TestStrings is UnitTest
  fun name(): String => "strings"
  fun apply(h: TestHelper)? =>
    match Ber.read_value([0x04; 0x06; 0x70; 0x75; 0x62; 0x6C; 0x69; 0x63].values())?
    | let s: String => h.assert_eq[String](s, "public")
    end
    match Ber.read_value([0x04; 0x07; 0x70; 0x72; 0x69; 0x76; 0x61; 0x74; 0x65].values())?
    | let s: String => h.assert_eq[String](s, "private")
    end

class iso _TestIntegers is UnitTest
  fun name(): String => "integers"
  fun apply(h: TestHelper)? =>
    match Ber.read_value([0x02; 0x01; 0x00].values())?
    | let i: I64 => h.assert_eq[I64](i, 0)
    end
    match Ber.read_value([0x02; 0x02; 0x00; 0x80].values())?
    | let i: I64 => h.assert_eq[I64](i, 128)
    end
    match Ber.read_value([0x02; 0x02; 0xFF; 0x7F].values())?
    | let i: I64 => h.assert_eq[I64](i, -129)
    end

