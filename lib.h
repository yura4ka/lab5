#ifndef LIB_H
#define LIB_H

typedef struct Node Node;

typedef struct {
  int _cap;
  int size;
  Node **arr;
} NodeArray;

struct Node {
  char *value;
  NodeArray children;
};

Node *newNode(const char *value, const int childCount, ...);

Node *newNodeLeaf(const char *parent, const char *value);

void makeArray(NodeArray *arr, int cap);

void push(NodeArray *arr, Node *node);

void createTreeOutput(Node *head);

#endif
