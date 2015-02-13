part of graph;

class Edge {
  Vertex v1;
  Vertex v2;
  int priority;
  bool isbad = true;
  bool instructure = false;

  Edge(this.v1, this.v2, this.priority) {
    v1.edges.add(this);
    v2.edges.add(this);
    update_badness();
  }
  void update_badness() {
    if (v1.color == v2.color) {
      isbad = true;
    }
    else {
      isbad = false;
    }
  }
  String toString() {
    return "$v1";
  }
}
