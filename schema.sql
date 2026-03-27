-- ============================================================
--  Student Grade Management System
--  File: schema.sql
--  Author: Jana Elhenawy
--  Description: Creates all tables for the grade management system
-- ============================================================

CREATE DATABASE IF NOT EXISTS grade_management;
USE grade_management;

-- ─────────────────────────────────────────
--  DEPARTMENTS
-- ─────────────────────────────────────────
CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    code            VARCHAR(10)  NOT NULL UNIQUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
--  INSTRUCTORS
-- ─────────────────────────────────────────
CREATE TABLE instructors (
    instructor_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    department_id   INT,
    hire_date       DATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

-- ─────────────────────────────────────────
--  STUDENTS
-- ─────────────────────────────────────────
CREATE TABLE students (
    student_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    department_id   INT,
    enrollment_date DATE         NOT NULL,
    status          ENUM('active', 'inactive', 'graduated') DEFAULT 'active',
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

-- ─────────────────────────────────────────
--  COURSES
-- ─────────────────────────────────────────
CREATE TABLE courses (
    course_id       INT AUTO_INCREMENT PRIMARY KEY,
    course_code     VARCHAR(20)  NOT NULL UNIQUE,
    title           VARCHAR(150) NOT NULL,
    credits         TINYINT      NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id   INT,
    instructor_id   INT,
    semester        ENUM('Fall', 'Spring', 'Summer') NOT NULL,
    year            YEAR NOT NULL,
    FOREIGN KEY (department_id)  REFERENCES departments(department_id)  ON DELETE SET NULL,
    FOREIGN KEY (instructor_id)  REFERENCES instructors(instructor_id)  ON DELETE SET NULL
);

-- ─────────────────────────────────────────
--  ENROLLMENTS
-- ─────────────────────────────────────────
CREATE TABLE enrollments (
    enrollment_id   INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT NOT NULL,
    course_id       INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    UNIQUE KEY uq_student_course (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)   ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  GRADES
-- ─────────────────────────────────────────
CREATE TABLE grades (
    grade_id        INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id   INT NOT NULL UNIQUE,
    midterm_score   DECIMAL(5,2) CHECK (midterm_score BETWEEN 0 AND 100),
    final_score     DECIMAL(5,2) CHECK (final_score   BETWEEN 0 AND 100),
    assignment_score DECIMAL(5,2) CHECK (assignment_score BETWEEN 0 AND 100),
    -- Weighted total: midterm 30% + final 50% + assignment 20%
    total_score     DECIMAL(5,2) GENERATED ALWAYS AS (
                        COALESCE(midterm_score, 0) * 0.30 +
                        COALESCE(final_score,   0) * 0.50 +
                        COALESCE(assignment_score, 0) * 0.20
                    ) STORED,
    letter_grade    CHAR(2) GENERATED ALWAYS AS (
                        CASE
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 93 THEN 'A+'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 90 THEN 'A'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 87 THEN 'A-'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 83 THEN 'B+'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 80 THEN 'B'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 77 THEN 'B-'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 73 THEN 'C+'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 70 THEN 'C'
                            WHEN (COALESCE(midterm_score,0)*0.30 + COALESCE(final_score,0)*0.50 + COALESCE(assignment_score,0)*0.20) >= 60 THEN 'D'
                            ELSE 'F'
                        END
                    ) STORED,
    recorded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  ATTENDANCE
-- ─────────────────────────────────────────
CREATE TABLE attendance (
    attendance_id   INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id   INT NOT NULL,
    session_date    DATE NOT NULL,
    status          ENUM('present', 'absent', 'late', 'excused') DEFAULT 'present',
    UNIQUE KEY uq_attendance (enrollment_id, session_date),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  VIEWS
-- ─────────────────────────────────────────

-- Full student transcript
CREATE VIEW student_transcript AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name)  AS student_name,
    s.email,
    d.name                                   AS department,
    c.course_code,
    c.title                                  AS course_title,
    c.credits,
    c.semester,
    c.year,
    g.midterm_score,
    g.final_score,
    g.assignment_score,
    g.total_score,
    g.letter_grade
FROM students s
JOIN enrollments  e ON s.student_id   = e.student_id
JOIN courses      c ON e.course_id    = c.course_id
JOIN departments  d ON s.department_id = d.department_id
LEFT JOIN grades  g ON e.enrollment_id = g.enrollment_id
ORDER BY s.student_id, c.year, c.semester;


-- GPA per student (4.0 scale)
CREATE VIEW student_gpa AS
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    d.name  AS department,
    ROUND(SUM(
        CASE g.letter_grade
            WHEN 'A+'THEN 4.0 WHEN 'A' THEN 4.0 WHEN 'A-'THEN 3.7
            WHEN 'B+'THEN 3.3 WHEN 'B' THEN 3.0 WHEN 'B-'THEN 2.7
            WHEN 'C+'THEN 2.3 WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0 ELSE 0.0
        END * c.credits
    ) / NULLIF(SUM(c.credits), 0), 2) AS gpa,
    SUM(c.credits) AS total_credits
FROM students     s
JOIN enrollments  e ON s.student_id    = e.student_id
JOIN courses      c ON e.course_id     = c.course_id
JOIN departments  d ON s.department_id = d.department_id
LEFT JOIN grades  g ON e.enrollment_id = g.enrollment_id
GROUP BY s.student_id, student_name, d.name;


-- Course performance summary
CREATE VIEW course_performance AS
SELECT
    c.course_code,
    c.title,
    c.semester,
    c.year,
    CONCAT(i.first_name, ' ', i.last_name) AS instructor,
    COUNT(e.enrollment_id)                  AS enrolled_count,
    ROUND(AVG(g.total_score), 2)            AS avg_score,
    MAX(g.total_score)                      AS highest_score,
    MIN(g.total_score)                      AS lowest_score,
    SUM(CASE WHEN g.letter_grade = 'F' THEN 1 ELSE 0 END) AS fail_count
FROM courses      c
JOIN enrollments  e  ON c.course_id    = e.course_id
JOIN instructors  i  ON c.instructor_id = i.instructor_id
LEFT JOIN grades  g  ON e.enrollment_id = g.enrollment_id
GROUP BY c.course_id, c.course_code, c.title, c.semester, c.year, instructor;


-- ─────────────────────────────────────────
--  TRIGGER: auto-create grade row on enroll
-- ─────────────────────────────────────────
DELIMITER $$
CREATE TRIGGER trg_init_grade
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
    INSERT INTO grades (enrollment_id) VALUES (NEW.enrollment_id);
END$$
DELIMITER ;


-- ─────────────────────────────────────────
--  STORED PROCEDURE: get full student report
-- ─────────────────────────────────────────
DELIMITER $$
CREATE PROCEDURE get_student_report(IN p_student_id INT)
BEGIN
    -- Basic info + GPA
    SELECT * FROM student_gpa WHERE student_id = p_student_id;
    -- Full transcript
    SELECT course_code, course_title, credits, semester, year,
           total_score, letter_grade
    FROM student_transcript
    WHERE student_id = p_student_id;
END$$
DELIMITER ;
