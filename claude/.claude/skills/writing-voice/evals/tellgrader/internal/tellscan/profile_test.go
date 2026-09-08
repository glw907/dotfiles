package tellscan

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

// tellgraderBin is the freshly built CLI binary, shared across the tests
// that must exercise the real process: golden exit codes and hook mode
// go through main(), not Scan() directly.
var tellgraderBin string

func TestMain(m *testing.M) {
	dir, err := os.MkdirTemp("", "tellgrader-bin")
	if err != nil {
		fmt.Fprintln(os.Stderr, "tellgrader test setup: mkdir temp:", err)
		os.Exit(1)
	}
	tellgraderBin = filepath.Join(dir, "tellgrader")
	build := exec.Command("go", "build", "-o", tellgraderBin, "./cmd/tellgrader")
	build.Dir = "../.."
	if out, err := build.CombinedOutput(); err != nil {
		fmt.Fprintf(os.Stderr, "tellgrader test setup: build binary: %v\n%s", err, out)
		_ = os.RemoveAll(dir)
		os.Exit(1)
	}

	code := m.Run()
	_ = os.RemoveAll(dir)
	os.Exit(code)
}

// runTellgrader execs the built binary and returns its combined output and
// exit code. An empty stdin leaves the child's stdin unset.
func runTellgrader(t *testing.T, stdin string, args ...string) (string, int) {
	t.Helper()
	cmd := exec.Command(tellgraderBin, args...)
	if stdin != "" {
		cmd.Stdin = strings.NewReader(stdin)
	}
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	err := cmd.Run()
	if err == nil {
		return out.String(), 0
	}
	if exitErr, ok := errors.AsType[*exec.ExitError](err); ok {
		return out.String(), exitErr.ExitCode()
	}
	t.Fatalf("run tellgrader %v: %v", args, err)
	return "", 0
}

// Fixture A: the off-on-site-content proof. testdata/repo declares the
// docs-register schema, but a file outside its include glob never gets
// the profile with no --profile flag.
func TestFixtureASiteContentStaysOff(t *testing.T) {
	path := "testdata/repo/src/content/posts/spring.md"
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	r := Scan(string(data), Options{Register: Docs, Path: path})
	if r.Profile != "" || r.Measures != nil {
		t.Errorf("Profile = %q, Measures = %+v, want both absent for a file outside the include glob", r.Profile, r.Measures)
	}
}

// Fixture B: the on-by-default proof and the exclude proof, both files in
// the same opted-in repo.
func TestFixtureBDocsFileGetsProfile(t *testing.T) {
	path := "testdata/repo/docs/extend/seam.md"
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	r := Scan(string(data), Options{Register: Docs, Path: path})
	if r.Profile != ProfileDocsRegister {
		t.Errorf("Profile = %q, want %q", r.Profile, ProfileDocsRegister)
	}
	if r.Measures == nil {
		t.Fatal("Measures = nil, want present")
	}
}

func TestFixtureBExcludedDocsFileStaysOff(t *testing.T) {
	path := "testdata/repo/docs/internal/note.md"
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	r := Scan(string(data), Options{Register: Docs, Path: path})
	if r.Profile != "" || r.Measures != nil {
		t.Errorf("Profile = %q, Measures = %+v, want both absent for an excluded path", r.Profile, r.Measures)
	}
}

// Fixture C: the opt-in-is-required proof, hermetic. A tree built under
// t.TempDir with no .tellgrader.json at any level, including the stand-in
// home the resolver is told to stop at.
func TestFixtureCNoOptInAnywhereStaysOff(t *testing.T) {
	home := t.TempDir()
	path := filepath.Join(home, "myrepo", "docs", "extend", "seam.md")
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	content := "# Seam\n\nSome prose that would otherwise qualify.\n"
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}

	r := Scan(content, Options{Register: Docs, Path: path, HomeDir: home})
	if r.Profile != "" || r.Measures != nil {
		t.Errorf("Profile = %q, Measures = %+v, want both absent with no .tellgrader.json anywhere up to home", r.Profile, r.Measures)
	}
}

// Fixture D: the force-on escape. --profile docs-register grades a file
// the repo never opted in, on demand.
func TestFixtureDForcedProfileOverridesOptIn(t *testing.T) {
	path := "testdata/repo/src/content/posts/spring.md"
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	r := Scan(string(data), Options{Register: Docs, Path: path, Profile: ProfileDocsRegister})
	if r.Profile != ProfileDocsRegister {
		t.Errorf("Profile = %q, want %q", r.Profile, ProfileDocsRegister)
	}
	if r.Measures == nil {
		t.Fatal("Measures = nil, want present")
	}
}

func TestResolveProfileForcedOffWinsOverOptIn(t *testing.T) {
	got := resolveProfile("testdata/repo/docs/extend/seam.md", "", ProfileNone)
	if got != "" {
		t.Errorf("resolveProfile with forced none = %q, want empty", got)
	}
}

