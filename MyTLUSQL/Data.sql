-- D? li?u cho 4 gi?ng viên
INSERT INTO users (user_code, password_hash, email, full_name, phone_number, user_role, account_status)
VALUES
('GV0001', 'hashed_password_1', 'dungcv@e.tlu.edu.vn', N'Cù Vi?t D?ng', '09' + CAST(FLOOR(RAND() * 100000000) AS VARCHAR(8)), 'lecturer', 'active'),
('GV0002', 'hashed_password_2', 'dungkt@e.tlu.edu.vn', N'Ki?u Tu?n D?ng', '03' + CAST(FLOOR(RAND() * 100000000) AS VARCHAR(8)), 'lecturer', 'active'),
('GV0003', 'hashed_password_3', 'huongntt@e.tlu.edu.vn', N'Nguy?n Th? Thu H??ng', '08' + CAST(FLOOR(RAND() * 100000000) AS VARCHAR(8)), 'lecturer', 'active'),
('GV0004', 'hashed_password_4', 'hanhnv@e.tlu.edu.vn', N'Nguy?n V?n H?nh', '09' + CAST(FLOOR(RAND() * 100000000) AS VARCHAR(8)), 'lecturer', 'active');

-- D? li?u cho 1000 sinh viên
DECLARE @student_loop_counter INT = 1;
DECLARE @user_code VARCHAR(50);
DECLARE @email VARCHAR(255);
DECLARE @full_name NVARCHAR(255);
DECLARE @year_code CHAR(1);
DECLARE @random_digits VARCHAR(4);
DECLARE @student_count INT = 1000;
DECLARE @phone_number VARCHAR(20);
DECLARE @phone_prefix VARCHAR(2);

DECLARE @first_names TABLE (name NVARCHAR(50));
INSERT INTO @first_names (name) VALUES (N'Nguy?n'), (N'Tr?n'), (N'Lê'), (N'Ph?m'), (N'Hoàng'), (N'V?'), (N'??ng'), (N'Bùi'), (N'??'), (N'H?'), (N'D??ng'), (N'Lý'), (N'Phan'), (N'Võ');
DECLARE @middle_names TABLE (name NVARCHAR(50));
INSERT INTO @middle_names (name) VALUES (N'V?n'), (N'Th?'), (N'H?u'), (N'??c'), (N'Minh'), (N'Thu'), (N'Thanh'), (N'Mai'), (N'Qu?c'), (N'Tùng'), (N'H?ng'), (N'Tr?ng'), (N'Công');
DECLARE @last_names TABLE (name NVARCHAR(50));
INSERT INTO @last_names (name) VALUES (N'Anh'), (N'Bình'), (N'Chung'), (N'D?ng'), (N'Giang'), (N'Hi?u'), (N'Khánh'), (N'Lan'), (N'Ph??ng'), (N'Linh'), (N'C??ng'), (N'Quang'), (N'Huy'), (N'Tú');

DECLARE @phone_prefixes TABLE (prefix VARCHAR(2));
INSERT INTO @phone_prefixes (prefix) VALUES ('09'), ('03'), ('08');

WHILE @student_loop_counter <= @student_count
BEGIN
    SET @year_code = CAST(FLOOR(RAND() * 4) + 2 AS CHAR(1));
    SET @random_digits = RIGHT('0000' + CAST(FLOOR(RAND() * 10000) AS VARCHAR(4)), 4);
    SET @user_code = '2' + @year_code + '5117' + @random_digits;
    SET @email = @user_code + '@e.tlu.edu.vn';
    SET @full_name = (SELECT TOP 1 name FROM @first_names ORDER BY NEWID()) + ' ' +
                     (SELECT TOP 1 name FROM @middle_names ORDER BY NEWID()) + ' ' +
                     (SELECT TOP 1 name FROM @last_names ORDER BY NEWID());
    SET @phone_prefix = (SELECT TOP 1 prefix FROM @phone_prefixes ORDER BY NEWID());
    SET @phone_number = @phone_prefix + CAST(FLOOR(RAND() * 100000000) AS VARCHAR(8));
    
    INSERT INTO users (user_code, password_hash, email, full_name, phone_number, user_role, account_status)
    VALUES (@user_code, 'hashed_password_' + @user_code, @email, @full_name, @phone_number, 'student', 'active');
    
    SET @student_loop_counter = @student_loop_counter + 1;
END;

---

