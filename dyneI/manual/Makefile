# simple makefile to automate the generation of manuals
# "$Header$"

# list of all files
DEPS = \
dynebolic-abiword.sgml \
dynebolic-anatolia.sgml \
dynebolic-audacity.sgml \
dynebolic-audio.sgml \
dynebolic-blender.sgml \
dynebolic-bluefish.sgml \
dynebolic-cinelerra.sgml \
dynebolic-comunication.sgml \
dynebolic-convert.sgml \
dynebolic-effectv.sgml \
dynebolic-ethereal.sgml \
dynebolic-ettercap.sgml \
dynebolic-everybuddy.sgml \
dynebolic-faq.sgml \
dynebolic-filesystem.sgml \
dynebolic-freeciv.sgml \
dynebolic-freecraft.sgml \
dynebolic-freej.sgml \
dynebolic-frozbubble.sgml \
dynebolic-gaim.sgml \
dynebolic-games.sgml \
dynebolic-gdam.sgml \
dynebolic-gftp.sgml \
dynebolic-gimp.sgml \
dynebolic-gmp4player.sgml \
dynebolic-gnuchess.sgml \
dynebolic-gpg.sgml \
dynebolic-gqview.sgml \
dynebolic-hack.sgml \
dynebolic-hasciicam.sgml \
dynebolic-hping.sgml \
dynebolic-ical.sgml \
dynebolic-icecast.sgml \
dynebolic-image.sgml \
dynebolic-index.sgml \
dynebolic-intro.sgml \
dynebolic-iptraf.sgml \
dynebolic-irssi.sgml \
dynebolic-kino.sgml \
dynebolic-kismet.sgml \
dynebolic-lbreakout.sgml \
dynebolic-lftp.sgml \
dynebolic-license.sgml \
dynebolic-links2.sgml \
dynebolic-linphone.sgml \
dynebolic-lopster.sgml \
dynebolic-ltris.sgml \
dynebolic-lynx.sgml \
dynebolic-madplay.sgml \
dynebolic-man.sgml \
dynebolic-matanza.sgml \
dynebolic-mc.sgml \
dynebolic-mencoder.sgml \
dynebolic-minicom.sgml \
dynebolic-mp4creator.sgml \
dynebolic-mp4live.sgml \
dynebolic-mplayer.sgml \
dynebolic-muse.sgml \
dynebolic-ncftp.sgml \
dynebolic-nedit.sgml \
dynebolic-nethack.sgml \
dynebolic-netris.sgml \
dynebolic-nmap.sgml \
dynebolic-nuvrec.sgml \
dynebolic-ogg123.sgml \
dynebolic-oggenc.sgml \
dynebolic-palantir.sgml \
dynebolic-pd.sgml \
dynebolic-pdGEM.sgml \
dynebolic-phoenix.sgml \
dynebolic-powermanga.sgml \
dynebolic-pvfm.sgml \
dynebolic-rami.sgml \
dynebolic-rdesktop.sgml \
dynebolic-rezound.sgml \
dynebolic-rip.sgml \
dynebolic-soundtracker.sgml \
dynebolic-sylpheed.sgml \
dynebolic-synaesthesia.sgml \
dynebolic-sys.sgml \
dynebolic-ted.sgml \
dynebolic-terminatorx.sgml \
dynebolic-tetradraw.sgml \
dynebolic-text.sgml \
dynebolic-video.sgml \
dynebolic-vnc.sgml \
dynebolic-xawtv.sgml \
dynebolic-xbox.sgml \
dynebolic-xcalc.sgml \
dynebolic-xchat.sgml \
dynebolic-xclock.sgml \
dynebolic-xfontsel.sgml \
dynebolic-xfsamba.sgml \
dynebolic-xmahjongg.sgml \
dynebolic-xman.sgml \
dynebolic-xmms.sgml \
dynebolic-xrmap.sgml \
dynebolic-xutils.sgml \
dynebolic-xvidtune.sgml \
dynebolic-xwc.sgml \
dynebolic-xwelltris.sgml  

all : pdf

html : $(DEPS)
	docbook2html -d dsssl-stylesheets-1.77/html/docbook.dsl \
		-o html dynebolic-man.sgml

pdf : $(DEPS)
	docbook2pdf -d dsssl-stylesheets-1.77/print/docbook.dsl \
		dynebolic-man.sgml

clean :
	rm -f html/*.html \
	dynebolic-man.pdf \
	dynebolic-man.ps  \
	dynebolic-man.tex \
	dynebolic-man.txt
