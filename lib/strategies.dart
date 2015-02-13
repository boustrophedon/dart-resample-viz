part of graph;

abstract class ResampleStrategy {
  ResampleStrategy();

  void add_edge(Edge e);

  void update_edge(Edge e);

  bool get isEmpty;

  Edge next_edge();
}

class FixedStrategy implements ResampleStrategy {
  HeapPriorityQueue heap;
  FixedStrategy() {
    heap = new HeapPriorityQueue((e1,e2) => (e1.priority - e2.priority));
  }
  
  void add_edge(Edge e) {
    if (e.isbad) {
      heap.add(e);
      e.instructure = true;
    }
  }

  void update_edge(Edge e) {
    e.update_badness();
    if ( (!e.instructure) && (e.isbad) ) {
      heap.add(e);
      e.instructure = true;
    }
  }

  Edge next_edge() {
    if (heap.isEmpty) {
      return null;
    }
    Edge e = heap.removeFirst();
    e.instructure = false;
    while (!e.isbad && heap.isNotEmpty) {
      e = heap.removeFirst();
      e.instructure = false;
    }
    if (!e.isbad) {
      return null;
    }
    else {
      return e;
    }
  }

  bool get isEmpty => heap.isEmpty;
}

class RandomStrategy implements ResampleStrategy {
  List<Edge> bad_edges;
  Random rng = new Random();
  RandomStrategy() {
    bad_edges = new List<Edge>();
  }

  void add_edge(Edge e) {
    if (e.isbad) {
      bad_edges.add(e);
      e.instructure = true;
    }
  }

  void update_edge(Edge e) {
    e.update_badness();
    if ( (!e.instructure) && (e.isbad) ) {
      bad_edges.add(e);
      e.instructure = true;
    }
  }

  Edge next_edge() {
    if (bad_edges.isEmpty) {
      return null;
    }
    Edge e = bad_edges.removeAt(rng.nextInt(bad_edges.length));
    e.instructure = false;
    while (!e.isbad && bad_edges.isNotEmpty) {
      e = bad_edges.removeAt(rng.nextInt(bad_edges.length));
      e.instructure = false;
    }
    if (!e.isbad) {
      return null;
    }
    else {
      return e;
    }
  }

  bool get isEmpty => bad_edges.isEmpty;
}
