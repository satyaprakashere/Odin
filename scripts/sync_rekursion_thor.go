package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

type SyncConfig struct {
	RekursionPath string
	OdinPath      string
	DryRun        bool
	Verbose       bool
}

type TestResult struct {
	Name     string
	Passed   bool
	Duration time.Duration
	Output   string
	Error    error
}

func main() {
	defaultRekursion := "/Users/prakash/Documents/projects/rekursion"
	if envPath := os.Getenv("REKURSION_PATH"); envPath != "" {
		defaultRekursion = envPath
	}

	rekursionPath := flag.String("rekursion", defaultRekursion, "Path to the local Rekursion repository")
	odinPath := flag.String("odin", ".", "Path to the Odin repository root")
	dryRun := flag.Bool("dry-run", false, "Preview sync actions without copying files")
	verbose := flag.Bool("verbose", false, "Print detailed command output")
	flag.Parse()

	absOdin, err := filepath.Abs(*odinPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error resolving Odin path: %v\n", err)
		os.Exit(1)
	}

	absRekursion, err := filepath.Abs(*rekursionPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error resolving Rekursion path: %v\n", err)
		os.Exit(1)
	}

	cfg := SyncConfig{
		RekursionPath: absRekursion,
		OdinPath:      absOdin,
		DryRun:        *dryRun,
		Verbose:       *verbose,
	}

	fmt.Println("================================================================================")
	fmt.Println("             Thor / Rekursion Synchronization Engine (Go)                      ")
	fmt.Println("================================================================================")
	fmt.Printf("Odin Root      : %s\n", cfg.OdinPath)
	fmt.Printf("Rekursion Root : %s\n", cfg.RekursionPath)
	fmt.Printf("Timestamp      : %s\n\n", time.Now().Format(time.RFC3339))

	// 1. Validate Rekursion Thor Source
	rekursionThorDir := filepath.Join(cfg.RekursionPath, "lang", "thor")
	if _, err := os.Stat(rekursionThorDir); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "[FAIL] Rekursion Thor directory not found at: %s\n", rekursionThorDir)
		os.Exit(1)
	}
	fmt.Printf("[OK] Located canonical rekursion/thor at: %s\n", rekursionThorDir)

	// 2. Query Rekursion Git Metadata
	commitHash, commitMsg, commitDate := getRekursionGitInfo(cfg.RekursionPath, "lang/thor")
	fmt.Printf("     Latest Commit : %s\n", commitHash)
	fmt.Printf("     Commit Date   : %s\n", commitDate)
	fmt.Printf("     Message       : %s\n\n", commitMsg)

	// 3. Mirror authoritative specification files
	specTargetDir := filepath.Join(cfg.OdinPath, "doc", "thor", "rekursion_specs")
	specsToSync := []string{"THOR.md", "GRAMMAR.md"}
	for _, spec := range specsToSync {
		src := filepath.Join(rekursionThorDir, spec)
		dst := filepath.Join(specTargetDir, spec)
		if err := syncFile(src, dst, cfg.DryRun, cfg.Verbose); err != nil {
			fmt.Fprintf(os.Stderr, "[ERROR] Failed syncing spec file %s: %v\n", spec, err)
			os.Exit(1)
		}
	}
	fmt.Println("[OK] Specification documents mirrored successfully.")

	// 4. Verify Zero Upstream Invariant
	fmt.Print("\n[1/5] Verifying upstream Odin zero-diff invariant (core/ & odin.ebnf)... ")
	diffOut, err := runCmd(cfg.OdinPath, "git", "diff", "upstream/master", "--", "core/", "odin.ebnf")
	if err != nil || len(strings.TrimSpace(diffOut)) > 0 {
		fmt.Println("FAILED")
		fmt.Fprintf(os.Stderr, "Upstream diff check failed! Expected 0 lines diff, got:\n%s\n", diffOut)
		os.Exit(1)
	}
	fmt.Println("PASSED (0 diff lines)")

	// 5. Run Thor Validation Test Suite
	thorBin := filepath.Join(cfg.OdinPath, "bin", "thor")
	if _, err := os.Stat(thorBin); os.IsNotExist(err) {
		thorBin = filepath.Join(cfg.OdinPath, "odin")
	}

	tests := []struct {
		name string
		args []string
	}{
		{
			name: "Syntax Check (source.thor)",
			args: []string{"check", "tests/rekursion_sync/source.thor", "-file", "-no-entry-point"},
		},
		{
			name: "Parity Test (test_rekursion_parity.thor)",
			args: []string{"run", "tests/rekursion_sync/test_rekursion_parity.thor", "-file"},
		},
		{
			name: "C-Ingest Compat (test_c_ingest_compat.thor)",
			args: []string{"run", "tests/rekursion_sync/test_c_ingest_compat.thor", "-file"},
		},
		{
			name: "Odin Interop Matrix (tests/thor_interop)",
			args: []string{"run", "tests/thor_interop"},
		},
		{
			name: "Upstream Libc Regression Check",
			args: []string{"check", "core/c/libc", "-no-entry-point"},
		},
	}

	fmt.Println("\nRunning Compiler Parity Matrix:")
	allPassed := true
	for i, t := range tests {
		fmt.Printf("[%d/%d] Running %-40s ... ", i+1, len(tests), t.name)
		start := time.Now()
		out, err := runCmd(cfg.OdinPath, thorBin, t.args...)
		duration := time.Since(start)

		if err != nil {
			fmt.Printf("FAILED (%v)\n", duration.Round(time.Millisecond))
			fmt.Fprintf(os.Stderr, "      Error Output: %s\n", strings.TrimSpace(out))
			allPassed = false
		} else {
			fmt.Printf("PASSED (%v)\n", duration.Round(time.Millisecond))
			if cfg.Verbose {
				fmt.Printf("      Output:\n%s\n", indent(out, "        "))
			}
		}
	}

	fmt.Println("\n================================================================================")
	if allPassed {
		fmt.Println(" [PASS] ALL REKURSION/THOR COMPATIBILITY TESTS PASSED SUCCESSFULLY!             ")
		fmt.Println(" Compiler is 100% in sync with rekursion/thor specifications & upstream Odin.   ")
	} else {
		fmt.Println(" [FAIL] ONE OR MORE PARITY TESTS FAILED. CHECK LOGS ABOVE.                      ")
		os.Exit(1)
	}
	fmt.Println("================================================================================")
}

