import 'dart:math';

double cosineSimilarity(List<double> vec1, List<double> vec2) {
  double dotProduct = 0.0;
  double normA = 0.0;
  double normB = 0.0;
  for (int i = 0; i < vec1.length; i++) {
    dotProduct += vec1[i] * vec2[i];
    normA += vec1[i] * vec1[i];
    normB += vec2[i] * vec2[i];
  }
  return dotProduct / (sqrt(normA) * sqrt(normB));
}