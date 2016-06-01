########### Analyze Output ##########
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/extractCodaVariables.R")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/standardizedResidual.R")
library('coda')
library('ggplot2')
library('ggmcmc')
library('parallel')
library('runjags')
library('dcms')


# To Do: This file needs massive clean-up!

# 1- review changes to all packages and commit 
# 2- Include guess/slip parameters in data simulation
# 3- Wrap the diff function plot thing into nicer code
# 4- As evidence of recovery show:
## simulated vs. predicted RMSD, St. Residual, Discrepency plot
## guess/slip RMSD, St. Residual and Discrepency plot
# 5- Do 10 simulation runs with ilogit and 10 without and compare
# 6- Determine how to best show evidence of convergence
# 7- simulated vs. predicted alpha mastery
# 9- Create "flat" data sets of 100, 500, 1000 where all items function the same
# 8- Once everything is cleaned-up 
## Non-hierarchical at 100, 500, 1000
## Hierarchical at 100, 500, 1000
# 9- Create "bad" dataset with 25% items that have a high guess/slip rate at 100, 500, 1000
# 10- Include data/model fit indices
# 11- Create datasets that have 10 items at 100, 500, 1000
# 12- Use complex Q data at 100, 500, 1000

# setwd("~/Desktop/R-DINA-JAGS")
# 
# load("~/Desktop/R-DINA-JAGS/R-DINA JAGS Sim.RData")
# load("~/Desktop/R-DINA-JAGS/Simulated-Data.RData")

# Load the data set
data("R_DINA_SimpleQ.1000")

oneChain <- combine.mcmc(sim)

codaSamples = as.mcmc.list(oneChain) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]

dHat <- extractCodaVariables(x=codaSamples, params='dHat', exact=FALSE)
fHat <- extractCodaVariables(x=codaSamples, params='fHat', exact=FALSE)

alpha1 <- extractCodaVariables(x=codaSamples, params='alpha1', exact=FALSE)
alpha2 <- extractCodaVariables(x=codaSamples, params='alpha2', exact=FALSE)

# plot(density(alpha1[1,]))

# Simulated vs. Predicted d
simD <- R_DINA_SimpleQ.1000$d

plot(simD, dHat[,1], xlim=c(0,12), ylim=c(0,12))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simD,dHat[,1])
mean(rmsd) #0.3341923
plot(density(rmsd))

stResidual <- standardizedResidual(simD, dHat[,1])
mean(stResidual)
plot(density(stResidual))
quantile(stResidual,c(.025,.975))

# Simulated vs. Predicted f
simF <- R_DINA_SimpleQ.1000$f

plot(simF, fHat[,1], xlim=c(-10,0), ylim=c(-10,0))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simF,f[,1])
mean(rmsd) #0.1889619
plot(density(rmsd))

stResidual <- standardizedResidual(simF, f[,1])
mean(stResidual)
plot(density(stResidual))
quantile(stResidual,c(.025,.975))

# Simulated vs. Predicted alphaIK
x <- alpha1[,1]
y <- R_DINA_SimpleQ.1000$alphaIK[,1]

plot(x,y,xlim=c(0, 1), ylim=c(0, 1))
abline(a=0,b=1)

diff <- f[,1]+d[,1]
plot(density(1-exp(diff)/(1+exp(diff))))


# Make vector of wanted parameter names
wanted_pars <- c(paste0("dHat[", 1:R_DINA_SimpleQ.1000$J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(simD)
estimated_values <- dHat

# Assesmble a data frame to pass to ggplot()
sim_df <- data.frame(parameter = factor(wanted_pars, rev(wanted_pars)), row.names = NULL)
sim_df$middle <- estimated_values[, "mean"] - generating_values
sim_df$lower <- estimated_values[, "2.5%"] - generating_values
sim_df$upper <- estimated_values[, "97.5%"] - generating_values

# Plot the discrepancy
ggplot(sim_df) + aes(x = parameter, y = middle, ymin = lower, ymax = upper) +
	scale_x_discrete() + geom_abline(intercept = 0, slope = 0, color = "white") +
	geom_linerange() + geom_point(size = 2) + labs(y = "Discrepancy", x = NULL) +
	theme(panel.grid = element_blank()) + coord_flip()

probHat <- boot::inv.logit(fHat[,1] + dHat[,1])
prob <- boot::inv.logit(simF + simD)

diff (probHat - prob)
