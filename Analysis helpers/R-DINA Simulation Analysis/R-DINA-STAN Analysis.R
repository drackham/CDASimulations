library('rstan')
library('ggmcmc')
library("shinystan")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")

# setwd("")
load("rDINA500.R")
load("Simulated Data.R")

post <- extract(fit, permuted = TRUE) # return a list of arrays

my_sso <- launch_shinystan(fit)

dHat <- colMeans(post$dHat)
simD <- data$d

plot(simD, dHat, xlim=c(0,18), ylim=c(0,18))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simD,dHat)
mean(rmsd)
plot(density(rmsd)) #.820549

fHat <- colMeans(post$fHat)
simF <- data$f

plot(simF, fHat, xlim=c(-10,0), ylim=c(-10,0))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(simF,fHat)
mean(rmsd)
plot(density(rmsd)) #.369

launch_shinystan(my_sso)