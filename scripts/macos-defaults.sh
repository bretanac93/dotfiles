#!/bin/zsh 

defaults write com.apple.dock tilesize -int 30 # shrink dock size
defaults write com.apple.dock size-immutable -bool yes # lock current size
defaults write com.apple.dock magnification -bool false # disable magnification
defaults write com.apple.dock orientation left # move dock to left
defaults write com.apple.dock autohide -bool true # autohide dock
defaults write -g AppleShowScrollBars -string WhenScrolling # show scrollbars only when scrolling
defaults write com.apple.dock workspaces-edge-delay -float 0 # remove delay for switching spaces
defaults write com.apple.dock autohide-time-modifier -float 0.5 # speed up autohide animation

killall Dock

