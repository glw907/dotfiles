package tellscan

import "regexp"

type match struct {
	start, end int
}

// A check pairs a name with the patterns that detect it and the rule for
// when a hit is a violation rather than a neutral count. A nil violates
// func means the hit violates every register.
type check struct {
	name     string
	patterns []*regexp.Regexp
	violates func(Register) bool
}

func (c *check) find(s string) []match {
	var out []match
	for _, re := range c.patterns {
		for _, idx := range re.FindAllStringIndex(s, -1) {
			out = append(out, match{start: idx[0], end: idx[1]})
		}
	}
	return out
}

func res(exprs ...string) []*regexp.Regexp {
	out := make([]*regexp.Regexp, len(exprs))
	for i, e := range exprs {
		out[i] = regexp.MustCompile(e)
	}
	return out
}

var checks = []check{
	{
		name:     "em-dash",
		patterns: res(`\x{2014}`),
		violates: func(r Register) bool { return r.emDashBanned() },
	},
	{
		// Google recommends the em dash with no surrounding spaces, so a
		// spaced em dash is a violation even where the character is allowed.
		name:     "em-dash-spaced",
		patterns: res(`\s\x{2014}\s`),
		violates: func(r Register) bool { return !r.emDashBanned() },
	},
	{
		name: "contrast-frame",
		patterns: res(
			`(?i)\b(?:is|are|was|were)n['’]t (?:just |only |merely |simply |about )[^.!?\n]{1,50}?[,;]\s*(?:it['’]s|they['’]re|but|rather)`,
			`(?i)\bit['’]s not (?:just |only |merely |simply |about )?[^.!?\n]{1,50}?[,;]\s*(?:it['’]s|but)`,
			`(?i)\bnot only\b[^.!?\n]{1,80}?\bbut(?: also)?\b`,
			`(?i)\bless about\b[^.!?\n]{1,50}?\bmore about\b`,
			`(?i)\bnot (?:just|merely|simply) [^.!?\n]{1,50}?\bbut\b`,
		),
	},
	{
		name: "connector-opener",
		patterns: res(
			`(?m)(?:^[ \t]*|[.!?]\s+)(?:Moreover|Furthermore|Additionally|In addition|Notably|Importantly|Crucially|In essence|Essentially|Ultimately|In conclusion|In summary|Overall),?\s`,
			`(?m)(?:^[ \t]*|[.!?]\s+)(?:Building on|Leveraging|Harnessing|Drawing on|Diving into)\b`,
		),
	},
	{
		name: "setup-colon",
		patterns: res(
			`(?m)^(?:The (?:point|result|goal|key|upshot|answer|takeaway|catch)|Bottom line|The best part|Here['’]s the (?:thing|catch|kicker))\s*:`,
			`\bThe (?:result|best part|catch|kicker)\?`,
		),
	},
	{
		name: "hedging-filler",
		patterns: res(
			`(?i)\bit(?:['’]s| is) (?:important|worth) (?:to note|noting)\b`,
			`(?i)\bit should be noted\b`,
			`(?i)\bneedless to say\b`,
		),
	},
	{
		name:     "scaffold-header",
		patterns: res(`(?mi)^#{1,6}\s*(?:Overview|Introduction|Conclusion|Summary|Final Thoughts)\s*$`),
	},
	{
		name:     "slop-hard",
		patterns: hardSlopPatterns,
	},
	{
		name:     "slop-soft",
		patterns: softSlopPatterns,
		violates: func(Register) bool { return false },
	},
	{
		name:     "tricolon",
		patterns: res(`\b[\w'’]+, [\w'’]+, and [\w'’]+\b`),
		violates: func(Register) bool { return false },
	},
	{
		name:     "exclamation",
		patterns: res(`!`),
		violates: func(Register) bool { return false },
	},
}
