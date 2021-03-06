FactoryGirl.define do
  factory :prover_output do
    association :proof_attempt
    content { '--------------------------SPASS-START-----------------------------
Input Problem:
1[0:Inp] || equal(skc1,skc1)* -> .
 This is a unit equality problem.
 This is a problem that has, if any, a finite domain model.
 There are no function symbols.
 The conjecture is ground.
 Axiom clauses: 0 Conjecture clauses: 1
 Inferences: IEqR=1
 Reductions: RFMRR=1 RBMRR=1 RObv=1 RUnC=1 RTaut=1 RFSub=1 RBSub=1
 Extras    : Input Saturation, Always Selection, No Splitting, Full Reduction,  Ratio: 5, FuncWeight: 1, VarWeight: 1
 Precedence: skc0 > skc1
 Ordering  : KBO
Processed Problem:

Worked Off Clauses:

Usable Clauses:

SPASS V 3.7
SPASS beiseite: Proof found.
Problem: Read from stdin.
SPASS derived 0 clauses, backtracked 0 clauses, performed 0 splits and kept 1 clauses.
SPASS allocated 45930 KBytes.
SPASS spent 0:00:00.03 on the problem.
    0:00:00.01 for the input.
    0:00:00.01 for the FLOTTER CNF translation.
    0:00:00.00 for inferences.
    0:00:00.00 for the backtracking.
    0:00:00.00 for the reduction.


Here is a proof with depth 0, length 2 :
1[0:Inp] || equal(skc1,skc1)* -> .
2[0:Obv:1.0] ||  -> .
Formulae used in the proof : ax1

--------------------------SPASS-STOP------------------------------' }
  end
end
