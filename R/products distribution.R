# x <- sample(10:20, 44, TRUE)

stats_hist <- read.csv("/Users/ubathsu/temp/stats.csv", header = TRUE)

head(stats_hist)
stats_hist <- select(stats_hist, RANGE_HI_KEY,EQ_ROWS)
head(stats_hist)
summary(stats_hist)



productids <- read.table("/Users/ubathsu/temp/productID.csv", header=TRUE)

hist(productids)
hist(productids$X.ProductID, main = 'Distribution of Product ID' ,border = "blue", breaks = 12)
str(productids)
summary(productids)

## SQL Server Statistics representation for ProductID
ggplot(data=stats_hist, aes(x=as.factor(RANGE_HI_KEY), y=EQ_ROWS, fill=EQ_ROWS)) + 
  geom_bar(stat="identity", breaks=seq(700, 1000, by=1)) + 
  labs(x="RANGE_HI_KEY", y="EQ_ROWS", title="SQL Server statistics representation for ProductID") + 
  scale_fill_gradient("EQ_ROWS", low = "green", high = "red")  
  # + coord_flip()

## Distribution of all the product ids of Sales.SalesOrder table
ggplot(data=productids, aes(productids$X.ProductID)) + 
    geom_histogram(col="red",fill="green",alpha = .2, breaks=seq(700, 1000, by=1)) + 
    labs(title="Distribution of Product ID") + 
    labs(x="ProductID", y="EQ_ROWS") + 
    scale_fill_gradient("EQ_ROWS", low = "green", high = "red") 
    geom_density(col=2)  ## ???


table(productids$X.ProductID)

lines(density(productids$X.ProductID))

head(stats)
stats
summary(stats)
str(stats)

install.packages('ggplot2', dep = TRUE)
library(ggplot2)

install.packages('sqldf')
library(sqldf)

install.packages('dplyr')
library(dplyr)

hist(stats$EQ_ROWS)

hist(stats, xlim=as.numeric(stats$RANGE_ROWS), ylim=stats$EQ_ROWS)