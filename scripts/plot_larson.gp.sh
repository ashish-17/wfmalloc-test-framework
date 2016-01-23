reset 

# uncomment the following lint to get the output on the terminal
# set term dumb

set term png size 1200,1200
set output outputDir."/larson.png"
print outputDir

# number of lines in one plot : ie, number of allocators
nLines = 4
nThreads = `head -1 ../configurations/larson`
nBlocks = "`head -2 ../configurations/larson | tail -1`"
minSize = "`head -3 ../configurations/larson | tail -1`"
maxSize = "`head -4 ../configurations/larson | tail -1`"
timeSlice = "`head -5 ../configurations/larson | tail -1`"

# size x, y tells the percentage of width and height of the plot window.
# x, y are multiplicative factors of 100%
set size 1,1
set multiplot title "Larson: minSize = ". word(minSize,1) . ", maxSize = " . word(maxSize, 1) 
unset key

# the starting column of time parameter. Before this column are the benchmark parameters.
startCol = 6 #"`wc -l ../configurations/larson`"
nPlotsY = words(nBlocks)
nPlotsX = words(timeSlice)

#colors = "red green blue violet pink"
titles = "glibc-malloc wfmalloc Hoard jemalloc"
#markers = "1 2 3 5 6"  # ["cross", "3 lines cross", "filled square"]
#linetype = "1 2 3 4" # ["solid", "dashed", "smaller dashes", "smaller dashes"]
columns(x) = x + (startCol - 1)
titleMargin = 0.03
originX = 0
originY = 1 - titleMargin  # 0.01 to accommodate the heading and legend
deltaX = 1.0/nPlotsX 
deltaY = (1.0-titleMargin)/nPlotsY
sizeX = deltaX
sizeY = deltaY
firstLine = 2
lastLine = firstLine + (nThreads - 2)

set xlabel "Number of Threads" #font "Times New Roman, 8"
set ylabel "# malloc/free pairs" #font "Times New Roman, 8"
#set key at 0,0 horizontal box
unset key
set size sizeX,sizeY
#set ytics 0,0.01

do for [k=1:nPlotsY] {
    originX = 0;
    originY = originY - deltaY;
    do for [j=1:nPlotsX] {
	set title "# objects=" . word(nBlocks,k) . ",timeSlice=" . word(timeSlice,j) #font "Times New Roman, 8"
	set origin originX,originY
        originX = originX + deltaX;
        #plot for [i=1:nLines] filename using 1:columns(i) every ::1::nThreads word(titles, i) lt 2 lc rgb word(colors, i) pt word(markers, i) with linespoints;
	plot for [i=1:nLines] outputDir."/outputLarson" using 1:columns(i) every ::firstLine::lastLine title word(titles,i) with linespoints
	firstLine = lastLine + 2
	lastLine = firstLine + (nThreads - 2)
   }
}

#############################################

unset origin
unset border
unset tics
unset label
unset arrow
unset title
unset object

set size 4,4

set key box 
set key horizontal samplen 1 width -4 maxrows 1 maxcols 12 
set key at screen 0.5,screen 0.97 center top

set xrange [-1:1]
set yrange [-1:1]

plot for [i=1:nLines] NaN title word(titles,i) with linespoints

#pause -1
unset multiplot


