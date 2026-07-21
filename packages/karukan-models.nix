{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation rec {
  pname = "karukan-models";
  version = "0.1.0";

  smallModel = fetchurl {
    url = "https://huggingface.co/togatogah/jinen-v1-small.gguf/resolve/main/jinen-v1-small-Q5_K_M.gguf";
    hash = "sha256-m74VtYMikXErTXfueQnJ3cuaZYeJHpMjeUgLTpnxO1I=";
  };

  xsmallModel = fetchurl {
    url = "https://huggingface.co/togatogah/jinen-v1-xsmall.gguf/resolve/main/jinen-v1-xsmall-Q5_K_M.gguf";
    hash = "sha256-uzEQ8G5Tm/hZZ1bfhaSLOUbxN45suRIyK5w2i+Bteao=";
  };

  tokenizer = fetchurl {
    url = "https://huggingface.co/togatogah/jinen-v1-small.gguf/resolve/main/tokenizer.json";
    hash = "sha256-3elxOWG6U2sU8g7QxuFmq+61REiGuWbFkNoa1E3Jo68=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/karukan-models
    cp $smallModel $out/share/karukan-models/jinen-v1-small-Q5_K_M.gguf
    cp $xsmallModel $out/share/karukan-models/jinen-v1-xsmall-Q5_K_M.gguf
    cp $tokenizer $out/share/karukan-models/tokenizer.json
  '';
}
