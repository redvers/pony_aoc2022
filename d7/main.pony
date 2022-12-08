use "files"
use "debug"
use "collections"

type DirectoryEntry is (ElfFile | ElfDirectory)

actor Main
  let env: Env
  let rootptr: ElfDirectory = ElfDirectory.create("/", None)
  var dirptr: ElfDirectory

  new create(env': Env) =>
    env = env'
    dirptr = rootptr

    for filename in env.args.slice(1).values() do
      process_file(filename)
      calculate_space()

      let results: SetIs[ElfDirectory] = rootptr.all_directories()
      var p1tot: USize = 0 // 95437
      for elfdir in all_directories_less_100000(results).values() do
        p1tot = p1tot + elfdir.totalsize
      end
      env.out.print("Part 1: " + p1tot.string())

      env.out.print("Part 2:")
      env.out.print("Total used: " + rootptr.totalsize.string())
      let totalfree: USize = 70000000 - rootptr.totalsize
      env.out.print("Total Free: " + totalfree.string())
      let x: USize = 30000000 - totalfree
      env.out.print("Must Find:  " + x.string())

      var runningmin: USize = rootptr.totalsize
      for elfdir in all_directories_greater_x(results, x).values() do
        if (elfdir.totalsize < runningmin) then
          runningmin = elfdir.totalsize
        end
      end
      env.out.print("Part 2: " + runningmin.string())

    end


  fun ref calculate_space() =>
    rootptr.calculate_recurse()

  fun ref all_directories_less_100000(results: SetIs[ElfDirectory]): SetIs[ElfDirectory] =>
    let rv: SetIs[ElfDirectory] = SetIs[ElfDirectory]
    for elfdir in results.values() do
      if (elfdir.totalsize <= 100000) then
        rv.set(elfdir)
      end
    end
    rv

  fun ref all_directories_greater_x(results: SetIs[ElfDirectory], x: USize): SetIs[ElfDirectory] =>
    let rv: SetIs[ElfDirectory] = SetIs[ElfDirectory]
    for elfdir in results.values() do
      if (elfdir.totalsize >= x) then
        rv.set(elfdir)
      end
    end
    rv





  fun ref process_file(filename: String val) =>
    let path = FilePath(FileAuth(env.root), filename)
    match OpenFile(path)
    | let file: File =>
      let lines: FileLines = FileLines(file)

      /* POPULATE THE DATASTRUCTURE */
      for line in lines do
        let command: String val = consume line
        if (command == "$ cd /") then
          Debug.out("Change directory to root")
          dirptr = rootptr
          continue
        end

        if (command == "$ ls") then
          Debug.out("ls command issued in directory " + dirptr.string())
          Debug.out("What follows should be new files...")
          continue
        end

        if (command.at("$ cd ", 0)) then
          Debug.out("THIS IS A CD")
          let targetdir: String val = command.substring(5)
          Debug.out("find the internal ref for " + targetdir)
          dirptr = dirptr.cd(targetdir)
          continue
        end
        dirptr.add(command)
      end

    else
      Debug.err("Error opening file '" + filename + "'")
    end

class ElfFile
  let name: String
  let size: USize
  let parent: ElfDirectory

  new create(name': String, size': USize, parent': ElfDirectory) =>
    name = name'
    size = size'
    parent = parent'

  fun string(): String => name


class ElfDirectory
  let name: String
  let contents: Map[String, DirectoryEntry] = Map[String, DirectoryEntry]
  let parent: (ElfDirectory | None)
  var totalsize: USize = 0

  new create(name': String, parent': (ElfDirectory | None)) =>
    name = name'
    parent = parent'

  fun string(): String => name

  fun ref add(line: String val) =>
    var fname: String = ""
    if (line.at("dir ", 0)) then
      fname = line.substring(4)
      contents.insert(fname, ElfDirectory.create(fname, this))
      Debug.out("DIRECTORY: " + fname)
    else
      try
        let fta: Array[String] = line.split_by(" ")
        let size: USize = fta(0)?.usize()?
        fname = fta(1)?
        let newfile: ElfFile = ElfFile.create(fname, size, this)
        Debug.out("FILE: " + newfile.string() + " [" + newfile.size.string() + "]")
        contents.insert(fname, ElfFile.create(fname, size, this))
        else
          Debug.out("We failed to parse size")
        end
    end

  fun ref cd(directory: String val): ElfDirectory =>
    if (directory == "..") then
      match parent
      | let t: None => return this
      | let t: ElfDirectory => return t
      end
    end

    match contents.get_or_else(directory, this)
    | let t: ElfFile => return this
    | let t: ElfDirectory => return t
    end

    // This is never reached //
    this

  fun ref calculate_recurse(): USize =>
    for item in contents.values() do
      match item
      | let t: ElfFile => totalsize = totalsize + t.size
      | let t: ElfDirectory => totalsize = totalsize + t.calculate_recurse()
      end
    end
    Debug.out("Total for " + name + ": " + totalsize.string())
    totalsize

  fun ref all_directories(): SetIs[ElfDirectory] =>
    let rv: SetIs[ElfDirectory] = SetIs[ElfDirectory].>set(this)
    for item in contents.values() do
      match item
      | let t: ElfDirectory => rv.union(t.all_directories().values())
      | let t: ElfFile => None
      end
    end
    rv



