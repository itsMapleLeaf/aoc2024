import gleam/set.{type Set}
import gleam/yielder
import lib/vec.{type Vec}

pub type Board {
  Board(
    size: Vec,
    position: Vec,
    direction: Vec,
    obstacles: Set(Vec),
    tracks: Set(Vec),
  )
}

pub fn new(size: Vec) {
  Board(
    size:,
    position: vec.zero,
    direction: vec.zero,
    obstacles: set.new(),
    tracks: set.new(),
  )
}

pub fn init_cursor(board: Board, position: Vec, direction: Vec) {
  board
  |> set_position(position)
  |> set_direction(direction)
}

pub fn set_position(board: Board, position: Vec) {
  Board(..board, position:, tracks: set.insert(board.tracks, position))
}

pub fn move_to(board: Board, destination: Vec) {
  Board(
    ..board,
    position: destination,
    tracks: set.union(
      board.tracks,
      vec.range(board.position, destination)
        |> yielder.to_list
        |> set.from_list,
    ),
  )
}

pub fn set_direction(board: Board, direction: Vec) {
  Board(..board, direction:)
}

pub fn add_obstacle(board: Board, position: Vec) {
  Board(
    ..board,
    obstacles: set.union(board.obstacles, set.from_list([position])),
  )
}

pub fn complete_patrol(board: Board) -> Board {
  let edge_point = edge_facing_point(board)

  let closest_in_path =
    vec.range(board.position, edge_point)
    |> yielder.find(set.contains(board.obstacles, _))

  // util.print_debug("board.position", board.position)
  // util.print_debug("board.direction", board.direction)
  // util.print_debug("board.size", board.size)
  // util.print_debug("obstacles_in_path", obstacles_in_path)
  // util.print_debug("closest_in_path", closest_in_path)
  // util.print_debug("edge_facing_point", edge_point)
  // io.println("---")

  case closest_in_path {
    Error(_) -> {
      board |> move_to(edge_point)
    }
    Ok(obstacle_position) -> {
      // our new position is one back from the obstacle
      let new_position = obstacle_position |> vec.subtract(board.direction)

      board
      |> move_to(new_position)
      |> set_direction(board.direction |> vec.rotate_right)
      |> complete_patrol
    }
  }
}

fn edge_facing_point(board: Board) {
  board.position
  |> vec.add(vec.multiply(board.direction, board.size))
  |> vec.clamp(vec.zero, board.size |> vec.subtract(vec.one))
}
