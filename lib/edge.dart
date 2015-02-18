part of graph;

class Edge {
  List<Vertex> vertices;
  int priority;
  bool isbad = true;
  bool instructure = false;

  Edge(this.vertices, this.priority) {
    for (Vertex v in vertices) {
      v.edges.add(this);
    }
    update_badness();
  }
  void update_badness() {
    if (vertices.any((v)=>((v.color!=vertices.first.color)&&(v!=vertices.first)))) {
      isbad = true;
    }
    else {
      isbad = false;
    }
  }
  String toString() {
    return "$vertices";
  }
}
