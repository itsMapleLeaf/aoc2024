import gleam/list
import gleam/string
import lib/solution.{Solution}
import lib/util

pub fn solution() {
  Solution(day: 9, example: "2333133121414131402", part1:, part2:)
}

fn part1(input) {
  input |> parse_disk_blocks |> compact_blocks |> disk_checksum
}

fn part2(input) {
  input
  |> parse_disk_spans
  |> compact_spans
  |> blocks_from_spans
  |> disk_checksum
}

type DiskChunk {
  DiskChunk(index: Int, file_length: Int, space_length: Int)
}

fn parse_disk_chunks(input: String) {
  input
  |> string.split("")
  |> list.sized_chunk(2)
  |> list.index_map(fn(chunk, index) {
    case chunk |> list.map(util.assert_parse_int) {
      [file_length, space_length] ->
        DiskChunk(index:, file_length:, space_length:)
      [file_length] -> DiskChunk(index:, file_length:, space_length: 0)
      _ -> panic
    }
  })
}

fn parse_disk_blocks(input: String) {
  parse_disk_chunks(input)
  |> list.flat_map(fn(chunk) {
    list.repeat(FileBlock(chunk.index), chunk.file_length)
    |> list.append(list.repeat(EmptyBlock, chunk.space_length))
  })
}

type Disk =
  List(DiskBlock)

type DiskBlock {
  FileBlock(id: Int)
  EmptyBlock
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
    let value = case block {
      EmptyBlock -> 0
      FileBlock(id:) -> id * index
    }
    count + value
  })
}

type SpanDisk =
  List(DiskSpan)

type DiskSpan {
  FileSpan(size: Int, id: Int)
  EmptySpan(size: Int)
}

fn parse_disk_spans(input: String) {
  parse_disk_chunks(input)
  |> list.fold([], fn(spans, chunk) {
    let spans = case chunk.file_length {
      0 -> spans
      size -> [FileSpan(id: chunk.index, size:), ..spans]
    }
    case chunk.space_length, spans {
      0, _ -> spans
      size, [EmptySpan(size: current_size), ..spans] -> [
        EmptySpan(size: size + current_size),
        ..spans
      ]
      size, _ -> [EmptySpan(size:), ..spans]
    }
  })
  |> list.reverse
}

fn compact_spans(disk: SpanDisk) {
  disk
  |> list.reverse
  |> list.fold(disk, fn(disk, span) {
    case span {
      EmptySpan(..) -> disk
      FileSpan(size:, id:) -> compact_file_span(disk, size, id)
    }
  })
}

fn compact_file_span(disk: SpanDisk, file_size: Int, file_id: Int) {
  case disk {
    [] -> {
      disk
    }
    [FileSpan(id:, ..), ..] if id == file_id -> {
      disk
    }
    [EmptySpan(size:), ..rest] if size == file_size -> {
      [FileSpan(size: file_size, id: file_id), ..erase_file_span(rest, file_id)]
    }
    [EmptySpan(size:), ..rest] if size > file_size -> {
      [
        FileSpan(size: file_size, id: file_id),
        EmptySpan(size: size - file_size),
        ..erase_file_span(rest, file_id)
      ]
    }
    [head, ..rest] -> {
      [head, ..compact_file_span(rest, file_size, file_id)]
    }
  }
}

fn erase_file_span(disk: SpanDisk, file_id: Int) {
  case disk {
    [] -> disk
    [FileSpan(id:, size:), EmptySpan(size: current_size), ..rest]
      if id == file_id
    -> {
      [EmptySpan(size: size + current_size), ..rest]
    }
    [FileSpan(id:, size:), ..rest] if id == file_id -> {
      [EmptySpan(size:), ..rest]
    }
    [head, ..rest] -> {
      [head, ..erase_file_span(rest, file_id)]
    }
  }
}

fn blocks_from_spans(disk: SpanDisk) {
  list.flat_map(disk, fn(span) {
    case span {
      EmptySpan(size:) -> list.repeat(EmptyBlock, size)
      FileSpan(size:, id:) -> list.repeat(FileBlock(id), size)
    }
  })
}

// fn spans_to_string(disk: SpanDisk) {
//   blocks_from_spans(disk)
//   |> list.map(block_to_string)
//   |> string.join(" ")
// }

// fn debug_disk_blocks(disk: List(DiskBlock)) {
//   let disk_output = blocks_to_string(disk)
//   io.println(disk_output <> " (" <> int.to_string(list.length(disk)) <> ")")
//   disk
// }

// fn blocks_to_string(disk: Disk) {
//   disk
//   |> list.map(block_to_string)
//   |> string.join(" ")
// }

// fn block_to_string(block) {
//   case block {
//     FileBlock(id) -> int.to_string(id)
//     EmptyBlock -> "."
//   }
// }

// fn is_file(block: DiskBlock) {
//   case block {
//     FileBlock(..) -> True
//     _ -> False
//   }
// }

fn is_space(block: DiskBlock) {
  case block {
    EmptyBlock -> True
    _ -> False
  }
}
