/* Taschino 2 - nest & dock application for dyne:bolic
 * (c) Copyright 2004 Denis Roio aka jaromil <jaromil@dyne.org>
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
 *
 * "$Id: results.cpp,v 1.1.1.1 2004/03/14 00:15:27 jaromil Exp $"
 *
 */

#include <stdio.h>
#include <stdarg.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>


#include <taschino.h>

static char message[1024];

static GtkWidget *win_error;
static GtkWidget *win_success;

static GtkLabel *error_text = NULL;
static GtkLabel *success_text = NULL;

#define SUCCESS_FILE "/var/log/setup/success"
#define ERROR_FILE "/var/log/setup/error"

void error(char *format, ...) {
  va_list arg;
  va_start(arg,format);
  
  vsnprintf(message,1023,format,arg);
  va_end(arg);

  win_error = glade_xml_get_widget(gui, "win_error");
  if(!win_error) {
    fprintf(stderr,"ERROR: missing error window\n");
    fprintf(stderr,"while trying to dump error message :>\n");
    fprintf(stderr,"%s\n",message);
    return;
  } else
    gtk_window_set_transient_for((GtkWindow*)win_error,(GtkWindow*)win_main);

  if(!error_text)
    error_text = (GtkLabel*)glade_xml_get_widget(gui,"error_text");
  gtk_label_set_text(error_text,message);

  gtk_widget_show(win_error);
  gtk_window_set_transient_for((GtkWindow*)win_error,(GtkWindow*)win_main);
}

void success(char *format, ...) {
  va_list arg;
  va_start(arg,format);
  
  vsnprintf(message,1023,format,arg);
  va_end(arg);

  win_success = glade_xml_get_widget(gui, "win_success");
  if(!win_success) {
    fprintf(stderr,"ERROR: missing success window\n");
    fprintf(stderr,"while trying to dump success message :>\n");
    fprintf(stderr,"%s\n",message);
    return;
  }

  if(!success_text)
    success_text = (GtkLabel*)glade_xml_get_widget(gui,"success_text");
  gtk_label_set_text(success_text,message);

  gtk_widget_show(win_success);
  gtk_window_set_transient_for((GtkWindow*)win_success,(GtkWindow*)win_main);
}

bool check_result() {
  struct stat st;
  FILE *fd;
  char rdln[512];
  char msg[512];
  bool res = false;
  if( stat(SUCCESS_FILE,&st) <0) {

    // there is an error
    fd = fopen(ERROR_FILE,"r");
    if(!fd) {
      fprintf(stderr,"can't open %s : %s\n",
	      ERROR_FILE,strerror(errno));
      sprintf(msg,"An unexpected error occurred\nduring the last operation :^(");
    } else {
      while( fgets(rdln,511,fd) )
	snprintf(msg,511,"%s\n%s",msg,rdln);
      fclose(fd);
      unlink(ERROR_FILE);
    }
    error(msg);

  } else {

    // completed with success
    fd = fopen(SUCCESS_FILE,"r");
    if(!fd) {
      fprintf(stderr,"can't open %s : %s\n",
	      SUCCESS_FILE,strerror(errno));
      sprintf(msg,"Operation completed succesfully! :^)");
    } else {
      while( fgets(rdln,511,fd) )
	snprintf(msg,511,"%s\n%s",msg,rdln);
      fclose(fd);
      unlink(SUCCESS_FILE);
    }
    success(msg);
    res = true;

  }
  
  return(res);
}
