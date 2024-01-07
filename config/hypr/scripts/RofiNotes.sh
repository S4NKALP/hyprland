#!/bin/bash

# <<--------- Settings --------->> #

# Set the directory where the notes are stored
NOTES_DIR="$HOME/Documents/Notes"
# Set the editor to use
EDITOR=nvim
TERMINAL=kitty

# <<--------- Choosing Templates --------->> #
Basic() {

    notify-send "Basic Document Created!"
    cp $NOTES_DIR/Templates/SimpleNote.md $NOTES_DIR/"$cn_name".$EXTENSION
    $TERMINAL -e $EDITOR $NOTES_DIR/"$cn_name".$EXTENSION
}

LaTeX() {

    notify-send "LaTeX Document Created!"
    cp $NOTES_DIR/Templates/LaTeX.tex $NOTES_DIR/"$cn_name".$EXTENSION
    $TERMINAL -e $EDITOR $NOTES_DIR/"$cn_name".$EXTENSION
}

Beamer() {

    notify-send "Beamer Presentation Created!"
    cp $NOTES_DIR/Templates/Presentation.tex $NOTES_DIR/"$cn_name".$EXTENSION
    $TERMINAL -e $EDITOR $NOTES_DIR/"$cn_name".$EXTENSION
}

RMark() {

    notify-send "R Markdown Document Created!"
    cp $NOTES_DIR/Templates/RMarkdown.rmd $NOTES_DIR/"$cn_name".$EXTENSION
    $TERMINAL -e $EDITOR $NOTES_DIR/"$cn_name".$EXTENSION
}

template() {

  tm_chosen=$(cat $HOME/Documents/Notes/Templates/temp_options.md | rofi -dmenu -i -p "Choose Template")

    if [ "$tm_chosen" = "Basic" ]; then
      EXTENSION="md"
      check
      Basic
    elif [ "$tm_chosen" = "LaTeX" ]; then
      EXTENSION="tex"
      check
      LaTeX
    elif [ "$tm_chosen" = "RMark" ]; then
      EXTENSION="rmd"
      check
      RMark
    elif [ "$tm_chosen" = "Beamer" ]; then
      EXTENSION="tex"
      check
      Beamer
    else
      exit 0
    fi
}

check() {

  if [ -f $NOTES_DIR/"$cn_name".$EXTENSION ]; then
      cn_exist=$(rofi -dmenu -i -p "Note already exists! Do you want to overwrite it?")
      if [ "$cn_exist" = "y" ]; then
        notify-send "New Note Created!" && $TERMINAL -e $EDITOR $NOTES_DIR/"$cn_name".$EXTENSION
        exit 0
      elif [ "$cn_exist" = "n" ]; then
        create_note
      else
        exit 0
      fi
  fi
}

create_note() {

    cn_name=$(rofi -dmenu -i -p "Enter the note name")
    if [ -z "$cn_name" ]; then
      exit 0
    else
      template
    fi
}

view_note() {

  selected=$(find $NOTES_DIR -type f -name "*" | rofi -dmenu -i -p "Open")
  if [ -z "$selected" ]; then
      exit 0
    else
      $TERMINAL -e $EDITOR $selected
  fi
}

delete_note() {

  selected=$(find $NOTES_DIR -type f -name "*" | rofi -dmenu -i -p "Delete")
  rm $selected

}

main() {

    # Check if the note directory exists
    if [ ! -d $NOTES_DIR ]; then
      mk_chosen=$(rofi -dmenu -i -p "Notes directory not found! Do you want to create it?")
      if [ "$mk_chosen" = "y" ]; then
        mkdir $NOTES_DIR
      elif [ "$mk_chosen" = "n" ]; then
        exit 0
      fi
    fi

    main_chosen=$(cat $HOME/Documents/Notes/Templates/main_options.md | rofi -dmenu -i -p "Choose an option")
    if [ -z "$main_chosen" ]; then
      exit 0
    else
      if [ "$main_chosen" = "Create a new note" ]; then
        create_note
      elif [ "$main_chosen" = "View notes" ]; then
        view_note
      elif [ "$main_chosen" = "Delete a note" ]; then
        delete_note
      fi
    fi
}

main
