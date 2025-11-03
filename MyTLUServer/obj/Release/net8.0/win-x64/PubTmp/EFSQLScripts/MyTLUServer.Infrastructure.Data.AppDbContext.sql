IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [faculties] (
        [faculty_code] varchar(50) NOT NULL,
        [faculty_name] nvarchar(255) NOT NULL,
        [office_location] nvarchar(255) NULL,
        CONSTRAINT [PK__facultie__8492FC161C03FCE3] PRIMARY KEY ([faculty_code])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [login] (
        [username] varchar(50) NOT NULL,
        [password_hash] varchar(255) NULL,
        [email] varchar(255) NOT NULL,
        [account_status] varchar(10) NOT NULL DEFAULT 'active',
        [user_role] varchar(20) NOT NULL,
        [created_at] datetime2 NULL DEFAULT ((getdate())),
        [updated_at] datetime2 NULL DEFAULT ((getdate())),
        [updated_pos] varchar(255) NULL,
        CONSTRAINT [PK__login__F3DBC5739DC1CB05] PRIMARY KEY ([username])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [departments] (
        [dept_code] varchar(50) NOT NULL,
        [dept_name] nvarchar(255) NOT NULL,
        [faculty_code] varchar(50) NULL,
        CONSTRAINT [PK__departme__799C94D4FF2F2EB4] PRIMARY KEY ([dept_code]),
        CONSTRAINT [FK__departmen__facul__4316F928] FOREIGN KEY ([faculty_code]) REFERENCES [faculties] ([faculty_code]) ON DELETE SET NULL
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [students] (
        [student_code] varchar(50) NOT NULL,
        [full_name] nvarchar(255) NOT NULL,
        [phone_number] varchar(20) NULL,
        [date_of_birth] date NULL,
        [gender] varchar(10) NULL,
        [admin_class] nvarchar(100) NULL,
        [major_name] nvarchar(255) NULL,
        [intake_year] nvarchar(20) NULL,
        [admission_decision] nvarchar(500) NULL,
        [academic_status] nvarchar(200) NULL,
        [academic_status_1] nvarchar(200) NULL,
        CONSTRAINT [PK__students__6DF33C44888D9674] PRIMARY KEY ([student_code]),
        CONSTRAINT [FK__students__studen__4BAC3F29] FOREIGN KEY ([student_code]) REFERENCES [login] ([username]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [lecturers] (
        [lecturer_code] varchar(50) NOT NULL,
        [full_name] nvarchar(255) NOT NULL,
        [phone_number] varchar(20) NULL,
        [avatar_url] varchar(255) NULL,
        [date_of_birth] date NULL,
        [gender] varchar(10) NULL,
        [dept_code] varchar(50) NULL,
        [degree] nvarchar(100) NULL,
        [academic_rank] nvarchar(100) NULL,
        [office_location] nvarchar(255) NULL,
        CONSTRAINT [PK__lecturer__14870CE86B1976E8] PRIMARY KEY ([lecturer_code]),
        CONSTRAINT [FK__lecturers__dept___47DBAE45] FOREIGN KEY ([dept_code]) REFERENCES [departments] ([dept_code]) ON DELETE SET NULL,
        CONSTRAINT [FK__lecturers__lectu__46E78A0C] FOREIGN KEY ([lecturer_code]) REFERENCES [login] ([username]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [majors] (
        [major_code] varchar(50) NOT NULL,
        [major_name] nvarchar(255) NOT NULL,
        [dept_code] varchar(50) NULL,
        CONSTRAINT [PK__majors__0D732CA0B387A0D5] PRIMARY KEY ([major_code]),
        CONSTRAINT [FK__majors__dept_cod__5535A963] FOREIGN KEY ([dept_code]) REFERENCES [departments] ([dept_code]) ON DELETE SET NULL
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [subjects] (
        [subject_code] varchar(50) NOT NULL,
        [subject_name] nvarchar(255) NOT NULL,
        [credits] int NOT NULL,
        [dept_code] varchar(50) NULL,
        [sessions_per_week] int NULL DEFAULT 1,
        [session_duration_minutes] int NULL DEFAULT 90,
        [description] nvarchar(max) NULL,
        CONSTRAINT [PK__subjects__CEACD92125372766] PRIMARY KEY ([subject_code]),
        CONSTRAINT [FK__subjects__dept_c__59FA5E80] FOREIGN KEY ([dept_code]) REFERENCES [departments] ([dept_code]) ON DELETE SET NULL
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [face_data] (
        [id] int NOT NULL IDENTITY,
        [student_code] varchar(50) NULL,
        [image_path] varchar(255) NULL,
        [face_embedding] varchar(max) NULL,
        [is_active] bit NULL DEFAULT CAST(0 AS bit),
        [upload_status] varchar(20) NULL DEFAULT 'pending',
        [uploaded_at] datetime2 NULL,
        CONSTRAINT [PK__face_dat__3213E83FCA0C7994] PRIMARY KEY ([id]),
        CONSTRAINT [FK__face_data__stude__7B5B524B] FOREIGN KEY ([student_code]) REFERENCES [students] ([student_code]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [student_details] (
        [student_code] varchar(50) NOT NULL,
        [ethnicity] nvarchar(50) NULL,
        [religion] nvarchar(50) NULL,
        [contact_address] nvarchar(500) NULL,
        [father_full_name] nvarchar(255) NULL,
        [father_phone_number] varchar(20) NULL,
        [mother_full_name] nvarchar(255) NULL,
        [mother_phone_number] varchar(20) NULL,
        CONSTRAINT [PK__student___6DF33C449A1AB826] PRIMARY KEY ([student_code]),
        CONSTRAINT [FK__student_d__stude__5165187F] FOREIGN KEY ([student_code]) REFERENCES [students] ([student_code]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [student_identification] (
        [student_code] varchar(50) NOT NULL,
        [place_of_birth] nvarchar(255) NULL,
        [national_id] varchar(20) NULL,
        [id_issue_date] date NULL,
        [id_issue_place] nvarchar(255) NULL,
        CONSTRAINT [PK__student___6DF33C44764F526B] PRIMARY KEY ([student_code]),
        CONSTRAINT [FK__student_i__stude__4E88ABD4] FOREIGN KEY ([student_code]) REFERENCES [students] ([student_code]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [classes] (
        [class_code] varchar(50) NOT NULL,
        [class_name] nvarchar(255) NOT NULL,
        [subject_code] varchar(50) NULL,
        [lecturer_code] varchar(50) NULL,
        [academic_year] varchar(50) NULL,
        [semester] varchar(20) NULL,
        [max_students] int NULL,
        [class_start_date] date NULL,
        [class_end_date] date NULL,
        [schedule_summary] nvarchar(255) NULL,
        [default_location] nvarchar(255) NULL,
        [class_type] varchar(10) NULL,
        [class_status] varchar(20) NULL,
        CONSTRAINT [PK__classes__0AF9B2E5773F8499] PRIMARY KEY ([class_code]),
        CONSTRAINT [FK__classes__lecture__66603565] FOREIGN KEY ([lecturer_code]) REFERENCES [lecturers] ([lecturer_code]) ON DELETE SET NULL,
        CONSTRAINT [FK__classes__subject__656C112C] FOREIGN KEY ([subject_code]) REFERENCES [subjects] ([subject_code]) ON DELETE SET NULL
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [curriculum] (
        [major_code] varchar(50) NOT NULL,
        [subject_code] varchar(50) NOT NULL,
        [required] bit NULL DEFAULT CAST(1 AS bit),
        [program_status] varchar(20) NULL DEFAULT 'active',
        CONSTRAINT [PK__curricul__0199E1324817072C] PRIMARY KEY ([major_code], [subject_code]),
        CONSTRAINT [FK__curriculu__major__5FB337D6] FOREIGN KEY ([major_code]) REFERENCES [majors] ([major_code]) ON DELETE CASCADE,
        CONSTRAINT [FK__curriculu__subje__60A75C0F] FOREIGN KEY ([subject_code]) REFERENCES [subjects] ([subject_code])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [class_sessions] (
        [id] int NOT NULL IDENTITY,
        [class_code] varchar(50) NULL,
        [title] nvarchar(255) NULL,
        [session_date] date NULL,
        [start_time] time NULL,
        [end_time] time NULL,
        [session_location] nvarchar(255) NULL,
        [qr_code_data] varchar(max) NULL,
        [session_status] varchar(15) NULL,
        CONSTRAINT [PK__class_se__3213E83F0228B959] PRIMARY KEY ([id]),
        CONSTRAINT [FK__class_ses__class__6FE99F9F] FOREIGN KEY ([class_code]) REFERENCES [classes] ([class_code]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [enrollments] (
        [student_code] varchar(50) NOT NULL,
        [class_code] varchar(50) NOT NULL,
        [enrollment_status] varchar(20) NULL DEFAULT 'enrolled',
        CONSTRAINT [PK__enrollme__2D5CA76AE3AF2049] PRIMARY KEY ([student_code], [class_code]),
        CONSTRAINT [FK__enrollmen__class__6C190EBB] FOREIGN KEY ([class_code]) REFERENCES [classes] ([class_code]) ON DELETE CASCADE,
        CONSTRAINT [FK__enrollmen__stude__6B24EA82] FOREIGN KEY ([student_code]) REFERENCES [students] ([student_code]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE TABLE [attendance_records] (
        [id] int NOT NULL IDENTITY,
        [class_session_id] int NULL,
        [student_code] varchar(50) NULL,
        [attendance_status] varchar(10) NOT NULL,
        [check_in_time] datetime2 NULL,
        [method] varchar(10) NULL,
        [notes] nvarchar(max) NULL,
        CONSTRAINT [PK__attendan__3213E83FE14295E5] PRIMARY KEY ([id]),
        CONSTRAINT [FK__attendanc__class__74AE54BC] FOREIGN KEY ([class_session_id]) REFERENCES [class_sessions] ([id]),
        CONSTRAINT [FK__attendanc__stude__75A278F5] FOREIGN KEY ([student_code]) REFERENCES [students] ([student_code]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_attendance_records_class_session_id] ON [attendance_records] ([class_session_id]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_attendance_records_student_code] ON [attendance_records] ([student_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_class_sessions_class_code] ON [class_sessions] ([class_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_classes_lecturer_code] ON [classes] ([lecturer_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_classes_subject_code] ON [classes] ([subject_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_curriculum_subject_code] ON [curriculum] ([subject_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_departments_faculty_code] ON [departments] ([faculty_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [UQ__departme__C7D39AE14318276A] ON [departments] ([dept_name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_enrollments_class_code] ON [enrollments] ([class_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_face_data_student_code] ON [face_data] ([student_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [UQ__facultie__22BC13FB33FEDEFA] ON [faculties] ([faculty_name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_lecturers_dept_code] ON [lecturers] ([dept_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [UQ__login__AB6E6164EEF18533] ON [login] ([email]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_majors_dept_code] ON [majors] ([dept_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE UNIQUE INDEX [UQ__majors__B2815F7AA8862F7D] ON [majors] ([major_name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_subjects_dept_code] ON [subjects] ([dept_code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20251031161049_InitialCreate'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20251031161049_InitialCreate', N'9.0.10');
END;

COMMIT;
GO

