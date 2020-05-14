--% Diario de cumplimiento de entrega
SELECT
       delivery_deadline,
       avg(sla_ok)
FROM
    (SELECT
        task.packid,
        package.deadlinetime as delivery_deadline,
        package.firstdeliverytime as delivery_time,
        CASE
            WHEN package.firstdeliverytime < package.deadlinetime
                THEN 1 ELSE 0 END as sla_ok
    FROM task JOIN package ON task.packid = package.packid
    WHERE ackstatus = 'Realizado com sucesso'
      AND waypointrole = 'Recipient Address'
      AND package.deadlinetime IS NOT NULL
      AND package.firstdeliverytime IS NOT NULL) as aux
GROUP BY delivery_deadline
ORDER BY delivery_deadline ASC;
​
​
--% Diario de cumplimiento por ciudad
​
SELECT
       public.itinerary.city,
       avg(sla_ok) as porcentage_sla
FROM
    (SELECT task.itineraryid,
            task.packid,
            package.deadlinetime as delivery_deadline,
            package.firstdeliverytime as delivery_time,
            CASE WHEN package.firstdeliverytime < package.deadlinetime
                THEN 1 ELSE 0 END as sla_ok
        FROM ds4a_team4.public.task
            JOIN package ON task.packid = package.packid
        WHERE ackstatus = 'Realizado com sucesso'
          AND waypointrole = 'Recipient Address'
          AND package.deadlinetime IS NOT NULL
          AND package.firstdeliverytime IS NOT NULL) as aux
    LEFT JOIN itinerary ON public.itinerary.itineraryid = aux.itineraryid
GROUP BY public.itinerary.city;
​
​
--% de cumplimiento por vehiculo
SELECT
       public.itinerary.transporttype,
       avg(sla_ok) as porcentage_sla
FROM
    (SELECT task.itineraryid,
            task.packid,
            package.deadlinetime as delivery_deadline,
            package.firstdeliverytime as delivery_time,
            CASE WHEN package.firstdeliverytime < package.deadlinetime
                THEN 1 ELSE 0 END as sla_ok
        FROM ds4a_team4.public.task JOIN package
            ON task.packid = package.packid
        WHERE ackstatus = 'Realizado com sucesso'
          AND waypointrole = 'Recipient Address'
          AND package.deadlinetime IS NOT NULL
          AND package.firstdeliverytime IS NOT NULL) as aux
    LEFT JOIN itinerary ON public.itinerary.itineraryid = aux.itineraryid
GROUP BY public.itinerary.transporttype;
​
--% de cumplimiento por tipo de servicio
SELECT
       public.itinerary.product,
       avg(sla_ok) as porcentage_sla
FROM
    (SELECT task.itineraryid,
            task.packid,
            package.deadlinetime as delivery_deadline,
            package.firstdeliverytime as delivery_time,
            CASE WHEN package.firstdeliverytime < package.deadlinetime
                THEN 1 ELSE 0 END as sla_ok
        FROM ds4a_team4.public.task JOIN package
            ON task.packid = package.packid
        WHERE ackstatus = 'Realizado com sucesso'
          AND waypointrole = 'Recipient Address'
          AND package.deadlinetime IS NOT NULL
          AND package.firstdeliverytime IS NOT NULL) as aux
    LEFT JOIN itinerary ON public.itinerary.itineraryid = aux.itineraryid
GROUP BY public.itinerary.product;
​
​
--% de cumplimiento por service level
SELECT
       public.itinerary.productversion,
       avg(sla_ok) as porcentage_sla
FROM
    (SELECT task.itineraryid,
            task.packid,
            package.deadlinetime as delivery_deadline,
            package.firstdeliverytime as delivery_time,
            CASE WHEN package.firstdeliverytime < package.deadlinetime
                THEN 1 ELSE 0 END as sla_ok
        FROM ds4a_team4.public.task JOIN package ON task.packid = package.packid
        WHERE ackstatus = 'Realizado com sucesso'
          AND waypointrole = 'Recipient Address'
          AND package.deadlinetime IS NOT NULL
          AND package.firstdeliverytime IS NOT NULL) as aux
    LEFT JOIN itinerary ON public.itinerary.itineraryid = aux.itineraryid
GROUP BY public.itinerary.productversion;
​
​
SELECT
       delivery_deadline,
       count(packid) total_delivered_packages
FROM
    (SELECT task.packid,
        package.deadlinetime as delivery_deadline,
        package.firstdeliverytime as delivery_time
    FROM ds4a_team4.public.task JOIN package ON task.packid = package.packid
    WHERE ackstatus = 'Realizado com sucesso'
      AND waypointrole = 'Recipient Address'
      AND package.deadlinetime IS NOT NULL
      AND package.firstdeliverytime IS NOT NULL) as aux
GROUP BY delivery_deadline
ORDER BY delivery_deadline ASC;
​
​
SELECT
        concat(round(CAST(itinerarydist.pickup_lat as numeric),4),' ',round(CAST(itinerarydist.pickup_lng as numeric),4))
            as pickup_location,
        sum(delivered_packages) as total_delivered_packages
FROM itinerarydist
WHERE delivered_packages IS NOT NULL AND pickup_lng IS NOT NULL AND pickup_lat IS NOT NULL
GROUP BY pickup_location
ORDER BY total_delivered_packages DESC;
​
SELECT
    avg(TO_TIMESTAMP(accepted,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')) as created_to_accepted,
    avg(TO_TIMESTAMP(started,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(accepted,'YY-MM-DD HH24:MI')) as accepted_to_started,
    avg(TO_TIMESTAMP(checked_in_at,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(started,'YY-MM-DD HH24:MI')) as started_to_check_in,
    avg(TO_TIMESTAMP(pickup_checkout_at,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(checked_in_at,'YY-MM-DD HH24:MI')) as check_in_to_check_out,
    avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI') - TO_TIMESTAMP(pickup_checkout_at,'YY-MM-DD HH24:MI')) as check_out_to_finish,
    avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')) as total_last_mile_delivery_time
FROM itinerarydist
WHERE status = 'finished';
​
SELECT
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(accepted,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')))/
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')))
        as created_to_accepted,
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(started,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(accepted,'YY-MM-DD HH24:MI')))/
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')))
        as accepted_to_started,
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(checked_in_at,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(started,'YY-MM-DD HH24:MI')))/
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')))
        as started_to_check_in,
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(pickup_checkout_at,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(checked_in_at,'YY-MM-DD HH24:MI')))/
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')))
        as check_in_to_check_out,
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(pickup_checkout_at,'YY-MM-DD HH24:MI')))/
    EXTRACT(epoch FROM avg(TO_TIMESTAMP(finished,'YY-MM-DD HH24:MI')-TO_TIMESTAMP(created,'YY-MM-DD HH24:MI')))
        as check_out_to_finish
FROM itinerarydist
WHERE status = 'finished';
​
