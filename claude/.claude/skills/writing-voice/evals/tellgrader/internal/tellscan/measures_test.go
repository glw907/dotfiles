package tellscan

import (
	"encoding/json"
	"os"
	"strings"
	"testing"
)

// TestFixtureBMeasuresShape holds task 1b's acceptance criterion 2: an opted-in docs file
// carries a measures object with the fraction unit, the prose selector, and shares in
// [0,1].
func TestFixtureBMeasuresShape(t *testing.T) {
	path := "testdata/repo/docs/extend/seam.md"
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	r := Scan(string(data), Options{Register: Docs, Path: path})
	if r.Measures == nil {
		t.Fatal("Measures = nil, want present")
	}
	if r.Measures.Unit != "fraction" {
		t.Errorf("Unit = %q, want %q", r.Measures.Unit, "fraction")
	}
	if r.Measures.Selector != "prose" {
		t.Errorf("Selector = %q, want %q", r.Measures.Selector, "prose")
	}
	if r.Measures.HingedPairShare < 0 || r.Measures.HingedPairShare > 1 {
		t.Errorf("HingedPairShare = %v, want in [0,1]", r.Measures.HingedPairShare)
	}
	if r.Measures.ShortSentenceShare < 0 || r.Measures.ShortSentenceShare > 1 {
		t.Errorf("ShortSentenceShare = %v, want in [0,1]", r.Measures.ShortSentenceShare)
	}
}

// TestZeroHingedPairShareIsReported holds task 1b's acceptance criterion 3: a legitimate
// zero share is present in the JSON, not omitted, because Measures is a pointer field
// present or absent as a unit.
func TestZeroHingedPairShareIsReported(t *testing.T) {
	text := "# No hinge here\n\nShort words. Plain sentences. Nothing joins them.\n"
	r := Scan(text, Options{Register: Docs, Path: "whatever.md", Profile: ProfileDocsRegister})
	if r.Measures == nil {
		t.Fatal("Measures = nil, want present")
	}
	if r.Measures.HingedPairShare != 0.0 {
		t.Errorf("HingedPairShare = %v, want 0.0", r.Measures.HingedPairShare)
	}
	out, err := json.Marshal(r)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(out), `"hinged_pair_share":0`) {
		t.Errorf("JSON = %s, want hinged_pair_share present at 0, not omitted", out)
	}
}

// TestHasHingedPairSerialListExclusion holds task 1b's acceptance criterion 4: a serial
// list's final ", and" is not a hinge, while a genuine comma-and pair is.
func TestHasHingedPairSerialListExclusion(t *testing.T) {
	if hasHingedPair("The plan covered a, b, and c.") {
		t.Error("hasHingedPair(serial list) = true, want false: an earlier comma marks a list, not a hinge")
	}
	if !hasHingedPair("It ran, and the gate passed.") {
		t.Error("hasHingedPair(comma-and pair) = false, want true")
	}
}

// TestProseOnlyDropsHeadings holds the conductor ruling that a heading is not a sentence:
// proseOnly must remove a heading line entirely, not leave its text to be flattened into
// an adjacent paragraph.
func TestProseOnlyDropsHeadings(t *testing.T) {
	text := "# A Heading With No Punctuation\n\nActual prose sentence stays.\n"
	sentences := splitSentences(proseOnly(text))
	if len(sentences) != 1 {
		t.Fatalf("sentences = %v, want exactly 1 (the heading must not become a sentence)", sentences)
	}
	if sentences[0] != "Actual prose sentence stays" {
		t.Errorf("sentences[0] = %q, want %q", sentences[0], "Actual prose sentence stays")
	}
}

// TestProseOnlyDropsListContinuations holds the conductor ruling that a list item's
// wrapped continuation lines are dropped along with the marker line: an indented line
// following a marker line, up to a blank line or a non-indented line, never contributes a
// sentence.
func TestProseOnlyDropsListContinuations(t *testing.T) {
	text := "- A list item that wraps\n  onto a continued line with words here.\n\nActual prose sentence stays.\n"
	sentences := splitSentences(proseOnly(text))
	if len(sentences) != 1 {
		t.Fatalf("sentences = %v, want exactly 1 (the list item and its continuation must not become a sentence)", sentences)
	}
	if sentences[0] != "Actual prose sentence stays" {
		t.Errorf("sentences[0] = %q, want %q", sentences[0], "Actual prose sentence stays")
	}
}

func TestIsShortSentence(t *testing.T) {
	if !isShortSentence("Too short.") {
		t.Error("isShortSentence(\"Too short.\") = false, want true")
	}
	if isShortSentence("This sentence has eight words exactly right here.") {
		t.Error("isShortSentence(long sentence) = true, want false")
	}
}
