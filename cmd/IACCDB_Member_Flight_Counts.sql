SELECT 
    e.family_name, e.given_name, COUNT(1) AS `flights`
FROM
    iaccdb.pf_results a
        JOIN
    pilot_flights b ON a.pilot_flight_id = b.id
        JOIN
    flights c ON c.id = b.flight_id
        JOIN
    contests d ON d.id = c.contest_id
        JOIN
    members e ON e.id = b.pilot_id
WHERE
    YEAR(d.start) = 2015
GROUP BY e.id
ORDER BY `flights` DESC;