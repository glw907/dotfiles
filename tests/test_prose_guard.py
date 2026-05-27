import importlib.machinery, importlib.util, pathlib

TOOL = pathlib.Path(__file__).resolve().parent.parent / "bin" / ".local" / "bin" / "prose-guard"


def _load():
    loader = importlib.machinery.SourceFileLoader("prose_guard", str(TOOL))
    spec = importlib.util.spec_from_loader("prose_guard", loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


pg = _load()


def test_module_loads():
    assert hasattr(pg, "classify")


import pytest


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


def _kinds(issues):
    return [k for k, _s, _h in issues]

# lexical
def test_em_dash_appendage():
    assert any("appendage" in k for k in _kinds(pg.scan("We tap the button — it then saves.", "comments")))
def test_em_dash_pair_ok():
    assert not any("appendage" in k or "spray" in k for k in _kinds(pg.scan("The camp — four days long — is the week's highlight.", "docs")))
def test_en_dash_ok():
    assert pg.scan("Open 9–17 on weekdays.", "docs") == []
def test_phrase_all_tiers():
    for t in ("general","docs","comments"):
        assert any("dive into" in k for k in _kinds(pg.scan("Let us dive into the code.", t)))
def test_opener():
    assert any("moreover" in k for k in _kinds(pg.scan("Moreover, the cache helps.", "docs")))
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
