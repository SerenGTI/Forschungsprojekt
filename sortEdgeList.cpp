#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <getopt.h>
#include <vector>
#include <unordered_map>

typedef int node_id;

const int lineLength = 100;

enum types {NONE, UNWEIGHTED, WEIGHTED};

struct edge {
    node_id from;
    node_id to;
    node_id weigth;
};

struct edgeList {
    edge * edges;
    unsigned int length;
    types type; 
};

inline void skipWhitespaces(char * line, size_t * i, size_t len) {
    while (*i < len && (line[*i] == ' ' || line[*i] == '\t' || line[*i] == '\r' || line[*i] == '\n')) {
        (*i)++;
    }
}

inline node_id parseInteger(char * line, size_t * i, size_t len) {
    node_id num = 0;
    while (*i < len && (line[*i] >= '0' && line[*i] <= '9')) {
        num *= 10;
        num += line[*i] - '0';
        (*i)++;
    }
    return num;
}

// read edge list from file into edgeList array
edgeList readEdgeList(char* filename, int isWeighted) {
    FILE* f;
    char line[lineLength];
    edgeList graph;
    if (isWeighted) {
        graph.type = WEIGHTED;
    }
    else {
        graph.type = UNWEIGHTED;
    }

    // open file
    f = fopen(filename, "r");
    if (f == NULL) {
        perror("Cannot open file\n");
        exit(EXIT_FAILURE);
    }

    // count lines for edgeList length
    graph.length = 0;
    int c;
    while ((c = fgetc(f)) != EOF) {
        if (c == '\n') {
            graph.length++;
        }
    }
    // go back to start of file
    rewind(f);
    // allocate edgeList
    graph.edges = (edge*) malloc(graph.length * sizeof(edge));
    if (graph.edges == NULL) {
        fprintf(stderr, "Failed to malloc array for graph with length %d\n", graph.length * sizeof(edge));
        fclose(f);
        return graph;
    }
    graph.length = 0;

    size_t i;
    size_t len;
    // parse edges
    while (fgets(line, lineLength, f) != NULL) {
        i = 0;
        len = strlen(line);
        
        skipWhitespaces(line, &i, len);
        // ignore if not a number
        if (i < len && !(line[i] >= '0' && line[i] <= '9')) {
            continue;
        }
        graph.edges[graph.length].from = parseInteger(line, &i, len);
        skipWhitespaces(line, &i, len);
        graph.edges[graph.length].to = parseInteger(line, &i, len);
        
        if (isWeighted) {
            skipWhitespaces(line, &i, len);
            graph.edges[graph.length].weigth = parseInteger(line, &i, len);
        }
        graph.length++;
    }
    
    fclose(f);
    return graph;
}


// write edgeList to file
void writeEdgeList(char * filename, edgeList graph) {
    FILE* f;
    f = fopen(filename, "w");
    if (f == NULL) {
        perror("Cannot open file\n");
        exit(EXIT_FAILURE);
    }
    if (graph.type == WEIGHTED) {
        for (size_t i = 0; i < graph.length; i++) {
            fprintf(f, "%d %d %d\n", graph.edges[i].from, graph.edges[i].to, graph.edges[i].weigth);
        }
    }
    else {
        for (size_t i = 0; i < graph.length; i++) {
            fprintf(f, "%d %d\n", graph.edges[i].from, graph.edges[i].to);
        }
    }
    fclose(f);
}


// compare for sort function (for all comperable node_id types)
node_id compare_node_id(const void * a, const void * b) {
    edge x = *(edge*) a;
    edge y = *(edge*) b;
    if ( x.from < y.from ) {
        return -1;
    }
    else if ( x.from > y.from ) {
        return 1;
    }
    else {
        return 0;
    }
}


// sort edgeList array
void sort(edgeList graph) {
    qsort(graph.edges, graph.length, sizeof(edge), compare_node_id);
}

void reindex(char * filename, edgeList graph) {
    std::vector<node_id> newToOld;
    newToOld.reserve(2000000);
    std::unordered_map<node_id, node_id> oldToNew;
    oldToNew.rehash(6000000);
    // reindex from nodes
    newToOld.push_back(0);
    oldToNew.insert(std::make_pair(0, 0));
    for (size_t i = 0; i < graph.length; i++) {
        if (newToOld[newToOld.size() - 1] != graph.edges[i].from) {
            newToOld.push_back(graph.edges[i].from);
            oldToNew.insert(std::make_pair(graph.edges[i].from, static_cast<node_id>(newToOld.size() - 1)));
        }

        graph.edges[i].from = newToOld.size() - 1;
    }
    // reindex to nodes
    for (size_t i = 0; i < graph.length; i++) {
        if (oldToNew.find(graph.edges[i].to) == oldToNew.end()) {
            newToOld.push_back(graph.edges[i].to);
            oldToNew.insert(std::make_pair(graph.edges[i].to, static_cast<node_id>(newToOld.size() - 1)));
            graph.edges[i].to = newToOld.size() - 1;
        }
        else {
            graph.edges[i].to = oldToNew.at(graph.edges[i].to);
        }
    }
    if (filename != NULL) {
        FILE* f;
        f = fopen(filename, "w");
        if (f == NULL) {
            perror("Cannot open file\n");
            exit(EXIT_FAILURE);
        }
        fprintf(f, "# [OldId] [NewId]\n");
        for (size_t i = 0; i < newToOld.size(); i++) {
            fprintf(f, "%llu %llu\n", newToOld[i], i);
        }
        fclose(f);
    }
}


