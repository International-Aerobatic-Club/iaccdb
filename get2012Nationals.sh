wget -rNp -l inf -np http://nationals.iac.org/files/results/au/index_au.htm
wget -rNp -l inf -np http://nationals.iac.org/files/results/psi/index_psi.htm
cat nationals.iac.org/files/results/au/single_*.htm | python stripPilots.py au
cat nationals.iac.org/files/results/au/multi_*.htm | python stripPilots.py au
cat nationals.iac.org/files/results/psi/single_*.htm | python stripPilots.py psi
cat nationals.iac.org/files/results/psi/multi_*.htm | python stripPilots.py psi
