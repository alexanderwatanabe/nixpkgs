{ stdenv, rustPlatform, fetchFromGitHub, llvmPackages, pkgconfig, less
, Security, libiconv, installShellFiles, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname   = "bat";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner  = "sharkdp";
    repo   = pname;
    rev    = "v${version}";
    sha256 = "1kaa6ps6v1wk9qs63h116k4pbz7y9mfbfxfbq7g89yjhzkjmh6xc";
    fetchSubmodules = true;
  };

  cargoSha256 = "01l1y124gjh6gf9z1jkbpfzh0w92hrgwvsmqkqdw3a9pa4w5f6yg";

  nativeBuildInputs = [ pkgconfig llvmPackages.libclang installShellFiles makeWrapper ];

  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ Security libiconv ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";

  postInstall = ''
    installManPage $releaseDir/build/bat-*/out/assets/manual/bat.1
    installShellCompletion $releaseDir/build/bat-*/out/assets/completions/bat.fish
  '';

  # Insert Nix-built `less` into PATH because the system-provided one may be too old to behave as
  # expected with certain flag combinations.
  postFixup = ''
    wrapProgram "$out/bin/bat" \
      --prefix PATH : "${stdenv.lib.makeBinPath [ less ]}"
  '';

  meta = with stdenv.lib; {
    description = "A cat(1) clone with syntax highlighting and Git integration";
    homepage    = "https://github.com/sharkdp/bat";
    license     = with licenses; [ asl20 /* or */ mit ];
    maintainers = with maintainers; [ dywedir lilyball ];
    platforms   = platforms.all;
  };
}
