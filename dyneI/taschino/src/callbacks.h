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

#include <gtk/gtk.h>


gboolean
on_hd_button_press_event               (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_usb_button_press_event              (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_floppy_button_press_event           (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

void
on_nest_selection_released             (GtkButton       *button,
                                        gpointer         user_data);

gboolean
on_hd_button_press_event               (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

void
on_nest_selection_released             (GtkButton       *button,
                                        gpointer         user_data);

void
on_nest_selection_released             (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_enter                (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_leave                (GtkButton       *button,
                                        gpointer         user_data);

void
on_cancel_nest_hd_released             (GtkButton       *button,
                                        gpointer         user_data);

void
on_ok_nest_hd_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_enter                (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_leave                (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_enter                (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_leave                (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_pressed              (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_released             (GtkButton       *button,
                                        gpointer         user_data);

void
on_toggle_pass_hd_toggled              (GtkToggleButton *togglebutton,
                                        gpointer         user_data);

void
on_combo_hd_partitions_activate        (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_toggle_pass_hd_toggled              (GtkToggleButton *togglebutton,
                                        gpointer         user_data);

void
on_combo_hd_partitions_changed         (GtkEditable     *editable,
                                        gpointer         user_data);

gboolean
on_combo_hd_partitions_button_press_event
                                        (GtkWidget       *widget,
                                        GdkEventButton  *event,
                                        gpointer         user_data);

gboolean
on_combo1_expose_event                 (GtkWidget       *widget,
                                        GdkEventExpose  *event,
                                        gpointer         user_data);

void
on_combo1_realize                      (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_win_nest_hd_destroy                 (GtkObject       *object,
                                        gpointer         user_data);

void
on_combo_hd_partitions_changed         (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_ok_nest_hd_released                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_tell_me_more_released        (GtkButton       *button,
                                        gpointer         user_data);

void
on_feel_good_released                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_abort_not_present_released   (GtkButton       *button,
                                        gpointer         user_data);

void
on_button_retry_not_present_released   (GtkButton       *button,
                                        gpointer         user_data);

void
on_win_success_destroy                 (GtkObject       *object,
                                        gpointer         user_data);

void
on_win_not_found_destroy               (GtkObject       *object,
                                        gpointer         user_data);

void
on_nest_selection_released             (GtkButton       *button,
                                        gpointer         user_data);

void
on_nest_selection_pressed              (GtkButton       *button,
                                        gpointer         user_data);

void
on_error_log_realize                   (GtkWidget       *widget,
                                        gpointer         user_data);
