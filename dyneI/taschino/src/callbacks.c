/* Taschino - nesting software for dyne:bolic GNU/Linux distribution
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
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/vfs.h>
#include <ctype.h>
#include <errno.h>
#include <asm/errno.h>

#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

//#define DEBUG 1

#define DYNEBOL_CFG = "dynebol.cfg"
#define DYNEBOL_NST = "dynebol.nst"

static GtkWidget *win_main = NULL;

static GtkWidget *win_hd = NULL;
static GtkWidget *win_usb = NULL;

static GtkWidget *win_not_found = NULL;
static GtkWidget *win_success = NULL;
static GtkWidget *win_failure = NULL;

static gboolean encrypt = FALSE;

struct partition {
  char path[255];
  char label[64];
  struct statfs fs;
  char total_space[32]; /* strings in format 32Mb or 3Gb */
  char avail_space[32]; 
};
static struct partition part[64]; /* i bet you don't have more than 64 partitions */
static struct partition usb[64];

static int part_num = 0, usb_num = 0;
static int part_sel = 0, usb_sel = 0;
static int media_sel = 0;
#define HD 3
#define USB 2
#define FD 1


int hd_selector(const struct dirent *dir) {
  if(strstr(dir->d_name,"hd")) return(1);
  return(0);
}
int usb_selector(const struct dirent *dir) {
  if(strstr(dir->d_name,"usb")) return(1);
  return(0);
}
int all_selector(const struct dirent *dir) {
  if( (dir->d_name[0]!='.')
      && (strncmp(dir->d_name,"..",2)!=0) ) return(1);
  return(0);
}

int detect_harddisk() { /* DETECT HARDDISKS */
  struct dirent **filelist;
  int found, c;
  int tmpfd;
  char tmp[512];
  GtkWidget *win_has_nest;
  
  /* zeroes all the struct */
  memset(part,0,sizeof(part));
  
  found = scandir("/vol",&filelist,hd_selector,alphasort);
  if(found<0) perror("can't scan /vol");
  
  for(c=0;c<found;c++) { /* now we cycle thru all the mounted harddisk in /vol */
    snprintf(part[c].path,255,"/vol/%s",filelist[c]->d_name);

    /* check if the partition is WRITABLE
       check if the partition has some space
       check if the partition has allready a nest */
    snprintf(tmp,512,"%s/dynebol.cfg",part[c].path);
    tmpfd = open(tmp,O_CREAT|O_EXCL,S_IRWXU);
    if(tmpfd<0) {
      /* some error occurred:
	 EACCESS | EROFS = non writable filesystem
	 ENOSPC = filesystem has no more space
	 EEXIST = a nest allready exists */
      if (errno == 13 || errno == 30) { /* EACCESS || EROFS */
	fprintf(stderr,"[!] non writable filesystem on %s\n",
		filelist[c]->d_name);
      }

      if(errno == 28) { /* ENOSPC */
	  fprintf(stderr,"[!] no space left on filesystem %s\n",
		  filelist[c]->d_name);
      }
	  
      if (errno == 17) { /* EEXIST */
	win_has_nest = create_win_has_nest();
	gtk_widget_show(win_has_nest);
	    fprintf(stderr,"[!] a nest allready exists on filesystem %s\n",
		    filelist[c]->d_name);
      }
      
      //      fprintf(stderr,"[!] %s\n", strerror(errno));
      // why errno is messy? */

    /* if we got to exclude the partition from the previous check
       then continue the for cycle analyzing the next partition */
      continue;
    } else {
      /* everything allright, file opened correctly
       but it was just a test, so we close and unlink */
      close(tmpfd);
      unlink(tmp);
    }
    
    


    if( statfs(part[c].path,&part[c].fs) <0 ) {
      fprintf(stderr,"can't gather information on %s : %s",
	      filelist[c]->d_name, strerror(errno));
      continue;
    }

    /* we got an installable partition! */
    part_num++;

    /* form human readable strings about the harddisk space
       first: TOTAL SPACE */
    if( (part[c].fs.f_blocks * (part[c].fs.f_bsize / 1024))/1000 > 1000) {
      /* >1000Mb it is about gigabytes */
      sprintf(part[c].total_space,"%.1fGb",
	      (float)(part[c].fs.f_blocks * (part[c].fs.f_bsize / 1024))/(1000*1000));
    } else {
      /* it is less than one gigabyte */
      sprintf(part[c].total_space,"%.1fMb",
	      (float)(part[c].fs.f_blocks * (part[c].fs.f_bsize / 1024))/1000);
    }	
    /* then FREE SPACE */
    if( (part[c].fs.f_bfree * (part[c].fs.f_bsize / 1024))/1000 > 1000) {
      /* >1000Mb it is about gigabytes */
      sprintf(part[c].avail_space,"%.1fGb",
	      (float)(part[c].fs.f_bavail * (part[c].fs.f_bsize / 1024))/(1000*1000));
    } else {
      /* it is less than one gigabyte */
      sprintf(part[c].avail_space,"%.1fMb",
	      (float)(part[c].fs.f_bavail * (part[c].fs.f_bsize / 1024))/1000);
    }
#ifdef DEBUG
    fprintf(stderr,"%s has %s free space of %s total\n",
	    filelist[c]->d_name,
	    part[c].avail_space,
	    part[c].total_space);
#endif
  }
  
  return part_num;
} /* end of HARDDISK DETECTION */

