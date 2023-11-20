#include "lib.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Node *newNode(const char *value, const int childCount, ...) {
  Node *node = (Node *)malloc(sizeof(Node));
  node->value = strdup(value);
  makeArray(&node->children, childCount);

  va_list args;
  va_start(args, childCount);
  for (int i = 0; i < childCount; i++) {
    push(&node->children, va_arg(args, Node *));
  }
  va_end(args);
  return node;
}

Node *newNodeLeaf(const char *parent, const char *value) {
  Node *node = newNode(value, 0);
  Node *result = newNode(parent, 1, node);
  return result;
}

void makeArray(NodeArray *arr, int cap) {
  if (cap <= 0) cap = 0;
  arr->_cap = cap;
  arr->size = 0;
  arr->arr = (Node **)malloc(cap * sizeof(Node));
}

void push(NodeArray *arr, Node *node) {
  if (arr->size == arr->_cap) {
    arr->_cap = (arr->_cap + 1) * 2;
    arr->arr = realloc(arr->arr, arr->_cap * sizeof(Node));
  }
  arr->arr[arr->size++] = node;
}

char *concat(const char *s1, const char *s2) {
  const size_t len1 = strlen(s1);
  const size_t len2 = strlen(s2);
  char *result = malloc(len1 + len2 + 1);
  memcpy(result, s1, len1);
  memcpy(result + len1, s2, len2 + 1);
  return result;
}

void printAST(const char *prefix, const Node *node, const int isLast) {
  printf("%s", prefix);
  printf("%s", !isLast ? "|-- " : "\\-- ");
  printf("%s\n", node->value);

  for (int i = 0; i < node->children.size; i++) {
    char *newPrefix = concat(prefix, (!isLast ? "|   " : "    "));
    printAST(newPrefix, node->children.arr[i], i == node->children.size - 1);
    free(newPrefix);
  }
}