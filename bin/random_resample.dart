import 'dart:math';
import 'package:dart_resample_viz/graph.dart';

void main() {
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
