{ pkgs ? import <nixpkgs> {}, fetchNuGet ? pkgs.fetchNuGet, buildDotnetPackage ? pkgs.buildDotnetPackage,
  fetchFromGitHub ? pkgs.fetchFromGitHub, mono ? pkgs.mono }:

let
  DotNetZip = fetchNuGet {
    baseName = "DotNetZip";
    version = "1.13.4";
    sha256 = "0j7b8b12dz7wxmhr1i9xs9mr9hq65xnsxdg4vlaz53k7ddi36v39";
    outputFiles = ["*"];
  };

  Jdenticon = fetchNuGet {
    baseName = "Jdenticon-net";
    version = "2.2.1";
    sha256 = "1li1flpfpj8dwz7sy5imbvgwpqxzn7nqk2znr21rx2sn761029vz";
    outputFiles = ["*"];
  };

  KeraLua = fetchNuGet {
    baseName = "KeraLua";
    version = "1.0.22";
    sha256 = "09b4kp6rnzkxdz69bk2w964l3vkypga6p1lnp5g7vzcnq24zhn6y";
    outputFiles = ["*"];
  };

  Cecil = fetchNuGet {
    baseName = "Mono.Cecil";
    version = "0.11.1";
    sha256 = "0c7srz0vqm0npli2ixg9j6x934l0drrng8brwanqh96s1wwaikr7";
    outputFiles = ["*"];
  };

  MonoMod = fetchNuGet {
    baseName = "MonoMod";
    version = "19.12.4.1";
    sha256 = "0fc943fhgak6bazdvjx0b2c3ifx9lxmmfg8c5ii1ykn5j3mvgfqw";
    outputFiles = ["*"];
  };

  MonoMod-RD = fetchNuGet {
    baseName = "MonoMod.RuntimeDetour";
    version = "19.12.4.1";
    sha256 = "1fsgp8jaz4j1xn7ic4ky8az3i5ag7kl3f4kj2ckvminpa8x7ngqm";
    outputFiles = ["*"];
  };

  MonoMod-RD-HG = fetchNuGet {
    baseName = "MonoMod.RuntimeDetour.HookGen";
    version = "19.12.4.1";
    sha256 = "001mzsc018955kcp2yz3yzs4hm9i51xixd0c324kwdxba938pa5i";
    outputFiles = ["*"];
  };

  MonoMod-Utils = fetchNuGet {
    baseName = "MonoMod.Utils";
    version = "19.12.4.1";
    sha256 = "0mznyj6184977d5vpw7d2y6pv2v3jczqj5wdxjwx22xcqlifgw1q";
    outputFiles = ["*"];
  };

  Json = fetchNuGet {
    baseName = "Newtonsoft.Json";
    version = "12.0.3";
    sha256 = "17dzl305d835mzign8r15vkmav2hq8l6g7942dfjpnzr17wwl89x";
    outputFiles = ["*"];
  };

  NLua = fetchNuGet {
    baseName = "NLua";
    version = "1.4.25";
    sha256 = "1n6ll2sh297bm9h1hip5pgm8yannbl5a38vy3yq4r3fg8ifb0r0r";
    outputFiles = ["*"];
  };

  YamlDotNet = fetchNuGet {
    baseName = "YamlDotNet";
    version = "8.0.0";
    sha256 = "09hr1jimmfhcpk97p963y94h2k5p7wzcj4mpwqpdnwzbyrp2flpm";
    outputFiles = ["*"];
  };
  
  commit = "a1d9077b4e3b36e79a6186e56626009ba1abf1d8";
  version = "1.1161.0";
  hash = "sha256:0pgj5wf0rl0g73ykjkgfvq6xs2i6mjl523hsmpa803vnhmdycjfk";

  src = fetchFromGitHub {
    owner = "EverestAPI";
    repo = "Everest";
    rev = commit;
    inherit hash;
  };

