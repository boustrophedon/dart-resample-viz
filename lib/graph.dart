library graph;

import 'dart:math';
import 'package:collection/priority_queue.dart';

part 'vertex.dart';
part 'edge.dart';

part 'strategies.dart';

class ResampleGraph {
  int size;
  int total_resamples = 0;

  int num_colors;
  List<String> colors;

  Random rng = new Random();

  num p;
  int p_distribution; // this tells us how many of the probabilities in the distribution are equal to p
  List<num> probabilities;

  String resample_strategy;

  List<Vertex> vertices;

  ResampleStrategy resampler;

  ResampleGraph(this.size, this.num_colors, this.p, this.p_distribution, this.resample_strategy) {
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

    create_resampler();

    generate_colors();
    generate_vertices();
    generate_edges();
  }

  void create_resampler() {
    switch (resample_strategy) {
      case 'fixed':
        resampler = new FixedStrategy();
        break;
      case 'random':
        resampler = new RandomStrategy();
        break;
      case 'least-bad-neighbors':
        resampler = new EvilStrategy();
        break;
      default:
        resampler = new FixedStrategy();
        break;
    }
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

  String choose_color() {
    num n = rng.nextDouble();
    for (int i = 0; i < probabilities.length; i++) {
      n-=probabilities[i];
      if (n<=0) {
        return colors[i];
      }
    }
    return null;
  }
  
  void new_edge(Vertex v1, Vertex v2, int priority) {
    Edge e = new Edge(v1, v2, priority);
    resampler.add_edge(e);
  }

  void generate_edges() {}

  void do_resample(Edge e) {
    e.v1.color = choose_color();
    e.v2.color = choose_color();

    e.v1.resamples+=1;
    e.v2.resamples+=1;
    total_resamples+=1;

    for (Edge n in e.v1.edges) {
      resampler.update_edge(n);
    }
    for (Edge n in e.v2.edges) {
      resampler.update_edge(n);
    }
  }

  bool step() {
    if (resampler.isEmpty) {
      return true;
    }
   
    Edge e = resampler.next_edge();
    if (e == null) {
      return true;
    }

    do_resample(e);
    return false;
  }
}

class ResampleGridGraph extends ResampleGraph {
  bool is_torus;
  num q;

  String graph_type;
  ResampleGridGraph(
      {size: 25, num_colors: 6, p: null, p_distribution: 3, resample_strategy: 'fixed', this.is_torus: false, this.q: 0}) : super(size, num_colors, p, p_distribution, resample_strategy) {
    if (is_torus) {
      graph_type = "Torus";
    }
    else {
      graph_type = "Grid";
    }
    if (q > 0) {
      graph_type += " with diagonals";
    }
  }

  void generate_edges() {
    int priority = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        if (x+1 < size || is_torus) {
          new_edge(vertices[y*size + x], vertices[y*size + (x+1)%size], priority);
          priority+=1;
        }
        if ( (((x+1 < size) && (y+1 < size)) || is_torus) && (rng.nextDouble() <= q)) {
          new_edge(vertices[y*size + x], vertices[((y+1)%size)*size + (x+1)%size], priority);
          priority+=1;
        }
        if (y+1 < size || is_torus) {
          new_edge(vertices[y*size + x], vertices[((y+1)%size)*size + x], priority);
          priority+=1;
        }
      }
    }
  }
} 

class ResampleRandomGraph extends ResampleGraph {
  int degree;

  String graph_type;
  ResampleRandomGraph(
      {size: 25, num_colors: 6, p: null, p_distribution: 3, resample_strategy: 'fixed', this.degree: 4}) : super(size, num_colors, p, p_distribution, resample_strategy) {
    graph_type = "Random";
  }

  void generate_vertices() {
    vertices = new List<Vertex>(size);
    for (int i = 0; i < size; i++) {
      num y = sin((2*PI*i)/(size));
      num x = cos((2*PI*i)/(size));
      vertices[i] = new Vertex(x, y, choose_color());
    }
  }

  void generate_edges() {
    int priority = 0;
    for (int i = 0; i < size; i++) {
      new_edge(vertices[i], vertices[(i+1)%size], priority);
      priority++;
    }
    for (Vertex v in vertices) {
      int count = 0;
      while (v.edges.length < degree && count < size*size*100) {
        Vertex vo = vertices[rng.nextInt(size)];
        if (vo.edges.length < degree && vo != v && !v.edges.any( (edge)=>(edge.v1 == vo || edge.v2 == vo) )) {
          new_edge(v, vo, priority);
          priority++;
        }
        else {
          count++;
        }
      }
    }
  }
}
