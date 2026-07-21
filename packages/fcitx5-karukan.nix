{ lib, stdenv, rustPlatform, fetchFromGitHub
, cmake, pkg-config, kdePackages
, fcitx5, libxkbcommon, openssl
, llvmPackages, python3
}:

rustPlatform.buildRustPackage rec {
  pname = "fcitx5-karukan";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "togatoga";
    repo = "karukan";
    rev = "954c221ee8b34e3eecf71d8ab90bda8562c39fb7";
    hash = "sha256-suriKc5ZAAb1pvewu/GXYvnqon96wVfxHAAqai6R4aU=";
  };

  cargoHash = "sha256-q7LqUnEi02En8fwbFVlrX2bLYEOLXrJdAjmGzBWMUsg=";

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    rustPlatform.bindgenHook
    python3
    llvmPackages.clang
    llvmPackages.libclang
    llvmPackages.libcxxClang
  ];

  buildInputs = [
    fcitx5
    libxkbcommon
    openssl
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  buildPhase = ''
    runHook preBuild
    cargo build --release -p karukan-fcitx5
    runHook postBuild
  '';

  doCheck = false;

  postPatch = ''
    python3 << 'PYEOF'
import re

# 1. karukan-engine/src/kanji/error.rs — add BackendInit variant
path = "karukan-engine/src/kanji/error.rs"
with open(path) as f:
    content = f.read()
content = content.replace(
    'UnknownVariant(String),\n\n    #[error("download failed")]',
    'UnknownVariant(String),\n\n    #[error("backend init failed: {0}")]\n    BackendInit(String),\n\n    #[error("download failed")]',
)
with open(path, "w") as f:
    f.write(content)

# 2. karukan-engine/src/kanji/backend.rs — add from_gguf_paths method before impl Backend close
path = "karukan-engine/src/kanji/backend.rs"
with open(path) as f:
    content = f.read()
new_method = """
    /// Create a backend from direct GGUF file path.
    ///
    /// The tokenizer is expected as `tokenizer.json` in the same directory.
    /// No HuggingFace download is performed.
    pub fn from_gguf_paths(gguf_path: &str) -> Result<Self> {
        use std::path::Path;
        let gguf = Path::new(gguf_path);
        let dir = gguf.parent().ok_or_else(|| {
            KanjiError::BackendInit(format!("no parent dir for: {}", gguf_path))
        })?;
        let tokenizer_path = dir.join("tokenizer.json");
        if !tokenizer_path.exists() {
            return Err(KanjiError::BackendInit(format!(
                "tokenizer.json not found in {:?}", dir
            )));
        }
        Ok(Backend {
            gguf_path: gguf_path.to_string(),
            tokenizer_json_path: tokenizer_path.to_string_lossy().to_string(),
            display_name: "custom".to_string(),
        })
    }
"""
# Insert before the closing } of impl Backend (before "/// Kanji converter")
content = content.replace(
    '        Self::from_variant(family, variant)\n    }\n}\n\n/// Kanji converter using llama.cpp backend',
    '        Self::from_variant(family, variant)\n    }' + new_method + '\n}\n\n/// Kanji converter using llama.cpp backend',
)
with open(path, "w") as f:
    f.write(content)

# 3. karukan-im/src/core/engine/mod.rs — accept GGUF file paths
path = "karukan-im/src/core/engine/mod.rs"
with open(path) as f:
    content = f.read()
old_block = """            if reg.find_variant(id).is_some() {
                Ok(id.to_string())
            } else {
                anyhow::bail!("unknown model variant: {}", id)
            }"""
new_block = """            if id.contains('/') && id.ends_with(".gguf") {
                // Direct GGUF file path — skip HF download
                Ok(id.to_string())
            } else if reg.find_variant(id).is_some() {
                Ok(id.to_string())
            } else {
                anyhow::bail!("unknown model variant: {}", id)
            }"""
content = content.replace(old_block, new_block, 1)
with open(path, "w") as f:
    f.write(content)

# 4. karukan-im/src/core/engine/init.rs — use from_gguf_paths for path-like model specs
path = "karukan-im/src/core/engine/init.rs"
with open(path) as f:
    content = f.read()
old_line = "    let backend = karukan_engine::Backend::from_variant_id(variant_id)?;"
new_line = """    let backend = if variant_id.contains('/') && variant_id.ends_with(".gguf") {
        // Direct GGUF file path: skip HuggingFace download
        karukan_engine::Backend::from_gguf_paths(variant_id)?
    } else {
        karukan_engine::Backend::from_variant_id(variant_id)?
    };"""
content = content.replace(old_line, new_line, 1)
with open(path, "w") as f:
    f.write(content)

# 5. Disable auto-suggest candidate window while composing.
# Candidates only appear after Space conversion; preedit stays hiragana.
path = "karukan-im/src/core/engine/input.rs"
with open(path) as f:
    content = f.read()
start_marker = "    /// Refresh the input state: rebuild preedit and run auto-suggest for candidates.\n"
end_marker = "\n    /// Process key in empty state\n"
start = content.find(start_marker)
end = content.find(end_marker, start)
if start < 0 or end < 0:
    raise SystemExit(
        f"refresh_input_state markers not found (start={start}, end={end})"
    )
new_block = """    /// Refresh the input state: rebuild preedit only.
    /// No popup while composing (no candidates, no aux). Candidates appear on Space.
    pub(super) fn refresh_input_state(&mut self) -> EngineResult {
        // Alphabet mode with active live conversion but no kana left to convert:
        // preserve the existing conversion display without re-running the model.
        if self.mode.current() == InputMode::Alphabet
            && !self.live.text.is_empty()
            && !karukan_engine::contains_kana(&self.input_buf.text)
        {
            let preedit = self.set_composing_state();
            return EngineResult::consumed()
                .with_action(EngineAction::UpdatePreedit(preedit))
                .with_action(EngineAction::HideCandidates)
                .with_action(EngineAction::HideAuxText);
        }

        // Live conversion: update preedit with converted text, no popup
        let convert = !self.input_buf.text.is_empty()
            && (self.mode.current() != InputMode::Alphabet
                || karukan_engine::contains_kana(&self.input_buf.text));
        if self.live.enabled
            && self.mode.current() != InputMode::Katakana
            && convert
        {
            if let Some(converted) = self.chunked_auto_suggest() {
                self.live.text = converted;
            } else {
                self.live.text.clear();
            }
            let preedit = self.set_composing_state();
            return EngineResult::consumed()
                .with_action(EngineAction::UpdatePreedit(preedit))
                .with_action(EngineAction::HideCandidates)
                .with_action(EngineAction::HideAuxText);
        }

        // Composing: hiragana preedit only (popup appears on Space conversion)
        self.live.text.clear();
        self.chunks.clear();
        let preedit = self.set_composing_state();
        EngineResult::consumed()
            .with_action(EngineAction::UpdatePreedit(preedit))
            .with_action(EngineAction::HideCandidates)
            .with_action(EngineAction::HideAuxText)
    }

    /// Build the auto-suggest result (unused while composing; kept for Space path helpers).
    #[allow(dead_code)]
    fn suggest_result(&mut self, candidates: Vec<String>, reading: &str) -> EngineResult {
        let preedit = self.set_composing_state();
        let mut all_candidates = self.lookup_learning_candidates(reading);
        let model_candidates: Vec<Candidate> = candidates
            .into_iter()
            .map(|s| Candidate::with_reading(s, reading))
            .collect();
        append_candidates_dedup(&mut all_candidates, model_candidates);
        append_candidates_dedup(&mut all_candidates, self.lookup_dict_candidates(reading));
        let aux = self.format_aux_suggest(&self.input_buf.text.clone());
        EngineResult::consumed()
            .with_action(EngineAction::UpdatePreedit(preedit))
            .with_action(EngineAction::ShowCandidates(CandidateList::new(
                all_candidates,
            )))
            .with_action(EngineAction::UpdateAuxText(aux))
    }
"""
content = content[:start] + new_block + content[end:]

# Suppress aux popup on remaining composing paths (start_input / empty seed / esc).
# Replace composing-time UpdateAuxText(format_aux_composing) with HideAuxText.
old_aux = ".with_action(EngineAction::UpdateAuxText(self.format_aux_composing()))"
new_aux = """.with_action(EngineAction::HideCandidates)
            .with_action(EngineAction::HideAuxText)"""
# Only replace occurrences outside suggest_result / conversion (composing helpers).
# format_aux_composing is only used while composing, so global replace is safe.
count = content.count(old_aux)
if count < 1:
    raise SystemExit("no format_aux_composing UpdateAuxText sites found")
content = content.replace(old_aux, new_aux)
# Also the variant with trailing semicolon on its own chain line
old_aux_sc = ".with_action(EngineAction::UpdateAuxText(self.format_aux_composing()));"
new_aux_sc = """.with_action(EngineAction::HideCandidates)
                .with_action(EngineAction::HideAuxText);"""
content = content.replace(old_aux_sc, new_aux_sc)

with open(path, "w") as f:
    f.write(content)
# Note: do not patch karukan.cpp updateUI.
# Upstream only updates the candidate panel when dirty; key-release clears
# dirty without actions. Forcing setCandidateList(nullptr) on !dirty would
# flash-hide candidates right after Space.
PYEOF
  '';

  installPhase = ''
    runHook preInstall

    cd karukan-fcitx5/fcitx5-addon
    cmake -B build \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DCMAKE_BUILD_TYPE=Release \
      -DECM_DIR=${kdePackages.extra-cmake-modules}/share/ECM/cmake
    cmake --build build -j$NIX_BUILD_CORES
    cmake --install build

    runHook postInstall
  '';

  meta = with lib; {
    description = "Neural kana-kanji conversion IME addon for fcitx5";
    homepage = "https://github.com/togatoga/karukan";
    license = with licenses; [ mit asl20 ];
    platforms = platforms.linux;
  };
}
