import MonomialOrderedPolynomial.MvPolynomial
import Groebner.Groebner
import Groebner.ToMathlib.List
import GroebnerTac
/-!
In this file we show some examples of using our tactic.
-/

section
open MvPolynomial MonomialOrder

set_option linter.unusedSimpArgs false in
set_option linter.unreachableTactic false in
set_option linter.unusedTactic false in

variable {σ : Type*} (m : MonomialOrder σ)

example : Ideal.span ({X 0 + X 1^2, X 1} : Set (MvPolynomial (Fin 3) ℚ)) ≤
            Ideal.span ({X 0, X 1} : Set (MvPolynomial (Fin 3) ℚ)) := by
  have h : Ideal.span ({X 0 + X 1^2, X 1} : Set (MvPolynomial (Fin 3) ℚ)) =
           Ideal.span ({X 0, X 1} : Set (MvPolynomial (Fin 3) ℚ)) := by idealeq
  exact h.le

