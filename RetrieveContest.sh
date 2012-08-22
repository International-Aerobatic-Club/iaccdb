#!/bin/bash
curl -d "<ContestDetail><ContestID>$1</ContestID></ContestDetail>" http://donkeykong.highroaddata.com:1001/ >Contest_$1.txt
