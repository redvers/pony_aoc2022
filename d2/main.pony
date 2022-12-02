use "files"
use "debug"
use "collections"

type Move is (Rock | Paper | Scissors)
type Result is (Win | Lose | Draw)

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

      var total1: USize = 0
      var total2: USize = 0
      try
      for game in lines do
        let gm: Array[String] = game.split_by(" ")

        // Part 1
        let elf: Move = DecodeMove(gm.apply(0)?)?
        let me:  Move = DecodeMove(gm.apply(1)?)?

        // Part 2
        let result: Result = DecodeResult(gm.apply(1)?)?

        // In Part 1, we play and score the game
        let score1: USize = me.play(elf)
        total1 = total1 + score1

        Debug.out("Part1: Elf Move: " + elf.string() + ", My Move: " + me.string() + " => " + score1.string())

        // In Part 2, we deduce what our move should be and
        // then score it the same way as Part 1
        let im: Move = result.i_must_play(elf)
        let score2: USize = im.play(elf)
        total2 = total2 + score2

        Debug.out("Part2: Elf Move: " + elf.string() + ", Required Result: " + result.string() + ", I Must Play: " + im.string() + " => " + score2.string())

      end
      env.out.print("Final Score1: " + total1.string()) // 10595
      env.out.print("Final Score2: " + total2.string()) // 9541
      end
    else
      env.err.print("Error opening file '" + filename + "'")
    end


primitive DecodeMove
  fun apply(c: String): Move ? =>
    match c
    | "A" => Rock
    | "B" => Paper
    | "C" => Scissors
    | "X" => Rock
    | "Y" => Paper
    | "Z" => Scissors
    else
      error
    end

primitive DecodeResult
  fun apply(c: String): Result ? =>
    match c
    | "X" => Lose
    | "Y" => Draw
    | "Z" => Win
    else
      error
    end


primitive Rock
  fun play(t: Move): USize =>
    match t
    | Rock => 3 + 1
    | Paper => 0 + 1
    | Scissors => 6 + 1
    end

  fun string(): String => "Rock"


primitive Paper
  fun play(t: Move): USize =>
    match t
    | Rock => 6 + 2
    | Paper => 3 + 2
    | Scissors => 0 + 2
    end

  fun string(): String => "Paper"


primitive Scissors
  fun play(t: Move): USize =>
    match t
    | Rock => 0 + 3
    | Paper => 6 + 3
    | Scissors => 3 + 3
    end

  fun string(): String => "Scissors"


primitive Win
  fun string(): String => "Win"
  fun i_must_play(m: Move): Move =>
    match m
    | Rock => Paper
    | Paper => Scissors
    | Scissors => Rock
    end

primitive Lose
  fun string(): String => "Lose"
  fun i_must_play(m: Move): Move =>
    match m
    | Rock => Scissors
    | Paper => Rock
    | Scissors => Paper
    end

primitive Draw
  fun string(): String => "Draw"
  fun i_must_play(m: Move): Move =>
    match m
    | Rock => Rock
    | Paper => Paper
    | Scissors => Scissors
    end