func TestResolveProfileNearestConfigWins(t *testing.T) {
	root := t.TempDir()
	must(t, os.WriteFile(filepath.Join(root, ".tellgrader.json"),
		[]byte(`{"profile":"docs-register","include":["**"]}`), 0o644))

	sub := filepath.Join(root, "nested")
	must(t, os.MkdirAll(sub, 0o755))
	must(t, os.WriteFile(filepath.Join(sub, ".tellgrader.json"),
		[]byte(`{"profile":"docs-register","include":["only-this.md"]}`), 0o644))

	other := filepath.Join(sub, "other.md")
	must(t, os.WriteFile(other, []byte("prose"), 0o644))

	if got := resolveProfile(other, root, ""); got != "" {
		t.Errorf("resolveProfile = %q, want empty: the nested config's include list excludes other.md", got)
	}

	onlyThis := filepath.Join(sub, "only-this.md")
	must(t, os.WriteFile(onlyThis, []byte("prose"), 0o644))
	if got := resolveProfile(onlyThis, root, ""); got != ProfileDocsRegister {
		t.Errorf("resolveProfile = %q, want %q from the nested config", got, ProfileDocsRegister)
	}
}

func TestGlobMatchLeadingDoubleStarMatchesZeroDirectories(t *testing.T) {
	if !globMatch("**/x.md", "x.md") {
		t.Error("globMatch(\"**/x.md\", \"x.md\") = false, want true: a leading **/ matches a root-level file too")
	}
	if !globMatch("**/x.md", "a/b/x.md") {
		t.Error("globMatch(\"**/x.md\", \"a/b/x.md\") = false, want true")
	}
	if globMatch("**/x.md", "x.txt") {
		t.Error("globMatch(\"**/x.md\", \"x.txt\") = true, want false")
	}
}

func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}

// goldenReport mirrors the fields of Report that the profile change must
// leave untouched.
type goldenReport struct {
	Path              string         `json:"path"`
	Register          string         `json:"register"`
	Words             int            `json:"words"`
	Sentences         int            `json:"sentences"`
	CadenceCV         float64        `json:"cadence_cv"`
	Counts            map[string]int `json:"counts"`
	Findings          []Finding      `json:"findings"`
	TellsPer1000Words float64        `json:"tells_per_1000_words"`
}

type goldenScan struct {
	Path     string       `json:"path"`
	ExitCode int          `json:"exit_code"`
	Report   goldenReport `json:"report"`
}

type goldenHookCase struct {
	Input  string `json:"input"`
	Output string `json:"output"`
}

type goldenFile struct {
	Scans map[string]goldenScan     `json:"scans"`
	Hook  map[string]goldenHookCase `json:"hook"`
}

func loadGolden(t *testing.T) goldenFile {
	t.Helper()
	data, err := os.ReadFile("testdata/golden/pre-profile.json")
	if err != nil {
		t.Fatal(err)
	}
	var g goldenFile
	if err := json.Unmarshal(data, &g); err != nil {
		t.Fatal(err)
	}
	return g
}

// TestGoldenRegressionScans holds task 1a's criterion 7: the findings,
// counts, tells-per-1000-words, and exit code captured before the
// profile existed are unchanged now that it does.
func TestGoldenRegressionScans(t *testing.T) {
	g := loadGolden(t)
	for name, sc := range g.Scans {
		t.Run(name, func(t *testing.T) {
			stdout, code := runTellgrader(t, "", "--register", sc.Report.Register, sc.Path)
			if code != sc.ExitCode {
				t.Fatalf("exit code = %d, want %d, output: %s", code, sc.ExitCode, stdout)
			}
			var got Report
			if err := json.Unmarshal([]byte(stdout), &got); err != nil {
				t.Fatalf("parse report: %v\n%s", err, stdout)
			}
			if !reflect.DeepEqual(got.Findings, sc.Report.Findings) {
				t.Errorf("Findings = %+v, want %+v", got.Findings, sc.Report.Findings)
			}
			if !reflect.DeepEqual(got.Counts, sc.Report.Counts) {
				t.Errorf("Counts = %+v, want %+v", got.Counts, sc.Report.Counts)
			}
			if got.TellsPer1000Words != sc.Report.TellsPer1000Words {
				t.Errorf("TellsPer1000Words = %v, want %v", got.TellsPer1000Words, sc.Report.TellsPer1000Words)
			}
			if got.Words != sc.Report.Words || got.Sentences != sc.Report.Sentences {
				t.Errorf("Words/Sentences = %d/%d, want %d/%d", got.Words, got.Sentences, sc.Report.Words, sc.Report.Sentences)
			}
			if got.CadenceCV != sc.Report.CadenceCV {
				t.Errorf("CadenceCV = %v, want %v", got.CadenceCV, sc.Report.CadenceCV)
			}
			if got.Register != sc.Report.Register {
				t.Errorf("Register = %q, want %q", got.Register, sc.Report.Register)
			}
			if got.Path != sc.Report.Path {
				t.Errorf("Path = %q, want %q", got.Path, sc.Report.Path)
			}
		})
	}
}

// TestGoldenRegressionHook holds task 1a's criterion 8: --hook output is
// byte-identical to before, over a fixture inside an opted-in tree.
func TestGoldenRegressionHook(t *testing.T) {
	g := loadGolden(t)
	for name, hc := range g.Hook {
		t.Run(name, func(t *testing.T) {
			stdout, code := runTellgrader(t, hc.Input, "--hook")
			if code != 0 {
				t.Fatalf("exit code = %d, want 0", code)
			}
			if stdout != hc.Output {
				t.Errorf("hook output =\n%q\nwant\n%q", stdout, hc.Output)
			}
		})
	}
}

func TestProfileFlagRejectsUnknownValue(t *testing.T) {
	path := "testdata/repo/src/content/posts/spring.md"
	_, code := runTellgrader(t, "", "--profile", "bogus", path)
	if code == 0 {
		t.Error("exit code = 0 for an unknown --profile value, want non-zero")
	}
}
