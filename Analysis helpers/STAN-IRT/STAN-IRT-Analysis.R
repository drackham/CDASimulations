library('devtools')
install_github("drackham/dcms", ref="develop")
library("dcms")
library('ggmcmc')
library('rstan')
library("shinystan")
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/rootMeanSquaredDifference.R")

# Load the files

# Load the data
data("IRT_1PL.1000")

print(fit)

# Load the simulated parameter values
thetaSim <- IRT_1PL.1000$theta
betaSim <- IRT_1PL.1000$beta

post <- rstan::extract(fit, permuted = TRUE) # return a list of arrays

thetaHat <- colMeans(post$theta)

plot(thetaSim, thetaHat, xlim=c(-5,5), ylim=c(-5,5))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(thetaSim,thetaHat)
mean(rmsd)
plot(density(rmsd)) 

betaHat <- colMeans(post$beta)

plot(betaSim, betaHat, xlim=c(-5,5), ylim=c(-5,5))
abline(a=0,b=1)

rmsd <- rootMeanSquaredDifference(betaSim,betaHat)
mean(rmsd)
plot(density(rmsd)) 

my_sso <- launch_shinystan(fit)
