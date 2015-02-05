part of graph;

class Vertex {
  int x;
  int y;
  int resamples = 0;
  List<Edge> edges;
  String color;
  Vertex(this.x, this.y, this.color) {
    edges = new List<Edge>();
  }
  String toString() {
    return "$x $y $color";
  }
}
