---
name: gb_solve
description: Guide for correctly using the gb_solve tactic (and related tactics) in this Lean 4 GBProver / GroebnerTactic project
user_invocable: true
---

# gb_solve — Gröbner Basis Tactic Guide

`gb_solve` is a Lean 4 tactic that automatically proves goals involving Gröbner basis computations by delegating to an external solver (SageMath or SymPy) and then kernel-verifying the result.

## Type constraint

`gb_solve` **only works with `MvPolynomial σ ℚ`** (rational coefficients).  
Variables must be indexed by a `Fin n` type (e.g. `Fin 2`, `Fin 3`).  
Polynomial expressions must be built from:
- `X i` — the i-th variable
- `C r` — a rational constant
- `+`, `-`, `*`, `^`, negation
- numeric literals (auto-coerced to `ℚ`)

If the goal contains polynomials over other types, `gb_solve` will fail.

---

## The six goal shapes `gb_solve` handles

### 1. Polynomial remainder

Prove that `f` reduces to remainder `r` modulo a finite set `G`.

```lean
example :
    lex.IsRemainder (X 0 * X 1 : MvPolynomial (Fin 3) ℚ)
      {2 * X 0 - X 1}
      (C (1/2 : ℚ) * X 1 ^ 2) := by
  gb_solve
```

- The remainder must be stated exactly — use `0` when you expect a zero remainder.
- The divisor set uses Lean set-builder notation `{...}`.

```lean
-- Zero remainder example
example :
    lex.IsRemainder (X 0 ^ 2 + X 1 ^ 3 + X 2 ^ 4 + X 3 ^ 5 : MvPolynomial (Fin 4) ℚ)
      {X 0, X 1, X 2, X 3} 0 := by
  gb_solve
```

### 2. Gröbner basis verification

Prove that a set `B` is a Gröbner basis for an ideal `I`.

```lean
example :
  lex.IsGroebnerBasis
    ({1} : Set (MvPolynomial (Fin 3) ℚ))
    (Ideal.span ({X 0, 1 - X 0} : Set (MvPolynomial (Fin 3) ℚ))) := by
  gb_solve
```

### 3. Ideal membership (positive)

Prove `f ∈ Ideal.span generators`.

```lean
example :
  X 0 ∈ Ideal.span ({X 0, X 1} : Set (MvPolynomial (Fin 2) ℚ)) := by
  gb_solve
```

### 4. Ideal non-membership (negative)

Prove `f ∉ Ideal.span generators`.

```lean
example :
  X 2 ∉ Ideal.span ({X 0 + X 1 ^ 2, X 1 ^ 2} : Set (MvPolynomial (Fin 3) ℚ)) := by
  gb_solve
```

### 5. Radical ideal membership (positive)

Prove `f ∈ (Ideal.span generators).radical`.

```lean
example :
  X 0 * X 1 ∈ (Ideal.span
    ({C (1/2 : ℚ) * (X 0 + X 1), C (1/2 : ℚ) * (X 0 - X 1)} :
     Set (MvPolynomial (Fin 2) ℚ))).radical := by
  gb_solve
```

### 6. Radical ideal non-membership (negative)

Prove `f ∉ (Ideal.span generators).radical`.

Internally uses the Rabinovich method: the goal is lifted from `Fin n` to `Fin (n+1)`.  
**Critical:** the polynomial type must use `Fin n` for some concrete `n` — abstract index types will fail.

```lean
example :
  X 0 ∉ (Ideal.span ({X 0 + X 1} : Set (MvPolynomial (Fin 3) ℚ))).radical := by
  gb_solve
```

---

## Related tactics

### `idealeq`

Proves equality of two ideals by comparing their Gröbner bases.

```lean
example :
  Ideal.span ({X 0 + X 1 ^ 2, X 1} : Set (MvPolynomial (Fin 3) ℚ)) =
    Ideal.span ({X 0, X 1} : Set (MvPolynomial (Fin 3) ℚ)) := by
  idealeq
```

### `add_gb_hyp`

Computes a Gröbner basis and injects it as a hypothesis for manual use.

```lean
example :
  lex.IsGroebnerBasis ({X 0, X 1} : Set (MvPolynomial (Fin 3) ℚ))
    (Ideal.span {X 0, X 0 + X 1}) := by
  add_gb_hyp h ({X 0, X 0 + X 1} : Set (MvPolynomial (Fin 3) ℚ))
  simp only [...] at h
  exact h
```

---

## Backend options

The default backend is local SageMath (mode 0). Use `set_option` to change:

| Mode | Backend | Notes |
|------|---------|-------|
| `0` (default) | Local SageMath | Requires SageMath installed |
| `1` | External SageMath API | Not recommended; rate-limited |
| `2` | Local SymPy | Lighter install; use if SageMath unavailable |

```lean
-- Use SymPy instead of SageMath
set_option gb_tactic.backend 2 in
example : ... := by gb_solve
```

---

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Coefficients over `ℤ` or `ℝ` instead of `ℚ` | Add `: MvPolynomial (Fin n) ℚ` annotation or `C (r : ℚ)` |
| Variable index type is not `Fin n` | Restate with `Fin n` |
| Set written as a `List` or `Finset` | Use `Set` literal `{...}` |
| Remainder stated as wrong expression | Check by computing manually first, then state exactly |
| Radical non-membership with non-concrete `n` | `gb_solve` needs `Fin 3`, not `Fin n` for a variable `n` |
| Calling `gb_solve` on a non-polynomial goal | The tactic only handles the six goal shapes above |

---

## How to apply this skill

When asked to write or fix a Lean 4 proof that involves:
- Gröbner bases, ideal membership/non-membership, radical membership, or polynomial remainders

1. Identify which of the six goal shapes applies.
2. Make sure the type is `MvPolynomial (Fin n) ℚ` with a concrete `n`.
3. Write the statement in the exact syntactic form shown above.
4. Apply `gb_solve` (or `idealeq` / `add_gb_hyp` as appropriate).
5. If SageMath is unavailable, prepend `set_option gb_tactic.backend 2 in`.
