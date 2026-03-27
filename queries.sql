-- ============================================================
--  Student Grade Management System
--  File: queries.sql
--  Description: Useful queries, analytics, and reports
-- ============================================================

USE grade_management;

-- ─────────────────────────────────────────
--  1. ALL STUDENTS WITH GPA (sorted best → worst)
-- ─────────────────────────────────────────
SELECT student_name, department, gpa, total_credits
FROM student_gpa
ORDER BY gpa DESC;


-- ─────────────────────────────────────────
--  2. FULL TRANSCRIPT FOR A SPECIFIC STUDENT
--     (change the student_id value as needed)
-- ─────────────────────────────────────────
CALL get_student_report(1);


-- ─────────────────────────────────────────
--  3. COURSE PERFORMANCE SUMMARY
-- ─────────────────────────────────────────
SELECT course_code, title, instructor,
       enrolled_count, avg_score, highest_score, lowest_score, fail_count
FROM course_performance
ORDER BY avg_score DESC;


-- ─────────────────────────────────────────
--  4. TOP 3 STUDENTS IN EACH COURSE
-- ─────────────────────────────────────────
SELECT course_code, student_name, total_score, letter_grade
FROM (
    SELECT
        c.course_code,
        CONCAT(s.first_name, ' ', s.last_name) AS student_name,
        g.total_score,
        g.letter_grade,
        RANK() OVER (PARTITION BY c.course_id ORDER BY g.total_score DESC) AS rnk
    FROM courses      c
    JOIN enrollments  e ON c.course_id    = e.course_id
    JOIN students     s ON e.student_id   = s.student_id
    JOIN grades       g ON e.enrollment_id = g.enrollment_id
) ranked
WHERE rnk <= 3
ORDER BY course_code, rnk;


-- ─────────────────────────────────────────
--  5. STUDENTS WHO FAILED ANY COURSE
-- ─────────────────────────────────────────
SELECT CONCAT(s.first_name, ' ', s.last_name) AS student_name,
       c.course_code, c.title, g.total_score, g.letter_grade
FROM grades       g
JOIN enrollments  e ON g.enrollment_id = e.enrollment_id
JOIN students     s ON e.student_id    = s.student_id
JOIN courses      c ON e.course_id     = c.course_id
WHERE g.letter_grade = 'F'
ORDER BY student_name;


-- ─────────────────────────────────────────
--  6. DEPARTMENT AVERAGE GPA LEADERBOARD
-- ─────────────────────────────────────────
SELECT department, ROUND(AVG(gpa), 2) AS avg_gpa, COUNT(*) AS student_count
FROM student_gpa
GROUP BY department
ORDER BY avg_gpa DESC;


-- ─────────────────────────────────────────
--  7. ATTENDANCE RATE PER STUDENT
-- ─────────────────────────────────────────
SELECT
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    COUNT(*)                                AS total_sessions,
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) AS present_count,
    ROUND(
        100.0 * SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS attendance_pct
FROM attendance   a
JOIN enrollments  e ON a.enrollment_id = e.enrollment_id
JOIN students     s ON e.student_id    = s.student_id
GROUP BY s.student_id, student_name
ORDER BY attendance_pct DESC;


-- ─────────────────────────────────────────
--  8. GRADE DISTRIBUTION (A / B / C / D / F) PER COURSE
-- ─────────────────────────────────────────
SELECT
    c.course_code,
    SUM(CASE WHEN g.letter_grade LIKE 'A%' THEN 1 ELSE 0 END) AS A_count,
    SUM(CASE WHEN g.letter_grade LIKE 'B%' THEN 1 ELSE 0 END) AS B_count,
    SUM(CASE WHEN g.letter_grade LIKE 'C%' THEN 1 ELSE 0 END) AS C_count,
    SUM(CASE WHEN g.letter_grade = 'D'     THEN 1 ELSE 0 END) AS D_count,
    SUM(CASE WHEN g.letter_grade = 'F'     THEN 1 ELSE 0 END) AS F_count
FROM courses      c
JOIN enrollments  e ON c.course_id     = e.course_id
JOIN grades       g ON e.enrollment_id = g.enrollment_id
GROUP BY c.course_id, c.course_code
ORDER BY c.course_code;


-- ─────────────────────────────────────────
--  9. STUDENTS WHO IMPROVED (midterm → final)
-- ─────────────────────────────────────────
SELECT
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    c.course_code,
    g.midterm_score,
    g.final_score,
    ROUND(g.final_score - g.midterm_score, 2) AS improvement
FROM grades       g
JOIN enrollments  e ON g.enrollment_id = e.enrollment_id
JOIN students     s ON e.student_id    = s.student_id
JOIN courses      c ON e.course_id     = c.course_id
WHERE g.final_score > g.midterm_score
ORDER BY improvement DESC;


-- ─────────────────────────────────────────
--  10. INSTRUCTOR COURSE LOAD & AVG STUDENT SCORE
-- ─────────────────────────────────────────
SELECT
    CONCAT(i.first_name, ' ', i.last_name) AS instructor_name,
    COUNT(DISTINCT c.course_id)             AS courses_taught,
    COUNT(e.enrollment_id)                  AS total_students,
    ROUND(AVG(g.total_score), 2)            AS avg_student_score
FROM instructors  i
JOIN courses      c ON i.instructor_id  = c.instructor_id
JOIN enrollments  e ON c.course_id      = e.course_id
LEFT JOIN grades  g ON e.enrollment_id  = g.enrollment_id
GROUP BY i.instructor_id, instructor_name
ORDER BY avg_student_score DESC;
