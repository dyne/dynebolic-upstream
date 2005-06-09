/* Lost-in-babylon - localization software for dyne:bolic GNU/Linux distribution
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
 * "$Header: /dynebolic/lost-in-babylon/src/callbacks.c,v 1.3 2003/09/24 10:00:06 jaromil Exp $"
 */


#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>
#include <ctype.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

//#define DEBUG 1
#define LOCALE_ALIAS "/usr/share/dynebolic/locale.alias"
#define KEYBOARD_LST "/usr/share/dynebolic/keyboard.lst"
#define MAX_PATH_SIZE 512

struct language {
  char name[256];
  char lang[16];
};
static struct language langs[512]; /* i bet they're not going to be more */
static int langs_len;
static char current_lang[16];
static int current_lang_num;

struct keyboard {
  char name[256];
  char kbd[16];
};
static struct keyboard keybs[512]; /* i bet they're also not going to be more */
static int keybs_len;
static char current_keyb[16];
static int current_keyb_num;

int chomp(char *str) {
  size_t len; //, ilen;
  char tmp[MAX_PATH_SIZE], *p = str;
  memset(tmp,'\0',MAX_PATH_SIZE);
  /* eliminate space and tabs at the beginning */
  while (*p == ' ' || *p == '\t') p++;
  strncpy(tmp, p, MAX_PATH_SIZE);
  /* point *p at the end of string */
  len = strlen(tmp); 
  p = &tmp[len-1];
  while ((*p == ' ' || *p == '\t' || *p == '\n') && len) {
    *p = '\0'; p--; len--; }
  strncpy(str, tmp, MAX_PATH_SIZE);
  return len;
}

void
on_combo1_realize                      (GtkWidget       *widget,
                                        gpointer         user_data)
{
  /* parse locale.alias file to index supported languages
     lines seem to be all like this:
     italian         it_IT.ISO-8859-1 */
  GList *items = NULL;
  FILE *locales;
  char line[512];
  int linelen;
  char name[256];
  char lang[16];
  char *p, *pp;
  int c;

  p = getenv("LANG"); if(p)
    strcpy(current_lang,p);
  else
    strcpy(current_lang,"POSIX"); /* default */

  langs_len = 0;
  locales = fopen(LOCALE_ALIAS,"r");
  if(!locales) {
    fprintf(stderr,"[!] error in opening %s\n[!] %s\n",
	    LOCALE_ALIAS,strerror(errno));
    return;
  }
  memset(langs,'\0',sizeof(langs));

  while(!feof(locales)) {
    /* read a line */
    if(!fgets(line,512,locales)) continue;
    linelen = chomp(line);
#ifdef DEBUG
    fprintf(stderr,"read: \"%s\" [%i]\n",line,linelen);
#endif
    /* skip void lines and comments starting with # */
    if(line[0]=='#' || !linelen) continue;
    /* gets the name */
    pp = p = line; while(!isblank((int)*p)) p++;
    *p = '\0'; strncpy(name,pp,256);
    /* gets the LANG keyword */
    while(!isalpha((int)*p)) p++;
    pp = p; while(*p != '.') p++;
    *p = '\0'; strncpy(lang,pp,16);
#ifdef DEBUG
    fprintf(stderr,"parsed: %s = %s\n", name, lang);
#endif
    if(langs_len>0) {
#ifdef DEBUG
      fprintf(stderr,"comparing %s with %s\n",lang,langs[langs_len-1].lang);
#endif
      if(strncmp(langs[langs_len-1].lang,lang,5)==0) {
#ifdef DEBUG
	fprintf(stderr,"skipped for repetition with %s = %s\n", 
		langs[langs_len-1].name, langs[langs_len-1].lang);
#endif
	continue;
      }
    }
    strcpy(langs[langs_len].name,name);
    strcpy(langs[langs_len].lang,lang);
    langs_len++;
  }

  /* fills the combo box with choices */
  for(c=0;c<langs_len;c++) {
#ifdef DEBUG
    fprintf(stderr,"[%i] \"%s\" - \"%s\"\n",c,langs[c].name,langs[c].lang);
#endif
    /* makes first in combo box the one selected */
    if(strcmp(current_lang,langs[c].name)==0) {
      items = g_list_prepend(items,langs[c].name);      
      current_lang_num = c;
    } else
      items = g_list_append(items,langs[c].name);
  }
  gtk_combo_set_popdown_strings((GtkCombo*)widget,items);
  g_list_free(items);
  fclose(locales);
}


