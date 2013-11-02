wget -rNp -l inf -np http://www.civa-results.com/2013/WAC_2013/indexpage.htm
cat www.civa-results.com/2013/WAC_2013/single_*.htm | python stripPilotsAt.py http://www.civa-results.com/2013/WAC_2013/
cat www.civa-results.com/2013/WAC_2013/multi_*.htm | python stripPilotsAt.py http://www.civa-results.com/2013/WAC_2013/
