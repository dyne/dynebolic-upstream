/* MuSE - Multiple Streaming Engine
 * Copyright (C) 2000-2002 Denis Roio aka jaromil <jaromil@dyne.org>
 *
 * This source code is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Public License as published 
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * This source code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * Please refer to the GNU Public License for more details.
 *
 * You should have received a copy of the GNU Public License along with
 * this source code; if not, write to:
 * Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef __UTILS_H__
#define __UTILS_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <string.h>

#define MAX_PATH_SIZE 512

#define MAX_DEBUG 2

#define FUNC 2 /* se il debug level e' questo
		  ci sono le funzioni chiamate */
#define WARN 1 /* ... blkbblbl */

#define CHAR_SET(func,var) \
char var[MAX_VALUE_SIZE]; \
void func(char *in) { \
if(strncmp(var,in,MAX_VALUE_SIZE)==0) return; \
else strncpy(var,in,MAX_VALUE_SIZE); \
} \
char *func() { return var; };
  
#define INT_SET(func,var) \
int var; \
void func(int in) { \
if(var==in) return; \
else var=in; \
} \
int func() { return var; };
  
#define FLOAT_SET(func,var) \
float var; \
void func(float in) { \
if(var==in) return; \
else var=in; \
} \
float func() { return var; };
  
  void set_debug(int lev);
  int get_debug();
  void set_logfile(char *file);
  void close_logfile();
  void notice(const char *format, ...);
  void func(const char *format, ...);
  void error(const char *format, ...);
  void act(const char *format, ...);
  void warning(const char *format, ...);
  double dtime();
  void jsleep(int sec, long nsec);
  int set_rtpriority(int max);
  void chomp(char *str);
  int resolve(char *host, char *ip);
  GtkWidget *openxpm(GtkWidget *win, char **xpm);
  
#ifdef __cplusplus
}
#endif

#endif
