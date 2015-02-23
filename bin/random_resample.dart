import 'dart:math';
import 'package:dart_resample_viz/graph.dart';

void main() {
  random_graph_resample();
  random_hypergraph_resample(3);
}

void random_graph_resample() {
  List<int> results = new List<int>();
  for (int i = 0; i<100; i++) {
    ResampleRandomGraph graph = new ResampleRandomGraph(size: 100);
    bool done = false;
    while (!done) {
      done = graph.step();
    }
    results.add(graph.total_resamples);
  }
  int avg = results.reduce((a,b) => (a+b))~/(results.length);
  print("$avg");
}

void random_hypergraph_resample(int k) {
  List<int> results = new List<int>();
  for (int i = 0; i<100; i++) {
    ResampleRandomKHypergraph graph = new ResampleRandomKHypergraph(size: 100, edge_cardinality: k);
    bool done = false;
    while (!done) {
      done = graph.step();
    }
    results.add(graph.total_resamples);
    print(graph.total_resamples);
  }
  int avg = results.reduce((a,b) => (a+b))~/(results.length);
  print("$avg");
}
