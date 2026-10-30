{
  lib,
  newScope,
  self,
}:
let
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.strings) hasPrefix removePrefix;
  inherit (lib.trivial) importJSON pipe;
in
lib.makeScope newScope (
  scope:
  lib.packagesFromDirectoryRecursive {
    inherit (scope) callPackage;
    directory = ./pkgs;
  }
  // {
    inherit self;
    meridianPlugins = pipe self.inputs [
      (filterAttrs (pname: _: hasPrefix "meridian-plugin-" pname))
      (mapAttrs' (
        pname: src:
        let
          package = importJSON "${src}/package.json";
        in
        nameValuePair (removePrefix "meridian-plugin-" pname) (
          scope.buildMeridianPlugin {
            inherit pname src;
            inherit (package) version;
            meta = { inherit (package) description; };
          }
        )
      ))
    ];
  }
)
