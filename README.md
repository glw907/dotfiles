## Stuff to Install
Following is a list of packages to install. This assumes you’ve already installed brew.

- iterm2
- ripgrep
- nvim
- starship
- font-fira-code-nerd-font
- zsh-syntax-highlighting
- zsh-autosuggestions
- autojump

## Symlinks
Following is a list of symlinks to add to ~/.config/

`ln -s ~/GitHub/dotfiles/starship/ ~/.config/`
`ln -s ~/GitHub/dotfiles/nvim/ ~/.config/`
`ln -s ~/GitHub/dotfiles/iterm2/com.googlecode.iterm2.plist ~/.config/iterm2/`

Also, create the following in the home directory:

`ln -s ~/GitHub/dotfiles/zsh/zshrc ~/.zshrc`

## iTerm2
Installing the packages and creating symlinks is all you need to do to set up zsh, starship, and nvim correctly. But iTerm requires a bit of special handling to load its config properly. Here are the steps:

1. Open iTerm and select settings
2. Got to General -> Settings
3. Select _Load settings from a custom folder or URL_
4. Click _Browse_ and then use _Cmd-Shift-._ to expose dotfiles.
5. Navigate to the ~/.config/iterm2/ directory and select it. (Note that you won’t be able to select the actual config file.)
6. You’ll get a dialog asking if you want to save your local config to the file. _Don’t do that._
7. Quite iTerm2 and reopen. You should see the new config!



