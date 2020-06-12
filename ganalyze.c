#include <stdio.h>
#include <string.h>
#include <stdbool.h>

int main(int argc, char *argv[]) {

  char c;
  int src, dest, weight, lsrc = 0, ldest = 0, edges = 0, hsrc = 0, hdest = 0, hnode;
  bool weighted = false, src_sorted = true, dest_sorted = true, src_gaps = false;

  // skip commentaries
  while ((c = getc(stdin)) == '#')
    while ((c = getc(stdin)) != '\n');
  fseek(stdin, -1, SEEK_CUR);

  // is graph weighted
  weighted = argc > 1 && !strcmp(argv[1], "weighted");

  // analyze
  while (true) {
    if (weighted) {
      if (scanf("%d %d %d\n", &src, &dest, &weight) == EOF)
        break;
    } else {
      if (scanf("%d %d\n", &src, &dest) == EOF)
        break;
    }

    if (lsrc > src) { // are the source nodes sorted
      printf("src %d after %d\n", src, lsrc);
      src_sorted = false;
    } else if (lsrc == src && ldest > dest) { // are the destination nodes sorted
      printf("dest %d after %d\n", dest, ldest);
      dest_sorted = false;
    } else {
      if (src > lsrc+1) { // found gap
        printf("gap %d to %d\n", lsrc, src);
        src_gaps = true;
      }
      if (src > hsrc) { // next biggest src
        hsrc = src;
      }
    }
    if (dest > hdest) { // next biggest dest
      hdest = dest;
    }
    lsrc = src;
    ldest = dest;
    ++edges;
  }

  // print stats
  fprintf(stderr, "nodes: %d\n", hsrc > hdest ? hsrc: hdest);
  fprintf(stderr, "edges: %d\n", edges);
  fprintf(stderr, "hsrc: %d\n", hsrc);
  fprintf(stderr, "hdest: %d\n", hdest);
  if (src_sorted) {
    fprintf(stderr, "src_sorted: true\n");
  } else {
    fprintf(stderr, "src_sorted: false\n");
  }
  if (dest_sorted) {
    fprintf(stderr, "dest_sorted: true\n");
  } else {
    fprintf(stderr, "dest_sorted: false\n");
  }
  if (src_gaps) {
    fprintf(stderr, "src_gaps: true\n");
  } else {
    fprintf(stderr, "src_gaps: false\n");
  }

  return 0;
}
