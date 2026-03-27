-- ============================================================
--  Student Grade Management System
--  File: seed_data.sql
--  Description: Sample data to populate all tables
-- ============================================================

USE grade_management;

-- ─────────────────────────────────────────
--  DEPARTMENTS
-- ─────────────────────────────────────────
INSERT INTO departments (name, code) VALUES
('Computer Science',        'CS'),
('Artificial Intelligence', 'AI'),
('Information Systems',     'IS'),
('Mathematics',             'MATH'),
('Software Engineering',    'SE');

-- ─────────────────────────────────────────
--  INSTRUCTORS
-- ─────────────────────────────────────────
INSERT INTO instructors (first_name, last_name, email, department_id, hire_date) VALUES
('Ahmed',   'Hassan',    'a.hassan@uni.edu',    1, '2018-09-01'),
('Sara',    'Mahmoud',   's.mahmoud@uni.edu',   2, '2019-01-15'),
('Khaled',  'Nasser',    'k.nasser@uni.edu',    3, '2016-09-01'),
('Layla',   'Ibrahim',   'l.ibrahim@uni.edu',   4, '2020-02-10'),
('Omar',    'Farouk',    'o.farouk@uni.edu',    5, '2021-09-01');

-- ─────────────────────────────────────────
--  STUDENTS
-- ─────────────────────────────────────────
INSERT INTO students (first_name, last_name, email, department_id, enrollment_date, status) VALUES
('Jana',     'Elhenawy',  'jana@student.edu',     1, '2024-09-01', 'active'),
('Mona',     'Ali',       'mona@student.edu',     2, '2024-09-01', 'active'),
('Youssef',  'Kamal',     'youssef@student.edu',  1, '2023-09-01', 'active'),
('Nour',     'Said',      'nour@student.edu',     3, '2023-09-01', 'active'),
('Tarek',    'Fawzy',     'tarek@student.edu',    5, '2022-09-01', 'active'),
('Dina',     'Mostafa',   'dina@student.edu',     2, '2022-09-01', 'graduated'),
('Hana',     'Zaki',      'hana@student.edu',     4, '2024-09-01', 'active'),
('Kareem',   'Adel',      'kareem@student.edu',   1, '2023-09-01', 'active');

-- ─────────────────────────────────────────
--  COURSES
-- ─────────────────────────────────────────
INSERT INTO courses (course_code, title, credits, department_id, instructor_id, semester, year) VALUES
('CS101',  'Introduction to Programming',      3, 1, 1, 'Fall',   2024),
('CS201',  'Data Structures & Algorithms',     3, 1, 1, 'Spring', 2024),
('AI301',  'Machine Learning Fundamentals',    3, 2, 2, 'Fall',   2024),
('IS201',  'Database Systems',                 3, 3, 3, 'Spring', 2024),
('MATH201','Discrete Mathematics',             3, 4, 4, 'Fall',   2024),
('SE301',  'Software Engineering Principles',  3, 5, 5, 'Spring', 2024),
('CS301',  'Operating Systems',               3, 1, 1, 'Spring', 2024),
('AI201',  'Introduction to AI',              3, 2, 2, 'Fall',   2024);

-- ─────────────────────────────────────────
--  ENROLLMENTS
-- ─────────────────────────────────────────
INSERT INTO enrollments (student_id, course_id) VALUES
-- Jana (student 1)
(1, 1), (1, 5), (1, 8),
-- Mona (student 2)
(2, 3), (2, 8),
-- Youssef (student 3)
(3, 2), (3, 1), (3, 5),
-- Nour (student 4)
(4, 4), (4, 6),
-- Tarek (student 5)
(5, 6), (5, 7),
-- Dina (student 6)
(6, 3), (6, 4),
-- Hana (student 7)
(7, 5), (7, 1),
-- Kareem (student 8)
(8, 1), (8, 2), (8, 7);

-- ─────────────────────────────────────────
--  GRADES  (enrollment rows auto-created by trigger; we UPDATE them)
--  enrollment_id order follows INSERT above: 1-19
-- ─────────────────────────────────────────
UPDATE grades SET midterm_score = 88,  final_score = 92,  assignment_score = 95  WHERE enrollment_id = 1;
UPDATE grades SET midterm_score = 75,  final_score = 80,  assignment_score = 78  WHERE enrollment_id = 2;
UPDATE grades SET midterm_score = 91,  final_score = 89,  assignment_score = 93  WHERE enrollment_id = 3;
UPDATE grades SET midterm_score = 70,  final_score = 68,  assignment_score = 72  WHERE enrollment_id = 4;
UPDATE grades SET midterm_score = 85,  final_score = 88,  assignment_score = 90  WHERE enrollment_id = 5;
UPDATE grades SET midterm_score = 79,  final_score = 83,  assignment_score = 81  WHERE enrollment_id = 6;
UPDATE grades SET midterm_score = 95,  final_score = 97,  assignment_score = 98  WHERE enrollment_id = 7;
UPDATE grades SET midterm_score = 62,  final_score = 65,  assignment_score = 60  WHERE enrollment_id = 8;
UPDATE grades SET midterm_score = 88,  final_score = 90,  assignment_score = 85  WHERE enrollment_id = 9;
UPDATE grades SET midterm_score = 72,  final_score = 74,  assignment_score = 70  WHERE enrollment_id = 10;
UPDATE grades SET midterm_score = 90,  final_score = 93,  assignment_score = 91  WHERE enrollment_id = 11;
UPDATE grades SET midterm_score = 55,  final_score = 58,  assignment_score = 60  WHERE enrollment_id = 12;
UPDATE grades SET midterm_score = 93,  final_score = 95,  assignment_score = 97  WHERE enrollment_id = 13;
UPDATE grades SET midterm_score = 87,  final_score = 84,  assignment_score = 89  WHERE enrollment_id = 14;
UPDATE grades SET midterm_score = 78,  final_score = 76,  assignment_score = 80  WHERE enrollment_id = 15;
UPDATE grades SET midterm_score = 82,  final_score = 85,  assignment_score = 83  WHERE enrollment_id = 16;
UPDATE grades SET midterm_score = 69,  final_score = 71,  assignment_score = 73  WHERE enrollment_id = 17;
UPDATE grades SET midterm_score = 91,  final_score = 94,  assignment_score = 92  WHERE enrollment_id = 18;
UPDATE grades SET midterm_score = 76,  final_score = 79,  assignment_score = 77  WHERE enrollment_id = 19;

-- ─────────────────────────────────────────
--  ATTENDANCE (sample for first 3 students, 5 sessions)
-- ─────────────────────────────────────────
INSERT INTO attendance (enrollment_id, session_date, status) VALUES
(1, '2024-09-10', 'present'), (1, '2024-09-17', 'present'), (1, '2024-09-24', 'late'),
(1, '2024-10-01', 'present'), (1, '2024-10-08', 'present'),
(2, '2024-09-10', 'present'), (2, '2024-09-17', 'absent'), (2, '2024-09-24', 'present'),
(2, '2024-10-01', 'excused'), (2, '2024-10-08', 'present'),
(3, '2024-09-10', 'present'), (3, '2024-09-17', 'present'), (3, '2024-09-24', 'present'),
(3, '2024-10-01', 'present'), (3, '2024-10-08', 'present');
