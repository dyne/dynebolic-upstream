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
 * "$Id$"
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <libintl.h>

#include <taschino.h>
#include <parts.h>
#include <dock.h>
#include <nest.h>


/* widget -> callback connection define */
static GtkWidget *wg;
#define CONNECT(w,s,c) \
  wg = glade_xml_get_widget(gui, w); \
  if(wg) g_signal_connect((gpointer) wg, s , \
			  G_CALLBACK( c ),NULL);
#define CONNECT_ARG(w,s,c,a) \
  wg = glade_xml_get_widget(gui, w); \
  if(wg) g_signal_connect((gpointer) wg, s , \
			  G_CALLBACK( c ),a);

/* global variables */
GladeXML *gui;
GtkWidget *win_main;
GtkWidget *win_knowmore;
GtkWidget *win_nest_hd;
GtkWidget *win_nest_usb;
GtkWidget *win_success;
GtkWidget *win_error;

void show_win(GtkWidget *widget, gpointer *data) {
  if(!data) {
    fprintf(stderr,"missing widget in GUI descrption\n");
    fprintf(stderr,"fatal error: taschino.glade is corrupted\n");
    gtk_main_quit();
  }
  gtk_widget_show((GtkWidget*)data);
}

void hide_win(GtkWidget *widget, gpointer *data) {
  if(!data) {
    fprintf(stderr,"hide win called on NULL pointer\n");
    return;
  }
  gtk_widget_hide((GtkWidget*)data);
}

int main(int argc, char **argv) {
  
  FILE *ftmp = NULL;
  char guipath[512];

  sprintf(guipath,"taschino.glade");

  ftmp = fopen(guipath,"r");
  if(!ftmp) {
    fprintf(stdout,"file missing: taschino.glade\n");
    sprintf(guipath,"/usr/share/dynebolic/taschino/taschino.glade");
    ftmp = fopen(guipath,"r");
  }
  if(!ftmp) {
    fprintf(stdout,"fatal error: GUI description not found");
    exit(0);
  } else fclose(ftmp);

  /* internationalization stuff */
  bindtextdomain ("taschino", "/usr/share/dynebolic/taschino");
  textdomain ("taschino");
  gtk_set_locale ();

  gtk_init(&argc,&argv);
  gui = glade_xml_new(guipath,NULL,NULL);

  /* connect callbacks automatically 
     glade_xml_signal_autoconnect(gui);
     it never worked for me, probably because
     i split the source in multiple files */
  
  /* signal to glib we're going to use threads
     g_thread_init(NULL); */

  /* ====== connect callbacks manually */

  /* setup window pointers and show/hide callbacks */
  win_main = glade_xml_get_widget(gui, "win_main");
  CONNECT("win_main","destroy",gtk_main_quit);



  /* dialogs from results.cpp */
  win_error = glade_xml_get_widget(gui, "win_error");
  CONNECT_ARG("error_button","clicked",hide_win,win_error);
  win_success = glade_xml_get_widget(gui, "win_success");
  CONNECT_ARG("success_button","clicked",hide_win,win_success);
  

  win_knowmore = glade_xml_get_widget(gui, "win_knowmore");
  CONNECT("win_knowmore","destroy",gtk_main_quit);
  CONNECT_ARG("button_knowmore","clicked",show_win,win_knowmore);
  CONNECT_ARG("close_knowmore","clicked",hide_win,win_knowmore);

  /* nest on harddisk window */
  win_nest_hd = glade_xml_get_widget(gui, "win_nest_hd");
  gtk_window_set_transient_for((GtkWindow*)win_nest_hd,(GtkWindow*)win_main);
  CONNECT("win_nest_hd","destroy",gtk_main_quit);
  /* nest on harddisk button */
  CONNECT_ARG("button_goto_nest_hd","clicked",show_win,win_nest_hd);
  /* apply|cancel buttons in win_nest_usb and win_nest_hd */
  CONNECT("apply_nest_hd","clicked",apply_nest_hd);
  CONNECT_ARG("cancel_nest_hd","clicked",hide_win,win_nest_hd);
  /* refreshes information about hd partitions */
  scan_nest_hd();

  /* nest on USB window */
  win_nest_usb = glade_xml_get_widget(gui, "win_nest_usb");
  gtk_window_set_transient_for((GtkWindow*)win_nest_usb,(GtkWindow*)win_main);
  CONNECT("win_nest_usb","destroy",gtk_main_quit);
  /* nest on USB button */
  CONNECT_ARG("button_goto_nest_usb","clicked",show_win,win_nest_usb);
  /* register the apply button callback from nest.cpp */
  CONNECT("apply_nest_usb","clicked",apply_nest_usb);
  CONNECT_ARG("cancel_nest_usb","clicked",hide_win,win_nest_usb);
  /* fill up the gtk widget with informations about the usb found */
  scan_nest_usb();

  
  gtk_main();

  exit(1);
}
