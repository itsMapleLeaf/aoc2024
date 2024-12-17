import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder
import lib/solution.{Solution}
import lib/util

type Disk =
  List(DiskBlock)

type DiskBlock {
  FileBlock(id: Int)
  EmptyBlock
}

pub fn solution() {
  Solution(
    day: 9,
    example: "2333133121414131402",
    part1: fn(input) { input |> parse_disk |> compact_blocks |> disk_checksum },
    part2: fn(input) { todo },
  )
}

fn parse_disk(input: String) {
  let indexed_chunks =
    input
    |> string.split("")
    |> list.sized_chunk(2)
    |> list.index_map(fn(chunk, index) {
      #(chunk |> list.map(util.assert_parse_int), index)
    })

  indexed_chunks
  |> list.flat_map(fn(entry) {
    case entry {
      #([file_length, space_length], id) -> {
        list.repeat(FileBlock(id), file_length)
        |> list.append(list.repeat(EmptyBlock, space_length))
      }
      #([file_length], id) -> {
        list.repeat(FileBlock(id), file_length)
      }
      _ -> panic
    }
  })
}

fn compact_blocks(disk: Disk) {
  let space_count = disk |> list.count(is_space)
  let tail = disk |> list.reverse |> list.take(space_count)
  let compacted = compact_blocks_rec(disk, tail, [])

  // the compaction will exit before getting all the compacted blocks,
  // so we need to get whatever's left over
  let extra =
    disk
    |> list.drop(list.length(compacted))
    |> list.take(list.length(disk) - list.length(compacted) - space_count)

  compacted |> list.append(extra)
}

fn compact_blocks_rec(disk: Disk, tail: Disk, result: Disk) {
  case disk, tail {
    [], _ -> panic
    _, [] -> {
      result |> list.reverse
    }
    [FileBlock(..) as file, ..disk], _ -> {
      compact_blocks_rec(disk, tail, [file, ..result])
    }
    _, [EmptyBlock, ..tail] -> {
      compact_blocks_rec(disk, tail, result)
    }
    [EmptyBlock, ..disk], [FileBlock(..) as file, ..tail] -> {
      compact_blocks_rec(disk, tail, [file, ..result])
    }
  }
}

fn disk_checksum(disk: Disk) {
  list.index_fold(disk, 0, fn(count, block, index) {
    let assert FileBlock(id) = block
    count + id * index
  })
}

fn debug_disk(disk: List(DiskBlock)) {
  let disk_output =
    disk
    |> list.map(fn(block) {
      case block {
        FileBlock(id) -> int.to_string(id)
        EmptyBlock -> "."
      }
    })
    |> string.join(" ")
  io.println(disk_output <> " (" <> int.to_string(list.length(disk)) <> ")")
  disk
}

fn pop_length_while_rec(
  list: List(a),
  count: Int,
  condition: fn(a) -> Bool,
  result: List(a),
) {
  case list, count {
    _, 0 | [], _ -> #(list.reverse(result), list)
    [x, ..rest], count -> {
      case condition(x) {
        True -> pop_length_while_rec(rest, count - 1, condition, [x, ..result])
        False -> pop_length_while_rec(rest, count, condition, result)
      }
    }
  }
}

fn is_file(block: DiskBlock) {
  case block {
    FileBlock(..) -> True
    _ -> False
  }
}

fn is_space(block: DiskBlock) {
  case block {
    EmptyBlock -> True
    _ -> False
  }
}