func getRekursionGitInfo(repoPath, subPath string) (hash, msg, date string) {
	out, err := runCmd(repoPath, "git", "log", "-n", "1", "--format=%h|%cd|%s", "--date=short", "--", subPath)
	if err != nil {
		return "unknown", "unknown", "unknown"
	}
	parts := strings.Split(strings.TrimSpace(out), "|")
	if len(parts) >= 3 {
		return parts[0], parts[2], parts[1]
	}
	return "unknown", "unknown", "unknown"
}

func syncFile(src, dst string, dryRun, verbose bool) error {
	if dryRun {
		if verbose {
			fmt.Printf("[dry-run] copy %s -> %s\n", src, dst)
		}
		return nil
	}

	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}

	dstFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	if err == nil && verbose {
		fmt.Printf("[synced] %s -> %s\n", src, dst)
	}
	return err
}

func runCmd(dir, name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	var outBuf bytes.Buffer
	var errBuf bytes.Buffer
	cmd.Stdout = &outBuf
	cmd.Stderr = &errBuf

	err := cmd.Run()
	combined := outBuf.String()
	if errBuf.Len() > 0 {
		if len(combined) > 0 {
			combined += "\n"
		}
		combined += errBuf.String()
	}
	return combined, err
}

func indent(s, prefix string) string {
	lines := strings.Split(s, "\n")
	for i, l := range lines {
		if strings.TrimSpace(l) != "" {
			lines[i] = prefix + l
		}
	}
	return strings.Join(lines, "\n")
}
