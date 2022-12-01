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
      let fl: FileLines = FileLines(file)
      let pa: PartA = PartA(env, fl)

      var callist: Array[USize] ref = recover Array[USize] end
      for v in pa.data.values() do
        callist.push(v)
      end

      callist = Sort[Array[USize], USize](callist)

      try
        env.out.print("(65912) MaxCal: " + callist.apply(callist.size()-1)?.string())
        var total3: USize = callist.pop()? + callist.pop()? + callist.pop()?
        env.out.print("(195625) Total for three: " + total3.string())
      end


    else
      env.err.print("Error opening file '" + filename + "'")
    end


class PartA
  let env: Env
  let data: Map[USize, USize] ref = recover Map[USize, USize] end
  var elfnum: USize = 1

  new create(env': Env, lines: FileLines) =>
    env = env'

    for line in lines do
      if (line == "") then
        elfnum = elfnum + 1
      else
        try data.update(elfnum, data.get_or_else(elfnum, 0) + line.usize()?) end
      end
    end

