/* Taschino 2 - nest & dock application for dyne:bolic
 * (c) Copyright 2004-2005 Denis "Jaromil" Roio <jaromil@dyne.org>
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
 * "$Id: nest.cpp,v 1.2 2004/03/17 12:20:09 jaromil Exp $"
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <errno.h>
#include <string.h>

#include <parts.h>
#include <results.h>
#include <taschino.h>

static GtkOptionMenu *options_hd;
static GtkOptionMenu *options_usb;
static GtkRange *hscale_hd;
static GtkRange *hscale_usb;

static int selection = -1;
static int selection_usb = -1;

void select_nest_hd(int *num) {
  int max = 1024; // MAX size for a nest
  int available;

  if(scan_parts()<*num) return;
  selection = *num;
  fprintf(stderr,"HD selected %i : %s\n", 
	  selection, parts[selection].label);

  available = ( parts[selection].fs.f_bavail * (parts[selection].fs.f_bsize/1024) ) /1000;
  if(available<max) max = available;

  gtk_range_set_adjustment
    (hscale_hd,GTK_ADJUSTMENT
     (gtk_adjustment_new(32, 32, max, 1, 0, 0) ) );
}

void select_nest_usb(int *num) {
  int max = 1024; // MAX size for a nest
  int available;

  if(scan_parts()<*num) return;
  selection_usb = *num;
  fprintf(stderr,"USB selected %i : %s\n", 
	  selection_usb, parts[selection_usb].label);

  available = ( parts[selection_usb].fs.f_bavail * (parts[selection_usb].fs.f_bsize/1024) ) /1000;
  if(available<max) max = available;

  gtk_range_set_adjustment
    (hscale_usb,GTK_ADJUSTMENT
     (gtk_adjustment_new(32, 32, max, 1, 0, 0) ) );
}

void scan_nest_usb() {
  GtkMenu *menu;
  GtkWidget *item;
  int c = 0;
  int avail = 0;

  options_usb = (GtkOptionMenu*)glade_xml_get_widget(gui,"option_nest_usb");
  hscale_usb = (GtkRange*)glade_xml_get_widget(gui,"hscale_nest_usb_size");
  menu = (GtkMenu*)gtk_menu_new();
  gtk_menu_set_title(menu,"choose from available usb storage");
  
    for(c=0;c<scan_parts();c++) {
    if( parts[c].has_error
	|| parts[c].no_space
	|| parts[c].no_write
	|| parts[c].support != USB) continue;
    item = gtk_menu_item_new_with_label(parts[c].label);
    gtk_widget_show(item);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu),item);
    g_signal_connect_swapped(G_OBJECT(item), "activate",
			     G_CALLBACK(select_nest_usb),
			     (gpointer)&parts[c].num);
    avail++;
    // default selection on first entry
    if(avail==1) select_nest_usb(&c);
  }
  if(!avail) {
    item = gtk_menu_item_new_with_label("no available partitions found");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu),item);
  }

  gtk_option_menu_set_menu(options_usb,(GtkWidget*)menu);

}

void scan_nest_hd() {
  GtkMenu *menu;
  GtkWidget *item;
  int c, avail = 0;
  
  options_hd = (GtkOptionMenu*)glade_xml_get_widget(gui,"option_nest_partition");
  hscale_hd = (GtkRange*)glade_xml_get_widget(gui,"hscale_nest_hd_size");
  menu = (GtkMenu*)gtk_menu_new();
  gtk_menu_set_title(menu,"choose from available partitions");

  for(c=0;c<scan_parts();c++) {
    if( parts[c].has_error
	|| parts[c].no_space
	|| parts[c].no_write
	|| parts[c].support != HD) continue;
    item = gtk_menu_item_new_with_label(parts[c].label);
    gtk_widget_show(item);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu),item);
    g_signal_connect_swapped(G_OBJECT(item), "activate",
			     G_CALLBACK(select_nest_hd),
			     (gpointer)&parts[c].num);
    avail++;
    // default selection on first entry
    if(avail==1) select_nest_hd(&c);
  }
  if(!avail) {
    item = gtk_menu_item_new_with_label("no available partitions found");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu),item);
  }

  gtk_option_menu_set_menu(options_hd,(GtkWidget*)menu);

} /* end of HARDDISK DETECTION */

static char nest_size[256];
static char nest_crypt[256];
void apply_nest(int sel) {
  GtkToggleButton *cryptoggle;
  GtkRange *sizebar;
  bool crypt = false;
  int size = 0;
  char nestfile[256];
  char mesg[512];
  
  pid_t proc;

  debug_parts(sel);

  /* gather user input settings */
 
  /* encryption */
  cryptoggle = (GtkToggleButton*)glade_xml_get_widget(gui,nest_crypt);
  crypt = gtk_toggle_button_get_active( cryptoggle );
  fprintf(stderr,"encryption is %i\n",crypt);

  sizebar = (GtkRange*)glade_xml_get_widget(gui,nest_size);
  size = (unsigned int) sizebar->adjustment->value;
  fprintf(stderr,"size is %i\n",size);

  // create the dyne directory
  snprintf(nestfile,255,"%s/dyne",parts[sel].path);
  mkdir(nestfile,S_IRWXU);

  snprintf(nestfile,255,"%s/dyne/dyne.nst,%u",parts[sel].path,size);
  snprintf(mesg,511,"creating dyne:bolic nest %sMB", nestfile);
  
  proc = fork();
  if(!proc) {
    setenv("PATH","/bin:/sbin:/usr/bin:/usr/sbin/:/usr/X11R6/bin",1);
    if(crypt)
      execlp("mknest","mknest","-x","-f", nestfile, "-e", NULL);
    else
      execlp("mknest","mknest","-x","-f", nestfile, NULL);
    perror("can't fork to launch docking command");
    _exit(1);
  }
  //  waitpid(proc, &res, 0);

  //  check_result();

  // this function now quits
  // so when user selects it will all be dealt by mknest
  // in future we can get rid of this old C program and do
  // everything in a shell script: much more mantainable!
  gtk_main_quit();
  exit(1);
}
void apply_nest_usb(GtkWidget *widget, gpointer *data) {
  if(selection_usb<0) {
    error("no USB device detected");
  } else if(parts[selection_usb].no_space) {
    error("you don't have enough space (minimum 32MB)");
    return;
  } else if(parts[selection_usb].no_write) {
    error("can't write on harddisk partition (NT filesystem?)");
    return;
  } else if(parts[selection_usb].has_error) {
    error("%s",parts[selection_usb].error);
    return;
  } else if(parts[selection_usb].has_nest) {
    error("the harddisk allready contains a nest!");
    return;
  } else {
    sprintf(nest_size,"hscale_nest_usb_size");
    sprintf(nest_crypt,"usb_encrypt_toggle");
    apply_nest(selection_usb);
  }
}
  void apply_nest_hd(GtkWidget *widget, gpointer *data) {
  if(selection<0) {
    error("no harddisk detected");
    return;
  } else if(parts[selection].no_space) {
    error("you don't have enough space (minimum 32MB)");
    return;
  } else if(parts[selection].no_write) {
    error("can't write on harddisk partition (NT filesystem?)");
    return;
  } else if(parts[selection].has_error) {
    error("%s",parts[selection].error);
    return;
  } else if(parts[selection].has_nest) {
    error("the harddisk allready contains a nest!");
    return;
  } else {
    sprintf(nest_size,"hscale_nest_hd_size");
    sprintf(nest_crypt,"hd_encrypt_toggle");
    apply_nest(selection);
  }
}

