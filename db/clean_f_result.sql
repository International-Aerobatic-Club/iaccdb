delete from f_results where flight_id not in (select id from flights);
delete from jf_results where f_result_id not in (select id from f_results);
delete from pf_results where f_result_id not in (select id from f_results);

