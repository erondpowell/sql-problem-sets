-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Who the thief is,
-- What city the thief escaped to, and
-- Who the thief’s accomplice is who helped them escape


-- CRIME REPORT INFO
SELECT * FROM crime_scene_reports WHERE description LIKE '%duck%';

-- id | year | month | day | street
-- 295 | 2020 | 7 | 28 | Chamberlin Street |
-- | description
-- Theft of the CS50 duck took place at 10:15am at the Chamberlin Street courthouse.
-- Interviews were conducted today with three witnesses who were present at the time
-- each of their interview transcripts mentions the courthouse.

-- CRIME REPORT INTERVIEW
SELECT *
FROM interviews
WHERE transcript LIKE "%courthouse%" AND MONTH = 7;

/*
-------------------- id | name | year | month | day | transcript --------------------
#### 161 | Ruth | 2020 | 7 | 28 |
Sometime within ten minutes of the theft, I saw the thief get
into a car in the courthouse parking lot and drive away.
If you have security footage from the courthouse parking lot,
you might want to look for cars that left the parking lot in that time frame.
#### 162 | Eugene | 2020 | 7 | 28 |
I don't know the thief's name, but it was someone I recognized.
Earlier this morning, before I arrived at the courthouse, I was walking
by the ATM on Fifer Street and saw the thief there withdrawing some money.
#### 163 | Raymond | 2020 | 7 | 28 |
As the thief was leaving the courthouse, they called
someone who talked to them for less than a minute.
In the call, I heard the thief say that they were
planning to take the earliest flight out of Fiftyville tomorrow.
The thief then asked the person on the
other end of the phone to purchase the flight ticket.

NOTES:
-- Gets into car ~10 around crime time ---> courthouse_security_logs
-- Fifer Street ATM. 7-28-202, AM. money withdrawal.
-- Phone call: <=60 seconds. as thief left courthouse.
               Leaves fiftyville at 7-29, earliest flight. Made friend buy ticket.

FIND PEOPLE WHO ON SAME DAY:
      AM courthouse security log
AND   AM withdrew money
AND   60 sec phonecall
AND   on EARLIEST 7-29 FLIGHT

*/

-- Queries license plates from courthouse security log
-- Yields: License Plates
SELECT *
FROM courthouse_security_logs
WHERE month = 7 AND day = 28 AND YEAR = 2020 AND hour = 10 AND minute BETWEEN 00 AND 30;

-- Queries ATM account numbers
-- Yields: acct_number, address, and amt_withdrawn
SELECT *
FROM atm_transactions
WHERE month = 7 AND day = 28 AND YEAR = 2020 AND transaction_type = 'withdraw' AND atm_location = 'Fifer Street';

-- Queries phone calls
-- Yields Caller and Callee Numbers
SELECT *
FROM phone_calls
WHERE month = 7 AND day = 28 AND YEAR = 2020 AND duration <= 60;

-- FIND who was at the atm, at the courthouse, on the phone and on the plane.
-- people: phone_number, license_plate, passport_number


-- Queries Fiftyville Airport Info.
SELECT *
FROM airports
WHERE abbreviation = 'CSF';


-- earliest 7-29 flight leaving fiftyville
--
SELECT *
FROM flights
WHERE
    month = 7
    AND day = 29
    AND year = 2020
    AND origin_airport_id = (
        SELECT id
        FROM airports
        WHERE abbreviation = 'CSF'
        )
    ORDER BY hour ASC AND
    ORDER BY minute ASC;

-- Queries passengers on earliest flight
SELECT *
FROM passengers
WHERE flight_id = (
        SELECT id
        FROM flights
        WHERE
            month = 7
            AND day = 29
            AND year = 2020
            AND origin_airport_id = (
                SELECT id
                FROM airports
                WHERE abbreviation = 'CSF'
                )
        ORDER BY hour ASC
        LIMIT 1);

-- Now we need to combine:
-- * from people WHERE
-- license_plate ----> courthouse_security_logs
-- account_number ----> atm_transactions
-- caller -----> phone_calls
-- passport_number -----> passengers on flight(id) = 36


--- FINAL QUERY: CASE SOLVED
--- This query returns who the thief is, and their accomlice.
--- The following query tells you where they escaped to.
WITH
    call_records AS (
        SELECT
            caller AS suspect_number,
            receiver AS accomplice_number,
            people.name AS accomplice_name
        FROM phone_calls
        JOIN people ON people.phone_number = accomplice_number
        WHERE month = 7 AND day = 28 AND YEAR = 2020 AND duration <= 60
    ),
    passenger_passports AS (
            SELECT passengers.passport_number
                FROM passengers
                WHERE flight_id = (
                    SELECT id
                    FROM flights
                    WHERE month = 7 AND day = 29 AND year = 2020
                        AND origin_airport_id = ( SELECT id FROM airports WHERE abbreviation = 'CSF')
                    ORDER BY hour ASC, minute ASC
                    LIMIT 1
                    )
    ),
    atm_records AS (
        SELECT
                bank_accounts.person_id
            FROM atm_transactions
            JOIN bank_accounts ON bank_accounts.account_number = atm_transactions.account_number
            JOIN people ON people.id = bank_accounts.person_id
            WHERE
                atm_transactions.month = 7
                AND atm_transactions.day = 28
                AND atm_transactions.year = 2020
                AND atm_transactions.transaction_type = 'withdraw'
                AND atm_transactions.atm_location = 'Fifer Street'
    ),
    lps_from_courthouse_sec_logs AS (
        SELECT license_plate
        FROM courthouse_security_logs
        WHERE month = 7 AND day = 28 AND YEAR = 2020 AND hour = 10 AND minute BETWEEN 00 AND 30
    )
SELECT *
FROM people
JOIN call_records ON call_records.suspect_number = people.phone_number
WHERE
    people.id IN atm_records
    AND people.license_plate IN lps_from_courthouse_sec_logs
    AND people.passport_number IN passenger_passports;


-- ESCAPE DESTINATION
-- This query tells you where the thief ran off to
SELECT airports.abbreviation, airports.full_name, flights.destination_airport_id, airports.city
FROM flights
JOIN airports ON airports.id = flights.destination_airport_id
WHERE month = 7 AND day = 29 AND year = 2020
    AND origin_airport_id = (SELECT id FROM airports WHERE abbreviation = 'CSF')
ORDER BY hour ASC, minute ASC
LIMIT 1;