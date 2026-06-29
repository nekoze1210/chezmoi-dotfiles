{ private, ... }:

{
  # nix-darwin module schema version。破壊的変更を跨ぐとき以外は据え置き。
  system.stateVersion = 5;

  # 単一ユーザ環境。homebrew や user-scoped activation はこの user を見る。
  system.primaryUser = private.username;

  # username（daikinagaoka）と home（/Users/nekoze）は一致しないので明示する。
  # ここを /Users/${username} 等で導出すると壊れる。
  users.users.${private.username} = {
    name = private.username;
    home = private.homeDirectory;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Determinate Nix が daemon と /etc/nix/nix.conf を管理しているので、nix-darwin 側の
  # Nix 管理は完全にオフ。これがないと両者が nix.conf/launchd を取り合って壊れる。
  nix.enable = false;

  # /etc/zshrc は Determinate Nix 由来のものを尊重し、nix-darwin 側では触らない
  # （shell は home-manager の programs.zsh が ~/.zshrc を管理している）。
  programs.zsh.enable = false;

  # --------------------------------------------------------------------------
  # Homebrew bridge — casks / mas / taps を宣言的に管理する（③ の主目的）。
  # cleanup = "none": リスト外を消さない（安全側）。慣れてきたら "uninstall" に。
  # CLI formula は nixpkgs へ移行済みなので brews はほぼ空（mas だけ masApps 用に確保）。
  # prefix は標準の /opt/homebrew（mizchi の ~/brew とは違うので未指定＝デフォルト）。
  # --------------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    taps = [
      "anthropics/tap"
      "aws/tap"
      "bufbuild/buf"
      "grishka/grishka"
      "hashicorp/tap"
      "libsql/sqld"
      "microsoft/apm"
      "olets/tap"
      "openclaw/tap"
      "oven-sh/bun"
      "phayes/repo"
      "steipete/tap"
      "stripe/stripe-cli"
      "tursodatabase/tap"
    ];

    brews = [
      "mas" # masApps を入れるのに必要
    ];

    casks = [
      "1password"
      "alt-tab"
      "anthropics/tap/ant"
      "blackhole-16ch"
      "blender"
      "chatgpt"
      "clipy"
      "codex"
      "discord"
      "expo-orbit"
      "figma"
      "font-fira-code-nerd-font"
      "font-hackgen"
      "font-hackgen-nerd"
      "font-iosevka"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "google-japanese-ime"
      "icon-composer"
      "iterm2"
      "karabiner-elements"
      "keyboardcleantool"
      "makemkv"
      "ngrok"
      "obsidian"
      "raycast"
      "visual-studio-code"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Apple Configurator" = 1037126344;
      "Developer" = 640199958;
      "GarageBand" = 682658836;
      "iMovie" = 408981434;
      "Keynote" = 409183694;
      "Kindle" = 302584613;
      "LadioCast" = 411213048;
      "LINE" = 539883307;
      "Magnet" = 441258766;
      "Numbers" = 361304891;
      "Pages" = 361309726;
      "Slack" = 803453959;
      "TestFlight" = 899247664;
      "Transporter" = 1450874784;
      "Xcode" = 497799835;
    };
  };

  # --------------------------------------------------------------------------
  # Touch ID で sudo を通す → darwin-rebuild switch 等の毎回のパスワードが指紋に。
  # /etc/pam.d/sudo_local に書く方式なので macOS アップデートでも消えない。
  # --------------------------------------------------------------------------
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS デフォルト（dock autohide 等）はデスクトップ挙動が変わるので任意。
  # 欲しくなったらコメントを外して darwin-rebuild switch。
  # system.defaults = {
  #   NSGlobalDomain = {
  #     AppleShowAllExtensions = true;
  #     InitialKeyRepeat = 14;
  #     KeyRepeat = 1;
  #     ApplePressAndHoldEnabled = false; # 長押しで accent menu を出さない
  #   };
  #   finder = {
  #     AppleShowAllFiles = true;
  #     FXEnableExtensionChangeWarning = false;
  #     ShowPathbar = true;
  #   };
  #   dock = {
  #     autohide = true;
  #     show-recents = false;
  #     mru-spaces = false;
  #   };
  #   trackpad.Clicking = true;
  # };
}
