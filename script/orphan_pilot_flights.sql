select updated_at from pilot_flights where not exists (select id from flights where pilot_flights.flight_id = id);
