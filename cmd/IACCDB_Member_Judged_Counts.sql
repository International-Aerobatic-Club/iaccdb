SELECT 
    e.family_name, e.given_name, count(1) AS `flights`
FROM
    iaccdb.scores a
		join
    judges b on b.id = a.judge_id
        join
	pilot_flights c on c.id = a.pilot_flight_id
        join
    flights f on f.id = c.flight_id
        join
    contests d on d.id = f.contest_id
        JOIN
    members e ON e.id = b.judge_id
/* WHERE */
/*    year(d.start) = 2015 */
GROUP BY e.id
ORDER BY `flights` DESC;
