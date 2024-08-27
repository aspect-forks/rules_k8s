// Copyright 2016 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
////////////////////////////////////////////////
// This package manipulates v2.2 image configuration metadata.
// It writes out both a config file and a manifest for the v2.2 image.

package resolver

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/pkg/errors"
)

// stampSubstitution is a key value pair used by 'Stamper' to convert values in
// the format "{key}" to "value".
type stampSubstitution struct {
	key   string
	value string
}

// Stamper provides functionality to stamp a given string based on key value
// pairs from a stamp info text file.
// Each stamp info text file can specify key value pairs in the following
// format:
// KEY1 VALUE1
// KEY2 VALUE2
// ...
// This will result in the stamper making the following substitutions in the
// specified order:
// {KEY1} -> VALUE1
// {KEY2} -> VALUE2
// ...
type Stamper struct {
	// subs is a list of substitutions done by the stamper for any given string.
	subs []stampSubstitution
}

// Stamp stamps the given value.
func (s *Stamper) Stamp(val string) string {
	for _, sb := range s.subs {
		val = strings.ReplaceAll(val, sb.key, sb.value)
	}
	return val
}

// uniquify uniquifies the substitutions in the given stamper. If a key appears
// multiple times, the latest entry for the key will be preserved and the
// earlier entries discarded.
func (s *Stamper) uniquify() {
	lookup := make(map[string]bool)
	reverseSubs := []stampSubstitution{}
	// Scan in reverse order rejecting duplicates.
	for i := len(s.subs) - 1; i >= 0; i-- {
		if _, ok := lookup[s.subs[i].key]; ok {
			continue
		}
		lookup[s.subs[i].key] = true
		reverseSubs = append(reverseSubs, s.subs[i])
	}
	s.subs = reverseSubs
	for i, j := 0, len(s.subs)-1; i <= j; i, j = i+1, j-1 {
		s.subs[i], s.subs[j] = s.subs[j], s.subs[i]
	}
}

// loadSubs loads key value substitutions from the reader representing a
// Bazel stamp file.
func (s *Stamper) loadSubs(r io.Reader) error {
	sc := bufio.NewScanner(r)
	for sc.Scan() {
		line := strings.Split(sc.Text(), " ")
		if len(line) < 2 {
			return errors.Errorf("line %q in stamp info file did not split into expected number of tokens, got %d, want >=2", sc.Text(), len(line))
		}
		s.subs = append(s.subs, stampSubstitution{
			key:   fmt.Sprintf("{%s}", line[0]),
			value: strings.Join(line[1:], " "),
		})
	}
	return nil
}

// NewStamper creates a Stamper object initialized to stamp strings with the key
// value pairs in the given stamp info files.
func NewStamper(stampInfoFiles []string) (*Stamper, error) {
	result := new(Stamper)
	for _, s := range stampInfoFiles {
		f, err := os.Open(s)
		if err != nil {
			return nil, errors.Wrapf(err, "unable to open stamp info file %s", s)
		}
		defer f.Close()

		if err := result.loadSubs(f); err != nil {
			return nil, errors.Wrapf(err, "error loading stamp info from %s", s)
		}
	}
	result.uniquify()
	return result, nil
}
