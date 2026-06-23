"""Tests for the vale-hook PostToolUse prose feedback hook."""
import importlib.machinery
import importlib.util
import io
import json
import pathlib
import shutil

import pytest

TOOL = pathlib.Path(__file__).resolve().parent.parent / "bin" / ".local" / "bin" / "vale-hook"
STYLES = pathlib.Path.home() / ".dotfiles" / "vale" / ".config" / "vale" / "styles"
EM_DASH = "—"


def _load():
    loader = importlib.machinery.SourceFileLoader("vale_hook", str(TOOL))
    spec = importlib.util.spec_from_loader("vale_hook", loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


vh = _load()


def test_changed_span_single_line():
    assert vh.changed_span("a\nWe delve here\nc\n", "We delve here") == {2}


def test_changed_span_multiline():
    assert vh.changed_span("a\nb1\nb2\nd\n", "b1\nb2") == {2, 3}


def test_changed_span_write_scopes_whole_file():
    assert vh.changed_span("a\nb\nc\n", "") == {1, 2, 3, 4}


def test_changed_span_absent_falls_back():
    assert vh.changed_span("a\nb\nc\n", "not here") == {1, 2, 3, 4}


def test_new_text_reads_edit_and_write():
    assert vh.new_text("Edit", {"new_string": "x"}) == "x"
    assert vh.new_text("Write", {"content": "y"}) == "y"


def test_config_root_finds_nearest(tmp_path):
    (tmp_path / ".vale.ini").write_text("StylesPath = x\n")
    sub = tmp_path / "a" / "b"
    sub.mkdir(parents=True)
    assert vh.config_root(str(sub)) == str(tmp_path)


def test_non_markdown_is_skipped(tmp_path, monkeypatch):
    payload = {"tool_name": "Edit",
               "tool_input": {"file_path": str(tmp_path / "x.ts"), "new_string": "x"}}
    monkeypatch.setattr("sys.stdin", io.StringIO(json.dumps(payload)))
    assert vh.main() == 0


def _write_config(tmp_path):
    (tmp_path / ".vale.ini").write_text(
        f"StylesPath = {STYLES}\nMinAlertLevel = suggestion\n[*.md]\nBasedOnStyles = glw907\n"
    )


needs_vale = pytest.mark.skipif(
    shutil.which("vale") is None or not STYLES.exists(),
    reason="vale or the glw907 styles are unavailable",
)


@needs_vale
def test_main_error_tier_exits_2(tmp_path, monkeypatch, capsys):
    _write_config(tmp_path)
    doc = tmp_path / "doc.md"
    doc.write_text(f"Clean opening line.\nA seamless tapestry {EM_DASH} here.\nClean closing line.\n")
    payload = {"tool_name": "Edit", "tool_input": {
        "file_path": str(doc), "new_string": f"A seamless tapestry {EM_DASH} here."}}
    monkeypatch.setattr("sys.stdin", io.StringIO(json.dumps(payload)))
    code = vh.main()
    captured = capsys.readouterr()
    assert code == 2
    assert "seamless" in captured.err


@needs_vale
def test_main_clean_edit_suppresses_pre_existing(tmp_path, monkeypatch, capsys):
    _write_config(tmp_path)
    doc = tmp_path / "doc.md"
    doc.write_text(f"Clean opening line.\nA seamless tapestry {EM_DASH} here.\nClean closing line.\n")
    payload = {"tool_name": "Edit", "tool_input": {
        "file_path": str(doc), "new_string": "Clean opening line."}}
    monkeypatch.setattr("sys.stdin", io.StringIO(json.dumps(payload)))
    code = vh.main()
    captured = capsys.readouterr()
    assert code == 0
    assert captured.out == ""
