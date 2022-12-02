use "files"
use "collections"

actor Main
  let env: Env

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

      let callist: Array[USize] = Sort[Array[USize], USize](process(lines))
      try
        // The highest value is the last value.
        env.out.print("(65912) MaxCal: " + callist.apply(callist.size()-1)?.string())

        // The highest three can be just popped off the top and summed
        var total3: USize = callist.pop()? + callist.pop()? + callist.pop()?
        env.out.print("(195625) Total for three: " + total3.string())
      end
    else
      env.err.print("Error opening file '" + filename + "'")
    end

  fun process(lines: FileLines): Array[USize] =>
    let data: Array[USize] ref = Array[USize]
    for line in lines do
      if (line == "") then
        data.push(0)
      else
        try data.push(data.pop()? + line.usize()?) end
      end
    end
    data

