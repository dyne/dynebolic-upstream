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
static GtkRange *hscale_hd;
static GtkRange *hscale_usb;
static GtkLabel *label_usb;

static int selection = -1;
static int selection_usb = -1;

void select_nest(int *num) {
  if(scan_parts()<*num) return;
  selection = *num;
  fprintf(stderr,"HD selected %i : %s\n", 
	  selection, parts[selection].label);

  gtk_range_set_adjustment
    (hscale_hd,GTK_ADJUSTMENT
     (gtk_adjustment_new(32,32,
			 (parts[selection].fs.f_bavail *
			  (parts[selection].fs.f_bsize/1024))/1000,1,0,0)));
}

void scan_nest_usb() {
  int c = 0;
  /* take only the first usb partition
     anyway only /rem/usb is checked, hardcoded in parts.cpp */
  label_usb = (GtkLabel*)glade_xml_get_widget(gui, "label_usb");


  for(c=0;c<=scan_parts();c++) {
    if(parts[c].support != USB) continue;

      selection_usb = c;
      if(parts[c].no_space) {
	gtk_label_set_text(label_usb,"you don't have enough space (minimum 32MB)");
	break;
      }
      if(parts[c].no_write) {
	gtk_label_set_text(label_usb,"can't write on usb storage device");
	break;
      }
      if(parts[c].has_nest) {
	gtk_label_set_text(label_usb,"device allready contains a nest!");
	break;
      }
      if(parts[c].has_error) {
	gtk_label_set_text(label_usb,parts[c].error);
	break;
      }
      //    debug_parts(c);
      gtk_label_set_text(label_usb,parts[c].label);
      hscale_usb = (GtkRange*)glade_xml_get_widget(gui,"hscale_nest_usb_size");
      gtk_range_set_adjustment
	(hscale_usb,GTK_ADJUSTMENT
	 (gtk_adjustment_new(32,32,
			     (parts[c].fs.f_bavail *
			      (parts[c].fs.f_bsize/1024))/1000,1,0,0)));
      break;

  }

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
			     G_CALLBACK(select_nest),
			     (gpointer)&parts[c].num);
    avail++;
    // default selection on first entry
    if(avail==1) select_nest(&c);
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
  char size_str[16];
  char mesg[512];
  
  pid_t proc;
  int res;

  debug_parts(sel);

  /* gather user input settings */
  
  cryptoggle = (GtkToggleButton*)glade_xml_get_widget(gui,nest_crypt);
  crypt = gtk_toggle_button_get_active( cryptoggle );
  fprintf(stderr,"encryption is %i\n",crypt);

  sizebar = (GtkRange*)glade_xml_get_widget(gui,nest_size);
  size = (unsigned int) sizebar->adjustment->value;
  fprintf(stderr,"size is %i\n",size);

  snprintf(size_str,15,"%u",size);
  snprintf(mesg,511,"creating%sdyne:bolic nest of %sMB in %s",
	   (crypt) ? " encrypted " : " ", size_str, parts[sel].label);
  
  proc = fork();
  if(!proc) {
    execlp("xterm","taschino","-tn","linux","-bg","lightgrey","-fg","black",
	   "-T",mesg,"-geometry","118x20",
	   "-e","nidifica", "-s",size_str, "-l", parts[sel].path,
	   (crypt) ? "-e" : NULL, (crypt) ? "AES128" : NULL, NULL);
    perror("can't fork to launch docking command");
    _exit(1);
  }
  wait(&res);

  check_result();

}
void apply_nest_usb(GtkWidget *widget, gpointer *data) {
  if(selection_usb<0)
    error("no USB device detected");
  else if(parts[selection_usb].no_space
	  || parts[selection_usb].no_write
	  || parts[selection_usb].has_error
	  || parts[selection_usb].has_nest)
    error("%s",gtk_label_get_text(label_usb));
  else {
    sprintf(nest_size,"hscale_nest_usb_size");
    sprintf(nest_crypt,"toggle_nest_usb_crypt");
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
    sprintf(nest_crypt,"toggle_nest_hd_crypt");
    apply_nest(selection);
  }
}

