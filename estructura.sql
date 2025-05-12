--Tabla Usuario
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    sexo CHAR(1) CHECK (sexo IN ('M', 'F')) NOT NULL,
    altura NUMERIC(5,2) CHECK (altura > 0) NOT NULL,
    peso_inicial NUMERIC(5,2) CHECK (peso_inicial > 0) NOT NULL,
    peso_actual NUMERIC(5,2) DEFAULT 0 CHECK (peso_actual >= 0)
);

--Tabla Entrenador
CREATE TABLE Entrenador (
    id_entrenador SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL
);

-- Tabla Rutina
CREATE TABLE Rutina (
    id_rutina SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    objetivo VARCHAR(50) NOT NULL,
    duracion_aproximada INTERVAL NOT NULL
);

-- Tabla Ejercicio
CREATE TABLE Ejercicio (
    id_ejercicio SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tipo VARCHAR(30) CHECK (tipo IN ('Cardio', 'Fuerza', 'Flexibilidad', 'Otro')) NOT NULL,
    zona_muscular VARCHAR(50) NOT NULL
);

-- Tabla Progreso
CREATE TABLE Progreso (
    id_progreso SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    peso NUMERIC(5,2) CHECK (peso > 0) NOT NULL,
    grasa_corporal NUMERIC(4,2) CHECK (grasa_corporal BETWEEN 0 AND 100),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla Medida
CREATE TABLE Medida (
    id_medida SERIAL PRIMARY KEY,
    id_progreso INT NOT NULL,
    parte_cuerpo VARCHAR(30) NOT NULL,
    medida_cm NUMERIC(5,2) CHECK (medida_cm > 0) NOT NULL,
    FOREIGN KEY (id_progreso) REFERENCES Progreso(id_progreso) ON DELETE CASCADE
);

-- Tabla Registro_Entrenamiento
CREATE TABLE Registro_Entrenamiento (
    id_registro SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_rutina INT NOT NULL,
    fecha DATE DEFAULT CURRENT_DATE,
    duracion_real INTERVAL NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_rutina) REFERENCES Rutina(id_rutina)
);

-- Crear tabla con descanso como INTERVAL
CREATE TABLE Rutina_Ejercicio (
    id_rutina INT NOT NULL,
    id_ejercicio INT NOT NULL,
    series INT CHECK (series > 0),
    repeticiones INT CHECK (repeticiones > 0),
    descanso INTERVAL NOT NULL,
    PRIMARY KEY (id_rutina, id_ejercicio),
    FOREIGN KEY (id_rutina) REFERENCES Rutina(id_rutina),
    FOREIGN KEY (id_ejercicio) REFERENCES Ejercicio(id_ejercicio)
);


-- Tabla Usuario_Entrenador 
CREATE TABLE Usuario_Entrenador (
    id_usuario INT NOT NULL,
    id_entrenador INT NOT NULL,
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin DATE,
    PRIMARY KEY (id_usuario, id_entrenador),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_entrenador) REFERENCES Entrenador(id_entrenador)
);

-- Tabla Alimentacion
CREATE TABLE Alimentacion (
    id_alimentacion SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha DATE DEFAULT CURRENT_DATE,
    descripcion TEXT NOT NULL,
    calorias_totales INT CHECK (calorias_totales >= 0),
    proteinas NUMERIC(5,2) DEFAULT 0,
    carbohidratos NUMERIC(5,2) DEFAULT 0,
    grasas NUMERIC(5,2) DEFAULT 0,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);


-- 1. Trigger: Actualizar peso_actual automáticamente al registrar un nuevo progreso
CREATE OR REPLACE FUNCTION actualizar_peso_actual()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Usuario
    SET peso_actual = NEW.peso
    WHERE id_usuario = NEW.id_usuario;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_peso
AFTER INSERT ON Progreso
FOR EACH ROW
EXECUTE FUNCTION actualizar_peso_actual();

-- 2. Trigger: Validar que fecha_fin no sea menor que fecha_inicio en Usuario_Entrenador
CREATE OR REPLACE FUNCTION validar_fecha_fin()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin IS NOT NULL AND NEW.fecha_fin < NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha_fin no puede ser menor que fecha_inicio';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_fecha_fin
BEFORE INSERT OR UPDATE ON Usuario_Entrenador
FOR EACH ROW
EXECUTE FUNCTION validar_fecha_fin();

-- 3. Trigger: Validar que grasa corporal no supere 60%
CREATE OR REPLACE FUNCTION validar_grasa()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.grasa_corporal > 60 THEN
        RAISE EXCEPTION 'El porcentaje de grasa corporal no puede ser mayor a 60%%';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_grasa
BEFORE INSERT OR UPDATE ON Progreso
FOR EACH ROW
EXECUTE FUNCTION validar_grasa();



