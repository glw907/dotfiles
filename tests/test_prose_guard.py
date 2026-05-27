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
