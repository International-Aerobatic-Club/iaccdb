wget -rNp -l inf -np http://nationals.iac.org/files/results/index.htm
cat nationals.iac.org/files/results/single_*.htm | python stripPilots.py 2013
cat nationals.iac.org/files/results/multi_*.htm | python stripPilots.py 2013
