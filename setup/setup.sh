#!/bin/bash
#
# NAME
#   setup.sh
# DESCRIPTION
#   dotfiles のシンボリックリンク配置と各種セットアップ。何度実行しても良い
# REQUIREMENTS
#   実行中に案内されないもの (sudo パスワードや Xcode CLT はプロンプトが出るので不要)
#   PROFILE=fout でのみ、事前に用意が要る
#   - Keychain の Redmine API キー (登録コマンドは fout_setup のコメント参照)
#   - ~/.ssh/config と ~/.ssh/id_rsa_bastion (.ssh は dotfiles 管理外。fout.zsh が使う)

##
## First of all, we need git
##
which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
which git >/dev/null || brew install git

##
## Get This Repository
##
## clone 自体は鍵の要らない HTTPS で行い、push できるよう origin だけ SSH に向け直す
[ ! -d $HOME/dotfiles ] && git clone https://github.com/doiken/dotfiles.git $HOME/dotfiles
git -C $HOME/dotfiles remote set-url origin git@github.com:doiken/dotfiles.git

##
## Profile
##
## 会社(fout)か家(home)かの判定。.zshrc.d/common.zsh の $DOTFILES_PROFILE や
## dotfiles/Brewfile と同じ規則。setup.sh は zsh 起動前にも走るため
## 環境変数ではなく $USER を直接見る。
##
case "$USER" in
    doi_kenji) PROFILE=fout ;;
    *)         PROFILE=home ;;
esac

## 反転表示で後続の brew 出力に埋もれないようにする。tty でなければ色を付けない
if [ -t 1 ]; then
    printf '\033[7m PROFILE=%s \033[0m (USER=%s)\n' "$PROFILE" "$USER"
else
    printf 'PROFILE=%s (USER=%s)\n' "$PROFILE" "$USER"
fi

##
## Sym Link
##
DOT_FILES=(
  .hammerspoon
  bin
  .zsh
  .zshrc
  .zshenv
  .zprofile
  .gitconfig
  .gitignore_global
  .vimrc
  .ideavimrc
  .tmux.conf
  .ctags
  .tmpl
  .editrc
  .git_template
  .claude
)

## .zshrc.d 配下は 1 ファイルずつリンクする
mkdir -p $HOME/.zshrc.d
for f in $HOME/dotfiles/.zshrc.d/*.zsh; do
    [ -e "$f" ] && DOT_FILES+=(".zshrc.d/${f##*/}")
done

## リネーム・削除で実体を失ったシンボリックリンクを掃除する
## (残すと .zshrc の `source ~/.zshrc.d/*.zsh` が失敗する)
for link in $HOME/.zshrc.d/*; do
    [ -L "$link" ] && [ ! -e "$link" ] && rm "$link"
done

for file in "${DOT_FILES[@]}"
do
    [ -L "$HOME/$file" ] && [ ! -e "$HOME/$file" ] && rm "$HOME/$file"
    [ ! -e "$HOME/$file" ] && ln -s "$HOME/dotfiles/$file" "$HOME/$file"
done

# sheldon (zsh plugin manager)
mkdir -p ~/.config/sheldon
[ ! -e ~/.config/sheldon/plugins.toml ] && ln -s $HOME/dotfiles/.config/sheldon/plugins.toml ~/.config/sheldon/plugins.toml

# mise (runtime version manager)
mkdir -p ~/.config/mise
[ ! -e ~/.config/mise/config.toml ] && ln -s $HOME/dotfiles/.config/mise/config.toml ~/.config/mise/config.toml

##
## Install Basics
##

## Homebrew
## dotfiles/Brewfile が会社(fout)/個人(home)を判定して Brewfile.* を取り込む。
## --global (~/.Brewfile) は使わなくなったので、旧シンボリックリンクがあれば掃除する。
[ -L $HOME/.Brewfile ] && rm $HOME/.Brewfile
BREW_LOG=/tmp/dotfiles_brew_bundle.log
echo "Running brew bundle in background... (see $BREW_LOG)"
{
	brew bundle --file $HOME/dotfiles/Brewfile >$BREW_LOG 2>&1
} &
##
## docker completion
## https://docs.docker.com/docker-for-mac/
##
# [ ! -e /usr/local/share/zsh/site-functions/_docker ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion /usr/local/share/zsh/site-functions/_docker
# [ ! -e /usr/local/share/zsh/site-functions/_docker-compose ] && ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion /usr/local/share/zsh/site-functions/_docker-compose

wait
echo "brew bundle finished (see $BREW_LOG)"

##
## Touch ID for sudo (macOS 14.4+)
## https://qiita.com/y-vectorfield/items/3fc96150e63448a80c1b
##
if [ -f /etc/pam.d/sudo_local.template ] && ! grep -q '^auth.*pam_tid.so' /etc/pam.d/sudo_local 2>/dev/null; then
    echo "Enabling Touch ID for sudo (password required once)"
    {
        ## tmux/screen 内でも Touch ID を効かせる
        PAM_REATTACH=$(brew --prefix)/lib/pam/pam_reattach.so
        [ -f $PAM_REATTACH ] && echo "auth       optional       $PAM_REATTACH"
        sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template
    } | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

##
## Configure
##
SCRIPTS=(
    $HOME/dotfiles/setup/defaults.pl
    $HOME/dotfiles/setup/podman_setup
    $HOME/dotfiles/setup/${PROFILE}_setup # 存在しないプロファイルは -x で弾かれる
)
for script in ${SCRIPTS[@]}; do
    ## プロファイル用スクリプトが無いマシンでも終了コードを 1 にしないよう continue で飛ばす
    [ -x $script ] || continue
    $script
done
