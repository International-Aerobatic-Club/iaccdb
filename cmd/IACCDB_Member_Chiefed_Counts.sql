SELECT members.family_name, members.given_name, count(*) AS `chiefed`
FROM flights, pilot_flights, members
WHERE pilot_flights.flight_id = flights.id
  AND flights.chief_id = members.id
GROUP BY members.id
ORDER BY `chiefed` DESC;
