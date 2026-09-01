package tellscan

import (
	"math"
	"regexp"
	"strings"
)

// flatCadenceCV is the sentence-length coefficient of variation below
// which prose reads as machine-flat. Human technical prose typically
// lands well above 0.4.
const flatCadenceCV = 0.35

var (
	bulletRe     = regexp.MustCompile(`(?m)^\s*[-*+]\s+`)
	boldBulletRe = regexp.MustCompile(`(?m)^\s*[-*+]\s+\*\*[^*\n]+\*\*`)
	fencedCodeRe = regexp.MustCompile("(?ms)^```.*?^```\\s*$")
	inlineCodeRe = regexp.MustCompile("`[^`\n]*`")
	sentenceEnd  = regexp.MustCompile(`[.!?]+(?:\s+|$)`)
	mdDecoration = regexp.MustCompile(`(?m)^\s*(?:#{1,6}\s+|[-*+]\s+|\d+\.\s+)|\*\*|__`)
)

// blankFencedCode replaces the contents of fenced code blocks and inline
// code spans with whitespace, preserving newlines so finding line
// numbers still map to the original input.
func blankFencedCode(s string) string {
	blank := func(m string) string {
		return strings.Map(func(r rune) rune {
			if r == '\n' {
				return '\n'
			}
			return ' '
		}, m)
	}
	s = fencedCodeRe.ReplaceAllStringFunc(s, blank)
	return inlineCodeRe.ReplaceAllStringFunc(s, blank)
}

// splitSentences returns the prose sentences with markdown decoration
// stripped, for cadence statistics.
func splitSentences(s string) []string {
	s = mdDecoration.ReplaceAllString(s, "")
	var out []string
	for para := range strings.SplitSeq(s, "\n\n") {
		flat := strings.Join(strings.Fields(para), " ")
		if flat == "" {
			continue
		}
		for _, sent := range sentenceEnd.Split(flat, -1) {
			if strings.TrimSpace(sent) != "" {
				out = append(out, sent)
			}
		}
	}
	return out
}

func wordCount(s string) int {
	return len(strings.Fields(mdDecoration.ReplaceAllString(s, "")))
}

// boldLeadBullets reports whether the machine list default is present:
// at least three bullets, half or more opening with a bolded lead
// phrase. Returns the line of the first bold bullet.
func boldLeadBullets(s string) (int, bool) {
	bullets := len(bulletRe.FindAllString(s, -1))
	bold := boldBulletRe.FindAllStringIndex(s, -1)
	if bullets < 3 || len(bold)*2 < bullets {
		return 0, false
	}
	return 1 + strings.Count(s[:bold[0][0]], "\n"), true
}

// cadenceCV returns the coefficient of variation of sentence word
// counts, the deterministic proxy for rhythm: identical-length
// sentences score near zero, varied prose scores high.
func cadenceCV(sentences []string) float64 {
	if len(sentences) < 2 {
		return 0
	}
	lengths := make([]float64, len(sentences))
	var sum float64
	for i, s := range sentences {
		lengths[i] = float64(len(strings.Fields(s)))
		sum += lengths[i]
	}
	mean := sum / float64(len(lengths))
	if mean == 0 {
		return 0
	}
	var variance float64
	for _, l := range lengths {
		variance += (l - mean) * (l - mean)
	}
	variance /= float64(len(lengths))
	return math.Sqrt(variance) / mean
}