in buildDotnetPackage rec {
  baseName = "Everest";
  name = "${baseName}-stable-${version}";
  
  inherit version src;

  xBuildFiles = [ "Celeste.Mod.mm/Celeste.Mod.mm.csproj" "MiniInstaller/MiniInstaller.csproj" ];
  outputFiles = [ "Celeste.Mod.mm/bin/Release/*" "MiniInstaller/bin/Release/*" ];

  patchPhase = ''
    # $(SolutionDir) does not work for some reason
    substituteInPlace Celeste.Mod.mm/Celeste.Mod.mm.csproj --replace '$(SolutionDir)' ".."
    substituteInPlace MiniInstaller/MiniInstaller.csproj --replace '$(SolutionDir)' ".."

    # See c4263f8 Celeste.Mod.mm/Mod/Everest/Everest.cs line 31
    # This is normally set by Azure
    substituteInPlace Celeste.Mod.mm/Mod/Everest/Everest.cs --replace '0.0.0-dev' "${version}-nix-${builtins.substring 0 7 commit}"
  '';

  preBuild = ''
    # Fake nuget restore, not very elegant but it works.
    mkdir -p packages
    ln -sn ${Jdenticon}/lib/dotnet/Jdenticon-net                     packages/Jdenticon-net.${Jdenticon.version}
    ln -sn ${KeraLua}/lib/dotnet/KeraLua                             packages/KeraLua.${KeraLua.version}
    ln -sn ${DotNetZip}/lib/dotnet/DotNetZip                         packages/DotNetZip.${DotNetZip.version}
    ln -sn ${Cecil}/lib/dotnet/Mono.Cecil                            packages/Mono.Cecil.${Cecil.version}
    ln -sn ${MonoMod}/lib/dotnet/MonoMod                             packages/MonoMod.${MonoMod.version}
    ln -sn ${MonoMod-RD}/lib/dotnet/MonoMod.RuntimeDetour            packages/MonoMod.RuntimeDetour.${MonoMod-RD.version}
    ln -sn ${MonoMod-RD-HG}/lib/dotnet/MonoMod.RuntimeDetour.HookGen packages/MonoMod.RuntimeDetour.HookGen.${MonoMod-RD-HG.version}
    ln -sn ${MonoMod-Utils}/lib/dotnet/MonoMod.Utils                 packages/MonoMod.Utils.${MonoMod-Utils.version}
    ln -sn ${Json}/lib/dotnet/Newtonsoft.Json                        packages/Newtonsoft.Json.${Json.version}
    ln -sn ${NLua}/lib/dotnet/NLua                                   packages/NLua.${NLua.version}
    ln -sn ${YamlDotNet}/lib/dotnet/YamlDotNet                       packages/YamlDotNet.${YamlDotNet.version}
  '';

  postInstall = ''
    mv \
      $out/lib/dotnet/Everest/libMonoPosixHelper.dylib.dSYM/Contents/Resources/DWARF/libMonoPosixHelper.dylib \
      $out/lib/dotnet/Everest/libMonoPosixHelper.dylib.dSYM/Contents/Info.plist \
      $out/lib/dotnet/Everest/lib64/* \
      $out/lib/dotnet/Everest/
    if [ -f "${mono}/lib/libMonoPosixHelper.so" ]; then
      cp ${mono}/lib/libMonoPosixHelper.so $out/lib/dotnet/Everest
    fi
    rm -r $out/lib/dotnet/Everest/lib64 $out/lib/dotnet/Everest/libMonoPosixHelper.dylib.dSYM
    sed -i '2i chmod -R u+w .'                                                                                       $out/bin/miniinstaller
    sed -i "2i cp -r $out/lib/dotnet/Everest/* ."                                                                    $out/bin/miniinstaller
    sed -i '2i fi'                                                                                                   $out/bin/miniinstaller
    sed -i '2i \ \ exit 1'                                                                                           $out/bin/miniinstaller
    sed -i '2i \ \ echo "No Celeste executable found, refusing to install" 1>&2'                                     $out/bin/miniinstaller
    sed -i '2i if ! [[ -f Celeste.exe || -f Celeste.bin.osx || -f Celeste.bin.x86_64 || -f Celeste.bin.x86 ]]; then' $out/bin/miniinstaller
    sed -i '2i cd "$1"'                                                                                              $out/bin/miniinstaller
  '';
} // { shell = import ./shell.nix; }
