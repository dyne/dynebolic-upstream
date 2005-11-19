#include <gtk/gtk.h>


void
on_button_ok_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_combo_lang_realize                  (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_combo_keyb_realize                  (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_combo1_realize                      (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_combo2_realize                      (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_combo_lang_changed                  (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_combo_keyb_changed                  (GtkEditable     *editable,
                                        gpointer         user_data);
