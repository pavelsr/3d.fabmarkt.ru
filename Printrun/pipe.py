import subprocess
proc = subprocess.Popen(['python','pronsole.py'],stdout=subprocess.PIPE)
while True:
  line = proc.stdout.readline()
  if line != '':
    #the real code does filtering here
    print "load temp.g", line.rstrip()
  else:
    break
