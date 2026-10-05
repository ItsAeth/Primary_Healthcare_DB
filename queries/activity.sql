-- ACTIVIDAD DEL CENTRO

--¿Cuántas citas hay por estado y modalidad (número y porcentaje del total)?
SELECT
    estado, 
    COUNT(id) AS Numero_de_citas, 
    ROUND(COUNT(id) * 100 / (SELECT COUNT(id) FROM citas), 2) AS porcentaje
FROM citas
GROUP BY estado;

SELECT
    modalidad, 
    COUNT(id) AS Numero_de_citas, 
    ROUND(COUNT(id) * 100 / (SELECT COUNT(id) FROM citas), 2) AS porcentaje
FROM citas
GROUP BY modalidad;

-- Porcentaje de no presentados respecto al resto de las citas planificadas
SELECT
    CASE 
        WHEN estado = 'No presentado' THEN 'No presentado'
        ELSE 'Resto'
    END AS presentado_o_no,
    COUNT(*) as num_citas,
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM citas), 2) AS porcentaje
FROM citas
GROUP BY presentado_o_no;

-- Días de la semana con más citas
WITH dias_semana AS (
    SELECT EXTRACT('ISODOW' FROM inicio) as dia
    FROM citas
)
SELECT ds.dia, COUNT(*) AS num_citas
FROM dias_semana ds
GROUP BY ds.dia
ORDER BY num_citas DESC;

-- ¿Quieren son los profesionales de cada especialidad que más citas atienden (Aceptadas y Finalizadas)?

WITH
emp_sanitarios AS (
    SELECT 
        e.id,
        s.especialidad
    FROM empleados e 
    JOIN info_sanitarios s ON e.id = s.id_empleado
),
emp_sanitarios_ranked AS (
    SELECT
        es.id,
        es.especialidad,
        COUNT(c.id) as num_citas_atendidas,
        RANK() OVER (
            PARTITION BY es.especialidad
            ORDER BY COUNT(c.id) DESC
        ) AS ranking
    FROM citas c JOIN emp_sanitarios es ON c.id_sanitario = es.id
    WHERE c.estado IN ('Finalizada', 'Aceptada')
    GROUP BY es.especialidad, es.id
)
SELECT
    esr.ranking as ranking_en_especialidad,
    esr.num_citas_atendidas,
    esr.especialidad,
    e.num_id,
    COALESCE (
        e.nombre || ' ' || e.apellido1 || ' ' || e.apellido2,
        e.nombre || ' ' || e.apellido1 ) 
    as nombre_completo
FROM emp_sanitarios_ranked esr JOIN empleados e ON e.id = esr.id
ORDER BY esr.especialidad ASC, esr.ranking ASC;

-- EPISODIOS

-- Recuento y duración promedio de cada tipo de episodio.
SELECT 
    tipo_episodio,
    COUNT(*) AS recuento,
    TO_CHAR(AVG(fin - inicio), 'HH24:MI:SS') AS duracion_media
FROM episodio
GROUP BY tipo_episodio
ORDER BY recuento DESC, duracion_media ASC;

-- Los 2 diagnósticos más frecuentes por tipo de episodio (con empates)
WITH ranked as (
    SELECT 
        tipo_episodio,
        COALESCE(id_diag_snomed, 'Sin diagnóstico') AS diagnostico,
        RANK() OVER (
            PARTITION BY tipo_episodio
            ORDER BY COUNT(*) DESC
        ) as ranking
    FROM episodio
    GROUP BY tipo_episodio, id_diag_snomed
)
SELECT *
FROM ranked
WHERE ranking <= 2
ORDER BY tipo_episodio, ranking;

-- ¿Qué nivel de triaje y resultado tienen los episodios de urgencias que más duran en promedio?
SELECT 
    nivel_triaje,
    resultado, 
    COUNT(*) AS recuento,
    TO_CHAR(AVG(fin-inicio), 'HH24:MI:SS') as duracion_media
FROM episodio
WHERE tipo_episodio = 'Urgencia'
GROUP BY nivel_triaje, resultado
ORDER BY duracion_media DESC

-- Evolución de episodios por periodo (día, mes, año)
SELECT
    EXTRACT(MONTH FROM inicio) AS mes,
    COUNT(*) AS recuento
FROM episodio
GROUP BY mes
ORDER BY mes;

SELECT
    EXTRACT(DAY FROM inicio) AS dia,
    COUNT(*) AS recuento
FROM episodio
GROUP BY dia
ORDER BY dia;

SELECT
    EXTRACT(YEAR FROM inicio) AS año,
    COUNT(*) AS recuento
FROM episodio
GROUP BY año
ORDER BY año;

/*
Citas asociadas a episodios
Se podría saber si una cita está asociada a un episodio si la fecha de la cita, el paciente y el profesional coinciden.
La hora te atención real (es decir, de inicio del episodio) no siempre coincidirá con la hora prevista para la cita.
Lo mismo sucede con el final de la cita y del episodio. Por ese motivo, utilizar la hora exacta no es fiable para inferir
la relación entre citas y episodios.

*/

 -- Extraemos el sanitario, el paciente y la fecha de las citas (sin hora)
WITH 
fechas_cita AS (                   
    SELECT 
        id_sanitario,
        id_paciente,
        DATE(inicio) as fecha_cita
    FROM citas
),
-- Extraemos los detalles de episodio el sanitario. La fecha sin hora.
fechas_episodio AS (                
    SELECT 
        id as id_episodio,
        id_sanitario,
        id_paciente,
        tipo_episodio,
        procedencia,
        tipo_consulta,
        id_snomed_motivo_consulta,
        DATE(inicio) as fecha_episodio
    FROM episodio
)
-- Usamos JOIN (INNER JOIN) para obtener solo las coincidencias con los detalles del episodio
SELECT fe.*                                         
FROM fechas_cita fc JOIN fechas_episodio fe ON (
    fc.id_sanitario = fe.id_sanitario
    AND
    fc.id_paciente = fe.id_paciente
    AND
    fc.fecha_cita = fe.fecha_episodio
)