#include <gtk/gtk.h>


void
on_order_button                        (GtkButton       *button,
                                        gpointer         user_data);

void
on_pressmouse_clicked                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_lang_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_net_released                   (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_modem_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_print_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_save_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_manual_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_jaromil_released                    (GtkButton       *button,
                                        gpointer         user_data);

void
on_bomboclat_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_c1cc10_released                     (GtkButton       *button,
                                        gpointer         user_data);

void
on_autoproduzioni_released             (GtkButton       *button,
                                        gpointer         user_data);

gboolean
on_jaropix_button_release_event        (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_bombopix_button_release_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_cicciopix_button_release_event      (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_logo_tenovis_button_release_event   (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_logo_pvl_button_release_event       (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_pixmap8_button_release_event        (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

void
on_window1_destroy                     (GtkObject       *object,
                                        gpointer         user_data);

void
on_iknow_released                      (GtkButton       *button,
                                        gpointer         user_data);

void
on_iwait_released                      (GtkButton       *button,
                                        gpointer         user_data);

void
on_iknow_released                      (GtkButton       *button,
                                        gpointer         user_data);

void
on_iwait_released                      (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_nest_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_conf_screen_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_donate_released              (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_spawn_released               (GtkButton       *button,
                                        gpointer         user_data);
