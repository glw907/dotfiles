package tellscan

// The slop lexicon is split by confidence. A hard entry is so strongly
// associated with machine prose that any occurrence is a violation. A
// soft entry is a judgment word that can be exact in context, so it is
// counted for the assertion layer but never flagged on its own.
// Provisional pending the external-research pass; extend from evidence,
// not vibes.

var hardSlopPatterns = res(
	`(?i)\bdelv(?:e|es|ed|ing)\b`,
	`(?i)\btapestry\b`,
	`(?i)\btestament to\b`,
	`(?i)\bgame[- ]?changer\b`,
	`(?i)\bin today['’]s\b`,
	`(?i)\bfast-paced\b`,
	`(?i)\bever-evolving\b`,
	`(?i)\bcutting[- ]edge\b`,
	`(?i)\bstate-of-the-art\b`,
	`(?i)\brevolutioniz\w*\b`,
	`(?i)\bseamless(?:ly)?\b`,
	`(?i)\beffortless(?:ly)?\b`,
	`(?i)\blook no further\b`,
	`(?i)\bunlock(?:s|ed|ing)? the\b`,
	`(?i)\bunleash\w*\b`,
	`(?i)\belevat(?:e|es|ing) your\b`,
	`(?i)\bsupercharge\w*\b`,
	`(?i)\bplethora\b`,
	`(?i)\bboasts\b`,
	`(?i)\bstands as\b`,
	`(?i)\bplays a (?:vital|crucial|pivotal|key) role\b`,
	`(?i)\bin the world of\b`,
	`(?i)\bin the realm of\b`,
	`(?i)\bat the end of the day\b`,
	`(?i)\ba wealth of\b`,
	`(?i)\bwhether you['’]re a\b`,
	`(?i)\bempower(?:s|ed|ing)?\b`,
)

var softSlopPatterns = res(
	`(?i)\brobust\b`,
	`(?i)\bcomprehensive\b`,
	`(?i)\bcrucial\b`,
	`(?i)\bvital\b`,
	`(?i)\bpivotal\b`,
	`(?i)\bintricate\b`,
	`(?i)\bleverag(?:e|es|ed|ing)\b`,
	`(?i)\bstreamlin(?:e|es|ed|ing)\b`,
	`(?i)\bholistic\b`,
	`(?i)\bshowcas(?:e|es|ed|ing)\b`,
	`(?i)\bunderscor(?:e|es|ed|ing)\b`,
	`(?i)\bfoster(?:s|ed|ing)?\b`,
	`(?i)\bmyriad\b`,
	`(?i)\blandscape\b`,
	`(?i)\bjourney\b`,
	`(?i)\bdeep dive\b`,
	`(?i)\bdive into\b`,
	`(?i)\bat its core\b`,
	`(?i)\bwhen it comes to\b`,
	`(?i)\bkeep in mind\b`,
)
