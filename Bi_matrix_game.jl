
using Ipopt
using JuMP
using PATHSolver
using Complementary


y=Model(with_optimizer(Ipopt.Optimizer))

@variable(y,probstrata[1:2])

@variable(y,probstratb[1:2])

@variable(y,maxa)

@variable(y,maxb)

payoffA=[1 9;
         9 -1]


payoffB=[-1 9;9 0]

@NLconstraint(y,[i in 1:2],probstrata[i]>=0)

@NLconstraint(y,[i in 1:2],probstratb[i]>=0)

@NLconstraint(y,sum(probstrata[i] for i in 1:2)==1)

@NLconstraint(y,sum(probstratb[i] for i in 1:2)==1)

@NLconstraint(y,[i in 1:2],sum(payoffA[i,j]*probstratb[j] for j in 1:2)<=maxa)

@NLconstraint(y,[j in 1:2],sum(payoffB[i,j]*probstrata[i] for i in 1:2)<=maxb)

@NLexpression(y,first[i in 1:2],sum(payoffA[i,j]*probstratb[j] for j in 1:2))

@NLexpression(y,second[j in 1:2],sum(payoffB[i,j]*probstrata[i] for i in 1:2))
  
for i in 1:2
       @complements(y,maxa<=first[i],        probstrata[i]>=0)
       end

for j in 1:2
       @complements(y,maxb<=second[j],       probstratb[j]>=0)
       end

@NLobjective(y,Min,1)


optimize!(y)

value.(probstrata)
 0.4736842106062692
 0.5263157893933335

value.(probstratb)
 0.5555555555155433 
 0.44444444448400444

value.(maxa)
4.555555548732115

 value.(maxb)
4.263157887844027



