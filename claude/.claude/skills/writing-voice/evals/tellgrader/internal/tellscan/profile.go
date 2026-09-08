package tellscan

import (
	"encoding/json"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

const (
	// ProfileDocsRegister is the docs-register profile name: the value a repo writes into
	// its .tellgrader.json and the value --profile accepts to force it on.
	ProfileDocsRegister = "docs-register"
	// ProfileNone forces the docs-register profile off regardless of any repo opt-in.
	ProfileNone = "none"
)

// tellgraderConfig is a repo's .tellgrader.json: the profile it wants, and which of its
// own files that profile covers.
type tellgraderConfig struct {
	Profile string   `json:"profile"`
	Include []string `json:"include"`
	Exclude []string `json:"exclude"`
}

// resolveProfile decides whether path gets the docs-register profile. forced, the raw
// --profile flag value, wins outright: ProfileDocsRegister turns it on, ProfileNone turns
// it off, and the empty string falls through to the repo's own opt-in.
//
// The opt-in walk starts at path's directory and climbs for the nearest .tellgrader.json,
// stopping at home (a session's real home directory in production, and a hermetic stand-in
// a test controls) or the filesystem root, whichever comes first. The nearest file wins
// outright; a .tellgrader.json further up the tree is never consulted once one is found.
// ~/.claude is a symlink into this dotfiles repo, so a file edited through it resolves
// home first and never walks into ~/.dotfiles; a .tellgrader.json committed here does not
// govern files edited that way.
//
// The profile applies only when the discovered config names docs-register and path,
// taken relative to the config's own directory, matches an include glob and no exclude
// glob.
func resolveProfile(path, home, forced string) string {
	switch forced {
	case ProfileDocsRegister:
		return ProfileDocsRegister
	case ProfileNone:
		return ""
	}

	absPath, err := filepath.Abs(path)
	if err != nil {
		return ""
	}
	absHome := home
	if home != "" {
		if h, err := filepath.Abs(home); err == nil {
			absHome = h
		}
	}

	root, cfg, ok := findConfig(filepath.Dir(absPath), absHome)
	if !ok || cfg.Profile != ProfileDocsRegister {
		return ""
	}

	rel, err := filepath.Rel(root, absPath)
	if err != nil {
		return ""
	}
	rel = filepath.ToSlash(rel)
	if !matchAny(rel, cfg.Include) || matchAny(rel, cfg.Exclude) {
		return ""
	}
	return ProfileDocsRegister
}

// findConfig walks upward from dir for the nearest .tellgrader.json, stopping at stopAt
// (inclusive) or the filesystem root. It returns the directory the config was found in, so
// callers can resolve a scanned path relative to that repo's declared root.
//
// A malformed .tellgrader.json fails off: findConfig reports no config found rather than
// an error, so a broken opt-in file silently leaves every scan in that tree at today's
// behavior instead of blocking it.
func findConfig(dir, stopAt string) (root string, cfg *tellgraderConfig, ok bool) {
	current := dir
	for {
		data, err := os.ReadFile(filepath.Join(current, ".tellgrader.json"))
		if err == nil {
			var c tellgraderConfig
			if json.Unmarshal(data, &c) != nil {
				return "", nil, false
			}
			return current, &c, true
		}
		if current == stopAt {
			return "", nil, false
		}
		parent := filepath.Dir(current)
		if parent == current {
			return "", nil, false
		}
		current = parent
	}
}

// matchAny reports whether rel matches any of the glob patterns.
func matchAny(rel string, patterns []string) bool {
	for _, p := range patterns {
		if globMatch(p, rel) {
			return true
		}
	}
	return false
}

// globMatch reports whether name matches pattern, a doublestar glob: "**" matches any
// sequence including "/", "*" matches within one path segment, and "?" matches one
// non-separator character. A leading or medial "**/" also matches zero directories, the
// doublestar convention that lets "**/x.md" match a root-level x.md. This is the glob
// convention `.tellgrader.json`'s include and exclude lists use.
func globMatch(pattern, name string) bool {
	re, err := globRegexp(pattern)
	if err != nil {
		return false
	}
	return re.MatchString(name)
}

func globRegexp(pattern string) (*regexp.Regexp, error) {
	var b strings.Builder
	b.WriteByte('^')
	for i := 0; i < len(pattern); i++ {
		switch c := pattern[i]; {
		case c == '*' && i+2 < len(pattern) && pattern[i+1] == '*' && pattern[i+2] == '/':
			b.WriteString("(?:.*/)?")
			i += 2
		case c == '*' && i+1 < len(pattern) && pattern[i+1] == '*':
			b.WriteString(".*")
			i++
		case c == '*':
			b.WriteString("[^/]*")
		case c == '?':
			b.WriteString("[^/]")
		default:
			b.WriteString(regexp.QuoteMeta(string(c)))
		}
	}
	b.WriteByte('$')
	return regexp.Compile(b.String())
}
