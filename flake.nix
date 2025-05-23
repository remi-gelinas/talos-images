{
  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;

          config.allowUnfree = true;

          overlays = [
            (final: prev: {
              cue = prev.cue.overrideAttrs (
                finalAttrs: prevAttrs: {
                  version = "0.13.0";

                  src = prev.fetchFromGitHub {
                    owner = "cue-lang";
                    repo = "cue";
                    rev = "v${finalAttrs.version}";
                    hash = "sha256-RvdjZ3wSc3IhQvYJL989x33qOtVZ4paoQTLFzWF9xj0=";
                  };

                  vendorHash = "sha256-J9Ox9Yt64PmL2AE+GRdWDHlBtpfmDtxgUbEPaka5JSo=";

                  ldflags = map (
                    flag:
                    if (builtins.match "^-X cuelang.org/go/cmd/cue/cmd.version=.*$" flag) != null then
                      "-X cuelang.org/go/cmd/cue/cmd.version=v${finalAttrs.version}"
                    else
                      flag
                  ) prevAttrs.ldflags;
                }
              );
            })
          ];
        }
      );

    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            name = "kube-kingdom";

            packages = with pkgs; [
              crane
              cue
              fluxcd
              go
              talosctl
            ];
          };
        }
      );
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };
}
