/*
 * DO NOT EDIT THIS FILE - it is generated by Glade.
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#include <gdk/gdkkeysyms.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"

GtkWidget*
create_window1 (void)
{
  GtkWidget *window1;
  GtkWidget *notebook1;
  GtkWidget *vbox1;
  GtkWidget *frame1;
  GtkWidget *vbox8;
  GtkWidget *dyne_org_presents;
  GtkWidget *splash;
  GtkWidget *frame2;
  GtkWidget *pressmouse;
  GtkWidget *welcome;
  GtkWidget *hbox1;
  GtkWidget *text1;
  GtkWidget *vbox2;
  GtkWidget *frame5;
  GtkWidget *pixmap2;
  GtkWidget *config;
  GtkWidget *vbuttonbox1;
  GtkWidget *button6;
  GtkWidget *button5;
  GtkWidget *button4;
  GtkWidget *button3;
  GtkWidget *button2;
  GtkWidget *getstart;
  GtkWidget *hbox2;
  GtkWidget *why_support;
  GtkWidget *frame6;
  GtkWidget *vbox3;
  GtkWidget *vbox6;
  GtkWidget *cdrom_desc;
  GtkWidget *cdrom;
  GtkWidget *order_button;
  GtkWidget *support;
  GtkWidget *vbox4;
  GtkWidget *hbox3;
  GtkWidget *frame9;
  GtkWidget *label_team;
  GtkWidget *vbox5;
  GtkWidget *scrolledwindow1;
  GtkWidget *credits;
  GtkWidget *sponsor;
  GtkWidget *hbox4;
  GtkWidget *logo_tenovis;
  GtkWidget *vbox7;
  GtkWidget *logo_pvl;
  GtkWidget *logo_mala;
  GtkWidget *autoproduzioni;
  GtkWidget *Credits;
  GtkWidget *gpl_license;
  GtkWidget *label8;
  GtkTooltips *tooltips;

  tooltips = gtk_tooltips_new ();

  window1 = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_object_set_data (GTK_OBJECT (window1), "window1", window1);
  gtk_window_set_title (GTK_WINDOW (window1), _(" dyne:bolic GNU/Linux - 100% free software"));
  gtk_window_set_position (GTK_WINDOW (window1), GTK_WIN_POS_CENTER);
  gtk_window_set_policy (GTK_WINDOW (window1), FALSE, FALSE, FALSE);
  gtk_window_set_wmclass (GTK_WINDOW (window1), "dynesplash", "dyneboli");

  notebook1 = gtk_notebook_new ();
  gtk_widget_ref (notebook1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "notebook1", notebook1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (notebook1);
  gtk_container_add (GTK_CONTAINER (window1), notebook1);
  gtk_container_set_border_width (GTK_CONTAINER (notebook1), 2);
  GTK_WIDGET_UNSET_FLAGS (notebook1, GTK_CAN_FOCUS);
  gtk_notebook_set_show_border (GTK_NOTEBOOK (notebook1), FALSE);
  gtk_notebook_set_tab_hborder (GTK_NOTEBOOK (notebook1), 5);

  vbox1 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox1", vbox1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox1);
  gtk_container_add (GTK_CONTAINER (notebook1), vbox1);

  frame1 = gtk_frame_new (NULL);
  gtk_widget_ref (frame1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "frame1", frame1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame1);
  gtk_box_pack_start (GTK_BOX (vbox1), frame1, FALSE, FALSE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (frame1), 1);
  gtk_frame_set_shadow_type (GTK_FRAME (frame1), GTK_SHADOW_IN);

  vbox8 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox8);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox8", vbox8,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox8);
  gtk_container_add (GTK_CONTAINER (frame1), vbox8);

  dyne_org_presents = gtk_label_new (_("DYNE.ORG PRODUCTIONS PRESENT"));
  gtk_widget_ref (dyne_org_presents);
  gtk_object_set_data_full (GTK_OBJECT (window1), "dyne_org_presents", dyne_org_presents,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (dyne_org_presents);
  gtk_box_pack_start (GTK_BOX (vbox8), dyne_org_presents, FALSE, FALSE, 0);
  gtk_misc_set_padding (GTK_MISC (dyne_org_presents), 0, 10);

  splash = create_pixmap (window1, "splash2.xpm");
  gtk_widget_ref (splash);
  gtk_object_set_data_full (GTK_OBJECT (window1), "splash", splash,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (splash);
  gtk_box_pack_start (GTK_BOX (vbox8), splash, TRUE, TRUE, 0);
  gtk_misc_set_padding (GTK_MISC (splash), 0, 10);

  frame2 = gtk_frame_new (NULL);
  gtk_widget_ref (frame2);
  gtk_object_set_data_full (GTK_OBJECT (window1), "frame2", frame2,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame2);
  gtk_box_pack_start (GTK_BOX (vbox1), frame2, FALSE, FALSE, 0);
  gtk_frame_set_shadow_type (GTK_FRAME (frame2), GTK_SHADOW_NONE);

  pressmouse = gtk_button_new_with_label (_("WELCOME TO YOUR DYNE:BOLIC DESKTOP\nPRESS THE RIGHT MOUSE BUTTON ON IT FOR THE MENU"));
  gtk_widget_ref (pressmouse);
  gtk_object_set_data_full (GTK_OBJECT (window1), "pressmouse", pressmouse,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (pressmouse);
  gtk_container_add (GTK_CONTAINER (frame2), pressmouse);
  gtk_container_set_border_width (GTK_CONTAINER (pressmouse), 1);
  gtk_button_set_relief (GTK_BUTTON (pressmouse), GTK_RELIEF_NONE);

  welcome = gtk_label_new (_(" Welcome to the hacktive media! "));
  gtk_widget_ref (welcome);
  gtk_object_set_data_full (GTK_OBJECT (window1), "welcome", welcome,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (welcome);
  gtk_notebook_set_tab_label (GTK_NOTEBOOK (notebook1), gtk_notebook_get_nth_page (GTK_NOTEBOOK (notebook1), 0), welcome);
  gtk_label_set_justify (GTK_LABEL (welcome), GTK_JUSTIFY_LEFT);

  hbox1 = gtk_hbox_new (FALSE, 0);
  gtk_widget_ref (hbox1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "hbox1", hbox1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (hbox1);
  gtk_container_add (GTK_CONTAINER (notebook1), hbox1);

  text1 = gtk_text_new (NULL, NULL);
  gtk_widget_ref (text1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "text1", text1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (text1);
  gtk_box_pack_start (GTK_BOX (hbox1), text1, TRUE, TRUE, 0);
  GTK_WIDGET_UNSET_FLAGS (text1, GTK_CAN_FOCUS);
  gtk_text_insert (GTK_TEXT (text1), NULL, NULL, NULL,
                   _("Dyne:bolic is a preconfigured GNU/Linux system which runs without\ninstalling anything on you harddisks, alltough you can see your\npartitions automatically mounted in the /vol directory.\n\nYour /home directory resides in your RAM memory and everything\nnew contained in it will not be there at the next boot.\n\nA samba filesharing daemon is running: everything contained in your\n/home/shared directory is made accessible (read and write) on the\nnetwork without any password.\n\nThe graphical environment is XFree86 with WindowMaker, the\ninterface follows the OpenStep paradigm to build the way interaction\ndistincts d:b from other common graphical environments.\nFor instance you have multiple desktops that you can also switch\nusing the key combination ALT+2 and other numbers.\n\nOn the bottom-right of the desktop you have leds and statistics\nabout your system usage and status, if you are online you'll see eth0\n(DHCP is detected at boot) otherwise you can configure your\nnetwork and other things from the buttons here -------------->"), -1);

  vbox2 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox2);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox2", vbox2,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox2);
  gtk_box_pack_start (GTK_BOX (hbox1), vbox2, FALSE, FALSE, 0);

  frame5 = gtk_frame_new (NULL);
  gtk_widget_ref (frame5);
  gtk_object_set_data_full (GTK_OBJECT (window1), "frame5", frame5,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame5);
  gtk_box_pack_start (GTK_BOX (vbox2), frame5, FALSE, TRUE, 0);
  gtk_frame_set_shadow_type (GTK_FRAME (frame5), GTK_SHADOW_NONE);

  pixmap2 = create_pixmap (window1, "logo.xpm");
  gtk_widget_ref (pixmap2);
  gtk_object_set_data_full (GTK_OBJECT (window1), "pixmap2", pixmap2,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (pixmap2);
  gtk_container_add (GTK_CONTAINER (frame5), pixmap2);
  gtk_misc_set_alignment (GTK_MISC (pixmap2), 0.5, 1.63913e-07);

  config = gtk_frame_new (_("CONFIGURE"));
  gtk_widget_ref (config);
  gtk_object_set_data_full (GTK_OBJECT (window1), "config", config,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (config);
  gtk_box_pack_start (GTK_BOX (vbox2), config, TRUE, TRUE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (config), 5);

  vbuttonbox1 = gtk_vbutton_box_new ();
  gtk_widget_ref (vbuttonbox1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbuttonbox1", vbuttonbox1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbuttonbox1);
  gtk_container_add (GTK_CONTAINER (config), vbuttonbox1);
  gtk_button_box_set_spacing (GTK_BUTTON_BOX (vbuttonbox1), 0);
  gtk_button_box_set_child_size (GTK_BUTTON_BOX (vbuttonbox1), 85, 26);

  button6 = gtk_button_new_with_label (_("Nest dyne:bolic"));
  gtk_widget_ref (button6);
  gtk_object_set_data_full (GTK_OBJECT (window1), "button6", button6,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (button6);
  gtk_container_add (GTK_CONTAINER (vbuttonbox1), button6);
  GTK_WIDGET_SET_FLAGS (button6, GTK_CAN_DEFAULT);
  gtk_tooltips_set_tip (tooltips, button6, _("Create a nest on harddisk, usbkey or floppy where your home and all your settings will be saved and found at the next boot"), NULL);

  button5 = gtk_button_new_with_label (_("Language"));
  gtk_widget_ref (button5);
  gtk_object_set_data_full (GTK_OBJECT (window1), "button5", button5,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (button5);
  gtk_container_add (GTK_CONTAINER (vbuttonbox1), button5);
  GTK_WIDGET_SET_FLAGS (button5, GTK_CAN_DEFAULT);
  gtk_tooltips_set_tip (tooltips, button5, _("Change the language and keyboard layout, all the applications supporting your language will switch to it"), NULL);

  button4 = gtk_button_new_with_label (_("Network"));
  gtk_widget_ref (button4);
  gtk_object_set_data_full (GTK_OBJECT (window1), "button4", button4,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (button4);
  gtk_container_add (GTK_CONTAINER (vbuttonbox1), button4);
  GTK_WIDGET_SET_FLAGS (button4, GTK_CAN_DEFAULT);
  gtk_tooltips_set_tip (tooltips, button4, _("Configure your network interface (via DHCP or static IP address)"), NULL);

  button3 = gtk_button_new_with_label (_("Modem"));
  gtk_widget_ref (button3);
  gtk_object_set_data_full (GTK_OBJECT (window1), "button3", button3,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (button3);
  gtk_container_add (GTK_CONTAINER (vbuttonbox1), button3);
  GTK_WIDGET_SET_FLAGS (button3, GTK_CAN_DEFAULT);
  gtk_tooltips_set_tip (tooltips, button3, _("Configure your modem to dialup your account"), NULL);

  button2 = gtk_button_new_with_label (_("Printer"));
  gtk_widget_ref (button2);
  gtk_object_set_data_full (GTK_OBJECT (window1), "button2", button2,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (button2);
  gtk_container_add (GTK_CONTAINER (vbuttonbox1), button2);
  GTK_WIDGET_SET_FLAGS (button2, GTK_CAN_DEFAULT);
  gtk_tooltips_set_tip (tooltips, button2, _("Configure your printer and share it on the net"), NULL);

  getstart = gtk_label_new (_(" Getting started "));
  gtk_widget_ref (getstart);
  gtk_object_set_data_full (GTK_OBJECT (window1), "getstart", getstart,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (getstart);
  gtk_notebook_set_tab_label (GTK_NOTEBOOK (notebook1), gtk_notebook_get_nth_page (GTK_NOTEBOOK (notebook1), 1), getstart);
  gtk_label_set_justify (GTK_LABEL (getstart), GTK_JUSTIFY_LEFT);

  hbox2 = gtk_hbox_new (FALSE, 0);
  gtk_widget_ref (hbox2);
  gtk_object_set_data_full (GTK_OBJECT (window1), "hbox2", hbox2,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (hbox2);
  gtk_container_add (GTK_CONTAINER (notebook1), hbox2);

  why_support = gtk_text_new (NULL, NULL);
  gtk_widget_ref (why_support);
  gtk_object_set_data_full (GTK_OBJECT (window1), "why_support", why_support,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (why_support);
  gtk_box_pack_start (GTK_BOX (hbox2), why_support, TRUE, TRUE, 0);
  GTK_WIDGET_UNSET_FLAGS (why_support, GTK_CAN_FOCUS);
  gtk_text_insert (GTK_TEXT (why_support), NULL, NULL, NULL,
                   _("The dyne:bolic developers rely on funding from\nnon-profit, grant-making and business\norganizations willing to sustain development of\nfree software.\n\nWe can achieve the perspective of sustainability\nby offering the services of customizations,\nworkshops and setups; but also with a little help\nfrom our friends.\n\nWe rely on support from individuals like you to\npreserve, protect and promote the freedom to\nshare this distribution and software.\n\nIf you find dyne:bolic useful, please consider\nmaking a donation today.\n\nIf you order it online, please do it from\nredistributors supporting us, you'll find\na contact list of them on our website.\n\nIf you have a job, please encourage your\ncompany to become a patron of the dyne:bolic\nproject.\n\nIf you redistribute it, please give us some shares\non sells: you'll be happy to see the new versions\ncoming out.\nYou can become an Official Redistributor and get\nlisted on our webpages: there you'll find more\ninformations about it.\n\nWe hope you understand how this is important to\nto keep ongoing our ecosystem of generosity.\n\nThanks! a thousand flowers will blossom!"), -1);

  frame6 = gtk_frame_new (NULL);
  gtk_widget_ref (frame6);
  gtk_object_set_data_full (GTK_OBJECT (window1), "frame6", frame6,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame6);
  gtk_box_pack_start (GTK_BOX (hbox2), frame6, FALSE, TRUE, 0);
  gtk_frame_set_shadow_type (GTK_FRAME (frame6), GTK_SHADOW_IN);

  vbox3 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox3);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox3", vbox3,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox3);
  gtk_container_add (GTK_CONTAINER (frame6), vbox3);

  vbox6 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox6);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox6", vbox6,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox6);
  gtk_box_pack_start (GTK_BOX (vbox3), vbox6, TRUE, TRUE, 0);

  cdrom_desc = gtk_label_new (_("The production quality printed CDROM\nmastered by our lab can be shipped ! "));
  gtk_widget_ref (cdrom_desc);
  gtk_object_set_data_full (GTK_OBJECT (window1), "cdrom_desc", cdrom_desc,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (cdrom_desc);
  gtk_box_pack_start (GTK_BOX (vbox6), cdrom_desc, FALSE, FALSE, 0);

  cdrom = create_pixmap (window1, "cdrom.xpm");
  gtk_widget_ref (cdrom);
  gtk_object_set_data_full (GTK_OBJECT (window1), "cdrom", cdrom,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (cdrom);
  gtk_box_pack_start (GTK_BOX (vbox6), cdrom, FALSE, FALSE, 0);

  order_button = gtk_button_new_with_label (_("ORDER ORIGINAL PRINTED COPIES!"));
  gtk_widget_ref (order_button);
  gtk_object_set_data_full (GTK_OBJECT (window1), "order_button", order_button,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (order_button);
  gtk_box_pack_start (GTK_BOX (vbox3), order_button, TRUE, TRUE, 0);

  support = gtk_label_new (_(" Support us "));
  gtk_widget_ref (support);
  gtk_object_set_data_full (GTK_OBJECT (window1), "support", support,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (support);
  gtk_notebook_set_tab_label (GTK_NOTEBOOK (notebook1), gtk_notebook_get_nth_page (GTK_NOTEBOOK (notebook1), 2), support);
  gtk_label_set_justify (GTK_LABEL (support), GTK_JUSTIFY_LEFT);

  vbox4 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox4);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox4", vbox4,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox4);
  gtk_container_add (GTK_CONTAINER (notebook1), vbox4);

  hbox3 = gtk_hbox_new (FALSE, 0);
  gtk_widget_ref (hbox3);
  gtk_object_set_data_full (GTK_OBJECT (window1), "hbox3", hbox3,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (hbox3);
  gtk_box_pack_start (GTK_BOX (vbox4), hbox3, TRUE, TRUE, 0);

  frame9 = gtk_frame_new (_("Hall of Fame "));
  gtk_widget_ref (frame9);
  gtk_object_set_data_full (GTK_OBJECT (window1), "frame9", frame9,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame9);
  gtk_box_pack_start (GTK_BOX (hbox3), frame9, FALSE, TRUE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (frame9), 3);

  label_team = gtk_label_new (_("Denis \"jaromil\" Rojo\n  HasciiCam MuSE\n  FreeJ dyne:bolic\n\nFederico \"bomboclat\" Prando\n  bolic1, dyne:bolic\n\nFrancesco \"c1cc10\" Rana\n  bolic1, dyne:bolic\n\nAlex \"smilzo\" Gnoli\n  console support\n\n...and a brave GNU world!\nfree software is made out\nof many people efforts and\na lot of LOVE!"));
  gtk_widget_ref (label_team);
  gtk_object_set_data_full (GTK_OBJECT (window1), "label_team", label_team,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (label_team);
  gtk_container_add (GTK_CONTAINER (frame9), label_team);
  gtk_label_set_justify (GTK_LABEL (label_team), GTK_JUSTIFY_LEFT);

  vbox5 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox5);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox5", vbox5,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox5);
  gtk_box_pack_start (GTK_BOX (hbox3), vbox5, TRUE, TRUE, 0);

  scrolledwindow1 = gtk_scrolled_window_new (NULL, NULL);
  gtk_widget_ref (scrolledwindow1);
  gtk_object_set_data_full (GTK_OBJECT (window1), "scrolledwindow1", scrolledwindow1,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (scrolledwindow1);
  gtk_box_pack_start (GTK_BOX (vbox5), scrolledwindow1, TRUE, TRUE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (scrolledwindow1), 2);
  gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolledwindow1), GTK_POLICY_NEVER, GTK_POLICY_ALWAYS);

  credits = gtk_text_new (NULL, NULL);
  gtk_widget_ref (credits);
  gtk_object_set_data_full (GTK_OBJECT (window1), "credits", credits,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (credits);
  gtk_container_add (GTK_CONTAINER (scrolledwindow1), credits);
  GTK_WIDGET_UNSET_FLAGS (credits, GTK_CAN_FOCUS);
  gtk_text_insert (GTK_TEXT (credits), NULL, NULL, NULL,
                   _("dyne:bolic 1.0 it is shaped on the needs of media activists\nto stimulate the production and not only the fruition of digital\nand analog informations.\nIt takes birth as a grassroot effort to spread free software\nand the spirit of sharing informations.\n\nThe following people also contributed to development:\n  Lo Smilzo (hack to make it work on XBOX)\n  Lobo (karma and knowledge)\n  Sandolo and Rageman (scripts and tricks)\n  Nightolo and Rubik (MuSE interface coders)\n  Maox (logo and graphics)\n  Eni and Newmark (watching horizons)\n\nHelp with online documentation was given by: Isazi, Quique,\nAli Uelke, Thomas Hassan, Ricardo Perry, Marco Herrn,\nTommaso Gagliardi, Patrice.\n\nSUPPORT in development was given by the following\norganizazions:\n  TENOVIS (Intl) http://tenovis.com\n  PUBLIC VOICE Lab (Vienna) http://pvl.at\n  MALASystem (Milano) http://malasystem.com\n  SERVUS.at (Linz) http://servus.at\n  OSSA (Intl) http://streamingalliance.org\n  Montevideo (Amsterdam) http://montevideo.nl\n  Stream on the fly (EU project)\n  JuX project (Vienna) http://netbridge.at\n  European Social Forum http://www.fse-esf.org\n  The city of Firenze\nand individuals:\n  Stefano Chiccarelli, Roland Alton-Scheidl, Adam Hyde,\n  Markus Panholzer, Zeljko Blace and Blicero\n\nOur waves and cheers also go to:\nNeURo, Neural.it, cjm di enemy.org, Luca Lampo per la camicia :)\nlittlejohn, Odo grand visir di mufhd0, kobaiashi di sikurezza.org\nTommaso aka m_0, Dolce, chmod, radio Ondarossa, enuzzo, void,\nDindon il carbonaro, #mdp and all the hackers at dyne.org.\n\nThis CD includes the work of hundreds of people all around\nthe world developing free software and GNU/Linux applications,\nwithout the efforts of this big communities dyne:bolic would\nhave never existed, among the others are gnu.org and the\nFree Software Foundation, gentoo.org, kernel.org, xfree86.org,\nmozilla.org.\n\nYou are welcome to join us!\nthe dyne:bolic mailinglist you can reach from dynebolic.org\nthe irc channel #dynebolic on irc.autistici.org\n\nhappy hacking ;^)"), -1);

  sponsor = gtk_frame_new (_("DEVELOPMENT SUPPORTED BY"));
  gtk_widget_ref (sponsor);
  gtk_object_set_data_full (GTK_OBJECT (window1), "sponsor", sponsor,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (sponsor);
  gtk_box_pack_end (GTK_BOX (vbox5), sponsor, FALSE, TRUE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (sponsor), 2);

  hbox4 = gtk_hbox_new (FALSE, 0);
  gtk_widget_ref (hbox4);
  gtk_object_set_data_full (GTK_OBJECT (window1), "hbox4", hbox4,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (hbox4);
  gtk_container_add (GTK_CONTAINER (sponsor), hbox4);

  logo_tenovis = create_pixmap (window1, "tenovis.xpm");
  gtk_widget_ref (logo_tenovis);
  gtk_object_set_data_full (GTK_OBJECT (window1), "logo_tenovis", logo_tenovis,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (logo_tenovis);
  gtk_box_pack_start (GTK_BOX (hbox4), logo_tenovis, FALSE, FALSE, 0);
  gtk_pixmap_set_build_insensitive (GTK_PIXMAP (logo_tenovis), FALSE);

  vbox7 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox7);
  gtk_object_set_data_full (GTK_OBJECT (window1), "vbox7", vbox7,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox7);
  gtk_box_pack_start (GTK_BOX (hbox4), vbox7, TRUE, TRUE, 0);

  logo_pvl = create_pixmap (window1, "pvl.xpm");
  gtk_widget_ref (logo_pvl);
  gtk_object_set_data_full (GTK_OBJECT (window1), "logo_pvl", logo_pvl,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (logo_pvl);
  gtk_box_pack_start (GTK_BOX (vbox7), logo_pvl, FALSE, FALSE, 0);
  gtk_pixmap_set_build_insensitive (GTK_PIXMAP (logo_pvl), FALSE);

  logo_mala = create_pixmap (window1, "malasystem.xpm");
  gtk_widget_ref (logo_mala);
  gtk_object_set_data_full (GTK_OBJECT (window1), "logo_mala", logo_mala,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (logo_mala);
  gtk_box_pack_start (GTK_BOX (vbox7), logo_mala, FALSE, FALSE, 0);
  gtk_pixmap_set_build_insensitive (GTK_PIXMAP (logo_mala), FALSE);

  autoproduzioni = gtk_button_new_with_label (_("dyne.org productions | http://dyne.org | mail: hackers@dyne.org | tel: +43 1 92 56 318"));
  gtk_widget_ref (autoproduzioni);
  gtk_object_set_data_full (GTK_OBJECT (window1), "autoproduzioni", autoproduzioni,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (autoproduzioni);
  gtk_box_pack_start (GTK_BOX (vbox4), autoproduzioni, FALSE, FALSE, 0);
  gtk_button_set_relief (GTK_BUTTON (autoproduzioni), GTK_RELIEF_NONE);

  Credits = gtk_label_new (_(" Credits "));
  gtk_widget_ref (Credits);
  gtk_object_set_data_full (GTK_OBJECT (window1), "Credits", Credits,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (Credits);
  gtk_notebook_set_tab_label (GTK_NOTEBOOK (notebook1), gtk_notebook_get_nth_page (GTK_NOTEBOOK (notebook1), 3), Credits);

  gpl_license = gtk_text_new (NULL, NULL);
  gtk_widget_ref (gpl_license);
  gtk_object_set_data_full (GTK_OBJECT (window1), "gpl_license", gpl_license,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (gpl_license);
  gtk_container_add (GTK_CONTAINER (notebook1), gpl_license);
  GTK_WIDGET_UNSET_FLAGS (gpl_license, GTK_CAN_FOCUS);
  gtk_text_insert (GTK_TEXT (gpl_license), NULL, NULL, NULL,
                   _("   GNU GENERAL PUBLIC LICENSE  Version 2, June 1991\n\n   dyne:bolic is free software; you can redistribute it and/or modify\n   it under the terms of the GNU General Public License as published by\n   the Free Software Foundation; either version 2 of the License, or (at\n   your option) any later version.\n\n   dyne:bolic is distributed in the hope that it will be useful, but\n   WITHOUT ANY WARRANTY; without even the implied warranty of\n   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n   See the GNU General Public License for more details.\n\n   You should have received a copy of the GNU General Public License\n   along with dyne:bolic; if not, write to:\n   Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.\n\n   dyne:bolic is copyleft (c) 2001-2003 by Denis Rojo <jaromil@dyne.org>\n   part of the included software is copyleft by the respective authors,\n   dyne.org is available to distribute the source of the included binaries\n   upon request, all the included software can be redistributed under the\n   terms of the GNU GPL license and, in some cases, the X/BSD license."), -1);

  label8 = gtk_label_new (_(" License "));
  gtk_widget_ref (label8);
  gtk_object_set_data_full (GTK_OBJECT (window1), "label8", label8,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (label8);
  gtk_notebook_set_tab_label (GTK_NOTEBOOK (notebook1), gtk_notebook_get_nth_page (GTK_NOTEBOOK (notebook1), 4), label8);

  gtk_signal_connect (GTK_OBJECT (window1), "destroy",
                      GTK_SIGNAL_FUNC (on_window1_destroy),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (pressmouse), "clicked",
                      GTK_SIGNAL_FUNC (on_pressmouse_clicked),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (button6), "released",
                      GTK_SIGNAL_FUNC (on_conf_save_released),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (button5), "released",
                      GTK_SIGNAL_FUNC (on_conf_lang_released),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (button4), "released",
                      GTK_SIGNAL_FUNC (on_conf_net_released),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (button3), "released",
                      GTK_SIGNAL_FUNC (on_conf_modem_released),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (button2), "released",
                      GTK_SIGNAL_FUNC (on_conf_print_released),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (order_button), "released",
                      GTK_SIGNAL_FUNC (on_order_button),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (logo_tenovis), "button_release_event",
                      GTK_SIGNAL_FUNC (on_logo_tenovis_button_release_event),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (logo_pvl), "button_release_event",
                      GTK_SIGNAL_FUNC (on_logo_pvl_button_release_event),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (logo_mala), "button_release_event",
                      GTK_SIGNAL_FUNC (on_pixmap8_button_release_event),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (autoproduzioni), "released",
                      GTK_SIGNAL_FUNC (on_autoproduzioni_released),
                      NULL);

  gtk_object_set_data (GTK_OBJECT (window1), "tooltips", tooltips);

  return window1;
}

GtkWidget*
create_i_said_right (void)
{
  GtkWidget *i_said_right;
  GtkWidget *vbox10;
  GtkWidget *hbox5;
  GtkWidget *frame7;
  GtkWidget *pixmap3;
  GtkWidget *justclick;
  GtkWidget *iknow;

  i_said_right = gtk_window_new (GTK_WINDOW_POPUP);
  gtk_object_set_data (GTK_OBJECT (i_said_right), "i_said_right", i_said_right);
  gtk_container_set_border_width (GTK_CONTAINER (i_said_right), 2);
  gtk_window_set_title (GTK_WINDOW (i_said_right), _("How the dyne:bolic menu works?"));
  gtk_window_set_position (GTK_WINDOW (i_said_right), GTK_WIN_POS_MOUSE);
  gtk_window_set_policy (GTK_WINDOW (i_said_right), FALSE, FALSE, TRUE);
  gtk_window_set_wmclass (GTK_WINDOW (i_said_right), "warning", "popup");

  vbox10 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox10);
  gtk_object_set_data_full (GTK_OBJECT (i_said_right), "vbox10", vbox10,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox10);
  gtk_container_add (GTK_CONTAINER (i_said_right), vbox10);

  hbox5 = gtk_hbox_new (FALSE, 0);
  gtk_widget_ref (hbox5);
  gtk_object_set_data_full (GTK_OBJECT (i_said_right), "hbox5", hbox5,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (hbox5);
  gtk_box_pack_start (GTK_BOX (vbox10), hbox5, TRUE, TRUE, 0);

  frame7 = gtk_frame_new (_("it's simple!"));
  gtk_widget_ref (frame7);
  gtk_object_set_data_full (GTK_OBJECT (i_said_right), "frame7", frame7,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame7);
  gtk_box_pack_start (GTK_BOX (hbox5), frame7, FALSE, FALSE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (frame7), 10);

  pixmap3 = create_pixmap (i_said_right, "teacher.xpm");
  gtk_widget_ref (pixmap3);
  gtk_object_set_data_full (GTK_OBJECT (i_said_right), "pixmap3", pixmap3,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (pixmap3);
  gtk_container_add (GTK_CONTAINER (frame7), pixmap3);

  justclick = gtk_label_new (_("to have the application\nmenu you have just to\nclick the right mouse\nbutton on the desktop\nbackground!\nnot here!\non the desktop!\n"));
  gtk_widget_ref (justclick);
  gtk_object_set_data_full (GTK_OBJECT (i_said_right), "justclick", justclick,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (justclick);
  gtk_box_pack_start (GTK_BOX (hbox5), justclick, FALSE, FALSE, 0);
  gtk_label_set_justify (GTK_LABEL (justclick), GTK_JUSTIFY_LEFT);
  gtk_misc_set_alignment (GTK_MISC (justclick), 0.5, 1);
  gtk_misc_set_padding (GTK_MISC (justclick), 15, 0);

  iknow = gtk_button_new_with_label (_("OK! Thank you!"));
  gtk_widget_ref (iknow);
  gtk_object_set_data_full (GTK_OBJECT (i_said_right), "iknow", iknow,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (iknow);
  gtk_box_pack_start (GTK_BOX (vbox10), iknow, FALSE, FALSE, 2);

  gtk_signal_connect (GTK_OBJECT (i_said_right), "destroy",
                      GTK_SIGNAL_FUNC (gtk_widget_destroy),
                      NULL);
  gtk_signal_connect (GTK_OBJECT (iknow), "released",
                      GTK_SIGNAL_FUNC (on_iknow_released),
                      i_said_right);

  return i_said_right;
}

GtkWidget*
create_notimplemented (void)
{
  GtkWidget *notimplemented;
  GtkWidget *vbox11;
  GtkWidget *hbox6;
  GtkWidget *frame8;
  GtkWidget *pixmap4;
  GtkWidget *label10;
  GtkWidget *iwait;

  notimplemented = gtk_window_new (GTK_WINDOW_POPUP);
  gtk_object_set_data (GTK_OBJECT (notimplemented), "notimplemented", notimplemented);
  gtk_container_set_border_width (GTK_CONTAINER (notimplemented), 2);
  gtk_window_set_title (GTK_WINDOW (notimplemented), _("We are working for you!"));
  gtk_window_set_policy (GTK_WINDOW (notimplemented), FALSE, FALSE, TRUE);

  vbox11 = gtk_vbox_new (FALSE, 0);
  gtk_widget_ref (vbox11);
  gtk_object_set_data_full (GTK_OBJECT (notimplemented), "vbox11", vbox11,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (vbox11);
  gtk_container_add (GTK_CONTAINER (notimplemented), vbox11);

  hbox6 = gtk_hbox_new (FALSE, 0);
  gtk_widget_ref (hbox6);
  gtk_object_set_data_full (GTK_OBJECT (notimplemented), "hbox6", hbox6,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (hbox6);
  gtk_box_pack_start (GTK_BOX (vbox11), hbox6, TRUE, TRUE, 0);

  frame8 = gtk_frame_new (NULL);
  gtk_widget_ref (frame8);
  gtk_object_set_data_full (GTK_OBJECT (notimplemented), "frame8", frame8,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (frame8);
  gtk_box_pack_start (GTK_BOX (hbox6), frame8, TRUE, TRUE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (frame8), 10);
  gtk_frame_set_shadow_type (GTK_FRAME (frame8), GTK_SHADOW_NONE);

  pixmap4 = create_pixmap (notimplemented, "unimplemented.xpm");
  gtk_widget_ref (pixmap4);
  gtk_object_set_data_full (GTK_OBJECT (notimplemented), "pixmap4", pixmap4,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (pixmap4);
  gtk_container_add (GTK_CONTAINER (frame8), pixmap4);

  label10 = gtk_label_new (_("This function is not\nyet implemented.\nPlease be patient\nwhile we are working\non it and keep an eye\non the next releases\nof dyne:bolic !"));
  gtk_widget_ref (label10);
  gtk_object_set_data_full (GTK_OBJECT (notimplemented), "label10", label10,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (label10);
  gtk_box_pack_start (GTK_BOX (hbox6), label10, FALSE, FALSE, 0);
  gtk_label_set_justify (GTK_LABEL (label10), GTK_JUSTIFY_LEFT);
  gtk_misc_set_padding (GTK_MISC (label10), 15, 0);

  iwait = gtk_button_new_with_label (_("OK! keep up the good work!"));
  gtk_widget_ref (iwait);
  gtk_object_set_data_full (GTK_OBJECT (notimplemented), "iwait", iwait,
                            (GtkDestroyNotify) gtk_widget_unref);
  gtk_widget_show (iwait);
  gtk_box_pack_start (GTK_BOX (vbox11), iwait, FALSE, FALSE, 2);

  gtk_signal_connect (GTK_OBJECT (iwait), "released",
                      GTK_SIGNAL_FUNC (on_iwait_released),
                      notimplemented);

  return notimplemented;
}

