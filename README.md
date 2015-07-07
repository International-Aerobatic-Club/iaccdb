[![Travis Test Status](https://travis-ci.org/wbreeze/iaccdb.svg)](https://travis-ci.org/wbreeze/iaccdb)

This project contains code for a Ruby-on-Rails web site that displays data
about Aerobatic Contests of the International Aerobatic club.

Find the site deployed at http://iaccdb.iac.org/

For more information contact Douglas Lovell, doug@wbreeze.com

Here are some further development items, beginning with work items definitely in the queue:

- parse the collegiate participation data now coming in from JaSPer in order to set up the collegiate computations (must do soon)
- enable entry of Nationals Chief Judge assistants (must do).
- enable multiple Chief Judge assistants.
- vastly simplify the data schema, incrementally, from 
[as-is](https://github.com/wbreeze/iaccdb/blob/master/doc/iaccdb_schema.pdf) 
[to-be](https://github.com/wbreeze/iaccdb/blob/master/doc/iaccdb_schema_to_be.pdf)
  - replace references to the f_results table with direct references to the flights table
  - remove the f_result table
  - replace references to the c_results table with direct references to category and contest
  - remove the c_result table
  - remove the unnecessary relations among computed result tables
  - replace use of the regional_pilots and region_contests tables with use of the results and result_accums tables
  - remove the regional_pilots and region_contests tables
- incrementally extend the RESTful JSON API that enables anyone to pull this data and do useful things with it 
- use the data for some statistical analysis projects and research
- add a system of authorizations/keys for specific roles on specific contests/flights
- add an AJAXy interface for selecting and adding members into the many member roles
- add an AJAXy interface for selecting and adding airplanes
- add an AJAXy interface for selecting and editing sequences
- add authorized edit screens for scoring director, chief judge table, boundary judge, and line judge roles
- add SVG capability for representing and displaying figures
- extend the sequence models with catalog numbers and figure representations

