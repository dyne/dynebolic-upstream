/* Dynesplash2 - splashscreen for dyne:bolic
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
 * "$Id: taschino.cpp,v 1.2 2004/03/14 00:19:58 jaromil Exp $"
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <libintl.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <gtk/gtk.h>
#include <glade/glade.h>

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
static GladeXML *gui;

static char *www_rastasoft = "http://rastasoft.org";
static char *www_dyne = "http://dyne.org";
static char *www_freaknet = "http://freaknet.org";
static char *www_europe = "http://www.peopleshareit.eu";
static char *www_morecredits = "http://dynebolic.org/index.php?show=authors";

void goto_url(GtkWidget *widget, gpointer *data) {
	pid_t proc;
	int res;
	if(!data) {
		fprintf(stderr,"error in goto_url: missing data pointer\n");
	} else {
		fprintf(stderr, "splash debug: goto url %s\n",(char*)data);
	}
	proc = fork();
	if(!proc) {
		execlp("sensible-browser","sensible-browser",(char*)data,NULL);
		perror("can't fork to launch a sensible web browser");
		_exit(1);
	}
	wait(&res);
}
	
void quit(GtkWidget *widget, gpointer *data) {
	gtk_main_quit();
	exit(1);
}

int main(int argc, char **argv) {
  
  FILE *ftmp = NULL;
  char guipath[512];
//  char cwd[512];

//  getcwd(cwd,511);
//  chdir("/usr/share/dynebolic/splash");

  sprintf(guipath,"dynesplash.glade");

  ftmp = fopen(guipath,"r");
  if(!ftmp) {
    sprintf(guipath,"/usr/share/dyne/splash/dynesplash.glade");
    ftmp = fopen(guipath,"r");
  }
  if(!ftmp) {
    fprintf(stdout,"file missing: dynesplash.glade\n");
    fprintf(stdout,"fatal error: GUI description not found");
    exit(0);
  } else fclose(ftmp);

  /* internationalization stuff */
  bindtextdomain ("dynesplash", "/usr/share/dyne/splash");
  textdomain ("dynesplash");
  gtk_set_locale ();

  gtk_init(&argc,&argv);
  gui = glade_xml_new(guipath,NULL,NULL);

  /* connect callbacks automatically  */
  glade_xml_signal_autoconnect(gui);
  
  /* ====== connect callbacks manually */
    
  // credits
  CONNECT_ARG("rastasoft_button","clicked",goto_url,www_rastasoft);
  CONNECT_ARG("dyne_button","clicked",goto_url,www_dyne);
  CONNECT_ARG("eu_button","clicked",goto_url,www_europe);
  CONNECT_ARG("morecredits_button","clicked",goto_url,www_morecredits);
  
  gtk_main();

  exit(1);
}
