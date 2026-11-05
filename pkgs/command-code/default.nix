{
  lib,
  buildNpmPackage,
  fetchurl,
  autoPatchelfHook,
  stdenv,
  jq,
  ripgrep,
}:

let
  inherit (lib.importJSON ./source.json) version hash npmDepsHash;
in
buildNpmPackage {
  pname = "command-code";
  inherit version npmDepsHash;

  src = fetchurl {
    url = "https://registry.npmjs.org/command-code/-/command-code-${version}.tgz";
    inherit hash;
  };

  # Das npm-Paket bringt kein Lockfile mit und listet private Workspace-Pakete als devDependencies
  # (schon in dist gebündelt), an denen npm ci scheitert – daher raus und eigenes Lockfile rein.
  # Absoluter jq-Pfad, weil postPatch auch in fetchNpmDeps läuft
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  # @vscode/ripgrep lädt rg im postinstall aus dem Netz – stattdessen rg aus nixpkgs
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  # ELF-Binaries in node_modules brauchen unter Linux angepasste Bibliothekspfade, macOS nicht
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  makeWrapperArgs = [
    "--set-default"
    "COMMAND_CODE_RIPGREP_PATH"
    (lib.getExe ripgrep)
  ];

  meta = {
    description = "Coding-Agent von Langbase, der den eigenen Coding-Stil lernt";
    homepage = "https://commandcode.ai";
    license = lib.licenses.unfree;
    mainProgram = "cmd";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
