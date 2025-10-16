CREATE DATABASE Student_Attendance_DB;
GO
USE Student_Attendance_DB;
GO
CREATE TABLE users (
    user_code VARCHAR(50) PRIMARY KEY,
    password_hash VARCHAR(255) NOT NULL, --
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name NVARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    avatar_url VARCHAR(255),
    user_role VARCHAR(10) NOT NULL CHECK (user_role IN ('admin', 'lecturer', 'student')), --
    account_status VARCHAR(10) NOT NULL CHECK (account_status IN ('active', 'inactive')) DEFAULT 'active', --
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE lecturers (
    lecturer_code VARCHAR(50) PRIMARY KEY,
    department_name NVARCHAR(255), --
    degree NVARCHAR(100),
    academic_rank NVARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    office_location NVARCHAR(255),
    FOREIGN KEY (lecturer_code) REFERENCES users(user_code) ON DELETE CASCADE
);

CREATE TABLE students (
    student_code VARCHAR(50) PRIMARY KEY,
    major_name NVARCHAR(255), --
    admin_class NVARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    FOREIGN KEY (student_code) REFERENCES users(user_code) ON DELETE CASCADE
);

CREATE TABLE subjects (
    subject_code VARCHAR(50) PRIMARY KEY,
    subject_name NVARCHAR(255) NOT NULL,
    credits INT,
    description NVARCHAR(MAX)
);

CREATE TABLE classes (
    class_code VARCHAR(50) PRIMARY KEY,
    class_name NVARCHAR(255) NOT NULL,
    subject_code VARCHAR(50),
    lecturer_code VARCHAR(50),
    academic_year VARCHAR(50),
    semester NVARCHAR(20),
    max_students INT,
    class_start_date DATE, --
    class_end_date DATE, --
    schedule_summary NVARCHAR(255) null,
    default_location NVARCHAR(255) null,
    class_type VARCHAR(10) CHECK (class_type IN ('theory', 'lab', 'seminar')),
    class_status VARCHAR(20) CHECK (class_status IN ('scheduled', 'open', 'closed', 'in_progress', 'completed')), --
    FOREIGN KEY (subject_code) REFERENCES subjects(subject_code) ON DELETE SET NULL,
    FOREIGN KEY (lecturer_code) REFERENCES lecturers(lecturer_code) ON DELETE SET NULL
);

CREATE TABLE enrollments (
    student_code VARCHAR(50),
    class_code VARCHAR(50),
    PRIMARY KEY (student_code, class_code),
    FOREIGN KEY (student_code) REFERENCES students(student_code) ON DELETE CASCADE,
    FOREIGN KEY (class_code) REFERENCES classes(class_code) ON DELETE CASCADE
);

CREATE TABLE class_sessions ( --
    id INT PRIMARY KEY IDENTITY(1,1),
    class_code VARCHAR(50),
    title NVARCHAR(255),
    session_date DATE,
    start_time TIME,
    end_time TIME,
    session_location NVARCHAR(255), --
    qr_code_data VARCHAR(MAX),
    session_status VARCHAR(15) CHECK (session_status IN ('scheduled', 'completed', 'cancelled')),
    FOREIGN KEY (class_code) REFERENCES classes(class_code) ON DELETE CASCADE
);

CREATE TABLE attendance_records (
    id INT PRIMARY KEY IDENTITY(1,1),
    class_session_id INT, --
    student_code VARCHAR(50),
    attendance_status VARCHAR(10) NOT NULL CHECK (attendance_status IN ('present', 'absent', 'late', 'excused')), --
    check_in_time DATETIME2 NULL,
    method VARCHAR(10) CHECK (method IN ('face_id', 'manual')),
    notes NVARCHAR(MAX),
    FOREIGN KEY (class_session_id) REFERENCES class_sessions(id) ON DELETE NO ACTION, -- Tránh xóa l?ng nhau --
    FOREIGN KEY (student_code) REFERENCES students(student_code) ON DELETE CASCADE
);

CREATE TABLE face_data (
    id INT PRIMARY KEY IDENTITY(1,1),
    student_code VARCHAR(50),
    image_path VARCHAR(255) null,
    face_embedding VARCHAR(MAX) null,
    is_active BIT DEFAULT 0,
    uploaded_at DATETIME2 DEFAULT GETDATE() null,
    FOREIGN KEY (student_code) REFERENCES students(student_code) ON DELETE CASCADE
);
