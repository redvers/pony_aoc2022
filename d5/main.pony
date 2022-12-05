use "files"
use "collections"

type CrateMoverModel is (CrateMover9000 | CrateMover9001)

actor Main
  let env: Env

  new create(env': Env) =>
    env = env'
    for filename in env.args.slice(1).values() do
      CrateMover(env, filename, CrateMover9000).process_file()  // GFTNRBZPF
      CrateMover(env, filename, CrateMover9001).process_file()  // VRQWPDSGP
    end

class CrateMover
  let env: Env
  let cmmodel: CrateMoverModel
  let filename: String val
  let stack: Map[USize, String ref] = Map[USize, String ref]

  new create(env': Env, filename': String val, cmmodel': CrateMoverModel) =>
    env = env'
    filename = filename'
    cmmodel = cmmodel'

  fun ref process_file() =>
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
        if (first) then statetext.push(consume line) else movetext.push(consume line) end
      end

      file.dispose()

      make_stacks(statetext)

			for moveline in movetext.values() do
				try decode_and_move(moveline)? else env.out.print("FAIL") end
			end

      print_stacks()
      print_result()
    else
      env.err.print("Error opening file '" + filename + "'")
    end

  fun ref decode_and_move(line: String val) ? =>
    var tokens: Array[String] = line.split_by(" ")
    let count: USize = tokens(1)?.usize()?
    let from: USize = tokens(3)?.usize()?
    let to: USize = tokens(5)?.usize()?
    cmmodel.moves(stack, count, from, to)

  fun print_stacks() =>
    try
      for index in Range(1,10) do
        env.out.print(index.string() + ": " + stack(index)?)
      end
    end

  fun ref print_result() =>
    try
			env.out.write("[" + cmmodel.string() + "]: ")
			env.out.write("Final Result: ")
      for index in Range(1,10) do
				let offset: USize = stack(index)?.size() - 1
        env.out.write(stack(index)?.substring(offset.isize()))
      end
    end
		env.out.print("")

  fun ref make_stacks(text: Array[String val] ref) =>
    try
      text.pop()? // Throw away numbers
      while true do
        var line: String val = text.pop()?
        var index: USize = 1
        for ptr in Range.create(1, line.size(), 4) do
          let c: U8 val = line.at_offset(ptr.isize())?
          if (c != ' ') then
            var stackline: String ref = stack.get_or_else(index, recover String end)
            stackline.push(c)
            stack.insert(index, stackline)
          end
        index = index + 1
        end
      end
    end


primitive CrateMover9000
  fun string(): String => "CrateMover9000"

  fun moves(stack: Map[USize, String ref], count: USize, from: USize, to: USize) =>
    var cnt: USize = count
    while (cnt > 0) do
      try move(stack, from, to)? end
      cnt = cnt - 1
    end

  fun move(stack: Map[USize, String ref], from: USize, to: USize) ? =>
    let carried: U8 = stack(from)?.pop()?
	  stack(to)?.push(carried)

primitive CrateMover9001
  fun string(): String => "CrateMover9001"

  fun moves(stack: Map[USize, String ref], count: USize, from: USize, to: USize) =>
    try
      var size: USize = stack(from)?.size()
      var snip: String ref = stack(from)?.substring((size - count).isize())
      stack(from)?.truncate(size - count)
      stack(to)?.append(snip)
    end

