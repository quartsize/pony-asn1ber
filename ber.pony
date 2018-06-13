use "buffered"

class BeginStruct
  let tagclass: U8
  let tagnumber: U64
  new create(c: U8 = 0, n: U64) => tagclass = c; tagnumber = n
primitive EndStruct


class BerReader
  embed _rd: Reader ref = Reader
  var count: USize = 0
  var stack: Array[USize] = Array[USize]()

  fun ref next_octet(): U8? =>
    let o = _rd.u8()?
    count = count + 1
    o


  fun ref append(data: (String val | Array[U8 val] val)): None val =>
    _rd.append(data)


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


  fun ref read_vlq(): U64? =>
    var o: U8
    var u = U64(0)
    repeat
      o = next_octet()?
      u = (u << 7) + (o and 0x7f).u64()
    until (o and 0x80) == 0 end
    u


  fun ref read_id(): (Bool, U8, U64)? =>
    let first_id_octet = next_octet()?
    var constructed: Bool = (first_id_octet and 0x20) == 0x20
    var tag_class: U8 = (first_id_octet and 0xc) >> 6
    var tag_number: U64 = (first_id_octet and 0x1F).u64()
    if tag_number == 0x1F then
      tag_number = read_vlq()?
    end
    (constructed, tag_class, tag_number)


  fun ref read_value(): (String | Signed | BeginStruct | EndStruct)? =>
    if (stack.size() > 0) and (count == stack(stack.size()-1)?) then
      stack.pop()?
      return EndStruct
    end

    (let constructed, let tag_class, let tag_number) = read_id()?
    var c = read_length()?

    if constructed then
      stack.push(count + c)
      BeginStruct(tag_class,tag_number)
    else
      match tag_number
      | 4 =>
        var s = recover String(c) end
        while c > 0 do
          c = c - 1
          s.push(next_octet()?)
        end
        s
      | 2 =>
        let o = next_octet()?
        c = c - 1
        var a = (o and 0x7f).i64() - (o and 0x80).i64()
        while c > 0 do
          c = c - 1
          a = (a << 8) + next_octet()?.i64()
        end
        a
      else
        error
      end
    end

