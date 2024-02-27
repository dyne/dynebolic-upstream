# Jaromil's dotfiles

This setup is based on the Bash shell and includes configurations for git, emacs, vim, direnv. In addition there is also a set of handy shell scripts and a level of integration with WSL host (Windows Subsystem for Linux).

Quick Install:

```
curl -L https://jaromil.dyne.org/dotfiles.sh | sh
```

Will install into `~/.dotfiles`

Go inside this directory and type `make` for a list of options.

Do `make setup` to activate, beware it will overwrite some dotfiles:
- ~/.gitconfig && ~/.gitignore
- ~/.bashrc && ~/.inputrc
- ~/.emacs && ~/.vimrc
- ~/.editorconfig
- ~/.signature
- ~/.direnvrc

## Usage

```
Usage:
  make <target>
  help             Display this help.
  setup            Setup dotfiles for the current user
  install          Base setup and install of APT rules
  install-apt      Install base distro packages on APT distros (*)
  install-devops   Install devops tools: docker, terraform (*)
  install-devtools  Install development tools: make, gcc, lua-dev.. (*)
  install-firewall  Install basic ufw firewall protection allowing only ssh
  install-emacs    Install emacs packages (*)
  install-latex    Install latex packages (*)
  install-nodejs   Install nodejs tools
  install-winhost  Copy WSL dotfiles to the Windows host user dir

(*) = needs root
```

## Shell scripts

- tile-goldratio :: minimal windowmanager tiling script using wmctl
- rd-rm-results :: rdfind helper to remove duplicate hits in results.txt
- lnxrouter :: shell script to activate NAT masq from current host
- adduser-remote :: generates script to quickly add a user and ssh key
- mladmin :: quickly opens the admin panel of a dyne.org mailinglist
- hcloud-datacenters :: list all hetzner datacenters for hcloud-cli
- torrent-serve :: serve files in current directory for LAN streaming
- .f-install-readme :: install direnv README.nfo in current dir
- .f-install-nvm :: install a NodeVM setup in current dir

## Emacs

Core packages to be installed from ELPA: `ivy helm`

Handy install script on APT systems: `make install-emacs`

The setup uses helm heavily (even swoop in place of find-file) supports golang and has support for spell-checker hunspell and english grammar-checker grammarly.

Keys are remapped for my confort as follows:

```elisp

(global-unset-key [(control x)(control z)])
(global-set-key (kbd "M-x") 'helm-M-x)
;; M-l in qwerty is soft on right hand and I use it also in tmux
(global-set-key (kbd "M-l") 'helm-M-x) ;; this overrides an ugly lowercase hotkey
(global-set-key (kbd "M-k") 'kill-buffer) ;; I'm not using it to delete lower block
(global-set-key (kbd "M-i") 'helm-imenu)
(global-set-key (kbd "M-,") 'helm-ag-project-root)
(global-set-key (kbd "M-.") 'helm-ag)
(global-set-key (kbd "C-x g") 'magit)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "M-o") 'helm-occur)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-s") 'helm-swoop)
(global-set-key (kbd "M-s M-s") 'helm-multi-swoop-all)

;; because I'm sloppy
(global-set-key (kbd "C-o") 'helm-find-files)
(global-set-key (kbd "C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "M-p") 'helm-buffers-list) ;; right ha

(global-unset-key (kbd "M-c")) ;; sloppy and not useful

```


## Layout

At shell startup the loader.sh is sourced to load all scripts in `system/` and then the shell specific one in `shell/`.

The `install/` dir contains collections of package install scripts.


```
.
├── bin
│   ├── adduser-remote
│   ├── hcloud-datacenters
│   ├── lnxrouter
│   ├── mladmin
│   ├── rd-rm-results
│   ├── shuriken
│   ├── tile-goldratio
│   └── torrent-serve
├── dotfiles.sh
├── emacs
│   ├── doom-themes-base.el
│   ├── doom-themes.el
│   ├── emacs
│   ├── flycheck-grammarly.el
│   ├── go-mode.el
│   ├── grammarly.el
│   ├── helm-flx.el
│   ├── helm-swoop.el
│   ├── mood-line.el
│   ├── nyan-mode
│   ├── rainbow-delimiters.el
│   ├── request-deferred.el
│   ├── request.el
│   ├── themes
│   └── ws-butler.el
├── git
│   ├── gitconfig
│   └── gitignore
├── install
│   ├── apt
│   ├── devops
│   ├── devtools
│   ├── emacs
│   ├── firewall
│   ├── latex
│   ├── neovim
│   ├── nodejs
│   ├── vscode
│   └── winhost
├── loader.sh
├── Makefile
├── misc
│   ├── direnvrc
│   ├── editorconfig
│   ├── nord-tmux
│   ├── signature
│   └── tmux.conf
├── README.md
├── shell
│   ├── bashrc
│   ├── inputrc
│   └── zshrc
├── system
│   ├── alias
│   ├── dir_colors
│   ├── env
│   ├── extensions
│   ├── function
│   ├── function_fs
│   ├── function_network
│   ├── function_text
│   ├── grep
│   ├── onedrive
│   ├── path
│   ├── prompt
│   └── startmenu
└── vim
    ├── nvim
    └── vimrc 
```
