{
  description = "Dev flake for this dotfiles repo (nixfmt formatter + devShell)";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  outputs =
    { nixpkgs, ... }:
    let
      # Apple Silicon (M1) Mac 専用。他プラットフォームに出す予定はないので
      # multi-system の足場は持たず aarch64-darwin 決め打ち（mizchi 同様）。
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [ pkgs.nixfmt ];
      };

      # `nix fmt` 用フォーマッタ
      formatter.${system} = pkgs.nixfmt;
    };
}