// writes the given graph to the specified file in the adjacencyGraph format
// requires a sorted and reindexed input graph
void writeAdjacencyGraph(char* filename, edgeList graph){
    node_id currentNode = graph.edges[0].from;
    int offset = 0;
    FILE* f = fopen(filename, "w");
    if (f == NULL) {
        perror("Cannot open file\n");
        exit(EXIT_FAILURE);
    }
    if (graph.type == UNWEIGHTED) {
        fprintf(f, "AdjacencyGraph\n");
    }
    else {
        fprintf(f, "WeightedAdjacencyGraph\n");
    }
    node_id biggestNodeId = graph.edges[graph.length-1].from;
    for (size_t i = 0; i < graph.length; i++){
        if (graph.edges[i].to > biggestNodeId){
            biggestNodeId = graph.edges[i].to;
        }
    }
    fprintf(f, "%d\n", biggestNodeId+1);
    fprintf(f, "%d\n", graph.length);
    for (size_t i = 0; i <= graph.edges[0].from; i++) {
        fprintf(f, "%d\n", 0);
    }
    // write the number of leaving edges per node
    for (size_t i = 1; i < graph.length; i++){
        offset++;
        if (currentNode != graph.edges[i].from){
            fprintf(f, "%d\n", offset);
            currentNode = graph.edges[i].from;
        }
    }
    for (; currentNode < biggestNodeId; currentNode++) {
        fprintf(f, "%d\n", offset + 1);
    }
    for (size_t i = 0; i < graph.length; i++){
        fprintf(f, "%d\n", graph.edges[i].to);
    }
    if (graph.type == WEIGHTED) {
        for (size_t i = 0; i < graph.length; i++){
            fprintf(f, "%d\n", graph.edges[i].weigth);
        }
    }
    fclose(f);
}

int main(int argc, char* argv[]) {
    const char* help = "Usage: sortEdgeList [OPTIONS]\nOptions:\n  -h, --help             Print this help and exit\n  -i, --in PATH          Location of the graph to convert in edge list format\n  -r, --reindex PATH     Location to save the file containing the function from old id to new id\n  -e, --edge-list PATH   Location to save the file containing the graph as edge list after reindexing\n  -a, --adjacency PATH   Location to save the file containing the graph in the adjacency format after reindexing\n  -w, --weighted         Interprets the input graph as weighted\n  -n, --add-weights      Add weight of 1 to each edge. This will override any existing weights\n";
    int isWeighted = 0;
    int newWeights = 0;
    int opt;
    char* input = NULL;
    char* reindexOut = NULL;
    char* edgeListOut = NULL;
    char* adjacencyOut = NULL;
    
    static const struct option long_options[] =
    {
        { "weighted",        no_argument, 0, 'w' },
        { "add-weights",     no_argument, 0, 'n' },
        { "in",        required_argument, 0, 'i' },
        { "reindex",   required_argument, 0, 'r' },
        { "edge-list", required_argument, 0, 'e' },
        { "adjacency", required_argument, 0, 'a' },
        { "help",            no_argument, 0, 'h' },
        { 0,                 no_argument, 0, 0 }
    };
    while ((opt = getopt_long(argc, argv, "wni:r:e:a:", long_options, NULL)) != -1) {
        switch (opt) {
        case 'w': isWeighted = 1; break;
        case 'n': newWeights = 1; break;
        case 'i': input = optarg; break;
        case 'r': reindexOut = optarg; break;
        case 'e': edgeListOut = optarg; break;
        case 'a': adjacencyOut = optarg; break;
        case 'h': 
            printf(help);
            exit(EXIT_SUCCESS);
        case '?':
            fprintf(stderr, "Error: Unknown parameter\n\n");
            fprintf(stderr, help);
            exit(EXIT_FAILURE);
        case ':':
            fprintf(stderr, "Error: Missing argument\n\n");
            fprintf(stderr, help);
            exit(EXIT_FAILURE);
        default:
            fprintf(stderr, help);
            exit(EXIT_FAILURE);
        }
    }

    if (input == NULL) {
        fprintf(stderr, "No Input file\n");
        fprintf(stderr, help);
        exit(EXIT_FAILURE);
    }

    clock_t begin = clock();
    edgeList graph = readEdgeList(input, isWeighted);
    printf("Reading edge list in: %f seconds\n", (double)(clock() - begin) / CLOCKS_PER_SEC);

    if (newWeights) {
        graph.type = WEIGHTED;
        for (size_t i = 0; i < graph.length; i++) {
            graph.edges[i].weigth = 1;
        }
    }

    begin = clock();
    sort(graph);
    printf("Sorting edge list in: %f seconds\n", (double)(clock() - begin) / CLOCKS_PER_SEC);

    begin = clock();
    reindex(reindexOut, graph);
    printf("Reindexing edge list in: %f seconds\n", (double)(clock() - begin) / CLOCKS_PER_SEC);

    if (edgeListOut != NULL) {
        begin = clock();
        writeEdgeList(edgeListOut, graph);
        printf("Writing edge list in: %f seconds\n", (double)(clock() - begin) / CLOCKS_PER_SEC);
    }

    if (adjacencyOut != NULL) {
        begin = clock();
        writeAdjacencyGraph(adjacencyOut, graph);
        printf("Writing adjacency graph in: %f seconds\n", (double)(clock() - begin) / CLOCKS_PER_SEC);
    }
    
    free(graph.edges);
}