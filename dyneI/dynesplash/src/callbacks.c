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
 * "Header: $"
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
on_order_button                        (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("mercuzio","mercuzio","http://dynebolic.org/order",NULL);
    perror("can't open online order page");
    _exit(1);
  }
}


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
    execlp("netconfig","netconfig",NULL);
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
on_conf_save_released                 (GtkButton       *button,
                                        gpointer         user_data)
{
  /*
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("printconfig","printconfig",NULL);
    perror("can't launch printer configurator");
    _exit(1);
  }
  */
  GtkWidget *popup = create_notimplemented();
  gtk_widget_show(popup);
}

void
on_conf_manual_released                (GtkButton       *button,
                                        gpointer         user_data)
{
  /*
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("links","-g","/usr/share/dynebolic/manual/index.html",NULL);
    perror("can't launch manual browser");
    _exit(1);
  }
  */
  GtkWidget *popup = create_notimplemented();
  gtk_widget_show(popup);

}


void
on_jaromil_released                    (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_bomboclat_released                  (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_c1cc10_released                     (GtkButton       *button,
                                        gpointer         user_data)
{

}


void
on_autoproduzioni_released             (GtkButton       *button,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("mercuzio","mercuzio","http://dyne.org",NULL);
    perror("can't open dyne.org page");
    _exit(1);
  }
}


gboolean
on_jaropix_button_release_event        (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data)
{
  pid_t proc;
  proc = fork();
  if(proc==0) {
    execlp("mercuzio","mercuzio","http://korova.dyne.org",NULL);
    perror("can't load jaromil's page");
    _exit(1);
  }

  return FALSE;
}


gboolean
on_bombopix_button_release_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data)
{

  return FALSE;
}


gboolean
on_cicciopix_button_release_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data)
{

  return FALSE;
}


gboolean
on_logo_tenovis_button_release_event   (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data)
{

  return FALSE;
}


gboolean
on_logo_pvl_button_release_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data)
{

  return FALSE;
}


gboolean
on_pixmap8_button_release_event        (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data)
{

  return FALSE;
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

