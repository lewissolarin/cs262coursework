from os import listdir
from os.path import isfile, join
from shutil import copyfile
import re
import mimetypes
import os
import time




# path where program file is stored
path = './'
# this is the list of expected answers to the example formulas
# example, 1,2,3,7,8,10
example1formula = 'x or neg x'
example1solution = 'YES'

question1formula = '((x imp y) and x) imp y'
question1solution = 'YES'

question2formula = '(neg x imp y) imp (neg (x notimp y) imp y)'
question2solution = 'YES'

question3formula = '((x imp y) and (y imp z)) imp (neg neg z or neg x)'
question3solution = 'YES'

question4formula = '(x imp (y imp z)) equiv ((x imp y) imp z'
question4solution = 'YES'

question5formula = '(x notequiv y) equiv (y notequiv x)'
question5solution = 'YES'

# question6formula = '(x notequiv (y notequiv z)) equiv ((x notequiv y) notequiv z)'
# question6solution = 'YES'

question7formula = '(neg x downarrow neg y) revimp neg (x uparrow y)'
question7solution = 'YES'

question8formula = '(neg x revimp neg y) and ((z notrevimp u) or (u uparrow neg v))'
question8solution = 'NO'

question9formula = '((x or y) imp (neg y notrevimp z)) or (neg neg (z equiv x) notrevimp y)'
question9solution = 'YES'

question10formula = '(neg (z notrevimp y) revimp x) imp ((x or w) imp ((y imp z) or w)'
question10solution = 'YES'


solutions = [example1solution, question1solution, question2solution, question3solution, question4solution , question5solution, question7solution, question9solution, question10solution]
# a list of all propositional formulas that we want to test the program on
formulas = [example1formula, question1formula, question2formula, question3formula, question4solution , question5formula, question7formula,  question9formula, question10solution]

# run the code with all the formulas as input
def run_tests():
  correct = 0
  for i in range(0,len(formulas)):
    f = formulas[i]
    copyfile(path + 'resolution.pl', 'test.pl')  # copy test file to current directory
    file = open('test.pl','a')
    file.write('\n\nmy_test:-test(' + f + ').')  # append test commands to this Prolog file
    file.close()
    
    # run Prolog interpreter
    # stdout is redirected to output file out.txt, stderr is dumped
    cmd = "swipl -l test.pl -t my_test. > out.txt 2>/dev/null"
    os.system(cmd)

    # read results from output file
    file = open('out.txt')
    fstr = file.read()

    file.close()
    answers = re.findall(r'YES|NO', fstr, re.IGNORECASE)  # search for occurences of yes/no in the output file
    print(answers)
    if (len(answers) == 0):
      print("  WARNING: no answer given for f=" + f)
      continue

    if (len(answers) > 1):
      print("  WARNING: multiple answers given for f=" + f)  # take the last one in this case

    a = answers[-1].upper()  # take the last answer given
    if (a == solutions[i]):
      correct += 1
      
  return correct
  
t = run_tests()
print("#correct answers=" + str(t) + "/" + str(len(formulas)))
