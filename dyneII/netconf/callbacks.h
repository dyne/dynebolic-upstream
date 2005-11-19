#include <gtk/gtk.h>


void
on_button_dhcp_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_staticip_released            (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_done_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_staticip_ok_released         (GtkButton       *button,
                                        gpointer         user_data);

void
on_eth_choice_realize                  (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_entry_staticip_address_realize      (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_entry_staticip_netmask_realize      (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_entry_staticip_gw_realize           (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_entry_staticip_dns_realize          (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_entry_staticip_hostname_realize     (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_eth_choice_changed                  (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_button_main_apply_released          (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_main_save_released           (GtkButton       *button,
                                        gpointer         user_data);

void
on_entry_hostname_realize              (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_button_staticip_released            (GtkButton       *button,
                                        gpointer         user_data);

void
on_check_active_realize                (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_check_active_pressed                (GtkButton       *button,
                                        gpointer         user_data);

void
on_check_active_released               (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_dhcp_realize                 (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_toggle_dhcp_released                (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_staticip_released            (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_staticip_realize             (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_win_staticip_destroy                (GtkObject       *object,
                                        gpointer         user_data);

void
on_button_main_quit_released           (GtkButton       *button,
                                        gpointer         user_data);

void
on_combo_eth_realize                   (GtkWidget       *widget,
                                        gpointer         user_data);
