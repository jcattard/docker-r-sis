library(deSolve)
args <- commandArgs(trailingOnly = TRUE)
path = "./"
file.create(paste(path, args[2], sep=""))
#setwd(path)
data <- read.table(paste(path, "/home/user01/data.txt", sep=""), header=TRUE, sep="\t", na.strings="NA", dec=".")
deriv <- function(t,y,p)
{
  c = 1
  with(as.list(c(p, y)), {
    dS <- - c*beta *S*I/(S+I) + gamma * I
    dI <- c*beta *S*I/(S+I) - gamma *I
    list(c(dS,dI))
  })
}
N = 44
Tmax = length(data[,1])
par_benoit = read.csv(args[1], header=FALSE)
par <- list(beta=par_benoit[1,2], gamma=par_benoit[2,2])
V <- c(S=N-1, I=1)
comparts <- lsoda(V, 1:Tmax, deriv, parms=par)
count = 0
for (i in 1:Tmax)
{
  write.table(as.matrix(t(c(count,"I",i,"I",comparts[i,3]))), file=args[2], quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
  count = count + 1
  write.table(as.matrix(t(c(count,"S",i,"S",comparts[i,2]))), file=args[2], quote=FALSE, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
  count = count + 1
}
