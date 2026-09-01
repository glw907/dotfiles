package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/glw907/workstation/tellgrader/internal/tellscan"
	"github.com/spf13/cobra"
)

type flags struct {
	register string
}

func newRootCmd() *cobra.Command {
	var f flags

	cmd := &cobra.Command{
		Use:          "tellgrader --register <name> file...",
		Short:        "Scan prose for AI-writing tells and report cadence statistics as JSON",
		Args:         cobra.MinimumNArgs(1),
		RunE:         func(cmd *cobra.Command, args []string) error { return run(args, &f) },
		SilenceUsage: true,
	}
	cmd.Flags().StringVar(&f.register, "register", "docs",
		"register to grade against: docs, editor, commit, reply, agent, comments")
	return cmd
}

func run(paths []string, f *flags) error {
	reg, err := tellscan.ParseRegister(f.register)
	if err != nil {
		return err
	}

	reports := make([]*tellscan.Report, 0, len(paths))
	for _, p := range paths {
		data, err := os.ReadFile(p)
		if err != nil {
			return fmt.Errorf("read %s: %v", p, err)
		}
		reports = append(reports, tellscan.Scan(string(data), tellscan.Options{
			Register: reg,
			Path:     p,
		}))
	}

	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	if len(reports) == 1 {
		return enc.Encode(reports[0])
	}
	return enc.Encode(reports)
}
