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
        left_to_right()?
        env.out.print("-----")
        right_to_left()?
        env.out.print("-----")
        bottom_to_top()?
        env.out.print("-----")
        top_to_bottom()?
        env.out.print("-----")
      else
        env.out.print("OOF")
      end

      report_part_1()
    end

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


  fun ref left_to_right() ? =>
    var xptr: USize = 0
    var yptr: USize = 0

    env.out.print("Forest has dimensions: " + max_x.string() + " x " + max_y.string())

    while (xptr < max_x) do
      var tallesttree: I8 = -1
      while (yptr < max_y) do
        if (data(xptr)?(yptr)? > tallesttree) then
          env.out.write("*")
          tallesttree = data(xptr)?(yptr)?
          visibility(xptr)?(yptr)? = true
        end
        env.out.write(data(xptr)?(yptr)?.string())
        yptr = yptr + 1
      end
      env.out.print("")
      xptr = xptr + 1
      yptr = 0
    end

  fun ref right_to_left() ? =>
    var xptr: USize = 0
    var yptr: USize = max_y - 1

    while (xptr < max_x) do
      var tallesttree: I8 = -1
      while (yptr.isize() >= 0) do
        if (data(xptr)?(yptr)? > tallesttree) then
          env.out.write("*")
          tallesttree = data(xptr)?(yptr)?
          visibility(xptr)?(yptr)? = true
        end
        env.out.write(data(xptr)?(yptr)?.string())
        yptr = yptr - 1
      end
      xptr = xptr + 1
      yptr = max_y - 1
      env.out.print("")
    end

  fun ref top_to_bottom() ? =>
    var xptr: USize = 0
    var yptr: USize = 0

    while (yptr < max_y) do
      var tallesttree: I8 = -1
      while (xptr < max_x) do
        if (data(xptr)?(yptr)? > tallesttree) then
          env.out.write("*")
          tallesttree = data(xptr)?(yptr)?
          visibility(xptr)?(yptr)? = true
        end
        env.out.write(data(xptr)?(yptr)?.string())
        xptr = xptr + 1
      end
      env.out.print("")
      yptr = yptr + 1
      xptr = 0
    end
  fun ref bottom_to_top() ? =>
    var xptr: USize = max_x - 1
    var yptr: USize = 0

    while (yptr < max_y) do
      var tallesttree: I8 = -1
      while (xptr < max_x) do
        if (data(xptr)?(yptr)? > tallesttree) then
          env.out.write("*")
          tallesttree = data(xptr)?(yptr)?
          visibility(xptr)?(yptr)? = true
        end
        env.out.write(data(xptr)?(yptr)?.string())
        xptr = xptr - 1
      end
      yptr = yptr + 1
      xptr = max_x - 1
      env.out.print("")
    end



  fun process_line(line: String): (Array[I8], Array[Bool]) =>
    let rv: Array[I8] = []
    let rv2: Array[Bool] = []

    for chr in line.values() do
      rv.push(chr.i8() - 48)
      rv2.push(false)
    end
    (rv, rv2)