-- D? li?u cho 5 môn h?c
INSERT INTO subjects (subject_code, subject_name, credits, description)
VALUES
('CNTT001', N'C?u trúc d? li?u và gi?i thu?t', 3, N'Nghiên c?u các c?u trúc d? li?u c? b?n và các thu?t toán liên quan.'),
('CNTT002', N'L?p trình h??ng ??i t??ng', 3, N'Tìm hi?u v? các nguyên lý và k? thu?t l?p trình h??ng ??i t??ng.'),
('CNTT003', N'C? s? d? li?u', 3, N'Gi?i thi?u v? các h? qu?n tr? c? s? d? li?u và ngôn ng? SQL.'),
('KTPM001', N'Phân tích và thi?t k? h? th?ng', 3, N'H?c cách phân tích yêu c?u và thi?t k? các h? th?ng ph?n m?m.'),
('KTPM002', N'Công ngh? ph?n m?m', 3, N'Nghiên c?u các mô hình, quy trình và công c? phát tri?n ph?n m?m.');

---

-- D? li?u cho 4 gi?ng viên trong b?ng lecturers
INSERT INTO lecturers (lecturer_code, department_name, degree, academic_rank, date_of_birth, gender, office_location)
VALUES
('GV0001', N'Khoa Công ngh? thông tin', N'Ti?n s?', N'Gi?ng viên', '1980-05-15', 'male', N'P202, Tòa C1'),
('GV0002', N'Khoa Công ngh? thông tin', N'Th?c s?', N'Gi?ng viên', '1985-08-20', 'male', N'P202, Tòa C1'),
('GV0003', N'Khoa Công ngh? thông tin', N'Th?c s?', N'Gi?ng viên', '1978-02-10', 'female', N'P203, Tòa C1'),
('GV0004', N'Khoa Công ngh? thông tin', N'Phó giáo s?, Ti?n s?', N'Gi?ng viên kiêm nhi?m', '1990-11-25', 'male', N'P203, Tòa C1');

---

-- D? li?u cho 15 l?p h?c
DECLARE @class_loop_counter INT = 1; 
DECLARE @class_code VARCHAR(50);
DECLARE @class_name NVARCHAR(255);
DECLARE @subject_code VARCHAR(50);
DECLARE @lecturer_code VARCHAR(50);
DECLARE @academic_year VARCHAR(50) = '2025-2026';
DECLARE @semester VARCHAR(20) = N'H?c k? 1';
DECLARE @max_students INT = 70;
DECLARE @class_start_date DATE;
DECLARE @class_end_date DATE;
DECLARE @schedule_summary NVARCHAR(255);
DECLARE @default_location NVARCHAR(255);
DECLARE @class_type VARCHAR(10);
DECLARE @class_status VARCHAR(20);
DECLARE @class_count INT = 15;
DECLARE @dept_code VARCHAR(4);
DECLARE @year_code_prefix CHAR(2);
DECLARE @location_option INT;

WHILE @class_loop_counter <= @class_count
BEGIN
    SELECT TOP 1 @subject_code = subject_code FROM subjects ORDER BY NEWID();
    SELECT TOP 1 @lecturer_code = lecturer_code FROM lecturers ORDER BY NEWID();

    IF LEFT(@subject_code, 4) = 'CNTT'
        SET @dept_code = 'CNTT';
    ELSE
        SET @dept_code = 'KTPM';

    SET @year_code_prefix = CAST(FLOOR(RAND() * 4) + 64 AS VARCHAR(2));
    DECLARE @class_number VARCHAR(2) = RIGHT('0' + CAST(@class_loop_counter AS VARCHAR(2)), 2);
    DECLARE @group_number VARCHAR(2) = RIGHT('0' + CAST(FLOOR(RAND() * 3) + 1 AS VARCHAR(1)), 2);
    
    SET @class_code = @year_code_prefix + @dept_code + @class_number + '_N' + @group_number;

    SET @class_name = (SELECT subject_name FROM subjects WHERE subject_code = @subject_code) + ' (' + @class_code + ')';
    SET @class_start_date = DATEADD(day, -FLOOR(RAND() * 90), GETDATE());
    SET @class_end_date = DATEADD(day, 90, @class_start_date);
    SET @class_type = 
        CASE 
            WHEN RAND() < 0.33 THEN 'theory'
            WHEN RAND() < 0.66 THEN 'lab'
            ELSE 'seminar'
        END;
    SET @class_status = CASE WHEN RAND() > 0.5 THEN 'in_progress' ELSE 'scheduled' END;

    SET @location_option = FLOOR(RAND() * 4);
    SET @default_location = 
        CASE @location_option
            WHEN 0 THEN N'Phòng h?c A2-301'
            WHEN 1 THEN N'Phòng h?c B3-402'
            WHEN 2 THEN N'Phòng máy tính C1-501'
            ELSE N'Gi?ng ???ng D-101'
        END;

    INSERT INTO classes (class_code, class_name, subject_code, lecturer_code, academic_year, semester, max_students, class_start_date, class_end_date, default_location, class_type, class_status)
    VALUES (@class_code, @class_name, @subject_code, @lecturer_code, @academic_year, @semester, @max_students, @class_start_date, @class_end_date, @default_location, @class_type, @class_status);

    SET @class_loop_counter = @class_loop_counter + 1;
