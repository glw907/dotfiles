package tellscan

import (
	"regexp"
	"strings"
)

// numberedListRe matches a numbered list item's leading marker, the numeric counterpart to
// bulletRe.
var numberedListRe = regexp.MustCompile(`(?m)^\s*\d+\.\s+`)

// headingRe matches a heading line's leading marker, recognizing a heading the same way
// mdDecoration recognizes one for CadenceCV's own splitter.
var headingRe = regexp.MustCompile(`(?m)^\s*#{1,6}\s+`)

// continuationRe matches an indented, non-blank line: a list item's wrapped continuation.
var continuationRe = regexp.MustCompile(`^[ \t]+\S`)

// hingeCoordinatorRe matches a comma followed by a coordinating conjunction, half of the
// hinged-pair rule. Whether it counts as a hinge depends on whether an earlier comma
// already opened a serial list; see hasHingedPair.
var hingeCoordinatorRe = regexp.MustCompile(`,\s+(?:and|but|or|so|yet|nor|for)\b`)

// relativeClauseRe matches a relative pronoun introducing a clause. Two or more in one
// sentence is the hinged-pair rule's "chain of relative clauses".
var relativeClauseRe = regexp.MustCompile(`\b(?:which|who)\b`)

// spacedDashRe matches a hyphen or an em/en dash surrounded by spaces, the hinged-pair
// rule's "spaced dash".
var spacedDashRe = regexp.MustCompile(`\s[-\x{2013}\x{2014}]\s`)

// shortSentenceWords is the word count under which a sentence counts as short.
const shortSentenceWords = 8

// proseOnly blanks heading lines and list items, keeping newlines so line numbers still
// map to the input. The docs-register measures grade prose paragraphs only: a heading is
// not a sentence, and a list item's text (including any wrapped continuation lines) is not
// prose. A heading line is recognized by headingRe, a list item's marker line by bulletRe
// or numberedListRe (the same recognition the scanner's other checks use), and a
// continuation line by continuationRe: an indented, non-blank line following a marker line,
// up to a blank line or a non-indented line. See MEASURES.md for the selector this
// implements.
func proseOnly(s string) string {
	lines := strings.Split(s, "\n")
	inListItem := false
	for i, line := range lines {
		switch {
		case headingRe.MatchString(line):
			lines[i] = strings.Repeat(" ", len(line))
			inListItem = false
		case bulletRe.MatchString(line) || numberedListRe.MatchString(line):
			lines[i] = strings.Repeat(" ", len(line))
			inListItem = true
		case inListItem && continuationRe.MatchString(line):
			lines[i] = strings.Repeat(" ", len(line))
		default:
			inListItem = false
		}
	}
	return strings.Join(lines, "\n")
}

// hasHingedPair reports whether sentence joins two clauses by a comma plus a coordinator,
// a colon, a semicolon, a spaced dash, or a chain of relative clauses. A comma-coordinator
// match does not count when an earlier comma already appears in sentence: "a, b, and c"
// closes a serial list, not a hinge, while "it ran, and the gate passed" has none, so its
// comma-and pairs two clauses. See MEASURES.md.
func hasHingedPair(sentence string) bool {
	if loc := hingeCoordinatorRe.FindStringIndex(sentence); loc != nil {
		if !strings.Contains(sentence[:loc[0]], ",") {
			return true
		}
	}
	if strings.ContainsAny(sentence, ":;") {
		return true
	}
	if spacedDashRe.MatchString(sentence) {
		return true
	}
	return len(relativeClauseRe.FindAllString(sentence, -1)) >= 2
}

// isShortSentence reports whether sentence falls under the short-sentence rule's
// eight-word bound.
func isShortSentence(sentence string) bool {
	return len(strings.Fields(sentence)) < shortSentenceWords
}

// measureShares computes the docs-register measures over prose's sentences: the
// hinged-pair share and the short-sentence share, both fractions in [0,1]. It reuses
// splitSentences, CadenceCV's own splitter, over the prose-only selector; the denominator
// is the resulting prose-only sentence count, which equals CadenceCV's own denominator
// only on a document with no headings or list items. See MEASURES.md for the full
// definition.
func measureShares(prose string) (sentences []string, hingedShare, shortShare float64) {
	sentences = splitSentences(proseOnly(prose))
	if len(sentences) == 0 {
		return sentences, 0, 0
	}
	var hinged, short int
	for _, s := range sentences {
		if hasHingedPair(s) {
			hinged++
		}
		if isShortSentence(s) {
			short++
		}
	}
	total := float64(len(sentences))
	return sentences, float64(hinged) / total, float64(short) / total
}