int detect_usbkey() { /* DETECT USB STORAGE */
  struct dirent **filelist;
  int found, c;
  int tmpfd;
  char tmp[512];
  GtkWidget *win_has_nest;
  
  /* zeroes all the struct */
  memset(part,0,sizeof(part));
  
  found = scandir("/vol",&filelist,usb_selector,alphasort);
  if(found<0) perror("can't scan /vol");
  
  for(c=0;c<found;c++) { /* now we cycle thru all the mounted harddisk in /vol */
    snprintf(usb[c].path,255,"/vol/%s",filelist[c]->d_name);

    /* check if the partition is WRITABLE
       check if the partition has some space
       check if the partition has allready a nest */
    snprintf(tmp,512,"%s/dynebol.cfg",usb[c].path);
    tmpfd = open(tmp,O_CREAT|O_EXCL,S_IRWXU);
    if(tmpfd<0) {
      /* some error occurred:
	 EACCESS | EROFS = non writable filesystem
	 ENOSPC = filesystem has no more space
	 EEXIST = a nest allready exists */
      if (errno == 13 || errno == 30) { /* EACCESS || EROFS */
	fprintf(stderr,"[!] non writable filesystem on %s\n",
		filelist[c]->d_name);
      }

      if(errno == 28) { /* ENOSPC */
	  fprintf(stderr,"[!] no space left on filesystem %s\n",
		  filelist[c]->d_name);
      }
	  
      if (errno == 17) { /* EEXIST */
	win_has_nest = create_win_has_nest();
	gtk_widget_show(win_has_nest);
	    fprintf(stderr,"[!] a nest allready exists on filesystem %s\n",
		    filelist[c]->d_name);
      }
      
      //      fprintf(stderr,"[!] %s\n", strerror(errno));
      // why errno is messy? */

    /* if we got to exclude the partition from the previous check
       then continue the for cycle analyzing the next partition */
      continue;
    } else {
      /* everything allright, file opened correctly
       but it was just a test, so we close and unlink */
      close(tmpfd);
      unlink(tmp);
    }
    
    


    if( statfs(usb[c].path,&usb[c].fs) <0 ) {
      fprintf(stderr,"can't gather information on %s : %s",
	      filelist[c]->d_name, strerror(errno));
      continue;
    }

    /* we got an installable partition! */
    usb_num++;

    /* form human readable strings about the harddisk space
       first: TOTAL SPACE */
    if( (usb[c].fs.f_blocks * (usb[c].fs.f_bsize / 1024))/1000 > 1000) {
      /* >1000Mb it is about gigabytes */
      sprintf(usb[c].total_space,"%.1fGb",
	      (float)(usb[c].fs.f_blocks * (usb[c].fs.f_bsize / 1024))/(1000*1000));
    } else {
      /* it is less than one gigabyte */
      sprintf(usb[c].total_space,"%.1fMb",
	      (float)(usb[c].fs.f_blocks * (usb[c].fs.f_bsize / 1024))/1000);
    }	
    /* then FREE SPACE */
    if( (usb[c].fs.f_bfree * (usb[c].fs.f_bsize / 1024))/1000 > 1000) {
      /* >1000Mb it is about gigabytes */
      sprintf(usb[c].avail_space,"%.1fGb",
	      (float)(usb[c].fs.f_bavail * (usb[c].fs.f_bsize / 1024))/(1000*1000));
    } else {
      /* it is less than one gigabyte */
      sprintf(usb[c].avail_space,"%.1fMb",
	      (float)(usb[c].fs.f_bavail * (usb[c].fs.f_bsize / 1024))/1000);
    }
#ifdef DEBUG
    fprintf(stderr,"%s has %s free space of %s total\n",
	    filelist[c]->d_name,
	    usb[c].avail_space,
	    usb[c].total_space);
#endif
  }
  
  return usb_num;
} /* end of USB STORAGE DETECTION */


