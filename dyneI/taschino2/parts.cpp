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
#include <unistd.h>
#include <dirent.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#include <parts.h>

struct partition parts[MAX_PARTS];

static int parts_found;
static bool scanned = false;

int hd_selector(const struct dirent *dir) {
  if(strstr(dir->d_name,"hd")) return(1);
  return(0);
}
int usb_selector(const struct dirent *dir) {
  if(strstr(dir->d_name,"usb")) return(1);
  return(0);
}


/* this function gathers all needed information about
   a partition that has been found. it just gets passed
   the index of the partition entry: that must point to
   a valid and existend parts[c].path file! */
void analyze(int num) {
  char tmp[512];
  int tmpfd;

  sync(); // sputa in terra

  /* check if the partition has allready a nest
     check if the partition is writable
     check if the partition has some space
     check if the partition has allready a config */
  snprintf(tmp,512,"%s/dynebol.nst",parts[num].path);
  tmpfd = open(tmp,O_RDONLY);
  if(tmpfd>0) {
    close(tmpfd);
    parts[num].has_nest = true;;
  } else {
    /* check also the new nest path */
    snprintf(tmp,512,"%s/dyne/dynebol.nst",parts[num].path);
    tmpfd = open(tmp,O_RDONLY);
    if(tmpfd>0) {
      close(tmpfd);
      parts[num].has_nest = true;
    }
  }
  snprintf(tmp,512,"%s/.dyne_test_writable",parts[num].path);
  tmpfd = open(tmp,O_CREAT|O_EXCL,S_IRWXU);
  if(tmpfd<0) {
    /* some error occurred:
       EACCESS | EROFS = non writable filesystem
       ENOSPC = filesystem has no more space
       EEXIST = a nest allready exists */
    if (errno == 13 || errno == 30) { /* EACCESS || EROFS */
      //      fprintf(stderr,"non writable filesystem on %s\n", parts[num].path);
      parts[num].no_write = true;
    } else if(errno == 28) { /* ENOSPC */     
      //      fprintf(stderr,"no space left on filesystem %s\n", parts[num].path);
      parts[num].no_space = true;
    } else {
      fprintf(stderr,"error on %s : %s\n", parts[num].path,strerror(errno));
      parts[num].has_error = true;
      sprintf(parts[num].error,"error: %s", strerror(errno));
      return; // if an unknown error occurred don't gather more info
    }      
    
  } else {
    /* everything allright, file opened correctly
       but it was just a test, so we close and unlink */
    close(tmpfd);
    unlink(tmp);
  }
  
  if( statfs(parts[num].path,&parts[num].fs) <0 ) {
    fprintf(stderr,"can't gather information on %s : %s",
	    parts[num].path, strerror(errno));
      parts[num].no_info = true;
  } else {
    /* form human readable strings about the harddisk space
       first: TOTAL SPACE */
    if( (parts[num].fs.f_blocks * (parts[num].fs.f_bsize / 1024))/1000 > 1000) {
      /* >1000Mb it is about gigabytes */
      sprintf(parts[num].total_space,"%.1fGb",
	      (float)(parts[num].fs.f_blocks * (parts[num].fs.f_bsize / 1024))/(1000*1000));
    } else {
      /* it is less than one gigabyte */
      sprintf(parts[num].total_space,"%.1fMb",
	      (float)(parts[num].fs.f_blocks * (parts[num].fs.f_bsize / 1024))/1000);
    }	
    /* then FREE SPACE */
    if( (parts[num].fs.f_bfree * (parts[num].fs.f_bsize / 1024))/1000 > 1000) {
      /* >1000Mb it is about gigabytes */
      sprintf(parts[num].avail_space,"%.1fGb",
	      (float)(parts[num].fs.f_bavail * (parts[num].fs.f_bsize / 1024))/(1000*1000));
    } else {
      /* it is less than one gigabyte */
      sprintf(parts[num].avail_space,"%.1fMb",
	      (float)(parts[num].fs.f_bavail * (parts[num].fs.f_bsize / 1024))/1000);
    }
    
  }// statfs to gather info
  
  snprintf(parts[num].label,255,"%s size:%s free:%s",
	   parts[num].path, parts[num].total_space, parts[num].avail_space);
  
#ifdef DEBUG
  fprintf(stderr,"%s %s is %s big, with %s free space\n",
	  (parts[num].support==HD) ? "HD" : (parts[num].support==USB) ? "USB" : "??",
	  parts[num].path,
	  parts[num].total_space,
	  parts[num].avail_space);
  fprintf(stderr,"no_info[%i] no_space[%i] no_write[%i] has_nest[%i] has_error[%i]\n",
	  parts[num].no_info, parts[num].no_space, parts[num].no_write,
	  parts[num].has_nest, parts[num].has_error);
#endif
  
  sync();
}

int scan_parts() {

  if(scanned) {
    //    fprintf(stderr,"scan_partitions() : allready scanned %i\n",parts_found);
    return parts_found;
  }

  struct dirent **filelist;
  int found, c;
  
  /* zeroes all the struct */
  memset(parts,0,sizeof(parts));
  parts_found = 0;

  /* scan for harddisk partitions */
  found = scandir("/vol",&filelist,hd_selector,alphasort);
  if(found<0) perror("can't scan /vol");  
  for(c=0;c<found;c++) { /* now we cycle thru all the mounted harddisk in /vol */
    snprintf(parts[c].path,255,"/vol/%s",filelist[c]->d_name);
    parts[c].num = c;
    parts[c].support = HD;

    analyze(c);

    parts_found++;
  } // for cycle thru partitions found by scandir

  found = chdir("/rem/usb");
  if(found<0) perror("can't scan /rem/usb");
  else {
    sync();
    c++;
    snprintf(parts[c].path,255,"/rem/usb");
    parts[c].num = c;
    parts[c].support = USB;
    
    analyze(c);
    
    parts_found++;
  }

  scanned = true;
  return parts_found;
}

void debug_parts(int c) {
#ifdef DEBUG
  fprintf(stderr,
	  "--\n"
	  "%s DEBUG DUMP\n"
	  "blocksize is %u\n"
	  "total blocks are %u\n"
	  "total size in bytes %lu\n"
	  "free blocks are %lu\n"
	  "free size in bytes %lu\n"
	  "file nodes are %lu\n"
	  "free nodes are %lu\n"
	  "--\n",
	  parts[c].path,
	  parts[c].fs.f_bsize,
	  (unsigned int)parts[c].fs.f_blocks,
	  parts[c].fs.f_blocks * (parts[c].fs.f_bsize / 1024),
	  parts[c].fs.f_bavail,
	  parts[c].fs.f_bavail * (parts[c].fs.f_bsize / 1024),
	  parts[c].fs.f_files,
	  parts[c].fs.f_ffree);
#endif
}
