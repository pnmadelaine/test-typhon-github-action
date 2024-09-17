{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.typhon.url = "github:typhon-ci/typhon/pnm/fix-https";
  inputs.typhon.inputs.nixpkgs.follows = "nixpkgs";
  outputs =
    { nixpkgs, typhon, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      typhonJobs.${system}.hello = pkgs.writeTextDir "hello.txt" "Hello world!";
      typhonProject = typhon.lib.builders.mkProject {
        #actions.end = typhon.lib.builders.mkActionScript (
        #  { pkgs, system }: {
        #    path = [ pkgs.jq ];
        #    script = ''
        #      stdin=$(cat)
        #      echo "$stdin" | >&2 jq '.secrets | keys[]'
        #    '';
        #  }
        #);
        actions.end = typhon.lib.compose.match [
          {
            jobset = "main";
            inherit system;
            job = "hello";
            action = typhon.lib.github.mkPushResult {
              owner = "pnmadelaine";
              repo = "test-typhon-github-action";
              branch = "hello";
            };
          }
          {
            action = typhon.lib.builders.mkDummyAction { output = "null"; };
          }
        ];
      };
    };
}
