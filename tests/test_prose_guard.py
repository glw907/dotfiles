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
