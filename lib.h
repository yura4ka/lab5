#ifndef LIB_H
#define LIB_H

typedef struct Node Node;

typedef struct {
  int _cap;
  int size;
  Node *arr;
} NodeArray;

struct Node {
  char *value;
  NodeArray children;
};

void makeArray(NodeArray *arr, int cap);

void push(NodeArray *arr, Node node);

#endif