int nest_selected() {
  /* media_sel contains the number of the selected button
     it is in reverse order as the buttons are inserted in the group */
  switch(media_sel) {
  case HD: /* HD */
    if(win_hd) return media_sel;
    
    if( detect_harddisk() < 1) {

      /* no media found, popup window */
      if(!win_not_found) win_not_found = create_win_not_found();
      gtk_widget_show(win_not_found);

    } else {

      win_hd = create_win_nest_hd();
      gtk_widget_show(win_hd);  
      return(media_sel);

    }
    break;

  case USB: /* USB */
    if(win_usb) return media_sel;
    
    if( detect_usbkey() < 1) {

      /* no media found, popup window */
      if(!win_not_found) win_not_found = create_win_not_found();
      gtk_widget_show(win_not_found);

    } else {

      win_usb = create_win_nest_usb();
      gtk_widget_show(win_usb);  
      return(media_sel);

    }
    break;

  case FD: /* FLOPPY */
    {
      GtkWidget *notimpl;
      fprintf(stderr,"  install on FLOPPY!\n");
      notimpl = create_notimplemented();
      gtk_widget_show(notimpl);
    }
    break;

  default:
    fprintf(stderr,"ERROR: wrong selection\n");
    break;

  }

  return(0);
}

/* analize the result of nidifica
   /var/log/setup/nidifica.success file exists in case of success */
void nest_result() {
  struct stat st;
  if( stat("/var/log/setup/nidifica.success",&st) <0) {
    win_failure = create_win_failure();
    gtk_widget_show(win_failure);
  } else {
    win_success = create_win_success();
    gtk_widget_show(win_success);
  }
}

void
on_nest_selection_pressed              (GtkButton       *button,
                                        gpointer         user_data)
{
  if(!win_main)
    win_main = (GtkWidget*)user_data;
}


void
on_nest_selection_released             (GtkButton       *button,
                                        gpointer         user_data)
{

#ifdef DEBUG
  fprintf(stderr,"on_nest_selection_released(%p,%p)\n",button,user_data);
#endif

  GSList *radio_group = (GSList*)user_data;

  GtkToggleButton *radio;

  media_sel = 0;

  do {

    media_sel++;

    radio = (GtkToggleButton*) radio_group->data;

#ifdef DEBUG
      fprintf(stderr,"checking radio button %p\n",radio);
#endif

    if( gtk_toggle_button_get_active(radio) ) break;

    radio_group = radio_group->next;

  } while(radio_group);

  /* calls the method which pops up the proper
     window for the selected nest method 
     returns 0 if no media was found
             >0 if media was found and nest window popped up
  */
  if( nest_selected() )
    gtk_widget_hide(win_main);
  
  
}



