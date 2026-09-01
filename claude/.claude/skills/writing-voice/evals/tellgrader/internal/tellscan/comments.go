package tellscan

import (
	"regexp"
	"slices"
)

var blockDecoration = regexp.MustCompile(`(?m)^(\s*)\*+ ?`)

// extractComments returns src with everything except comment text
// blanked to spaces, newlines preserved, so tell checks grade only the
// prose a code file carries. The extract argument is extractSlash or
// extractHash, chosen by the file's language.
func extractComments(src string, extract func(string) string) string {
	return blockDecoration.ReplaceAllString(extract(src), "$1  ")
}

// extractSlash blanks everything outside // and /* */ comments. String
// literals are tracked so a URL inside one is not mistaken for a comment.
func extractSlash(src string) string {
	const (
		code = iota
		lineComment
		blockComment
		str
	)
	runes := []rune(src)
	out := slices.Clone(runes)
	state := code
	var quote rune
	for i := 0; i < len(runes); i++ {
		r := runes[i]
		// The cases below advance i past the second rune of a two-rune
		// delimiter, so idx keeps the index this pass examined.
		idx := i
		keep := false
		switch state {
		case code:
			switch {
			case r == '"' || r == '\'' || r == '`':
				state, quote = str, r
			case r == '/' && i+1 < len(runes) && runes[i+1] == '/':
				state = lineComment
				out[i+1] = ' '
				i++
			case r == '/' && i+1 < len(runes) && runes[i+1] == '*':
				state = blockComment
				out[i+1] = ' '
				i++
			}
		case str:
			switch r {
			case '\\':
				i++
			case quote:
				state = code
			}
		case lineComment:
			if r == '\n' {
				state = code
			}
			keep = true
		case blockComment:
			if r == '*' && i+1 < len(runes) && runes[i+1] == '/' {
				state = code
				out[i+1] = ' '
				i++
			} else {
				keep = true
			}
		}
		if !keep && out[idx] != '\n' {
			out[idx] = ' '
		}
	}
	return string(out)
}

// extractHash blanks everything outside # comments and triple-quoted
// strings, which count as docstrings.
func extractHash(src string) string {
	const (
		code = iota
		lineComment
		triple
		str
	)
	runes := []rune(src)
	out := slices.Clone(runes)
	state := code
	var quote rune
	tripleAt := func(i int) bool {
		return i+2 < len(runes) && runes[i+1] == runes[i] && runes[i+2] == runes[i]
	}
	for i := 0; i < len(runes); i++ {
		r := runes[i]
		idx := i
		keep := false
		switch state {
		case code:
			switch {
			case r == '#':
				state = lineComment
			case (r == '"' || r == '\'') && tripleAt(i):
				state, quote = triple, r
				out[i+1], out[i+2] = ' ', ' '
				i += 2
			case r == '"' || r == '\'':
				state, quote = str, r
			}
		case str:
			switch r {
			case '\\':
				i++
			case quote, '\n':
				state = code
			}
		case lineComment:
			if r == '\n' {
				state = code
			}
			keep = true
		case triple:
			if r == quote && tripleAt(i) {
				state = code
				out[i+1], out[i+2] = ' ', ' '
				i += 2
			} else {
				keep = true
			}
		}
		if !keep && out[idx] != '\n' {
			out[idx] = ' '
		}
	}
	return string(out)
}
