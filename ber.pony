primitive BeginSeq
primitive EndStruct

class BER
  var input: Iterator[U8]
  var count: USize = 0
  var stack: Array[USize] = Array[USize]()

  new create(input': Iterator[U8]) =>
    input = input'

  fun ref next_octet(): U8? =>
    let o = input.next()?
    count = count + 1
    o

  fun ref read_length(): USize? =>
    let first_octet = next_octet()?

    if first_octet < 0x80 then
      first_octet.usize()
    elseif first_octet == 0x80 then
      error // unimplemented
    else
      var c = first_octet and 0x7f
      var a = USize(0)
      while c > 0 do
        c = c - 1
        a = (a << 8) + next_octet()?.usize()
      end
      a
    end

  fun ref read_value(): (String | Signed | BeginSeq | EndStruct)? =>
    if (stack.size() > 0) and (count == stack(stack.size()-1)?) then
      stack.pop()?
      return EndStruct
    end

    match next_octet()?
    | 0x04 =>
      var c = read_length()?
      var s = recover String(c) end
      while c > 0 do
        c = c - 1
        s.push(next_octet()?)
      end
      s
    | 0x02 =>
      var c = read_length()? - 1
      let o = next_octet()?
      var a = (o and 0x7f).i64() - (o and 0x80).i64()
      while c > 0 do
        c = c - 1
        a = (a << 8) + next_octet()?.i64()
      end
      a
    | 0x30 =>
      var l = read_length()?
      stack.push(count + l)
      BeginSeq
    else
      error
    end

