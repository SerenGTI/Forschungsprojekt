#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int node_id;

const int lineLength = 100;

node_id* edgeList;          // 2d-array with source id and target id
node_id edgeListLength;

// read edge list from file into edgeList array
void readEdgeList(char* filename) {
    FILE* f;
    char line[lineLength];

    // open file
    f = fopen(filename, "r");
    if (f == NULL) {
        perror("Cannot open file\n");
        exit(EXIT_FAILURE);
    }

    // count lines for edgeList length
    while (!feof(f)) {
        if (fgetc(f) == '\n') {
            edgeListLength++;
        }
    }

    // allocate edgeList
    edgeList = malloc(2 * edgeListLength * sizeof(node_id));
    if (edgeList == NULL) {
        fprintf(stderr, "Failed to malloc edge list array with length %d\n", 2 * edgeListLength * sizeof(node_id));
        fclose(f);
        exit(EXIT_FAILURE);
    }
    edgeListLength = 0;

    // go back to start of file
    rewind(f);

    int i;
    int len;
    node_id edgeStart;
    node_id edgeEnd;

    // parse edges
    while (fgets(line, lineLength, f) != NULL) {
        i = 0;
        len = strlen(line);
        
        // skip whitespaces
        while (i < len && (line[i] == ' ' || line[i] == '\t' || line[i] == '\r' || line[i] == '\n')) {
            i++;
        }

        // ignore if not a number
        if (i < len && !(line[i] >= '0' && line[i] <= '9')) {
            continue;
        }

        // parse start id
        edgeStart = 0;
        while (i < len && (line[i] >= '0' && line[i] <= '9')) {
            edgeStart *= 10;
            edgeStart += line[i] - '0';
            i++;
        }

        // skip whitespaces
        while (i < len && (line[i] == ' ' || line[i] == '\t' || line[i] == '\r' || line[i] == '\n')) {
            i++;
        }

        // parse end id
        edgeEnd = 0;
        while (i < len && (line[i] >= '0' && line[i] <= '9')) {
            edgeEnd *= 10;
            edgeEnd += line[i] - '0';
            i++;
        }

        edgeList[2 * edgeListLength] = edgeStart;
        edgeList[2 * edgeListLength + 1] = edgeEnd;
        edgeListLength++;
    }

    // close file
    fclose(f);
}


// write edge list from edgeList buffer to file
void writeEdgeList(char * filename) {
    FILE* f;

    f = fopen(filename, "w");
    if (f == NULL) {
        perror("Cannot open file\n");
        exit(EXIT_FAILURE);
    }

    for (unsigned long long i = 0; i < edgeListLength; i++) {
        fprintf(f, "%d %d\n", edgeList[2 * i], edgeList[2 * i + 1]);
    }

    fclose(f);
}


// compare for sort function (for all comperable node_id types)
int compare_node_id(const void * a, const void * b) {
    if ( *(node_id*)a < *(node_id*)b ) {
        return -1;
    }
    else if ( *(node_id*)a > *(node_id*)b ) {
        return 1;
    }
    else {
        return 0;
    }
}


// sort edgeList array
void sort() {
    qsort(edgeList, edgeListLength, 2 * sizeof(node_id), compare_node_id);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        return 0;
    }

    readEdgeList(argv[1]);
    sort();
    writeEdgeList(argv[2]);

    free(edgeList);
}
