use "files"
use "debug"
use "collections"

actor Main
  let env: Env
  let data: Array[Array[I8]] = []
  let visibility: Array[Array[Bool]] = []

  var max_x: USize = 0
  var max_y: USize = 0

  new create(env': Env) =>
    env = env'

    for filename in env.args.slice(1).values() do
      try
        process_file(filename)?

        max_x = data.size()
        max_y = data(0)?.size()
      else
        env.out.print("I DED")
      end

      try
        var xptr: USize = 0
        while (xptr < max_x) do
          // Left To Right
          var valline: Array[I8] = extract_left_to_right(xptr)?
          var visline: Array[Bool] = calc_visibility(valline)
          or_left_to_right(xptr, visline)?

          // Right To Left
          valline = valline.reverse()
          visline = calc_visibility(valline)
          or_left_to_right(xptr, visline.reverse())?
          xptr = xptr + 1
        end

        var yptr: USize = 0
        while (yptr < max_y) do
          // Top To Bottom
          var valline: Array[I8] = extract_top_to_bottom(yptr)?
          var visline: Array[Bool] = calc_visibility(valline)
          or_top_to_bottom(yptr, visline)?

          // Bottom To Top
          valline = valline.reverse()
          visline = calc_visibility(valline)
          or_top_to_bottom(yptr, visline.reverse())?

          yptr = yptr + 1
        end
      else
        env.out.print("OOF")
      end

      report_part_1()
    end

  fun ref extract_left_to_right(x: USize): Array[I8] ? =>
    data(x)?

  fun ref or_left_to_right(x: USize, d: Array[Bool]) ? =>
    var y: USize = 0
    for value in d.values() do
      if (value) then
        visibility(x)?(y)? = true
      end
      y = y + 1
    end

  fun ref extract_top_to_bottom(yptr: USize): Array[I8] ? =>
    let rv: Array[I8] = []
    var xptr: USize = 0

    while (xptr < max_x) do
      rv.push(data(xptr)?(yptr)?)
      xptr = xptr + 1
    end
    rv

  fun ref or_top_to_bottom(y: USize, d: Array[Bool]) ? =>
    var x: USize = 0
    for value in d.values() do
      if (value) then
        visibility(x)?(y)? = true
      end
      x = x + 1
    end

  fun calc_visibility(valline: Array[I8]): Array[Bool] =>
    let rv: Array[Bool] = Array[Bool]
    var tallesttree: I8 = -1

    for value in valline.values() do
      if (value > tallesttree) then
        rv.push(true)
        tallesttree = value
      else
        rv.push(false)
      end
    end
    rv

  fun report_part_1() =>
    var count: USize = 0

    for x in visibility.values() do
      for y in x.values() do
        if (y) then
          count = count + 1
        end
      end
    end
    env.out.print("Visible Locations: " + count.string()) // 1711




  fun ref process_file(filename: String val) ? =>
    if (false) then error end
    let path = FilePath(FileAuth(env.root), filename)
    match OpenFile(path)
    | let file: File =>
      let lines: FileLines = FileLines(file)

      for line in lines do
        (let a: Array[I8], let b: Array[Bool]) = process_line(consume line)
        data.push(a)
        visibility.push(b)
      end

    else
      Debug.err("Error opening file '" + filename + "'")
    end

  fun process_line(line: String): (Array[I8], Array[Bool]) =>
    let rv: Array[I8] = []
    let rv2: Array[Bool] = []

    for chr in line.values() do
      rv.push(chr.i8() - 48)
      rv2.push(false)
    end
    (rv, rv2)

