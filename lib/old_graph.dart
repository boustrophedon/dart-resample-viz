library graph;

import 'dart:math';
import 'package:collection/priority_queue.dart';

part 'vertex.dart';
part 'edge.dart';

class ResampleGridGraph {
  int size;
  int total_resamples = 0;

  int num_colors;
  List<String> colors;

  Random rng = new Random();

  num p;
  int p_distribution; // this tells us how many of the probabilities in the distribution are equal to p
  List<num> probabilities;

  bool is_torus;

  num q;

  String graph_type;
  List<Vertex> vertices;
  HeapPriorityQueue heap;

  ResampleGridGraph({this.size: 25, this.num_colors: 6, this.p: null, this.p_distribution: 3, this.is_torus: false, this.q: 0}) {
    if (is_torus) {
      graph_type = "Torus";
    }
    else {
      graph_type = "Grid";
    }
    if (q > 0) {
      graph_type += "with diagonals";
    }

    if (p == null) {
      p = 1/num_colors;
    }
    if (p_distribution == null) {
      p_distribution = num_colors~/2;
    }

    if (num_colors < p_distribution) {
      throw new ArgumentError("Number of colors is less than size of distribution");
    }

    probabilities = new List<num>(num_colors);
    for(int i = 0; i<p_distribution; i++) {
      probabilities[i] = p;
    }
    for (int i = p_distribution; i<num_colors; i++) {
      probabilities[i] = (1 - p_distribution*p).abs()/(num_colors - p_distribution);
    }
    num sum = probabilities.reduce((a,b) => (a+b));
    if ( (1-sum).abs() > 0.00000001 ) {
      throw new ArgumentError("Your probabilities do not sum to 1: ${probabilities}");
    }
    heap = new HeapPriorityQueue((e1,e2) => (e1.priority - e2.priority));
    generate_colors();
    generate_vertices();
    generate_edges();
  }

  void generate_colors() {
    if (num_colors <=6) {
      colors = ["#FF0000","#00FF00","#0000FF","#FF00FF","#FFFF00","#00FFFF"];
    }
    else {
      colors = new List<String>(num_colors);
      for (int i = 0; i<num_colors; i++) {
        String col = generate_color();
        // technically it's possible we generate the same color twice
        while (colors.indexOf(col) != -1) {
          col = generate_color();
        }       
        colors[i] = col;
      }
    }
  }
  String generate_color() {
    int red = (rng.nextInt(256)+200)~/2;
    int green = (rng.nextInt(256));
    int blue = (rng.nextInt(256)+200)~/2;
    return '#' +
      red.toRadixString(16).padLeft(2, '0') +
      green.toRadixString(16).padLeft(2, '0') +
      blue.toRadixString(16).padLeft(2, '0');
  }
  void generate_vertices() {
    vertices = new List<Vertex>(size*size);
    for (int i = 0; i < size*size; i++) {
      int y = (i~/size);
      int x = i%size;
      vertices[i] = new Vertex(x, y, choose_color());
    }
  }

  void generate_edges() {
    int priority = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (x+1 < size || is_torus) {
          Edge e = new Edge(vertices[y*size + x], vertices[y*size + (x+1)%size], priority);
          if (e.isbad) {
            heap.add(e);
            e.inheap = true;
          }
          priority+=1;
        }
        if ( (((x+1 < size) && (y+1 < size)) || is_torus) && (rng.nextDouble() <= q)) {
          Edge e = new Edge(vertices[y*size + x], vertices[((y+1)%size)*size + (x+1)%size], priority);
          if (e.isbad) {
            heap.add(e);
            e.inheap = true;
          }
          priority+=1;
        }
        if (y+1 < size || is_torus) {
          Edge e = new Edge(vertices[y*size + x], vertices[((y+1)%size)*size + x], priority);
          if (e.isbad) {
            heap.add(e);
            e.inheap = true;
          }
          priority+=1;
        }
      }
    }
  } 

  String choose_color() {
    num n = rng.nextDouble();
    for (int i = 0; i < probabilities.length; i++) {
      n-=probabilities[i];
      if (n<=0) {
        return colors[i];
      }
    }
  }

  void do_resample(Edge e) {
    e.v1.color = choose_color();
    e.v2.color = choose_color();

    e.v1.resamples+=1;
    e.v2.resamples+=1;
    total_resamples+=1;

    for (Edge n in e.v1.edges) {
      n.update_badness();
      if ( (!n.inheap) && (n.isbad) ) {
        heap.add(n);
        n.inheap = true;
      }
    }
    for (Edge n in e.v2.edges) {
      n.update_badness();
      if ( (!n.inheap) && (n.isbad) ) {
        heap.add(n);
        n.inheap = true;
      }
    }
  }

  bool step() {
    // this is kind of a mess with all of the isEmpty checks

    if (heap.isEmpty) {
      return true;
    }
    Edge e = heap.removeFirst();
    e.inheap = false;

    // if we picked an edge from the heap that was already fixed, keep going until we find one that is bad
    while (!e.isbad && heap.isNotEmpty) {
      e = heap.removeFirst();
      e.inheap = false;
    }
    
    if (e.isbad) {
      do_resample(e);
      if (heap.isEmpty) {
        return true;
      }
      else {
        return false;
      }
    }
    else if (heap.isEmpty) {
      return true;
    }
  }
}
