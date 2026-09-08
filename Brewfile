#
# brew bundle のエントリポイント。共通パッケージはこのファイルに直接列挙し、
# マシン固有のものだけ Brewfile.fout (会社) / Brewfile.home (家) に分ける。
#
# プロファイルは $USER で判定する (doi_kenji なら fout、それ以外は home)。
# .zshrc.d/common.zsh の $DOTFILES_PROFILE と同じ規則。
# 上書きは HOMEBREW_DOTFILES_PROFILE=fout brew bundle のように渡す
# (brew は環境変数を絞り込むため HOMEBREW_ 接頭辞が要る)。
#
# Brewfile.fout / Brewfile.home を --file で直接渡さないこと。
# brew bundle cleanup は渡された Brewfile に無いものを削除対象とするため、
# 一部だけ渡すと他プロファイルのパッケージが巻き添えで消える。
#
profile = ENV["HOMEBREW_DOTFILES_PROFILE"]
profile = (ENV["USER"] == "doi_kenji" ? "fout" : "home") if profile.nil? || profile.empty?
path = File.expand_path("Brewfile.#{profile}", __dir__)
instance_eval(File.read(path), path) if File.exist?(path)

brew "bat"
brew "coreutils"
brew "cpanminus"
brew "universal-ctags"
brew "docker"
brew "docker-compose"
brew "eza"
brew "fd"
brew "fswatch"
brew "fzf"
brew "gh"
brew "git"
brew "git-delta"
brew "gnutls"
brew "htop"
brew "jq"
brew "mas"
brew "mise"
brew "mysql"
brew "pam-reattach"
brew "podman"
brew "ripgrep"
brew "scala"
brew "sheldon"
brew "terminal-notifier"
brew "tmux"
brew "uv"
brew "zoxide"

# 時間かかりすぎるため手動に切り替え
# mas "Xcode", id: 497799835
# mas "Skitch", id: 425955336

cask "claude-code"
cask "google-chrome"
cask "deepl"
cask "font-jetbrains-mono"
cask "font-ricty-diminished"
cask "font-plemol-jp"
cask "font-udev-gothic"
cask "fuwari"
cask "gcloud-cli"
cask "google-japanese-ime"
cask "hammerspoon"
cask "iina"
cask "intellij-idea-ce"
cask "iterm2"
cask "keycastr"
cask "licecap"
cask "notion"
cask "podman-desktop"
cask "pycharm-ce"
cask "raycast"
cask "slack"
cask "the-unarchiver"
cask "visual-studio-code"
cask "warp"
cask "wavebox"
