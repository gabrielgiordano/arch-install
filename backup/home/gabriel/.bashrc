#
# ~/.bashrc
# Check for an interactive session
[ -z "$PS1" ] && return

archey
PS1='[\[\e[0;32m\]\u\[\e[0m\]@\[\e[33m\]\h\[\e[0m\]\[\e[36m\] \W\[\e[0m\]]\[\e[31m\]\$\[\e[0m\] '

#### ALIASES ####
alias ls='ls --color=auto'

#---------------------------------------------------

# If not running interactively, don't do anything
#[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
