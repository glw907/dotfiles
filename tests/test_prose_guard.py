import importlib.machinery
import importlib.util
import io
import json
import pathlib

import pytest

TOOL = pathlib.Path(__file__).resolve().parent.parent / "bin" / ".local" / "bin" / "prose-guard"


def _load():
    loader = importlib.machinery.SourceFileLoader("prose_guard", str(TOOL))
    spec = importlib.util.spec_from_loader("prose_guard", loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


pg = _load()


def _kinds(issues):
    return [k for k, _s, _h in issues]


def _run_hook(monkeypatch, payload):
    monkeypatch.setattr("sys.stdin", io.StringIO(json.dumps(payload)))
    out = io.StringIO()
    monkeypatch.setattr("sys.stdout", out)
    code = pg.main_hook()
    return code, out.getvalue()


def test_module_loads():
    assert hasattr(pg, "classify")


@pytest.mark.parametrize("path,tier", [
    ("ecnordic-ski/src/content/posts/x.md", "general"),
    ("/abs/site/src/content/pages/y.md", "general"),
    ("cairn-cms/docs/PLAN.md", "docs"),
    ("README.md", "docs"),
    ("/home/glw907/.claude/CLAUDE.md", "docs"),
    ("src/lib/cairn/auth.ts", "comments"),
    ("App.svelte", "comments"),
    ("scripts/mint.py", "comments"),
    ("photo.png", None),
    ("data.json", None),
])
def test_classify(path, tier):
    assert pg.classify(path) == tier


def test_scannable_skips_frontmatter_fence_placeholder():
    text = (
        "---\ntitle: robust thing\n---\n"
        "real prose line\n"
        "```\nfenced robust code\n```\n"
        "PLACEHOLDER: ignore me\n"
        "second prose line\n"
    )
    lines = list(pg._scannable_lines(text))
    assert "real prose line" in lines and "second prose line" in lines
    assert all("robust" not in ln for ln in lines)
    assert all("PLACEHOLDER" not in ln for ln in lines)


# lexical

def test_em_dash_any_in_technical_tiers():
    # docs + comments: humans rarely use em dashes in technical writing, so any one is a tell
    assert any("em dash" in k for k in _kinds(pg.scan("We tap the button — it then saves.", "comments")))
    assert any("em dash" in k for k in _kinds(pg.scan("The cache warms the path — then serves it fast and reliably.", "docs")))
    assert any("em dash" in k for k in _kinds(pg.scan("The camp — four days long — is the highlight.", "docs")))


def test_em_dash_appendage_general():
    # general/marketing keeps the appendage nuance
    assert any("appendage" in k for k in _kinds(pg.scan("We tap the button — it then saves.", "general")))


def test_em_dash_pair_ok_general():
    # a balanced pair in marketing prose is allowed
    assert not any("em-dash" in k for k in _kinds(pg.scan("The camp — four days long — is the week's highlight.", "general")))


def test_en_dash_ok():
    assert pg.scan("Open 9–17 on weekdays.", "docs") == []


def test_phrase_all_tiers():
    for t in ("general", "docs", "comments"):
        assert any("dive into" in k for k in _kinds(pg.scan("Let us dive into the code.", t)))


def test_opener():
    assert any("moreover" in k for k in _kinds(pg.scan("Moreover, the cache helps.", "docs")))


def test_filler_words_all_tiers():
    for t in ("general", "docs", "comments"):
        assert any("genuinely" in k for k in _kinds(pg.scan("This is genuinely fast.", t)))
        assert any("honestly" in k for k in _kinds(pg.scan("Honestly, it works.", t)))


def test_filler_word_boundary():
    assert pg.scan("The dishonestly named flag.", "docs") == []


def test_word_tiering_judgment():
    assert any("robust" in k for k in _kinds(pg.scan("a robust system", "general")))
    assert not any("robust" in k for k in _kinds(pg.scan("a robust system", "docs")))
    assert not any("robust" in k for k in _kinds(pg.scan("a robust system", "comments")))


def test_word_tiering_slop():
    assert any("tapestry" in k for k in _kinds(pg.scan("a rich tapestry", "docs")))
    assert not any("tapestry" in k for k in _kinds(pg.scan("a rich tapestry", "comments")))


# structural (every tier; high precision)

def test_negative_antithesis():
    assert any("antithesis" in k for k in _kinds(pg.scan("It's not a bug, it's a feature.", "comments")))


def test_not_just_but():
    assert any("not just" in k for k in _kinds(pg.scan("This is not just fast but also safe.", "docs")))


def test_setup_colon_payoff():
    assert any("setup-colon" in k for k in _kinds(pg.scan("The takeaway: ship it.", "docs")))


def test_setup_colon_negative():
    # a normal definitional colon must NOT fire (hollow-noun list only)
    assert not any("setup-colon" in k for k in _kinds(pg.scan("The config: a JSON file.", "docs")))


def test_serves_as():
    assert any("copula" in k for k in _kinds(pg.scan("The cache serves as a buffer.", "docs")))


def test_participial_windup():
    assert any("wind-up" in k for k in _kinds(pg.scan("Building on this, the system scales.", "docs")))


def test_bold_header_bullet():
    assert any("bold-header" in k for k in _kinds(pg.scan("- **Performance**: it is fast", "docs")))


def test_bold_header_bullet_capital_pronoun():
    assert any("bold-header" in k for k in _kinds(pg.scan("- **Speed**: It scales well.", "docs")))


def test_bold_header_bullet_skips_definition_list():
    # terse key-value reference bullets are legitimate, not the AI listicle tell
    for line in ("- **OS**: Linux Mint 22.3",
                 "- **Shell**: bash",
                 "- **Packages**: apt for system tools",
                 "- **Destructive ops**: Show a dry-run first"):
        assert not any("bold-header" in k for k in _kinds(pg.scan(line, "docs")))


# analyze_document

def test_burstiness_flags_flat_prose():
    # 13 sentences (>=150 words), all near-identical length -> low burstiness
    flat = " ".join(["The system reads the file and writes the result to disk now."] * 13)
    kinds = [k for k, _s, _h in pg.analyze_document(flat, "docs")]
    assert any("burstiness" in k for k in kinds)


def test_burstiness_ok_for_varied_prose():
    varied = ("Stop. "
              "The cache warms on the first request and stays warm for the rest of a long session that touches many files. "
              "It helps. "
              "When a write misses, the loader falls back to the slow path, reads from origin, and repopulates every layer it can. "
              "Fast again.")
    kinds = [k for k, _s, _h in pg.analyze_document(varied, "docs")]
    assert not any("burstiness" in k for k in kinds)


def test_anaphora_flagged():
    text = "We ship fast. We test first. We never guess."
    kinds = [k for k, _s, _h in pg.analyze_document(text, "docs")]
    assert any("anaphora" in k for k in kinds)


def test_anaphora_ignores_bullet_lists():
    text = "- first item here.\n- second item here.\n- third item here.\n- fourth item here."
    kinds = [k for k, _s, _h in pg.analyze_document(text, "docs")]
    assert not any("anaphora" in k for k in kinds)


def test_stats_skipped_for_comments_tier():
    flat = " ".join(["The system reads the file and writes the result now."] * 12)
    assert pg.analyze_document(flat, "comments") == []


# extract_comments

def test_extract_ts_comment_vs_string():
    src = ('// it\'s worth noting this loop is slow\n'
           'const url = "https://example.com/dive-into";  // delve here\n'
           'const robust = 1;\n')
    c = pg.extract_comments("x.ts", src)
    assert "it's worth noting" in c and "delve here" in c
    assert "https://example.com" not in c and "const robust" not in c


def test_extract_python():
    c = pg.extract_comments("y.py", '# moreover this matters\nx = "moreover not this"\n')
    assert "moreover this matters" in c and "not this" not in c


def test_extract_svelte_fallback():
    c = pg.extract_comments("App.svelte", "<!-- it's worth noting the layout -->\n<div>plain</div>\n")
    assert "it's worth noting" in c


def test_extract_unknown_graceful():
    assert pg.extract_comments("weird.xyz", "delve in") == ""


# hook

def test_hook_denies_doc_with_tell(monkeypatch):
    code, out = _run_hook(monkeypatch, {"tool_name": "Write",
        "tool_input": {"file_path": "docs/X.md", "content": "Moreover, this matters."}})
    assert code == 0
    payload = json.loads(out)
    assert payload["hookSpecificOutput"]["permissionDecision"] == "deny"
    assert "opener" in payload["hookSpecificOutput"]["permissionDecisionReason"]


def test_hook_allows_clean_doc(monkeypatch):
    code, out = _run_hook(monkeypatch, {"tool_name": "Write",
        "tool_input": {"file_path": "docs/X.md", "content": "This matters because the cache is warm."}})
    assert code == 0 and out.strip() == ""


def test_hook_comments_tier_ts(monkeypatch):
    code, out = _run_hook(monkeypatch, {"tool_name": "Edit",
        "tool_input": {"file_path": "a.ts", "new_string": "// let's dive into this\nconst x=1;"}})
    assert json.loads(out)["hookSpecificOutput"]["permissionDecision"] == "deny"


def test_hook_skips_unknown_path(monkeypatch):
    code, out = _run_hook(monkeypatch, {"tool_name": "Write",
        "tool_input": {"file_path": "img.png", "content": "delve delve delve"}})
    assert code == 0 and out.strip() == ""


def test_hook_multiedit(monkeypatch):
    code, out = _run_hook(monkeypatch, {"tool_name": "MultiEdit",
        "tool_input": {"file_path": "d.md", "edits": [{"new_string": "fine line"}, {"new_string": "Furthermore, no."}]}})
    assert "furthermore" in out.lower()


# sweep

def test_sweep_reports_nonzero(tmp_path, capsys):
    f = tmp_path / "doc.md"
    f.write_text("Moreover, this is a tell.\n")
    assert pg.main_sweep([str(f)]) == 1
    assert "banned opener" in capsys.readouterr().out


def test_sweep_clean_zero(tmp_path):
    f = tmp_path / "doc.md"
    f.write_text("This sentence is clean and direct.\n")
    assert pg.main_sweep([str(f)]) == 0


def test_sweep_runs_stats(tmp_path, capsys):
    f = tmp_path / "flat.md"
    f.write_text(" ".join(["The system reads the file and writes the result to disk now."] * 13) + "\n")
    assert pg.main_sweep([str(f)]) == 1
    assert "burstiness" in capsys.readouterr().out


def test_sweep_skips_unreadable(tmp_path):
    assert pg.main_sweep([str(tmp_path / "nope.md")]) == 0


def test_sweep_all_skips_vendor(tmp_path, monkeypatch, capsys):
    (tmp_path / "node_modules").mkdir()
    (tmp_path / "node_modules" / "x.md").write_text("Moreover bad.\n")
    (tmp_path / "keep.md").write_text("Furthermore bad.\n")
    monkeypatch.chdir(tmp_path)
    assert pg.main_sweep(["--all"]) == 1
    out = capsys.readouterr().out
    assert "keep.md" in out and "node_modules" not in out


# code-fence and inline-code precision

def test_tilde_fence_skipped():
    text = "prose line\n~~~js\nconst y = \"x — delve\";\n~~~\nmore prose\n"
    assert pg.scan(text, "docs") == []


def test_indented_code_block_skipped():
    text = "A code sample:\n\n    const x = a—b;\n\nback to prose\n"
    lines = list(pg._scannable_lines(text))
    assert all("const x" not in ln for ln in lines)
    assert pg.scan(text, "docs") == []


def test_inline_code_stripped():
    # an em dash and a banned word inside an inline span must not flag
    assert pg.scan("Run `npm build — watch` to start.", "docs") == []
    assert pg.scan("The `delve` helper is internal.", "docs") == []


# new blocking lexical rules

def test_marketing_word_blocks_all_tiers():
    for t in ("general", "docs", "comments"):
        assert any("streamline" in k for k in _kinds(pg.scan("We streamline the loop.", t)))


def test_marketing_word_inflections():
    assert any("effortless" in k for k in _kinds(pg.scan("an effortlessly fast setup", "docs")))


def test_honest_throat_clearing_phrase():
    assert any("to be honest" in k for k in _kinds(pg.scan("To be honest, it works.", "docs")))
    assert any("realm of" in k for k in _kinds(pg.scan("In the realm of CMSes.", "docs")))


# advisory layer is never blocking

def test_advisory_passive_phrase_not_in_scan():
    # the blocking layer (what the hook runs) ignores passive phrasing
    assert pg.scan("This lets the plugin: it allows you to publish.", "docs") == []


def test_advisory_passive_phrase_flagged_in_sweep():
    assert any("allows you to" in k for k in _kinds(pg.scan_advisory("It allows you to publish.", "docs")))


def test_advisory_passive_named_agent():
    assert any("named agent" in k for k in _kinds(pg.scan_advisory("The file is verified by the build.", "docs")))
    assert pg.scan_advisory("The build verifies the file.", "docs") == []


def test_advisory_tricolon_lowercase_only():
    assert any("tricolon" in k for k in _kinds(pg.scan_advisory("It is fast, lean, and maintainable.", "docs")))
    # capitalized entity lists are legitimate, not the rhetorical tricolon
    assert not any("tricolon" in k for k in _kinds(pg.scan_advisory("Posts, Pages, and Fragments.", "docs")))


def test_advisory_emoji():
    assert any("emoji" in k for k in _kinds(pg.scan_advisory("Ship it 🚀", "docs")))
    assert not any("emoji" in k for k in _kinds(pg.scan_advisory("A flows to B then C.", "docs")))


def test_advisory_opener_not_blocking():
    assert pg.scan("Importantly, the cache is warm.", "docs") == []
    assert any("importantly" in k for k in _kinds(pg.scan_advisory("Importantly, the cache is warm.", "docs")))


def test_advisory_comments_tier_only_spaced_hyphen():
    issues = pg.scan_advisory("// it allows you to win - a lot 🚀", "comments")
    kinds = _kinds(issues)
    assert any("spaced-hyphen" in k for k in kinds)
    assert not any("allows you to" in k for k in kinds)
    assert not any("emoji" in k for k in kinds)


def test_hook_allows_advisory_only_doc(monkeypatch):
    # a doc whose only issues are advisory must NOT be blocked at write time
    code, out = _run_hook(monkeypatch, {"tool_name": "Write",
        "tool_input": {"file_path": "docs/X.md", "content": "It allows you to publish posts."}})
    assert code == 0 and out.strip() == ""


# web-content lexicon expansion (2026-06-06)
NEW_BLOCKING = ["embark", "harness", "bolster", "groundbreaking",
                "cutting-edge", "innovative", "foundational"]
NEW_ADVISORY = ["vital", "crucial", "essential", "dynamic", "journey", "passion"]


@pytest.mark.parametrize("word", NEW_BLOCKING)
def test_new_blocking_words_block_in_general(word):
    issues = pg.scan(f"We {word} the season together.", "general")
    assert f"banned word: {word}" in _kinds(issues)


@pytest.mark.parametrize("word", NEW_BLOCKING)
def test_new_blocking_words_skip_docs_tier(word):
    issues = pg.scan(f"We {word} the season together.", "docs")
    assert f"banned word: {word}" not in _kinds(issues)


@pytest.mark.parametrize("word", NEW_ADVISORY)
def test_new_advisory_words_do_not_block(word):
    issues = pg.scan(f"This is a {word} part of training.", "general")
    assert not any(k.startswith("banned word") for k in _kinds(issues))


@pytest.mark.parametrize("word", NEW_ADVISORY)
def test_new_advisory_words_surface_in_sweep(word):
    issues = pg.scan_advisory(f"This is a {word} part of training.", "general")
    assert any(word in k for k in _kinds(issues))