END;

---

-- D? li?u cho b?ng students
INSERT INTO students (student_code, major_name, admin_class, date_of_birth, gender)
SELECT 
    u.user_code,
    CASE 
        WHEN SUBSTRING(u.user_code, 2, 1) IN ('2', '3') THEN N'Công ngh? thông tin'
        ELSE N'K? thu?t ph?n m?m' 
    END AS major_name,
    CAST(CAST(SUBSTRING(u.user_code, 2, 1) AS INT) + 62 AS VARCHAR(2)) + 
    CASE 
        WHEN SUBSTRING(u.user_code, 2, 1) IN ('2', '3') THEN 'CNTT' 
        ELSE 'KTPM' 
    END +
    RIGHT('0' + CAST((CAST(SUBSTRING(u.user_code, 7, 2) AS INT) % 3) + 1 AS VARCHAR(2)), 2) AS admin_class,
    DATEADD(day, -FLOOR(RAND() * 7300), GETDATE()),
    CASE 
        WHEN RAND() > 0.5 THEN 'male' 
        ELSE 'female' 
    END AS gender
FROM users u
WHERE u.user_role = 'student';

---

-- Chèn d? li?u vào b?ng class_sessions
DECLARE @session_class_code VARCHAR(50);
DECLARE @start_date DATE;
DECLARE @end_date DATE;
DECLARE @session_location NVARCHAR(255);
DECLARE @subject_code_session VARCHAR(50); -- ?ã ??i tên bi?n
DECLARE @sessions_to_create INT = 2;

DECLARE @subject_schedules TABLE (
    subject_code VARCHAR(50),
    day_of_week INT,
    day_of_week_name NVARCHAR(20),
    start_time TIME,
    end_time TIME
);

INSERT INTO @subject_schedules (subject_code, day_of_week, day_of_week_name, start_time, end_time)
VALUES
('CNTT001', 2, N'Th? Ba', '07:30:00', '09:00:00'),
('CNTT002', 4, N'Th? N?m', '13:30:00', '15:00:00'),
('CNTT003', 5, N'Th? Sáu', '09:00:00', '10:30:00'),
('KTPM001', 3, N'Th? T?', '10:00:00', '11:30:00'),
('KTPM002', 6, N'Th? B?y', '15:00:00', '16:30:00');

DECLARE classes_cursor CURSOR FOR
SELECT class_code, subject_code, class_start_date, class_end_date, default_location FROM classes;

OPEN classes_cursor;
FETCH NEXT FROM classes_cursor INTO @session_class_code, @subject_code_session, @start_date, @end_date, @session_location;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @day_of_week INT;
    DECLARE @start_time_session TIME;
    DECLARE @end_time_session TIME;
    
    SELECT @day_of_week = day_of_week, @start_time_session = start_time, @end_time_session = end_time
    FROM @subject_schedules WHERE subject_code = @subject_code_session;
    
    DECLARE @session_date DATE = @start_date;
    DECLARE @sessions_count INT = 1;

    WHILE @sessions_count <= @sessions_to_create
    BEGIN
        WHILE DATEPART(weekday, @session_date) != @day_of_week
        BEGIN
            SET @session_date = DATEADD(day, 1, @session_date);
        END;

        INSERT INTO class_sessions (class_code, title, session_date, start_time, end_time, session_location, qr_code_data, session_status)
        VALUES (
            @session_class_code, 
            N'Bu?i h?c #' + CAST(@sessions_count AS NVARCHAR(10)),
            @session_date,
            @start_time_session,
            @end_time_session,
            @session_location,
            NULL,
            'scheduled'
        );

        SET @session_date = DATEADD(week, 1, @session_date);
        SET @sessions_count = @sessions_count + 1;
    END;

    FETCH NEXT FROM classes_cursor INTO @session_class_code, @subject_code_session, @start_date, @end_date, @session_location;
END;

CLOSE classes_cursor;
DEALLOCATE classes_cursor;

---

-- C?p nh?t tr??ng schedule_summary cho t?ng l?p
UPDATE c
SET c.schedule_summary = CONCAT(s.day_of_week_name, ', ', LEFT(CAST(s.start_time AS VARCHAR(8)), 5), ' - ', LEFT(CAST(s.end_time AS VARCHAR(8)), 5))
FROM classes c
JOIN @subject_schedules s ON c.subject_code = s.subject_code;

---

-- Chèn d? li?u vào b?ng enrollments, ??m b?o không trùng l?ch
DECLARE @enrollment_student_code VARCHAR(50);
DECLARE @enrollment_class_code VARCHAR(50);
DECLARE @enrollment_count INT;

DECLARE student_enroll_cursor CURSOR LOCAL FOR
SELECT student_code FROM students;

