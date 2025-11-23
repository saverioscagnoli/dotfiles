#!/bin/bash

# Simple 2-pane setup: btop + shell
SESSION_NAME="monitor"

# Kill existing session
tmux kill-session -t $SESSION_NAME 2>/dev/null

# Create new session
tmux new-session -d -s $SESSION_NAME

# Split horizontally - btop gets 90% width, shell gets 10%
tmux split-window -h -p 10 -t $SESSION_NAME:0

# Left pane: btop
tmux send-keys -t $SESSION_NAME:0.0 'btop' C-m

# Right pane: shell with smaller/compact display
tmux send-keys -t $SESSION_NAME:0.1 'export PS1="\[\033[32m\]>\[\033[0m\] "' C-m 

# Make it look cool - no borders, no status bar
tmux set-option -g status off
tmux set-option -g pane-border-style fg=black
tmux set-option -g pane-active-border-style fg=black
tmux set-option -g pane-border-lines single
tmux set-option -g pane-border-status off

# Focus on shell pane
tmux select-pane -t $SESSION_NAME:0.1

# Attach
tmux attach-session -t $SESSION_NAME