void
on_ok_nest_hd_released                 (GtkButton       *button,
                                        gpointer         user_data)
{
  char nest[512];
  char nest_mb[16];
  char mesg[512];
  pid_t proc;
  int res;

#ifdef DEBUG
  fprintf(stderr,
	  "--\n"
	  "%s selected for nesting\n"
	  "blocksize is %u\n"
	  "total blocks are %u\n"
	  "total size in bytes %lu\n"
	  "free blocks are %lu\n"
	  "free size in bytes %lu\n"
	  "file nodes are %lu\n"
	  "free nodes are %lu\n"
	  "--\n",
	  part[part_sel].path,
	  part[part_sel].fs.f_bsize,
	  (unsigned int)part[part_sel].fs.f_blocks,
	  part[part_sel].fs.f_blocks * (part[part_sel].fs.f_bsize / 1024),
	  part[part_sel].fs.f_bavail,
	  part[part_sel].fs.f_bavail * (part[part_sel].fs.f_bsize / 1024),
	  part[part_sel].fs.f_files,
	  part[part_sel].fs.f_ffree);
#endif
  
  //  snprintf(nest,512,"%s/dynebol.nst",part[part_sel].path);
  snprintf(nest_mb,16,"%u",(unsigned int)((GtkRange*)user_data)->adjustment->value);
  
  snprintf(mesg,512,"creating%sdyne:bolic nest of %sMb in %s\n",
	  (encrypt) ? " encrypted " : " ", nest_mb, nest);

  proc = fork();

  if(proc==0) {
    
    execlp("xterm","taschino","-tn","linux","-bg","darkgrey","-fg","black",
	   "-T",mesg,"-geometry","118x20",
	   "-e","nidifica","-m","hd","-s",nest_mb,"-l", part[part_sel].path,
	   (encrypt) ? "-e" : NULL, (encrypt) ? "AES128" : NULL, NULL);
    perror("can't fork to launch nesting command");
    _exit(1);
  }
  wait(&res);

  gtk_widget_hide(win_hd);  

  nest_result();
  
}

void
on_ok_nest_usb_released                 (GtkButton       *button,
                                        gpointer         user_data)
{
  char nest[512];
  char nest_mb[16];
  char mesg[512];
  pid_t proc;
  int res;

#ifdef DEBUG
  fprintf(stderr,
	  "--\n"
	  "%s selected for nesting\n"
	  "blocksize is %u\n"
	  "total blocks are %u\n"
	  "total size in bytes %lu\n"
	  "free blocks are %lu\n"
	  "free size in bytes %lu\n"
	  "file nodes are %lu\n"
	  "free nodes are %lu\n"
	  "--\n",
	  usb[usb_sel].path,
	  usb[usb_sel].fs.f_bsize,
	  (unsigned int)usb[usb_sel].fs.f_blocks,
	  usb[usb_sel].fs.f_blocks * (usb[usb_sel].fs.f_bsize / 1024),
	  usb[usb_sel].fs.f_bavail,
	  usb[usb_sel].fs.f_bavail * (usb[usb_sel].fs.f_bsize / 1024),
	  usb[usb_sel].fs.f_files,
	  usb[usb_sel].fs.f_ffree);
#endif
  
  //  snprintf(nest,512,"%s/dynebol.nst",usb[usb_sel].path);
  snprintf(nest_mb,16,"%u",(unsigned int)((GtkRange*)user_data)->adjustment->value);
  
  snprintf(mesg,512,"creating%sdyne:bolic nest of %sMb in %s\n",
	  (encrypt) ? " encrypted " : " ", nest_mb, nest);

  proc = fork();

  if(proc==0) {
    
    execlp("xterm","taschino","-tn","linux","-bg","darkgrey","-fg","black",
	   "-T",mesg,"-geometry","118x20",
	   "-e","nidifica","-m","hd","-s",nest_mb,"-l", usb[usb_sel].path,
	   (encrypt) ? "-e" : NULL, (encrypt) ? "AES128" : NULL, NULL);
    perror("can't fork to launch nesting command");
    _exit(1);
  }
  wait(&res);

  gtk_widget_hide(win_hd);  

  nest_result();
  
}

