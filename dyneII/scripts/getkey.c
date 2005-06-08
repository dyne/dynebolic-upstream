/* FWIW, this is GNU GPL
   jaromil coded a bit and got stuck on the termios thing
   then asked martin guy and he got the right answer :) */

#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <errno.h>

int main(int argc, char **argv) {
  int res; char s='~';
  struct termios stty;
  int timeout = 5;
  if(argc>1) timeout = atoi(argv[1]);
  tcgetattr(0,&stty);
  stty.c_lflag ^= ICANON|ECHO;
  stty.c_cc[VTIME] = timeout*10;
  stty.c_cc[VMIN] = 0;
  tcsetattr(0,TCSANOW,&stty);
  if(read(0,&s,1) <0) {
    fprintf(stderr,"error onstdin: %s\n",
	    strerror(errno));
    exit -1; }
  switch(s) {
  case '~': res = -1; break;
  default: res = 0; break; }
  stty.c_lflag |= ICANON|ECHO;
  tcsetattr(0,TCSANOW,&stty);
  putc(s,stdout);
  exit( res ); 
}
