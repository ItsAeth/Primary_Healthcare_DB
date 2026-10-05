-- PACIENTES

-- Perfil del paciente más habitual en el centro
-- Tasa de no presentación del paciente
-- Pacientes con más citas
-- Pacientes sin vacunaciones
-- Distribución de edad

-- HCE

-- Medicamentos y principio activo más comunes entre los pacientes.
-- Alergias más comunes entre los pacientes.
-- Nº de vacunas administradas por (periodo de tiempo)
-- Hábitos perjudiciales y tóxicos más frecuentes entre los pacientes.
-- Antecedentes más frecuentes entre los pacientes
-- Distribución por tipo de antecedente

/*
Obtener todos los registros relacionados con la historia clínica deL paciente con DNI '44556677D'.
Mostrar todas la información de cada regisstro, el nombre y los apellidos del paciente.

Las diferencias en la cantidad de columnas impide usar UNION ALL
*/

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_antecedentes r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_antecedentes_familiares r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_dispositivos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_alergias r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_situaciones_funcionales r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_habitos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_toxicos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_vacunaciones r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_medicamentos r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';

SELECT p.nombre, p.apellido1, p.apellido2 ,r.*
FROM registro_formulas_magistrales r JOIN pacientes p ON r.id = p.id
WHERE p.num_id = '44556677D';