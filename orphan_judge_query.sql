select * from judges where not exists (select * from scores where judge_id = judges.id);
