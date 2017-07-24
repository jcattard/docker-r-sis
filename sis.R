library(deSolve)
library("optparse")

# parse inputs
option_list = list(
    make_option(
        c("-p", "--parameters-input-file"),
        type="character",
        default=NULL,
        help="parameters set file path",
        metavar="./p.csv"),
    make_option(
        c("-x", "--state-input-file"),
        type="character",
        default=NULL,
        help="state set file path",
        metavar="./x.csv"),
    make_option(
        c("-y", "--observation-output-file"),
        type="character",
        default=NULL,
        help="observation file path",
        metavar="./y.csv"),
    make_option(
        c("-X", "--state-output-file"),
        type="character",
        default=NULL,
        help="state output file path",
        metavar="./x_next.csv"),
    make_option(
        c("-n", "--nbr-step"),
        type="integer",
        default=NULL,
        help="number of step to do",
        metavar="10"),
    make_option(
        c("-i", "--initial-time"),
        type="integer",
        default=NULL,
        help="time to begin simulation",
        metavar="0")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Check inputs numbers
step=FALSE
if(length(opt) == 7)
{
    step=TRUE
}else if(length(opt) == 3)
{
    step=FALSE
}else
{
    stop("Args error. Please given parameter input file and observation output file for simple simulation or all args for step simulation. See script usage (--help)")
}

## create observation output file
path = "./"
y_file = file.create(paste(path, opt["observation-output-file"], sep=""))

## load environment
data <- read.table("/home/user01/data.txt", header=TRUE, sep="\t", na.strings="NA", dec=".")

## prepare simulation
if(step)
{
    x_new = file.create(paste(path, opt["state-output-file"], sep=""))
    state = read.csv(toString(opt["state-input-file"][1]), header=FALSE)
    state <- list(S=state[state[,1]=="S",2], I=state[state[,1]=="I",2])
    V <- c(S=as.numeric(state["S"]), I=as.numeric(state["I"]))
    Tmin = as.numeric(opt["initial-time"][1])
    Tmax = as.numeric(opt["initial-time"][1])+as.numeric(opt["nbr-step"][1])
}else
{
    ## define constant
    Tmin = 1
    Tmax = length(data[,1])
    N = 44
    V <- c(S=N-1, I=1)
}

## define constant
time = Tmin:Tmax

## define model
deriv <- function(t,y,p)
{
  c = 1
  with(as.list(c(p, y)), {
    dS <- - c*beta *S*I/(S+I) + gamma * I
    dI <- c*beta *S*I/(S+I) - gamma *I
    list(c(dS,dI))
  })
}

## load parameters
par = read.csv(toString(opt["parameters-input-file"][1]), header=FALSE)
par <- list(beta=par[par[,1]=="beta",2], gamma=par[par[,1]=="gamma",2])

## computation
comparts <- lsoda(V, time, deriv, parms=par)


## write outputs
if(step)
{
    ## write observations
    count = 0
    write.table(as.matrix(t(c(count,"S",comparts[length(comparts[,1]),1],"S",comparts[length(comparts[,2]),2]))), file=toString(opt["observation-output-file"]), quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
    count = count + 1
    write.table(as.matrix(t(c(count,"I",comparts[length(comparts[,1]),1],"I",comparts[length(comparts[,3]),3]))), file=toString(opt["observation-output-file"]), quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
    count = count + 1

    ## write xnew
    x_new = file.create(paste(path, opt["state-output-file"], sep=""))
    write.table(as.matrix(t(c("S",comparts[length(comparts[,2]),2]))), file=toString(opt["state-output-file"]), quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
    write.table(as.matrix(t(c("I",comparts[length(comparts[,3]),3]))), file=toString(opt["state-output-file"]), quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
}else
{
    ## write observations
    count = 0
    for (i in 1:length(comparts[,1]))
    {
        write.table(as.matrix(t(c(count,"S",comparts[i,1],"S",comparts[i,2]))), file=toString(opt["observation-output-file"]), quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
        count = count + 1
        write.table(as.matrix(t(c(count,"I",comparts[i,1],"I",comparts[i,3]))), file=toString(opt["observation-output-file"]), quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
        count = count + 1
    }
}
