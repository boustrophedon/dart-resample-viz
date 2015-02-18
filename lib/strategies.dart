part of graph;

abstract class ResampleStrategy {
  void add_edge(Edge e);

  void add_to_structure(Edge e);

  void update_edge(Edge e);
  
  Edge next_edge();

  Edge get_edge_from_structure();

  bool get isEmpty;
}

class DefaultResampleStrategy implements ResampleStrategy {
  List<Edge> bad_edges;
  DefaultResampleStrategy() {
    bad_edges = new List<Edge>();
  }

  void add_edge(Edge e) {
    if (e.isbad) {
      add_to_structure(e);
    }
  }

  void add_to_structure(Edge e) {
    bad_edges.add(e);
  }

  void update_edge(Edge e) {
    e.update_badness();
    if ( (!e.instructure) && (e.isbad) ) {
      add_to_structure(e);
      e.instructure = true;
    }
  }
  
  Edge next_edge() {
    if (isEmpty) {
      return null;
    }
    Edge e = get_edge_from_structure();
    e.instructure = false;
    while (!e.isbad && !isEmpty) {
      e = get_edge_from_structure();
      e.instructure = false;
    }
    if (!e.isbad) {
      return null;
    }
    else {
      return e;
    }
  }

  Edge get_edge_from_structure() {
    return bad_edges.removeLast();
  }

  bool get isEmpty => bad_edges.isEmpty;
}

class FixedStrategy extends DefaultResampleStrategy {
  HeapPriorityQueue heap;
  FixedStrategy() {
    heap = new HeapPriorityQueue((e1,e2) => (e1.priority - e2.priority));
  }
  
  void add_to_structure(Edge e) {
    heap.add(e);
  }
  
  Edge get_edge_from_structure() {
    return heap.removeFirst();
  }

  bool get isEmpty => heap.isEmpty;
}

class RandomStrategy extends DefaultResampleStrategy {
  Random rng = new Random();
  RandomStrategy() : super();

  Edge get_edge_from_structure() {
    return bad_edges.removeAt(rng.nextInt(bad_edges.length));
  }
}

class EvilStrategy extends DefaultResampleStrategy {
  EvilStrategy() : super();
  Edge get_edge_from_structure() {
    int min_bad = 0;
    int min_neighbors = bad_neighbors(bad_edges.first);
    for (int i = 0; i < bad_edges.length; i++) {
      int cur = bad_neighbors(bad_edges[i]); 
      if (cur < min_neighbors) {
        min_neighbors = cur;
        min_bad = i;
      }
      if (min_neighbors == 0) {
        return bad_edges.removeAt(min_bad);
      }
    }
    return bad_edges.removeAt(min_bad);
  }

  int bad_neighbors(Edge e) {
    int bad = 0;
    for (Edge n in e.v1.edges) {
      if (n != e && n.isbad) {
        bad++;
      }
    }
    for (Edge n in e.v2.edges) {
      if (n != e && n.isbad) {
        bad++;
      }
    }
    return bad;
  }
}