void
on_combo2_realize                      (GtkWidget       *widget,
                                        gpointer         user_data)
{
  GList *items = NULL;
  FILE *keyboards;
  char line[512];
  int linelen;
  char name[256];
  char kbd[16];
  char *p, *pp;
  int c;

  p = getenv("KEYB"); if(p)
    strcpy(current_keyb,p);
  else
    strcpy(current_keyb,"us"); /* default */

  keybs_len = 0;
  keyboards = fopen(KEYBOARD_LST,"r");
  if(!keyboards) {
    fprintf(stderr,"[!] error in opening %s\n[!] %s\n",
	    KEYBOARD_LST,strerror(errno));
    return;
  }
  memset(keybs,'\0',sizeof(keybs));

  while(!feof(keyboards)) {
    /* read a line */
    if(!fgets(line,512,keyboards)) continue;
    linelen = chomp(line);
#ifdef DEBUG
    fprintf(stderr,"read: \"%s\" [%i]\n",line,linelen);
#endif
    /* skip void lines and comments starting with # */
    if(line[0]=='#' || !linelen) continue;
    /* gets the KBD code */
    pp = p = line; while(!isblank((int)*p)) p++;
    *p = '\0'; strncpy(kbd,pp,16);
    /* gets the keyboard name */
    while(!isalpha((int)*p)) p++;
    pp = p; while(*p != '\0') p++;
    strncpy(name,pp,256);
#ifdef DEBUG
    fprintf(stderr,"parsed: %s = %s\n", name, kbd);
#endif
    /* here we don't check for repeated entries! */
       
    strcpy(keybs[keybs_len].name,name);
    strcpy(keybs[keybs_len].kbd,kbd);
    keybs_len++;
  }
  
  /* fills the combo box with choices */
  for(c=0;c<keybs_len;c++) {
#ifdef DEBUG
    fprintf(stderr,"[%i] \"%s\" - \"%s\"\n",c,keybs[c].name,keybs[c].kbd);
#endif
    if(strcmp(current_keyb,keybs[c].kbd)==0) {
      items = g_list_prepend(items,keybs[c].name);
      current_keyb_num = c;
    } else
      items = g_list_append(items,keybs[c].name);
  }
  gtk_combo_set_popdown_strings((GtkCombo*)widget,items);
  g_list_free(items);
  fclose(keyboards);

      
}


void
on_combo_lang_changed                  (GtkEditable     *editable,
                                        gpointer         user_data)
{
  char tmp[256];
  int c;
  strncpy(tmp, gtk_entry_get_text((GtkEntry*)editable), 256);
  for(c=0;c<langs_len;c++)
    if(strcmp(langs[c].name,tmp)==0) break;
  current_lang_num = c;
  strcpy(current_lang,tmp);
#ifdef DEBUG
  fprintf(stderr,"changed language selection to %s \"%s\"\n",
	  current_lang,langs[current_lang_num].lang);
#endif
}


void
on_combo_keyb_changed                  (GtkEditable     *editable,
                                        gpointer         user_data)
{
  char tmp[256];
  int c;
  strncpy(tmp, gtk_entry_get_text((GtkEntry*)editable), 256);
  for(c=0;c<keybs_len;c++)
    if(strcmp(keybs[c].name,tmp)==0) break;
  current_keyb_num = c;
  strcpy(current_keyb,tmp);
#ifdef DEBUG
  fprintf(stderr,"changed keyboard selection to %s \"%s\"\n",
	  current_keyb,keybs[current_keyb_num].kbd);
#endif
  
}



void
on_button_ok_released                  (GtkButton       *button,
                                        gpointer         user_data)
{
  char tmp[256];
  FILE *rc;
  pid_t proc;
  int res;

  fprintf(stderr,"[*] setup %s language and %s keyboard\n",current_lang,current_keyb);
  rc = fopen("/etc/LANGUAGE","w");
  if(!rc) {
    fprintf(stderr,"[!] error writing /etc/LANGUAGE: %s\n",strerror(errno));
  } else {
    fputs("# dyne:bolic language configuration file\n",rc);
    snprintf(tmp,256,"# %s version %s\n",PACKAGE,VERSION);
    fputs(tmp,rc);
    fputs("# DO NOT EDIT BY HAND THIS FILE\n",rc);
    fputs("# write 'lost-in-babylon' in your XTERM instead!\n\n",rc);
    setenv("LC_ALL",langs[current_lang_num].lang,1);
    snprintf(tmp,256,"export LC_ALL=\"%s\"\n",langs[current_lang_num].lang);
    fputs(tmp,rc);
    setenv("LANG",current_lang,1);
    snprintf(tmp,256,"export LANG=\"%s\"\n",current_lang);
    fputs(tmp,rc);
    setenv("KEYB",keybs[current_keyb_num].kbd,1);
    snprintf(tmp,256,"export KEYB=\"%s\"\n",keybs[current_keyb_num].kbd);
    fputs(tmp,rc);
    fputs("\n# gooo rastammannn! faiddababylon!\n",rc);
    fclose(rc);
    fprintf(stderr," .  settings succesfully saved\n");
  }

  //  proc = fork();
  //  if(proc==0) {
  execlp("setxkbmap","setxkbmap","-layout",keybs[current_keyb_num].kbd,NULL);

  execlp("source","source","/etc/LANGUAGE",NULL);
    //    sleep(1);
    //    _exit(1);
    //  }
    //  wait(&res);
  
  fprintf(stderr," .  keyboard settings activated\n");
  gtk_main_quit();
  
}

