package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/Masterminds/semver/v3"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
	"github.com/hashicorp/hcl/v2/hclwrite"
	"github.com/zclconf/go-cty/cty"
)

const releasesURL = "https://api.github.com/repos/k3s-io/k3s/releases"

type release struct {
	TagName string `json:"tag_name"`
}

func latestStable() (*semver.Version, error) {
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Get(releasesURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("%s: %s: %s", releasesURL, resp.Status, body)
	}
	var releases []release
	if err := json.NewDecoder(resp.Body).Decode(&releases); err != nil {
		return nil, err
	}
	var best *semver.Version
	for _, r := range releases {
		v, err := semver.NewVersion(r.TagName)
		if err != nil {
			continue
		}
		if v.Prerelease() != "" {
			continue
		}
		if best == nil || v.GreaterThan(best) {
			best = v
		}
	}
	if best == nil {
		return nil, errors.New("no stable releases found")
	}
	return best, nil
}

func k3sVersionBlock(body *hclwrite.Body) (*hclwrite.Block, *semver.Version, error) {
	for _, b := range body.Blocks() {
		if b.Type() != "variable" || len(b.Labels()) != 1 || b.Labels()[0] != "k3s_version" {
			continue
		}
		attr := b.Body().GetAttribute("default")
		if attr == nil {
			return nil, nil, errors.New("k3s_version block has no default attribute")
		}
		for _, t := range attr.Expr().BuildTokens(nil) {
			if t.Type == hclsyntax.TokenQuotedLit {
				v, err := semver.NewVersion(string(t.Bytes))
				if err != nil {
					return nil, nil, fmt.Errorf("parse current version %q: %w", t.Bytes, err)
				}
				return b, v, nil
			}
		}
		return nil, nil, errors.New("k3s_version default has no string literal")
	}
	return nil, nil, errors.New("k3s_version variable not found")
}

func tagWithV(v *semver.Version) string {
	s := v.Original()
	if !strings.HasPrefix(s, "v") {
		s = "v" + s
	}
	return s
}

func run() error {
	if len(os.Args) != 2 {
		return fmt.Errorf("usage: %s <path/to/variables.tf>", os.Args[0])
	}
	tfPath := os.Args[1]

	latest, err := latestStable()
	if err != nil {
		return err
	}
	fmt.Printf("Latest: %s\n", tagWithV(latest))

	src, err := os.ReadFile(tfPath)
	if err != nil {
		return err
	}
	f, diags := hclwrite.ParseConfig(src, tfPath, hcl.Pos{Line: 1, Column: 1})
	if diags.HasErrors() {
		return diags
	}

	block, current, err := k3sVersionBlock(f.Body())
	if err != nil {
		return err
	}
	fmt.Printf("Current: %s\n", tagWithV(current))

	if !latest.GreaterThan(current) {
		return nil
	}

	block.Body().SetAttributeValue("default", cty.StringVal(tagWithV(latest)))
	if err := os.WriteFile(tfPath, f.Bytes(), 0o644); err != nil {
		return err
	}
	fmt.Printf("Updated: %s -> %s\n", tagWithV(current), tagWithV(latest))
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
