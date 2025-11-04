using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyTLUServer.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "faculties",
                columns: table => new
                {
                    faculty_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    faculty_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    office_location = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__facultie__8492FC161C03FCE3", x => x.faculty_code);
                });

            migrationBuilder.CreateTable(
                name: "login",
                columns: table => new
                {
                    username = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    password_hash = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: true),
                    email = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: false),
                    account_status = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: false, defaultValue: "active"),
                    user_role = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: true, defaultValueSql: "(getdate())"),
                    updated_at = table.Column<DateTime>(type: "datetime2", nullable: true, defaultValueSql: "(getdate())"),
                    updated_pos = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__login__F3DBC5739DC1CB05", x => x.username);
                });

            migrationBuilder.CreateTable(
                name: "departments",
                columns: table => new
                {
                    dept_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    dept_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    faculty_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__departme__799C94D4FF2F2EB4", x => x.dept_code);
                    table.ForeignKey(
                        name: "FK__departmen__facul__4316F928",
                        column: x => x.faculty_code,
                        principalTable: "faculties",
                        principalColumn: "faculty_code",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "students",
                columns: table => new
                {
                    student_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    full_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    phone_number = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    date_of_birth = table.Column<DateOnly>(type: "date", nullable: true),
                    gender = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: true),
                    admin_class = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    major_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    intake_year = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    admission_decision = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    academic_status = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    academic_status_1 = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__students__6DF33C44888D9674", x => x.student_code);
                    table.ForeignKey(
                        name: "FK__students__studen__4BAC3F29",
                        column: x => x.student_code,
                        principalTable: "login",
                        principalColumn: "username",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "lecturers",
                columns: table => new
                {
                    lecturer_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    full_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    phone_number = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    avatar_url = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: true),
                    date_of_birth = table.Column<DateOnly>(type: "date", nullable: true),
                    gender = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: true),
                    dept_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    degree = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    academic_rank = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    office_location = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__lecturer__14870CE86B1976E8", x => x.lecturer_code);
                    table.ForeignKey(
                        name: "FK__lecturers__dept___47DBAE45",
                        column: x => x.dept_code,
                        principalTable: "departments",
                        principalColumn: "dept_code",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK__lecturers__lectu__46E78A0C",
                        column: x => x.lecturer_code,
                        principalTable: "login",
                        principalColumn: "username",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "majors",
                columns: table => new
                {
                    major_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    major_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    dept_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__majors__0D732CA0B387A0D5", x => x.major_code);
                    table.ForeignKey(
                        name: "FK__majors__dept_cod__5535A963",
                        column: x => x.dept_code,
                        principalTable: "departments",
                        principalColumn: "dept_code",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "subjects",
                columns: table => new
                {
                    subject_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    subject_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    credits = table.Column<int>(type: "int", nullable: false),
                    dept_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    sessions_per_week = table.Column<int>(type: "int", nullable: true, defaultValue: 1),
                    session_duration_minutes = table.Column<int>(type: "int", nullable: true, defaultValue: 90),
                    description = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__subjects__CEACD92125372766", x => x.subject_code);
                    table.ForeignKey(
                        name: "FK__subjects__dept_c__59FA5E80",
                        column: x => x.dept_code,
                        principalTable: "departments",
                        principalColumn: "dept_code",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "face_data",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    student_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    image_path = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: true),
                    face_embedding = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    is_active = table.Column<bool>(type: "bit", nullable: true, defaultValue: false),
                    upload_status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true, defaultValue: "pending"),
                    uploaded_at = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__face_dat__3213E83FCA0C7994", x => x.id);
                    table.ForeignKey(
                        name: "FK__face_data__stude__7B5B524B",
                        column: x => x.student_code,
                        principalTable: "students",
                        principalColumn: "student_code",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "student_details",
                columns: table => new
                {
                    student_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    ethnicity = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    religion = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    contact_address = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    father_full_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    father_phone_number = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    mother_full_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    mother_phone_number = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__student___6DF33C449A1AB826", x => x.student_code);
                    table.ForeignKey(
                        name: "FK__student_d__stude__5165187F",
                        column: x => x.student_code,
                        principalTable: "students",
                        principalColumn: "student_code",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "student_identification",
                columns: table => new
                {
                    student_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    place_of_birth = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    national_id = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    id_issue_date = table.Column<DateOnly>(type: "date", nullable: true),
                    id_issue_place = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__student___6DF33C44764F526B", x => x.student_code);
                    table.ForeignKey(
                        name: "FK__student_i__stude__4E88ABD4",
                        column: x => x.student_code,
                        principalTable: "students",
                        principalColumn: "student_code",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "classes",
                columns: table => new
                {
                    class_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    class_name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    subject_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    lecturer_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    academic_year = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    semester = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    max_students = table.Column<int>(type: "int", nullable: true),
                    class_start_date = table.Column<DateOnly>(type: "date", nullable: true),
                    class_end_date = table.Column<DateOnly>(type: "date", nullable: true),
                    schedule_summary = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    default_location = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    class_type = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: true),
                    class_status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__classes__0AF9B2E5773F8499", x => x.class_code);
                    table.ForeignKey(
                        name: "FK__classes__lecture__66603565",
                        column: x => x.lecturer_code,
                        principalTable: "lecturers",
                        principalColumn: "lecturer_code",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK__classes__subject__656C112C",
                        column: x => x.subject_code,
                        principalTable: "subjects",
                        principalColumn: "subject_code",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "curriculum",
                columns: table => new
                {
                    major_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    subject_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    required = table.Column<bool>(type: "bit", nullable: true, defaultValue: true),
                    program_status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true, defaultValue: "active")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__curricul__0199E1324817072C", x => new { x.major_code, x.subject_code });
                    table.ForeignKey(
                        name: "FK__curriculu__major__5FB337D6",
                        column: x => x.major_code,
                        principalTable: "majors",
                        principalColumn: "major_code",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__curriculu__subje__60A75C0F",
                        column: x => x.subject_code,
                        principalTable: "subjects",
                        principalColumn: "subject_code");
                });

            migrationBuilder.CreateTable(
                name: "class_sessions",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    class_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    title = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    session_date = table.Column<DateOnly>(type: "date", nullable: true),
                    start_time = table.Column<TimeOnly>(type: "time", nullable: true),
                    end_time = table.Column<TimeOnly>(type: "time", nullable: true),
                    session_location = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    qr_code_data = table.Column<string>(type: "varchar(max)", unicode: false, nullable: true),
                    session_status = table.Column<string>(type: "varchar(15)", unicode: false, maxLength: 15, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__class_se__3213E83F0228B959", x => x.id);
                    table.ForeignKey(
                        name: "FK__class_ses__class__6FE99F9F",
                        column: x => x.class_code,
                        principalTable: "classes",
                        principalColumn: "class_code",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "enrollments",
                columns: table => new
                {
                    student_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    class_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: false),
                    enrollment_status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true, defaultValue: "enrolled")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__enrollme__2D5CA76AE3AF2049", x => new { x.student_code, x.class_code });
                    table.ForeignKey(
                        name: "FK__enrollmen__class__6C190EBB",
                        column: x => x.class_code,
                        principalTable: "classes",
                        principalColumn: "class_code",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK__enrollmen__stude__6B24EA82",
                        column: x => x.student_code,
                        principalTable: "students",
                        principalColumn: "student_code",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "attendance_records",
                columns: table => new
                {
                    id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    class_session_id = table.Column<int>(type: "int", nullable: true),
                    student_code = table.Column<string>(type: "varchar(50)", unicode: false, maxLength: 50, nullable: true),
                    attendance_status = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: false),
                    check_in_time = table.Column<DateTime>(type: "datetime2", nullable: true),
                    method = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: true),
                    notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__attendan__3213E83FE14295E5", x => x.id);
                    table.ForeignKey(
                        name: "FK__attendanc__class__74AE54BC",
                        column: x => x.class_session_id,
                        principalTable: "class_sessions",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK__attendanc__stude__75A278F5",
                        column: x => x.student_code,
                        principalTable: "students",
                        principalColumn: "student_code",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_attendance_records_class_session_id",
                table: "attendance_records",
                column: "class_session_id");

            migrationBuilder.CreateIndex(
                name: "IX_attendance_records_student_code",
                table: "attendance_records",
                column: "student_code");

            migrationBuilder.CreateIndex(
                name: "IX_class_sessions_class_code",
                table: "class_sessions",
                column: "class_code");

            migrationBuilder.CreateIndex(
                name: "IX_classes_lecturer_code",
                table: "classes",
                column: "lecturer_code");

            migrationBuilder.CreateIndex(
                name: "IX_classes_subject_code",
                table: "classes",
                column: "subject_code");

            migrationBuilder.CreateIndex(
                name: "IX_curriculum_subject_code",
                table: "curriculum",
                column: "subject_code");

            migrationBuilder.CreateIndex(
                name: "IX_departments_faculty_code",
                table: "departments",
                column: "faculty_code");

            migrationBuilder.CreateIndex(
                name: "UQ__departme__C7D39AE14318276A",
                table: "departments",
                column: "dept_name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_enrollments_class_code",
                table: "enrollments",
                column: "class_code");

            migrationBuilder.CreateIndex(
                name: "IX_face_data_student_code",
                table: "face_data",
                column: "student_code");

            migrationBuilder.CreateIndex(
                name: "UQ__facultie__22BC13FB33FEDEFA",
                table: "faculties",
                column: "faculty_name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_lecturers_dept_code",
                table: "lecturers",
                column: "dept_code");

            migrationBuilder.CreateIndex(
                name: "UQ__login__AB6E6164EEF18533",
                table: "login",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_majors_dept_code",
                table: "majors",
                column: "dept_code");

            migrationBuilder.CreateIndex(
                name: "UQ__majors__B2815F7AA8862F7D",
                table: "majors",
                column: "major_name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_subjects_dept_code",
                table: "subjects",
                column: "dept_code");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "attendance_records");

            migrationBuilder.DropTable(
                name: "curriculum");

            migrationBuilder.DropTable(
                name: "enrollments");

            migrationBuilder.DropTable(
                name: "face_data");

            migrationBuilder.DropTable(
                name: "student_details");

            migrationBuilder.DropTable(
                name: "student_identification");

            migrationBuilder.DropTable(
                name: "class_sessions");

            migrationBuilder.DropTable(
                name: "majors");

            migrationBuilder.DropTable(
                name: "students");

            migrationBuilder.DropTable(
                name: "classes");

            migrationBuilder.DropTable(
                name: "lecturers");

            migrationBuilder.DropTable(
                name: "subjects");

            migrationBuilder.DropTable(
                name: "login");

            migrationBuilder.DropTable(
                name: "departments");

            migrationBuilder.DropTable(
                name: "faculties");
        }
    }
}