void
on_toggle_pass_hd_toggled              (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
  if(gtk_toggle_button_get_active( togglebutton ))
    encrypt = TRUE;
  else
    encrypt = FALSE;
}

void
on_toggle_pass_usb_toggled              (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
  if(gtk_toggle_button_get_active( togglebutton ))
    encrypt = TRUE;
  else
    encrypt = FALSE;
}




/* ==============================================
   the harddisk partition combo box for selection */

void
on_combo_hd_partitions_changed         (GtkEditable     *editable,
                                        gpointer         user_data)
{
  char tmp[128];
  snprintf(tmp,128,"%s", gtk_entry_get_text((GtkEntry*)editable));
#ifdef DEBUG
  fprintf(stderr,"partition changes to %s\n", tmp);
#endif
  /* find the position in the struct where it is placed */
  sscanf(&tmp[0],"%u.",&part_sel);

  /* adjust the horizontal scaler to the geometry of selected partition */
  gtk_range_set_adjustment((GtkRange*)user_data,
			    GTK_ADJUSTMENT
			   (gtk_adjustment_new(64, 64,
					       (part[part_sel].fs.f_bavail *
						(part[part_sel].fs.f_bsize/1024))/1000,
					       1,0,0)));
}

void
on_combo_usb_partitions_changed        (GtkEditable     *editable,
					gpointer         user_data)
{
  char tmp[128];
  snprintf(tmp,128,"%s", gtk_entry_get_text((GtkEntry*)editable));
#ifdef DEBUG
  fprintf(stderr,"usb changes to %s\n", tmp);
#endif
  /* find the position in the struct where it is placed */
  sscanf(&tmp[0],"%u.",&usb_sel);

  /* adjust the horizontal scaler to the geometry of selected partition */
  gtk_range_set_adjustment((GtkRange*)user_data,
			    GTK_ADJUSTMENT
			   (gtk_adjustment_new(64, 64,
					       (usb[usb_sel].fs.f_bavail *
						(part[usb_sel].fs.f_bsize/1024))/1000,
					       1,0,0)));
}

void
on_combo1_realize                      (GtkWidget       *widget,
                                        gpointer         user_data)
{
  int c;
  GList *items = NULL;
  for(c=0;c<part_num;c++) {
    /* form the label for the combo box */
    snprintf(part[c].label,255,"%i.  %s  size:%s  free:%s",
	     c, part[c].path, part[c].total_space, part[c].avail_space);
    
    /* append another partition to the combo box */
    items = g_list_append(items, part[c].label);
  }

  gtk_combo_set_popdown_strings(GTK_COMBO(widget),items);
  g_list_free(items);
}

void
on_combo_usb_realize                   (GtkWidget       *widget,
					gpointer         user_data) 
{
  int c;
  GList *items = NULL;
  for(c=0;c<usb_num;c++) {
    /* form the label for the combo box */
    snprintf(usb[c].label,255,"%i.  %s  size:%s  free:%s",
	     c, usb[c].path, usb[c].total_space, usb[c].avail_space);
    
    /* append another partition to the combo box */
    items = g_list_append(items, usb[c].label);
  }

  gtk_combo_set_popdown_strings(GTK_COMBO(widget),items);
  g_list_free(items);

}

void
on_button_retry_not_present_released   (GtkButton       *button,
                                        gpointer         user_data)
{
  if( nest_selected() ) {
    gtk_widget_hide(win_main);
    gtk_widget_destroy(win_not_found);
  }
}

void
on_win_nest_hd_destroy                 (GtkObject       *object,
                                        gpointer         user_data)
{ 
  win_hd = NULL;
  gtk_widget_show(win_main);
}

void
on_win_nest_usb_destroy                 (GtkObject       *object,
                                        gpointer         user_data)
{
  win_usb = NULL;
  gtk_widget_show(win_main);
}

void
on_win_not_found_destroy               (GtkObject       *object,
                                        gpointer         user_data)
{ win_not_found = NULL; }

