#ifndef __PARTS_H__
#define __PARTS_H__

#include <sys/vfs.h>

#define MAX_PARTS 64

/* partition.support type */
#define HD 1
#define USB 2

struct partition {
  char path[255];
  char label[64];
  struct statfs fs;
  char total_space[32]; /* strings in format 32Mb or 3Gb */
  char avail_space[32];
  int support;
  bool no_info;
  bool no_space;
  bool no_write;
  bool has_nest;
  bool has_error;
  char error[256];
  int num;
};
extern struct partition parts[MAX_PARTS];

int scan_parts();
void debug_parts(int c);

#endif
