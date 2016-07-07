

filename_input = 'write.result'
filename_output = 'write.result.analysis'

result = []

with open(filename_input, 'r') as fin:
    for line in fin.readlines():
        result.append( float(line.split()[-1]) )

average = 0
num = 0
balance_begin = 0            #by default
balance_end = len(result)-1  #by default  

import sys
if len(sys.argv) >=2:
    balance_begin = int(sys.argv[1])       #7
if len(sys.argv) >=3:
    balance_end = int(sys.argv[2])         #14

with open(filename_output, 'w') as fout:
    for i, x in enumerate(result):
        if i>=balance_begin and i<=balance_end:
            average += x
        fout.write('%.3f ' % x)
    fout.write('\nselected (%d ~ %d) - \n' % (balance_begin, balance_end))
    for x in result[balance_begin:balance_end+1]:
        fout.write('%.3f ' % x)
    fout.write('\nAverage from No.%d to No.%d is %f\n' % (balance_begin, balance_end, average/(balance_end-balance_begin+1)))

