#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int node_id;

const int lineLength = 100;

enum {NONE, UNWEIGHTED, WEIGHTED};

struct edgeList {
    node_id* graph;         // 2d array containing: sourceId, destinationId and if its weighted the weight
    unsigned int length;
    int type; 
};

// read edge list from file into edgeList array
struct edgeList readEdgeList(char* filename, int isWeighted) {
    FILE* f;
    char line[lineLength];
    struct edgeList graph;

    int arrayLen;
    if (isWeighted) {
        graph.type = WEIGHTED;
        arrayLen = 3;
    }
    else {
        graph.type = UNWEIGHTED;
        arrayLen = 2;
    }

    // open file
    f = fopen(filename, "r");
    if (f == NULL) {
        perror("Cannot open file\n");
        exit(EXIT_FAILURE);
    }

    // count lines for edgeList length
    while (!feof(f)) {
        if (fgetc(f) == '\n') {
            graph.length++;
        }
    }

    // go back to start of file
    rewind(f);

    // allocate edgeList
    graph.graph = malloc(arrayLen * graph.length * sizeof(node_id));
    if (graph.graph == NULL) {
        fprintf(stderr, "Failed to malloc array for graph with length %d\n", 2 * graph.length * sizeof(node_id));
        fclose(f);
        return graph;
    }
    graph.length = 0;

    node_id (*data)[arrayLen] = graph.graph;

    unsigned int i;
    unsigned int len;
    node_id edgeStart;
    node_id edgeEnd;
    int weight;
    int decimalPlaces;

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

        if (isWeighted) {
            // skip whitespaces
            while (i < len && (line[i] == ' ' || line[i] == '\t' || line[i] == '\r' || line[i] == '\n')) {
                i++;
            }

            // parse weight
            weight = 0;
            decimalPlaces = 1;
            while (i < len && (line[i] >= '0' && line[i] <= '9')) {
                weight *= 10;
                weight += line[i] - '0';
                i++;
            }
            /*
            if (i < len && (line[i] == '.')) {
                i++;
                while (i < len && (line[i] >= '0' && line[i] <= '9')) {
                    weight *= 10;
                    decimalPlaces *= 10;
                    weight += line[i] - '0';
                    i++;
                }
            }
            */

            data[graph.length][2] = weight;
            // data[graph.length][2] = (float) weight / decimalPlaces;
        }

        data[graph.length][0] = edgeStart;
        data[graph.length][1] = edgeEnd;
        graph.length++;
    }

    // close file
    fclose(f);

    return graph;
}


// write edgeList to file
void writeEdgeList(char * filename, struct edgeList graph) {
    FILE* f;

    f = fopen(filename, "w");
    if (f == NULL) {
        perror("Cannot open file\n");
        return;
    }

    if (graph.type == UNWEIGHTED) {
        node_id (*data)[2] = graph.graph;
        for (unsigned int i = 0; i < graph.length; i++) {
            fprintf(f, "%d %d\n", data[i][0], data[i][1]);
        }
    }
    else if (graph.type == WEIGHTED) {
        node_id (*data)[3] = graph.graph;
        for (unsigned int i = 0; i < graph.length; i++) {
            fprintf(f, "%d %d %d\n", data[i][0], data[i][1], data[i][2]);
        }
    }
    else {
        perror("writeEdgeList: Unknown graph type\n");
    }

    fclose(f);
}


// compare for sort function (for all comperable node_id types)
node_id compare_node_id(const void * a, const void * b) {
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
void sort(struct edgeList graph) {
    if (graph.type == UNWEIGHTED) {
        qsort(graph.graph, graph.length, 2 * sizeof(node_id), compare_node_id);
    }
    else if (graph.type == WEIGHTED) {
        qsort(graph.graph, graph.length, 3 * sizeof(node_id), compare_node_id);
    }
}

// change node ids to range 0..numberOfNodes
// requires sorted array
// array will be sorted afterwards
void reindex(char* filename, struct edgeList graph) {
    // mapping betwenn old and new id: index is new id, array contains old id
    node_id* nodes = malloc(2 * graph.length * sizeof(node_id));
    if (nodes == NULL) {
        fprintf(stderr, "Failed to malloc nodes array with length %d\n", 2 * graph.length * sizeof(node_id));
        return;
    }

    int arrayLen;
    if (graph.type == UNWEIGHTED) {
        arrayLen = 2;
    }
    else {
        arrayLen = 3;
    }
    node_id (*data)[arrayLen] = graph.graph;

    // handle all source nodes
    nodes[0] = data[0][0];
    data[0][0] = 0;
    unsigned int nodesLength = 1;
    for (unsigned int i = 1; i < graph.length; i++) {
        if (nodes[nodesLength - 1] != data[i][0]) {
            nodes[nodesLength] = data[i][0];
            nodesLength++;
        }
        
        data[i][0] = nodesLength - 1;
    }

    // handle all destiantion nodes
    for (unsigned int i = 0; i < graph.length; i++) {
        int foundNode = 0;

        for (unsigned int j = 0; j < nodesLength; j++) {
            if (data[i][1] == nodes[j]) {
                data[i][1] = j;
                foundNode = 1;
                break;
            }
        }

        if (foundNode == 0) {
            nodes[nodesLength] = data[i][1];
            nodesLength++;
            data[i][1] = nodesLength - 1;
        }
    }

    if (filename != NULL) {
        FILE* f;

        f = fopen(filename, "w");

        if (f == NULL) {
            perror("Cannot open file\n");
        }

        fprintf(f, "# [OldId] [NewId]\n");

        for (unsigned int i = 0; i < nodesLength; i++) {
            fprintf(f, "%llu %llu\n", nodes[i], i);
        }

        fclose(f);
    }

    free(nodes);
}

// writes the given graph to the specified file in the adjacencyGraph format
// requires a sorted and reindexed input graph
void writeAdjacencyGraph(char* filename, struct edgeList graph){
    int arrayLen;
    FILE* f = fopen(filename, "w");
    if (graph.type == WEIGHTED){
        arrayLen = 3;
        fprintf(f, "WeightedAdjacencyGraph\n");
    } else {
        arrayLen = 2;
        fprintf(f, "AdjacencyGraph\n");
    }
    node_id (*data)[arrayLen] = graph.graph;
    node_id currentNode = data[0][0];
    int offset = 0;
    node_id biggestNodeId = data[graph.length-1][0];
    for (int i = 0; i < graph.length; i++){
        if (data[i][1] > biggestNodeId){
            biggestNodeId = data[i][1];
        }
    }
    fprintf(f, "%d\n", biggestNodeId+1);
    fprintf(f, "%d\n", graph.length);
    fprintf(f, "%d\n", 0);
    // write the number of leaving edges per node
    for (int i = 1; i < graph.length; i++){
        offset++;
        if (currentNode != data[i][0]){
            fprintf(f, "%d\n", offset);
            currentNode = data[i][0];
        }
    }
    // write the target node of the i-th edge
    for (int i = 0; i < graph.length; i++){
        fprintf(f, "%d\n", data[i][1]);
    }
    // if the graph is weighted the weights will be appended
    if (graph.type == WEIGHTED){
        for (int i = 0; i < graph.length; i++){
            fprintf(f, "%d\n", data[i][2]);
        }
    }
    fclose(f);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        return 0;
    }

    struct edgeList graph = readEdgeList(argv[1], 0);
    sort(graph);
    writeEdgeList(argv[2], graph);
    if (argc == 4 && argv[3] != NULL){
        reindex(NULL, graph);
        writeAdjacencyGraph(argv[3], graph);
    }

    free(graph.graph);
}
