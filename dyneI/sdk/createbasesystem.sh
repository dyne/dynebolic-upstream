#!/bin/sh
# createbasesystem.sh
# by bomboclat & c1cc10

INSTDIR=/home/the_root

########################################################################
# FUNZIONI VIDEO
########################################################################
function colora_rosso() {
	echo -e "\033[31m"
	echo -e $1
	echo -e "\033[37m"
}

function colora_verde() {
	echo -e "\033[32m"
	echo -e $1
	echo -e "\033[37m"
}

#######################################################################

########################################################################
# FUNZIONI PRINCIPALI
########################################################################

# con questa funzione si verifica a che punto e' lo stage1, cioe' se e' presente
# portage ed e' quindi possibile compilare l'ambiente di compilazione base.
 
function initrd_root() {
	# Il portage e' stato gia' scaricato...
	if [ -d /usr/portage ] ; then
		colora_rosso "esiste gia' una dir /usr/portage. mi fido?(N/s)"
		read YESNO
		if ! [ $YESNO == "s" -o $YESNO == "" ] ; then
			emerge sync
		fi
	else 
		emerge sync
	fi
	# Il bootstrap e' stato gia' eseguito (almeno in parte)
	if ! [ -d /var/tmp/portage/ ] ; then
		/usr/portage/scripts/bootstrap.sh
	else 
		colora_rosso "esiste gia' /var/tmp/portage. hai gia' compilato il bootstrap?"
		read YESNO
		if ! [ $YESNO == "S" -o $YESNO == "" ] ; then
			/usr/portage/scripts/bootstrap.sh
		fi
	fi
	emerge gentoolkit
	[ -d $INSTDIR ] || mkdir $INSTDIR
	mkdir $INSTDIR/boot $INSTDIR/cdrom $INSTDIR/dev $INSTDIR/etc $INSTDIR/floppy $INSTDIR/home $INSTDIR/mnt \ 
		$INSTDIR/proc $INSTDIR/root $INSTDIR/usr $INSTDIR/var
	cp -a /var/db $INSTDIR/var
}

# il pacchetto che cazzo credi che sia da primo livello del FSH. pro initrd.gz
# gia' da questi pacchetti va sfoltito, sono solo alcuni eseguibili del cazzo che
# si puo' decidere che vanno dentro il tree in /usr.
# come dipendenze di compilazione lamenta anche linux-headers, da
# rimuovere in fase di creazione dell'initrd di d:b.
# per spiegare. ha senso che ci teniamo comandi come nohup rbash ptx nell'initrd?
# oppure che abbiamo libmemusage? secondo me certe lib van bene anche in /usr/lib, mentre gli
# eseguibili si possono pure cancellare. discutiamone.
function install_initrd_pkg () {
	
cat > /tmp/.initrd.lst << EOF
linux-headers
devfsd
glibc
ncurses
bash
coreutils
iputils
net-tools
EOF
	
for PKG in `cat /tmp/.initrd.lst` ; do
	ROOT=$INSTDIR emerge $PKG ;
done

rm /tmp/.initrd.lst 

}

# per ora con questo si ottiene un xfree con un tot di driver extra,
# bisognera' lavorarci per avere qualcosa di piu' nostro, se lo riteniamo.
# da considerarsi valido per ora, per avere una versione che funziona da subito.
function build_xfree() {
	ROOT=$INSTDIR USE='mmx sse 3dfx 3dnow' emerge ati-drivers

# si puo' pensare di voler aggiungere dei flag relativi agli aspetti
# specifici del processore per cui si vuole ottimizzare, piuttosto che 
# i flag multimedia
colora_verde "Quali CFLAG settiamo? default: '-O2 -mcpu=i586 -fomit-frame-pointer -pipe'"
read CFLAG_SET
[ -z $CFLAG_SET ] && export CFLAG_SET="-O2 -mcpu=i586 -fomit-frame-pointer -pipe" 
colora_verde "$CFLAG_SET  ...ok! modifico /etc/make.conf"

cat > /etc/make.conf << EOF
# These settings were set by the catalyst build script that automatically built this stage
# Please consult /etc/make.conf.example for a more detailed example
CFLAGS="$CFLAG_SET"
CHOST="i586-pc-linux-gnu" 
CXXFLAGS="${CFLAGS}"
EOF

}

# non appena si avra' un SDK su quico omogeneo con gli script questo tgz sara'
# creato dalle ultime versioni dei file di conf presenti in cvs.
# questo singifica mettere i file di conf che si preparano sul cvs, se si vuole avere 
# conformita' con l'ultima release. ad ogni modo e' da discutere bene questo passaggio qui.
# ovvero, come avere uno /etc corretto per il live cd che si vuole fare.
# ANZI. questo sara' un aspetto da baselayout-dynebolic.ebuild, quindi dal cvs dovremo rendere 
# possibile la raccolta dei file che vanno in /etc.
function install_configuration_files(){
	if ! [ -f $WORKINGDIR/baselayout-db.tgz ] ; then
		wget http://www.autistici.org/bolic1/baselayout-db.tgz
	fi
	tar -zxvf baselayout-db.tgz -C $INSTDIR
	ROOT=$INSTDIR emerge baselayout-db
}
###############################################################################

##############################################################################
# Let's GO!
##############################################################################
# siamo dentro lo stage1. e' dove decidiamo i CFLAGS, per costruire prima l'ambiente di compilazione
# gentoo da cui poi deriviamo in /home/the_root la dynebolic.
# ogni aspetto l'abbiamo infilato in una funzione per auspicare uno sviluppo di ciasun passaggio

# punto 3
env-update
source /etc/profile

colora_verde "Quali CFLAG settiamo? default: '-O2 -mcpu=i586 -fomit-frame-pointer -pipe'"
read CFLAG_SET
[ -z $CFLAG_SET ] && export CFLAG_SET="-O2 -mcpu=i586 -fomit-frame-pointer -pipe" 
colora_verde "$CFLAG_SET  ...ok! modifico /etc/make.conf"

cat > /etc/make.conf << EOF
# These settings were set by the catalyst build script that automatically built this stage
# Please consult /etc/make.conf.example for a more detailed example
CFLAGS="$CFLAG_SET"
CHOST="i586-pc-linux-gnu" 
CXXFLAGS="${CFLAGS}"
EOF


initrd_root && colora_verde "Ho completato l'SDK. Ora popolo l'initrd." || colora_rosso "qualcosa e' andato storto. non e' stata colpa mia"

# punto 4
install_initrd_pkg && colora_verde "Ho completato l'initrd_root..." || colora_rosso "qualcosa e' andato storto. non e' stata colpa mia"

# punto 5
build_xfree  && colora_verde "Ho completato l'initrd_root..." || colora_rosso "qualcosa e' andato storto. non e' stata colpa mia"

# punto 6
install_configuration_files && colora_verde "Ho completato l'installazione delle configurazioni" || colora_rosso "qualcosa e' andato storto. non e' stata colpa mia" 
