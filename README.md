# Nash equilibrium of a bi-matrix game

A Nash equilibrium is achieved in game theory when a number of players cannot benefit from deviating from their chosen strategies https://en.wikipedia.org/wiki/Nash_equilibrium.  This program demonstrates how to achieve that with non-linear constraints that complement each other.   

We need to first create a variable to find the probability of a strategy being chosen

@variable(y,probstrata[1:2])
@variable(y,probstratb[1:2])

The maximum expected payoff for the players through their possible strategies.
@variable(y,maxa)
@variable(y,maxb)

We need to have two matrices, one for each player.  Each index is their payoff for each strategy.  For this example the A player uses the i index for their strategies. 
B uses the j indeces for their strategies.

payoffA=[1 9;
         9 -1]
         
payoffB=[-1 9;
          9 0]

Constraint that states each mixed strategy of each player must be non-negative

@NLconstraint(y,[i in 1:2],probstrata[i]>=0)
@NLconstraint(y,[i in 1:2],probstratb[i]>=0)

There needs to be a constraint that states each players strategies must equal to one.  The reason for this
is that all of the strategies here are stated in probabilities which are given in
percentages out of 100.  So for example a total strategy for a could be :
              a[1]=.33
              a[2]=.66
which would approximately equal 1 if sumed over the indeces.

@NLconstraint(y,sum(probstrata[i] for i in 1:2)==1)

@NLconstraint(y,sum(probstratb[i] for i in 1:2)==1)

The expected value of the players payout cannot exceed the maximum payout for each.

@NLconstraint(y,[i in 1:2],sum(payoffA[i,j]*probstratb[j] for j in 1:2)<=maxa)
@NLconstraint(y,[j in 1:2],sum(payoffB[i,j]*probstrata[i] for i in 1:2)<=maxb)

In order to use the @complements when we are complementing an operation inside
the parenthesis we need to define a non-linear expression.  Here we calculate the
payout for player a choosing strategy i and player b playing strategy j.  This is 
stored in "first".
@NLexpression(y,first[i in 1:2],sum(payoffA[i,j]*probstratb[j] for j in 1:2))

@NLexpression(y,second[j in 1:2],sum(payoffB[i,j]*probstrata[i] for i in 1:2))

This is faster instead of declaring each separate complement.  Since we stored the 
value of player a's "winnings" in first we can use the non-linear expression of the sum
of the total strategies of a playing i and b playing j and vice versa.  The strategy
of player a is positive if the value for first is equal to the expected payoff.  
A good way to visualize this is looking at this as a single variable with both upper
and lower bounds
##   lower_bound_for_x<= x <=upper_bound_for_x    F(x)=0
##   lower_bound_for_x = x                        F(x)>=0
##   upper_bound_for_x =x                         F(x)<=0  which wouldn't apply because we 
don't have an upper bound declared because all of our separate strategies are under the 
constraint that they must sum up to 1 or 100 total percent.  The F(x) is the function of 
our variable and it is what we are trying to find out.  For this problem the F(x) is the 
probability of a Nash equilibrium being achieved where no players wish to change their
strategy and optimal winnings are achieved for all.  

for i in 1:2
       @complements(y,maxa<=first[i],        probstrata[i]>=0)
       end

for j in 1:2
       @complements(y,maxb<=second[j],       probstratb[j]>=0)
       end

@NLobjective(y,Min,1)


optimize!(y)

The maximum winnings for player a.
value.(maxa)
5.999999993229386

The probability of player a winning for each strategy
value.(probstrata)
2-element Array{Float64,1}:
 0.49999999950597457
 0.5000000004933631 

value.(maxb)
5.499999993582053

The probability of player b winning for each strategy
achieved
 value.(probstratb)
2-element Array{Float64,1}:
 0.42857142857115754
 0.5714285714280565 

The ideal strategy is where player A chooses strategy 2 and player B chooses strategy 2 as well.  This will
achieve a Nash equilibrium because neither player will want to change their strategy.  



