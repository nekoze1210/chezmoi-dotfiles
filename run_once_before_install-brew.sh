#!/bin/sh
# Bootstrap: 標準の /opt/homebrew に Homebrew が無ければ入れる。
# nix-darwin の homebrew module は brew の存在を前提にするので、初回の
# darwin-rebuild switch より前に用意しておく必要がある。
# chezmoi の run_once_before フック（初回 apply 時に一度だけ・ファイル展開前）。
#
# 注: /opt/homebrew の作成には root が要るため、真っさらな Mac では公式
#     installer が sudo を一度要求する（既に brew があればここで skip）。
set -eu

if command -v brew >/dev/null 2>&1 || [ -x /opt/homebrew/bin/brew ]; then
  exit 0
fi

echo "[chezmoi] Installing Homebrew into /opt/homebrew ..." >&2
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
