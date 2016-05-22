########### Analyze Output ##########
library('devtools')
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/extractCodaVariables.R")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/standardizedResidual.R")
library('coda')
library('ggmcmc')
library('parallel')
library('runjags')

setwd("~/RDINA-100")

load("Simulated Data.R")
load("Simulated Q.R")
load("Sim1.RData")

d <- extractCodaVariables(x=codaSamples, params='d', exact=FALSE)
f <- extractCodaVariables(x=codaSamples, params='f', exact=FALSE)

alpha1 <- extractCodaVariables(x=codaSamples, params='alpha1', exact=FALSE)
alpha2 <- extractCodaVariables(x=codaSamples, params='alpha2', exact=FALSE)

plot(density(alpha1[1,]))

# Simulated vs. Predicted f
simF <- data$f

plot(simF, f[,1], xlim=c(-10,0), ylim=c(-10,0))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simF,f[,1])
mean(rmsd) #0.1889619
plot(density(rmsd))

# Simulated vs. Predicted d
simD <- data$d

plot(simD, d[,1], xlim=c(0,12), ylim=c(0,12))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simD,d[,1])
mean(rmsd) #0.3341923
plot(density(rmsd))

# Simulated vs. Predicted alphaJK
x <- alpha2[,1]
y <- data$alphaJK[,2]

plot(x,y,xlim=c(0, 1), ylim=c(0, 1))
abline(a=0,b=1)

diff <- f[,1]+d[,1]
plot(density(1-exp(diff)/(1+exp(diff))))
