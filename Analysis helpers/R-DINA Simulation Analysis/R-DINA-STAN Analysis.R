library('ggplot2')
library('ggmcmc')
library("shinystan")
library('rstan')

##############################################################################
#													Load the data																			 #
##############################################################################
data(R_DINA_SimpleQ.100)
dSim <- R_DINA_SimpleQ.100$d
fSim <- R_DINA_SimpleQ.100$f

alpha1Sim <- R_DINA_SimpleQ.100$alphaIK[,1]
alpha2Sim <- R_DINA_SimpleQ.100$alphaIK[,2]

##############################################################################
#                             Summary                                        #
##############################################################################
print(fit)

##############################################################################
#                         Transformations                                    #
##############################################################################

# Convert sim to data frame
sim_monitor <- as.data.frame(monitor(fit, print = FALSE))

post <- rstan::extract(fit, permuted = TRUE) # return a list of arrays

##############################################################
#               Convergence diagnostics                      #
##############################################################
# Launch ShinyStan
sso <- launch_shinystan(fit)

##############################################################################
#									Extract	posterior means																		 #
##############################################################################

dHat <- colMeans(post$dHat)
fHat <- colMeans(post$fHat)

alpha1 <- colMeans(post$alpha1)
alpha2 <- colMeans(post$alpha2)

##############################################################################
#									Plot dHat discrepencies    																 #
##############################################################################

# Make vector of wanted parameter names
wanted_pars <- c(paste0("dHat[", 1:R_DINA_SimpleQ.100$J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(dSim)
estimated_values <- sim_monitor[wanted_pars, c("mean", "2.5%", "97.5%")]

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
#									Plot fHat discrepencies    																 #
##############################################################################

# Make vector of wanted parameter names
wanted_pars <- c(paste0("fHat[", 1:R_DINA_SimpleQ.100$J, "]"))

# Get estimated and generating values for wanted parameters
generating_values = c(fSim)
estimated_values <- sim_monitor[wanted_pars, c("mean", "2.5%", "97.5%")]

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
#										Check alpha recovery    																 #
##############################################################################

#	Check alpha recovery
plot(alpha1Sim, alpha1, main = "Alpha1 Recovery")
abline(a=0,b=1)

plot(alpha2Sim, alpha2, main = "Alpha2 Recovery")
abline(a=0,b=1)

# Check Prob(response) recovery
probHat <- boot::inv.logit(fHat + dHat)
prob <- boot::inv.logit(fSim + dSim)

diff <- (probHat - prob)
mean(diff)

