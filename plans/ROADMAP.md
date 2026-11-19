# Thor & Odin Compiler Roadmap

> **Location:** [`odin/plans/ROADMAP.md`](file:///Users/prakash/Documents/Repositories/odin/plans/ROADMAP.md)  
> **Repository:** [`git@github.com:satyaprakashere/Odin.git`](file:///Users/prakash/Documents/Repositories/odin)  
> **Upstream:** [`git@github.com:odin-lang/Odin.git`](https://github.com/odin-lang/Odin)

---

## ⚡ 1. Now (Committed / Active Execution)

| Feature ID | Initiative | Plan Link | Status | Target |
| :--- | :--- | :--- | :--- | :--- |
| `FEAT-THOR-SEPARATE` | **Zero-Diff Separation**: Strict syntactic isolation of `.thor` from `.odin` preserving 100% compatibility with upstream Odin `core:` and `vendor:`. | [`thor_strict_separation_plan.md`](thor_strict_separation_plan.md) | **Implemented / Gated** | Q4 2026 |
| `FEAT-THOR-SYNC` | **Rekursion-Thor Continuous Sync**: Bi-directional automated synchronization protocol between `rekursion/thor` dialect and the compiler frontend. | [`rekursion_thor_sync_plan.md`](rekursion_thor_sync_plan.md) | **Active** | Q4 2026 |
| `FEAT-THOR-PURITY` | **LLVM Purity Codegen**: LLVM function attributes (`memory(none)`, `nounwind`, `willreturn`) for pure `func` definitions enabling aggressive optimization. | [`thor_stack_improvement_plan.md`](thor_stack_improvement_plan.md) | **Active** | Q4 2026 |

---

## ⏳ 2. Next (Scoped & Queued)

| Feature ID | Initiative | Plan Link | Status | Target |
| :--- | :--- | :--- | :--- | :--- |
| `FEAT-THOR-SYNTAX` | **Extended Functional Syntax**: Exhaustive pattern matching (`match`), pipeline operator (`\|>`), and pure effect assertions. | [`thor_stack_improvement_plan.md`](thor_stack_improvement_plan.md) | **Next** | Q1 2027 |
| `FEAT-THOR-STDLIB` | **Canonical `thor:` Stdlib**: Pure persistent data structures (HAMT Map, Vector) and QuickCheck-style property testing. | [`thor_stack_improvement_plan.md`](thor_stack_improvement_plan.md) | **Next** | Q1 2027 |
| `FEAT-THOR-LSP` | **Thor Language Server & DX**: Integration of `.thor` syntax into OLS (Odin Language Server) and Tree-sitter grammar generation. | [`thor_stack_improvement_plan.md`](thor_stack_improvement_plan.md) | **Next** | Q1 2027 |

---

## 🔮 3. Later (Long-Term Upstream Evolution)

| Feature ID | Initiative | Plan Link | Status | Focus Area |
| :--- | :--- | :--- | :--- | :--- |
| `FEAT-THOR-COMPTIME` | **Pure Comptime Execution**: Sandboxed compile-time evaluation for pure `func` blocks with guaranteed termination. | [`thor_stack_improvement_plan.md`](thor_stack_improvement_plan.md) | **Backlog** | Compiler Frontend |
| `FEAT-THOR-UPSTREAM-CI` | **Automated Upstream Invariant Matrix**: Multi-OS GitHub Actions workflow continuously rebasing against upstream Odin master. | [`thor_stack_improvement_plan.md`](thor_stack_improvement_plan.md) | **Backlog** | CI / Automation |

---

## 🏁 4. Verification & Operational Commands

- **Build Odin + Thor Compiler**: `./build_thor.sh` or `./build_odin.sh`
- **Run Thor Test Suite**: `./odin test tests/thor`
- **Verify Clean Upstream Separation**: `git diff upstream/master -- src/core src/vendor`
