import 'dart:math';
import 'package:dart_resample_viz/graph.dart';

void main() {
  ResampleRandomGraph graph = new ResampleRandomGraph();
  bool done = false;
  while (!done) {
    done = graph.step();
  }
  print("${graph.total_resamples}");
  print("${graph.graph_type} ${graph.size} ${graph.p} ${graph.num_colors} ${graph.p_distribution}"); 
}
