########### Analyze Output ##########
library('devtools')
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/extractCodaVariables.R")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/standardizedResidual.R")
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')
library('dcms')

# setwd("~/Desktop/R-DINA-JAGS")
# 
# load("~/Desktop/R-DINA-JAGS/R-DINA JAGS Sim.RData")
# load("~/Desktop/R-DINA-JAGS/Simulated-Data.RData")

# Load the data set
data("R_DINA_SimpleQ.1000")

oneChain <- combine.mcmc(sim)

codaSamples = as.mcmc.list(oneChain) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]

d <- extractCodaVariables(x=codaSamples, params='d', exact=FALSE)
f <- extractCodaVariables(x=codaSamples, params='f', exact=FALSE)

alpha1 <- extractCodaVariables(x=codaSamples, params='alpha1', exact=FALSE)
alpha2 <- extractCodaVariables(x=codaSamples, params='alpha2', exact=FALSE)

# plot(density(alpha1[1,]))

# Simulated vs. Predicted d
simD <- R_DINA_SimpleQ.1000$d

plot(simD, d[,1], xlim=c(0,12), ylim=c(0,12))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simD,d[,1])
mean(rmsd) #0.3341923
plot(density(rmsd))

stResidual <- standardizedResidual(simD, d[,1])
mean(stResidual)
plot(density(stResidual))
quantile(stResidual,c(.025,.975))

# Simulated vs. Predicted f
simF <- R_DINA_SimpleQ.1000$f

plot(simF, f[,1], xlim=c(-10,0), ylim=c(-10,0))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simF,f[,1])
mean(rmsd) #0.1889619
plot(density(rmsd))

stResidual <- standardizedResidual(simF, f[,1])
mean(stResidual)
plot(density(stResidual))
quantile(stResidual,c(.025,.975))

# Simulated vs. Predicted alphaIK
x <- alpha2[,1]
y <- R_DINA_SimpleQ.1000$alphaIK[,2]

plot(x,y,xlim=c(0, 1), ylim=c(0, 1))
abline(a=0,b=1)

diff <- f[,1]+d[,1]
plot(density(1-exp(diff)/(1+exp(diff))))


# oneChain <- combine.mcmc(sim)

# codaSamples = as.mcmc.list(oneChain) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]

# S <- ggs(as.mcmc.list(sim))
# ggmcmc(S, file=paste("CDA/ConvergencePlots F.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^f", param_page=1)
# ggmcmc(S, file=paste("CDA/ConvergencePlots D.pdf", sep=""), plot=c("traceplot", "autocorrelation"), family="^d", param_page=1)

