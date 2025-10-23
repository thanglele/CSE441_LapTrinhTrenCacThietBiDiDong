using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Models;

namespace MyTLUServer.Data;

public partial class AppDbContext : DbContext
{
    public AppDbContext()
    {
    }

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AttendanceRecord> AttendanceRecords { get; set; }

    public virtual DbSet<Class> Classes { get; set; }

    public virtual DbSet<ClassSession> ClassSessions { get; set; }

    public virtual DbSet<Curriculum> Curricula { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Enrollment> Enrollments { get; set; }

    public virtual DbSet<FaceDatum> FaceData { get; set; }

    public virtual DbSet<Faculty> Faculties { get; set; }

    public virtual DbSet<Lecturer> Lecturers { get; set; }

    public virtual DbSet<Login> Logins { get; set; }

    public virtual DbSet<Major> Majors { get; set; }

    public virtual DbSet<Student> Students { get; set; }

    public virtual DbSet<StudentDetail> StudentDetails { get; set; }

    public virtual DbSet<StudentIdentification> StudentIdentifications { get; set; }

    public virtual DbSet<Subject> Subjects { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=remote.thanglele.cloud;Database=MyTLU;User Id=sa;Password=mdq1jCu0Zy@2SkS5MF!q;TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AttendanceRecord>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__attendan__3213E83FE14295E5");

            entity.HasOne(d => d.ClassSession).WithMany(p => p.AttendanceRecords).HasConstraintName("FK__attendanc__class__74AE54BC");

            entity.HasOne(d => d.StudentCodeNavigation).WithMany(p => p.AttendanceRecords)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__attendanc__stude__75A278F5");
        });

        modelBuilder.Entity<Class>(entity =>
        {
            entity.HasKey(e => e.ClassCode).HasName("PK__classes__0AF9B2E5773F8499");

            entity.HasOne(d => d.LecturerCodeNavigation).WithMany(p => p.Classes)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__classes__lecture__66603565");

            entity.HasOne(d => d.SubjectCodeNavigation).WithMany(p => p.Classes)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__classes__subject__656C112C");
        });

        modelBuilder.Entity<ClassSession>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__class_se__3213E83F0228B959");

            entity.HasOne(d => d.ClassCodeNavigation).WithMany(p => p.ClassSessions)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__class_ses__class__6FE99F9F");
        });

        modelBuilder.Entity<Curriculum>(entity =>
        {
            entity.HasKey(e => new { e.MajorCode, e.SubjectCode }).HasName("PK__curricul__0199E1324817072C");

            entity.Property(e => e.ProgramStatus).HasDefaultValue("active");
            entity.Property(e => e.Required).HasDefaultValue(true);

            entity.HasOne(d => d.MajorCodeNavigation).WithMany(p => p.Curricula).HasConstraintName("FK__curriculu__major__5FB337D6");

            entity.HasOne(d => d.SubjectCodeNavigation).WithMany(p => p.Curricula)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__curriculu__subje__60A75C0F");
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.HasKey(e => e.DeptCode).HasName("PK__departme__799C94D4FF2F2EB4");

            entity.HasOne(d => d.FacultyCodeNavigation).WithMany(p => p.Departments)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__departmen__facul__4316F928");
        });

        modelBuilder.Entity<Enrollment>(entity =>
        {
            entity.HasKey(e => new { e.StudentCode, e.ClassCode }).HasName("PK__enrollme__2D5CA76AE3AF2049");

            entity.Property(e => e.EnrollmentStatus).HasDefaultValue("enrolled");

            entity.HasOne(d => d.ClassCodeNavigation).WithMany(p => p.Enrollments).HasConstraintName("FK__enrollmen__class__6C190EBB");

            entity.HasOne(d => d.StudentCodeNavigation).WithMany(p => p.Enrollments).HasConstraintName("FK__enrollmen__stude__6B24EA82");
        });

        modelBuilder.Entity<FaceDatum>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__face_dat__3213E83FCA0C7994");

            entity.Property(e => e.IsActive).HasDefaultValue(false);
            entity.Property(e => e.UploadStatus).HasDefaultValue("pending");

            entity.HasOne(d => d.StudentCodeNavigation).WithMany(p => p.FaceData)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK__face_data__stude__7B5B524B");
        });

        modelBuilder.Entity<Faculty>(entity =>
        {
            entity.HasKey(e => e.FacultyCode).HasName("PK__facultie__8492FC161C03FCE3");
        });

        modelBuilder.Entity<Lecturer>(entity =>
        {
            entity.HasKey(e => e.LecturerCode).HasName("PK__lecturer__14870CE86B1976E8");

            entity.HasOne(d => d.DeptCodeNavigation).WithMany(p => p.Lecturers)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__lecturers__dept___47DBAE45");

            entity.HasOne(d => d.LecturerCodeNavigation).WithOne(p => p.Lecturer).HasConstraintName("FK__lecturers__lectu__46E78A0C");
        });

        modelBuilder.Entity<Login>(entity =>
        {
            entity.HasKey(e => e.Username).HasName("PK__login__F3DBC5739DC1CB05");

            entity.Property(e => e.AccountStatus).HasDefaultValue("active");
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(getdate())");
        });

        modelBuilder.Entity<Major>(entity =>
        {
            entity.HasKey(e => e.MajorCode).HasName("PK__majors__0D732CA0B387A0D5");

            entity.HasOne(d => d.DeptCodeNavigation).WithMany(p => p.Majors)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__majors__dept_cod__5535A963");
        });

        modelBuilder.Entity<Student>(entity =>
        {
            entity.HasKey(e => e.StudentCode).HasName("PK__students__6DF33C44888D9674");

            entity.HasOne(d => d.StudentCodeNavigation).WithOne(p => p.Student).HasConstraintName("FK__students__studen__4BAC3F29");
        });

        modelBuilder.Entity<StudentDetail>(entity =>
        {
            entity.HasKey(e => e.StudentCode).HasName("PK__student___6DF33C449A1AB826");

            entity.HasOne(d => d.StudentCodeNavigation).WithOne(p => p.StudentDetail).HasConstraintName("FK__student_d__stude__5165187F");
        });

        modelBuilder.Entity<StudentIdentification>(entity =>
        {
            entity.HasKey(e => e.StudentCode).HasName("PK__student___6DF33C44764F526B");

            entity.HasOne(d => d.StudentCodeNavigation).WithOne(p => p.StudentIdentification).HasConstraintName("FK__student_i__stude__4E88ABD4");
        });

        modelBuilder.Entity<Subject>(entity =>
        {
            entity.HasKey(e => e.SubjectCode).HasName("PK__subjects__CEACD92125372766");

            entity.Property(e => e.SessionDurationMinutes).HasDefaultValue(90);
            entity.Property(e => e.SessionsPerWeek).HasDefaultValue(1);

            entity.HasOne(d => d.DeptCodeNavigation).WithMany(p => p.Subjects)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK__subjects__dept_c__59FA5E80");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
