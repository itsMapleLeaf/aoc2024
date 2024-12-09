import gleam/yielder
import gleeunit/should
import vec

pub fn rotate_right_test() {
  vec.rotate_right(vec.down) |> should.equal(vec.left)
  vec.rotate_right(vec.left) |> should.equal(vec.up)
  vec.rotate_right(vec.up) |> should.equal(vec.right)
  vec.rotate_right(vec.right) |> should.equal(vec.down)
  vec.rotate_right(vec.zero) |> should.equal(vec.zero)
}

pub fn normalize_test() {
  vec.normalize(vec.of(2, 4)) |> should.equal(vec.of(0, 1))
  vec.normalize(vec.of(4, 2)) |> should.equal(vec.of(1, 0))
  vec.normalize(vec.of(-2, -4)) |> should.equal(vec.of(0, -1))
  vec.normalize(vec.of(-4, -2)) |> should.equal(vec.of(-1, 0))
  vec.normalize(vec.zero) |> should.equal(vec.zero)
}

pub fn add_test() {
  vec.add(vec.of(1, 2), vec.of(3, 4)) |> should.equal(vec.of(4, 6))
  vec.add(vec.zero, vec.one) |> should.equal(vec.one)
  vec.add(vec.of(-1, -2), vec.of(1, 2)) |> should.equal(vec.zero)
}

pub fn subtract_test() {
  vec.subtract(vec.of(4, 6), vec.of(1, 2)) |> should.equal(vec.of(3, 4))
  vec.subtract(vec.one, vec.one) |> should.equal(vec.zero)
  vec.subtract(vec.of(1, 2), vec.of(3, 4)) |> should.equal(vec.of(-2, -2))
}

pub fn multiply_test() {
  vec.multiply(vec.of(2, 3), vec.of(3, 2)) |> should.equal(vec.of(6, 6))
  vec.multiply(vec.one, vec.one) |> should.equal(vec.one)
  vec.multiply(vec.zero, vec.of(5, 5)) |> should.equal(vec.zero)
}

pub fn scale_test() {
  vec.scale(vec.of(2, 3), 2) |> should.equal(vec.of(4, 6))
  vec.scale(vec.one, 5) |> should.equal(vec.of(5, 5))
  vec.scale(vec.of(-1, -2), 3) |> should.equal(vec.of(-3, -6))
}

pub fn unscale_test() {
  vec.unscale(vec.of(4, 6), 2) |> should.equal(vec.of(2, 3))
  vec.unscale(vec.of(5, 5), 5) |> should.equal(vec.one)
  vec.unscale(vec.of(-6, -9), 3) |> should.equal(vec.of(-2, -3))
}

pub fn sign_test() {
  vec.sign(vec.of(5, -5)) |> should.equal(vec.of(1, -1))
  vec.sign(vec.zero) |> should.equal(vec.zero)
  vec.sign(vec.of(-3, 3)) |> should.equal(vec.of(-1, 1))
}

pub fn distance_test() {
  vec.distance(from: vec.zero, to: vec.of(3, 4)) |> should.equal(5.0)
  vec.distance(from: vec.of(1, 1), to: vec.of(4, 5)) |> should.equal(5.0)
  vec.distance(from: vec.zero, to: vec.zero) |> should.equal(0.0)
}

pub fn closest_test() {
  vec.closest(vec.zero, vec.of(1, 1), vec.of(3, 3))
  |> should.equal(vec.of(1, 1))
  vec.closest(vec.of(5, 5), vec.of(3, 3), vec.of(6, 6))
  |> should.equal(vec.of(6, 6))
}

pub fn direction_test() {
  vec.direction(from: vec.zero, to: vec.of(3, 3)) |> should.equal(vec.of(1, 1))
  vec.direction(from: vec.zero, to: vec.of(-4, -2))
  |> should.equal(vec.of(-1, 0))
  vec.direction(from: vec.of(1, 1), to: vec.of(1, 5))
  |> should.equal(vec.of(0, 1))
}

pub fn min_max_test() {
  vec.min(vec.of(1, 5), vec.of(3, 2)) |> should.equal(vec.of(1, 2))
  vec.max(vec.of(1, 5), vec.of(3, 2)) |> should.equal(vec.of(3, 5))

  let #(min, max) = vec.normalize_corners(vec.of(3, 1), vec.of(1, 5))
  min |> should.equal(vec.of(1, 1))
  max |> should.equal(vec.of(3, 5))
}

pub fn range_test() {
  let points =
    vec.range(from: vec.of(0, 0), to: vec.of(1, 1))
    |> yielder.to_list()

  points
  |> should.equal([vec.of(0, 0), vec.of(0, 1), vec.of(1, 0), vec.of(1, 1)])
}

pub fn segment_contains_test() {
  // Point on the segment
  vec.segment_contains(#(vec.of(0, 0), vec.of(2, 2)), vec.of(1, 1))
  |> should.be_true()

  // Point at segment start
  vec.segment_contains(#(vec.of(0, 0), vec.of(2, 2)), vec.of(0, 0))
  |> should.be_true()

  // Point at segment end
  vec.segment_contains(#(vec.of(0, 0), vec.of(2, 2)), vec.of(2, 2))
  |> should.be_true()

  // Point not on the segment but on the line
  vec.segment_contains(#(vec.of(0, 0), vec.of(2, 2)), vec.of(3, 3))
  |> should.be_false()

  // Point not on the line at all
  vec.segment_contains(#(vec.of(0, 0), vec.of(2, 2)), vec.of(1, 0))
  |> should.be_false()

  // Vertical segment
  vec.segment_contains(#(vec.of(1, 0), vec.of(1, 4)), vec.of(1, 2))
  |> should.be_true()

  // Horizontal segment
  vec.segment_contains(#(vec.of(0, 1), vec.of(4, 1)), vec.of(2, 1))
  |> should.be_true()
}
