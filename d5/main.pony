use "files"
use "collections"

use @printf[I32](fmt: Pointer[U8] tag, ...)

actor Main
  let env: Env
  let stack: Array[Array[String] ref] ref = [[] ; [] ; []; []; []; []; []; []; []]

  new create(env': Env) =>
    env = env'
    for filename in env.args.slice(1).values() do
      process_file(filename)
    end

  fun ref process_file(filename: String val) =>
    let path = FilePath(FileAuth(env.root), filename)
    match OpenFile(path)
    | let file: File =>
      let lines: FileLines = FileLines(file)

      var first: Bool = true

      let statetext: Array[String val] ref = []
      let movetext: Array[String val] ref = []

      for line in lines do
        if (line == "") then
          first = false
          continue
        else
          false
        end
        env.out.print(first.string() + ": " + line.clone())
        if (first) then statetext.push(consume line) else movetext.push(consume line) end
      end

      make_stacks(statetext)
      print_stack()
      for moveline in movetext.values() do
        try decode_and_move(moveline)? else env.out.print("FAIL") end
      end
      try
        print_final()?
      else
        env.out.print("It all went horribly wrong")
      end


    else
      env.err.print("Error opening file '" + filename + "'")
    end


  fun print_final()? =>
    env.out.write("Final Result: ")
    for str in stack.values() do
      env.out.write(str(str.size() -1)?)
    end
    env.out.print("")


  fun print_stack() =>
    env.out.print("")
    for (index, line) in stack.pairs() do
      env.out.write("Index: ->" + index.string() + ": ")
      for chrstr in line.values() do
        env.out.write(chrstr)
      end
      env.out.print("<-")
    end
    env.out.print("")

  fun ref decode_and_move(line: String val) ? =>
    var tokens: Array[String] = line.split_by(" ")
    let count: USize = tokens(1)?.usize()?
    let from: USize = tokens(3)?.usize()?
    let to: USize = tokens(5)?.usize()?
    env.out.print("Count: " + count.string())
    env.out.print("From: " + from.string())
    env.out.print("To: " + to.string())
    moves(count, from, to)

  fun ref moves(count: USize, from: USize, to: USize) =>
    var cnt: USize = count
    while (cnt > 0) do
      move(from, to)
      cnt = cnt - 1
    end
    print_stack()

  fun dline(line: Array[String val] ref) =>
    env.out.write("dline: ")
    for f in line.values() do
      env.out.write(f)
    end
    env.out.print("")

  fun ref move(from: USize, to: USize) =>
    env.out.print(from.string() + " -> " + to.string())
    try
    let arrayfrom: USize = from - 1
    let arrayto: USize = to - 1
    var darray: Array[String] = stack(arrayto)?
    var farray: Array[String] = stack(arrayfrom)?

    let carried: String val = farray.pop()?
    env.out.print("carried: " + carried)
    darray.push(carried)
    else
      env.out.print("Failed to move")
    end


  fun ref make_stacks(text: Array[String val] ref) =>
    try
      text.pop()? // Throw away numbers
      while true do
        var line: String val = text.pop()?
        var index: U8 = 0
        for ptr in Range.create(1, line.size(), 4) do
          let c: U8 val = line.at_offset(ptr.isize())?
          if (c != ' ') then
            stack(index.usize())?.push(String.from_array([c]))
          end
        index = index + 1
        end
      end
    end








