/* dynesplash - splash application for dyne:bolic GNU/Linux distribution
 * http://dynebolic.org
 * Copyright (C) 2003 Denis Rojo aka jaromil <jaromil@dyne.org>
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
 * "$Header$"
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

void
on_pressmouse_clicked                  (GtkButton       *button,
                                        gpointer         user_data)
{
  GtkWidget *popup = create_i_said_right();
  gtk_widget_show(popup);
}


void
on_conf_lang_released                  (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("lost-in-babylon","lost-in-babylon",NULL);
    perror("lost-in-babylon");
    _exit(1);
  }
}


void
on_conf_net_released                   (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("nettante","nettante",NULL);
    perror("can't launch network configurator");
    _exit(1);
  }
}


void
on_conf_modem_released                 (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("db-xterm","modemconfig","MODEMCONFIG :: setup your ppp connection","pppconfig",NULL);
    perror("can't launch modem configurator");
    _exit(1);
  }
}


void
on_conf_print_released                 (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("links","printconfig","-g","http://localhost:631",NULL);
    perror("can't launch printer configurator");
    _exit(1);
  }
//  GtkWidget *popup = create_notimplemented();
//  gtk_widget_show(popup);
}

void
on_autoproduzioni_released             (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("links","links","-g","http://dyne.org",NULL);
    perror("can't open dyne.org page");
    _exit(1);
  }
}



void
on_window1_destroy                     (GtkObject       *object,
                                        gpointer         user_data)
{
  exit(1);
}


void
on_iwait_released                      (GtkButton       *button,
                                        gpointer         user_data)
{
  gtk_widget_destroy(user_data);
}


void
on_iknow_released                      (GtkButton       *button,
                                        gpointer         user_data)
{
  gtk_widget_destroy(user_data);
}


void
on_conf_nest_released                  (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("taschino","taschino",NULL);
    perror("can't launch taschino: nest configurator");
    _exit(1);
  }

}


void
on_conf_screen_released                (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("xf86cfg","xf86cfg","-xf86config","/etc/XF86Config",NULL);
    perror("can't launch xf86cfg");
    _exit(1);
  }

}


void
on_button_donate_released              (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("donate","donate",NULL);
    perror("can't open online donation page");
    _exit(1);
  }
}

