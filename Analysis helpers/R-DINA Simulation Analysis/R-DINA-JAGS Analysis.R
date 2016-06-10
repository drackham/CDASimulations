########### Analyze Output ##########
source("/Users/Dave/dev/EffectiveThetaBIN/Helpers/extractCodaVariables.R")
library('coda')
library('ggplot2')
library('ggmcmc')
library('parallel')
library('runjags')
library('dcms')
##############################################################################
#                         Load the data                                      #
##############################################################################
data("R_DINA_SimpleQ.500") # needs to be specified by the simulation tracker...
dSim <- R_DINA_SimpleQ.500$d
fSim <- R_DINA_SimpleQ.500$f
J <- R_DINA_SimpleQ.500$J

alpha1Sim <- R_DINA_SimpleQ.500$alphaIK[,1]
alpha2Sim <- R_DINA_SimpleQ.500$alphaIK[,2]

##############################################################################
#                             Summary                                        #
##############################################################################

# data-model fit
dic <- runjags::extract(sim, what='dic')

##############################################################################
#                         Transformations                                    #
##############################################################################
# Convert to coda object
codaSamples = as.mcmc.list(combine.mcmc(sim)) # resulting codaSamples object has these indices: codaSamples[[ chainIdx ]][ stepIdx , paramIdx ]
codaList <- as.mcmc.list(sim)

# Setup ggmcmc object
S <- ggs(as.mcmc.list(sim))

##############################################################
# 							Convergence diagnostics											 #
##############################################################

# Item parameter summmaries
dHatSummary <- add.summary(sim, vars = c("dHat"))
fHatSummary <- add.summary(sim, vars = c("fHat"))

geweke <- geweke.diag(codaSamples)

raftery <- raftery.diag(codaSamples)[[1]]$resmatrix[1:60,] # I should be less than 5

# dHat effective sample sizes
dHatEffectiveSize = matrix(nrow=J, ncol=2) # To Do: Add row.names
for (j in 1:30){
	dHatEffectiveSize[j,1] <- paste("dHat[", j, "]", sep="")
	dHatEffectiveSize[j,2] <- effectiveSize(codaSamples[,paste("dHat[", j, "]", sep="")])
}

# fHat effective sample sizes
fHatEffectiveSize = matrix(nrow=J, ncol=2) # To Do: Add row.names
for (j in 1:30){
	fHatEffectiveSize[j,1] <- paste("fHat[", j, "]", sep="")
	fHatEffectiveSize[j,2] <- effectiveSize(codaSamples[,paste("fHat[", j, "]", sep="")])
}

# Plot convergence diagnostics
ggmcmc(S, file="dHat.html", plot=c("traceplot", "density", "running", "autocorrelation"), family="dHat", param_page=4)
ggmcmc(S, file="fHat.html", plot=c("traceplot", "density", "running", "autocorrelation"), family="fHat", param_page=4)

# Check rHat plots
ggs_Rhat(S, family = "dHat", scaling = 1.5)
ggs_Rhat(S, family = "fHat", scaling = 1.5)

##############################################################
# 						  Extract posterior means											 #
##############################################################

dHat <- extractCodaVariables(x=codaSamples, params='dHat', exact=FALSE)
fHat <- extractCodaVariables(x=codaSamples, params='fHat', exact=FALSE)

alpha1 <- extractCodaVariables(x=codaSamples, params='alpha1', exact=FALSE)
alpha2 <- extractCodaVariables(x=codaSamples, params='alpha2', exact=FALSE)

##############################################################################
#                 Plot dHat discrepencies                                    #
##############################################################################

# Make vector of wanted parameter names
wanted_pars <- c(paste0("dHat[", 1:J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(dSim)
estimated_values <- dHat

# Assesmble a data frame to pass to ggplot()
sim_df <- data.frame(parameter = factor(wanted_pars, rev(wanted_pars)), row.names = NULL)
sim_df$middle <- estimated_values[, "mean"] - generating_values
sim_df$lower <- estimated_values[, "2.5%"] - generating_values
sim_df$upper <- estimated_values[, "97.5%"] - generating_values

# Plot the discrepancy
ggplot(sim_df) + aes(x = parameter, y = middle, ymin = lower, ymax = upper) +
  scale_x_discrete() + geom_abline(intercept = 0, slope = 0, color = "white") +
  geom_linerange() + geom_point(size = 2) + labs(y = "Discrepancy", x = NULL, title = "dHat Sim vs. Predicted Discrepency") +
  theme(panel.grid = element_blank()) + coord_flip()

##############################################################################
#                 Plot fHat discrepencies                                    #
##############################################################################

# Make vector of wanted parameter names
wanted_pars <- c(paste0("fHat[", 1:J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(fSim)
estimated_values <- fHat

# Assesmble a data frame to pass to ggplot()
sim_df <- data.frame(parameter = factor(wanted_pars, rev(wanted_pars)), row.names = NULL)
sim_df$middle <- estimated_values[, "mean"] - generating_values
sim_df$lower <- estimated_values[, "2.5%"] - generating_values
sim_df$upper <- estimated_values[, "97.5%"] - generating_values

# Plot the discrepancy
ggplot(sim_df) + aes(x = parameter, y = middle, ymin = lower, ymax = upper) +
  scale_x_discrete() + geom_abline(intercept = 0, slope = 0, color = "white") +
  geom_linerange() + geom_point(size = 2) + labs(y = "Discrepancy", x = NULL, title = "fHat Sim vs. Predicted Discrepency") +
  theme(panel.grid = element_blank()) + coord_flip()

##############################################################################
#                   Check alpha recovery                                     #
##############################################################################

# Check alpha recovery
plot(alpha1Sim, alpha1[,1], main = "Alpha1 Recovery")
abline(a=0,b=1)

plot(alpha2Sim, alpha2[,1], main = "Alpha2 Recovery")
abline(a=0,b=1)

# Check Prob(response) recovery
probHat <- boot::inv.logit(fHat + dHat)
prob <- boot::inv.logit(fSim + dSim)

diff <- (prob - probHat)
mean(diff[,1])

##############################################################################
#                 Check guess and slip recovery                              #
##############################################################################
gSim <- boot::inv.logit(fSim)
sSim <- boot::inv.logit(fSim + dSim)

gHat <- boot::inv.logit(fHat[,1])
sHat <- boot::inv.logit(fHat[,1] + dHat[,1])

plot(gHat, gSim, main = "Guess simulated vs. predicted" )
abline(a = 0, b = 1)

plot(sHat, sSim, main = "Slip simulated vs. predicted" )
abline(a = 0, b = 1)

##############################################################################
#                   Marginal Posterior Analysis                              #
##############################################################################

# start with means...
varnames(codaList)

s <- sort(1-boot::inv.logit(fHat[,1] + dHat[,1]))
g <- sort(boot::inv.logit(fHat[,1]))
f = function(s, g) { (1-s) * g }
p_resp = outer(s, g, f)
p_resp[is.na(z)] = 1

#Perspective Plot
persp(s,g,p_resp,col="lightblue",main="Perspective Plot",theta=-45, phi=0)

tmp <- as.mcmc(codaSamples)
tmp[,1]

fChain <- codaSamples[,1:30]
dChain <- codaSamples[,31:60]

s <- sort(1-boot::inv.logit(tmp[,1] + tmp[,31]))
g <- sort(boot::inv.logit(tmp[,1]))
f = function(s, g) { (1-s) * g }
p_resp = outer(s, g, f)

#Perspective Plot
persp(s,g,p_resp,col="lightblue",main="Perspective Plot",theta=-45, phi=0)
