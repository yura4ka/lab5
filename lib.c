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

void treeToFile(FILE *file, Node *node) {
  if (node == NULL) {
    return;
  }

  fprintf(file, "{ value: '%s', children: [", node->value);

  for (int i = 0; i < node->children.size; ++i) {
    treeToFile(file, node->children.arr[i]);
    if (i < node->children.size - 1) {
      fprintf(file, ",");
    }
  }

  fprintf(file, "] }");
}

void createTreeOutput(Node *head) {
  FILE *file = fopen("treeOutput.html", "w");
  if (file == NULL) {
    fprintf(stderr, "Error opening file.\n");
  }

  fprintf(
      file,
      "<!DOCTYPE html>\n<html lang='en'>\n<head>\n<meta charset='UTF-8'>\n"
      "<meta http-equiv='X-UA-Compatible' content='IE=edge'>\n"
      "<meta name='viewport' content='width=device-width, initial-scale=1.0'>\n"
      "<title>Tree output</title>\n"
      "<script type='text/javascript' "
      "src='https://d3js.org/d3.v3.min.js'></script>\n"
      "</head>\n<body>\n"
      "<style>"
      ".node circle {"
      "fill: #fff;"
      "stroke: steelblue;"
      "stroke-width: 1.5px;"
      "}"
      ".node text {"
      "font-size: 11px;"
      "}"
      "path.link {"
      "fill: none;"
      "stroke: #ccc;"
      "stroke-width: 1.5px;"
      "}"
      "</style>\n"
      "<script type='module'>\n");

  fprintf(file, "const root = ");
  treeToFile(file, head);

  fprintf(file,
          ";\n"
          "function getDepth(n) {"
          "let max = 0;"
          "for (const child of n.children)"
          "max = Math.max(max, getDepth(child));"
          "return max + 1;"
          "}"
          "const m = [20, 120, 20, 120];"
          "let i = 0;"
          "const levelWidth = [1];"
          "const childCount = (level, n) => {"
          "if (n.children && n.children.length > 0) {"
          "if (levelWidth.length <= level + 1) levelWidth.push(0);"
          "levelWidth[level + 1] += n.children.length;"
          "n.children.forEach((d) => childCount(level + 1, d));"
          "}"
          "};"
          "const depth = getDepth(root);"
          "childCount(0, root);"
          "const h = d3.max(levelWidth) * 30;"
          "const w = depth * 160;"
          "root.x0 = h / 2;"
          "root.y0 = 0;"
          "const diagonal = d3.svg.diagonal().projection((d) => [d.y, d.x]);"
          "const tree = d3.layout.tree().size([h, w]);"
          "const vis = d3.select('body').append('svg:svg')"
          ".attr('width', w + m[1] + m[3])"
          ".attr('height', h + m[0] + m[2])"
          ".append('svg:g')"
          ".attr('transform', 'translate(' + m[3] + ',' + m[0] + ')');"
          "const nodes = tree.nodes(root).reverse();"
          "nodes.forEach((d) => d.y = d.depth * 160);"
          "const node = vis.selectAll('g.node')"
          ".data(nodes, (d) => d.id || (d.id = ++i));"
          "const nodeEnter = node.enter().append('svg:g')"
          ".attr('class', 'node')"
          ".attr('transform', (d) => 'translate(' + d.y + ',' + d.x + ')');"
          "nodeEnter.append('svg:circle')"
          ".attr('r', 4.5)"
          ".style('fill', (d) => d.children ? 'lightsteelblue' : '#fff');"
          "nodeEnter.append('svg:text')"
          ".attr('x', (d) => d.children ? -10 : 10)"
          ".attr('dy', '.35em')"
          ".attr('text-anchor', (d) => d.children ? 'end' : 'start')"
          ".text((d) => d.value);"
          "const link = vis.selectAll('path.link')"
          ".data(tree.links(nodes), (d) => d.target.id);"
          "link.enter().insert('svg:path', 'g')"
          ".attr('class', 'link')"
          ".attr('d', (d) => {"
          "const o = { x: root.x0, y: root.y0 };"
          "return diagonal({ source: o, target: o });"
          "})"
          ".attr('d', diagonal);"
          "</script>\n</body>\n</html>");

  fclose(file);
  printf("Tree data has been written to treeOutput.html\n");
}