OPEN student_enroll_cursor;
FETCH NEXT FROM student_enroll_cursor INTO @enrollment_student_code;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @enrollment_count = 0;
    
    DECLARE class_enroll_cursor CURSOR LOCAL FOR
    SELECT class_code FROM classes ORDER BY NEWID();

    OPEN class_enroll_cursor;
    FETCH NEXT FROM class_enroll_cursor INTO @enrollment_class_code;

    WHILE @@FETCH_STATUS = 0 AND @enrollment_count < 3
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE student_code = @enrollment_student_code AND class_code = @enrollment_class_code)
        BEGIN
            DECLARE @is_overlap BIT = 0;
            
            IF EXISTS (
                SELECT 1
                FROM class_sessions cs_new
                JOIN class_sessions cs_existing ON cs_new.session_date = cs_existing.session_date
                JOIN enrollments e ON cs_existing.class_code = e.class_code
                WHERE e.student_code = @enrollment_student_code
                AND cs_new.class_code = @enrollment_class_code
                AND (cs_new.start_time < cs_existing.end_time AND cs_existing.start_time < cs_new.end_time)
            )
            BEGIN
                SET @is_overlap = 1;
            END;

            IF @is_overlap = 0
            BEGIN
                INSERT INTO enrollments (student_code, class_code)
                VALUES (@enrollment_student_code, @enrollment_class_code);
                SET @enrollment_count = @enrollment_count + 1;
            END;
        END;
        FETCH NEXT FROM class_enroll_cursor INTO @enrollment_class_code;
    END;

    CLOSE class_enroll_cursor;
    DEALLOCATE class_enroll_cursor;
    
    FETCH NEXT FROM student_enroll_cursor INTO @enrollment_student_code;
END;

CLOSE student_enroll_cursor;
DEALLOCATE student_enroll_cursor;

---

-- Chèn d? li?u vào b?ng attendance_records
DECLARE @session_id INT;
DECLARE @session_class_code_ar VARCHAR(50);
DECLARE @student_code_ar VARCHAR(50);
DECLARE @attendance_status VARCHAR(10);
DECLARE @check_in_time DATETIME2;
DECLARE @method VARCHAR(10);
DECLARE @is_present_or_late BIT;

DECLARE sessions_cursor_ar CURSOR FOR
SELECT id, class_code FROM class_sessions;

OPEN sessions_cursor_ar;
FETCH NEXT FROM sessions_cursor_ar INTO @session_id, @session_class_code_ar;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE students_in_class_cursor CURSOR FOR
    SELECT student_code FROM enrollments WHERE class_code = @session_class_code_ar;
    
    OPEN students_in_class_cursor;
    FETCH NEXT FROM students_in_class_cursor INTO @student_code_ar;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @is_present_or_late = CASE WHEN RAND() > 0.1 THEN 1 ELSE 0 END;
        
        IF @is_present_or_late = 1
        BEGIN
            SET @attendance_status = CASE WHEN RAND() > 0.9 THEN 'late' ELSE 'present' END;
            SET @check_in_time = DATEADD(minute, FLOOR(RAND() * 20) - 10, GETDATE());
            SET @method = CASE WHEN RAND() > 0.5 THEN 'face_id' ELSE 'manual' END;
        END
        ELSE
        BEGIN
            SET @attendance_status = 'absent';
            SET @check_in_time = NULL;
            SET @method = NULL;
        END;

        INSERT INTO attendance_records (class_session_id, student_code, attendance_status, check_in_time, method)
        VALUES (@session_id, @student_code_ar, @attendance_status, @check_in_time, @method);

        FETCH NEXT FROM students_in_class_cursor INTO @student_code_ar;
    END;

    CLOSE students_in_class_cursor;
    DEALLOCATE students_in_class_cursor;

    FETCH NEXT FROM sessions_cursor_ar INTO @session_id, @session_class_code_ar;
END;

CLOSE sessions_cursor_ar;
DEALLOCATE sessions_cursor_ar;

---

-- Chèn d? li?u vào b?ng face_data
DECLARE @student_code_face VARCHAR(50);
DECLARE @image_path VARCHAR(255);
DECLARE @face_embedding VARCHAR(MAX);

DECLARE students_face_cursor CURSOR FOR
SELECT student_code FROM students;

OPEN students_face_cursor;
FETCH NEXT FROM students_face_cursor INTO @student_code_face;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @image_path = 'https://example.com/avatars/' + @student_code_face + '.jpg';
    SET @face_embedding = 'embedding_data_for_' + @student_code_face + '_123456';
    
    INSERT INTO face_data (student_code, image_path, face_embedding)
    VALUES (@student_code_face, @image_path, @face_embedding);

    FETCH NEXT FROM students_face_cursor INTO @student_code_face;
END;

CLOSE students_face_cursor;
DEALLOCATE students_face_cursor;