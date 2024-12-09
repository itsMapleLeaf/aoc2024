import gleam/float
import gleam/int
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}
import lib/util

pub type Vec {
  Vec(x: Int, y: Int)
}

pub const zero = Vec(0, 0)

pub const one = Vec(1, 1)

pub const left = Vec(-1, 0)

pub const right = Vec(1, 0)

pub const up = Vec(0, -1)

pub const down = Vec(0, 1)

pub fn of(x: Int, y: Int) -> Vec {
  Vec(x:, y:)
}

pub fn get_x(vec: Vec) {
  vec.x
}

pub fn get_y(vec: Vec) {
  vec.y
}

pub fn map(vec: Vec, with mapper: fn(Int) -> Int) {
  of(mapper(vec.x), mapper(vec.y))
}

pub fn zip(a: Vec, b: Vec, with zipper: fn(Int, Int) -> Int) {
  of(zipper(a.x, b.x), zipper(a.y, b.y))
}

pub fn add(a: Vec, b: Vec) -> Vec {
  zip(a, b, int.add)
}

pub fn subtract(a: Vec, b: Vec) -> Vec {
  zip(a, b, int.subtract)
}

pub fn multiply(a: Vec, b: Vec) -> Vec {
  zip(a, b, int.multiply)
}

pub fn divide(a: Vec, b: Vec) -> Vec {
  of(a.x / b.x, a.y / b.y)
}

pub fn scale(vec: Vec, factor: Int) -> Vec {
  map(vec, int.multiply(_, factor))
}

pub fn unscale(vec: Vec, factor: Int) -> Vec {
  of(vec.x / factor, vec.y / factor)
}

pub fn sign(vec: Vec) {
  map(vec, util.int_sign)
}

pub fn distance(from a: Vec, to b: Vec) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  int.to_float(dx * dx + dy * dy)
  |> float.square_root
  |> result.lazy_unwrap(fn() {
    panic as string.concat([
      "distance result was negative (",
      string.inspect(a),
      ", ",
      string.inspect(b),
      ")",
    ])
  })
}

pub fn closest(reference: Vec, a: Vec, b: Vec) {
  case distance(reference, a) <. distance(reference, b) {
    True -> a
    False -> b
  }
}

pub fn normalize(vec: Vec) -> Vec {
  case vec {
    Vec(0, 0) -> vec
    Vec(x, y) ->
      unscale(vec, int.max(int.absolute_value(x), int.absolute_value(y)))
  }
}

pub fn direction(from start: Vec, to other: Vec) {
  normalize(subtract(other, start))
}

pub fn min(a: Vec, b: Vec) -> Vec {
  zip(a, b, int.min)
}

pub fn max(a: Vec, b: Vec) -> Vec {
  zip(a, b, int.max)
}

pub fn clamp(vec: Vec, min: Vec, max: Vec) {
  of(int.clamp(vec.x, min.x, max.x), int.clamp(vec.y, min.y, max.y))
}

pub fn normalize_corners(a: Vec, b: Vec) {
  #(min(a, b), max(a, b))
}

pub fn rotate_right(vec: Vec) {
  of(vec.y * -1, vec.x)
}

pub fn range(from start: Vec, to end: Vec) -> Yielder(Vec) {
  yielder.flat_map(yielder.range(start.x, end.x), fn(x) {
    yielder.map(yielder.range(start.y, end.y), fn(y) { of(x, y) })
  })
}

pub fn segment_contains(segment: #(Vec, Vec), point: Vec) {
  float.loosely_equals(
    distance(segment.0, point) +. distance(segment.1, point),
    distance(segment.0, segment.1),
    0.00001,
  )
}
