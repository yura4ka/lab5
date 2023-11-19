#include "lib.h"

#include <stdlib.h>

void makeArray(NodeArray *arr, int cap) {
  if (cap <= 0) cap = 0;
  arr->_cap = cap;
  arr->size = 0;
  arr->arr = (Node *)malloc(cap * sizeof(Node));
}

void push(NodeArray *arr, Node node) {
  if (arr->size == arr->_cap) {
    arr->_cap = (arr->_cap + 1) * 2;
    arr->arr = realloc(arr->arr, arr->_cap * sizeof(Node));
  }
  arr->arr[arr->size++] = node;
}
