using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[Table("students")]
public partial class Student
{
    [Key]
    [Column("student_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string StudentCode { get; set; } = null!;

    [Column("full_name")]
    [StringLength(255)]
    public string FullName { get; set; } = null!;

    [Column("phone_number")]
    [StringLength(20)]
    [Unicode(false)]
    public string? PhoneNumber { get; set; }

    [Column("date_of_birth")]
    public DateOnly? DateOfBirth { get; set; }

    [Column("gender")]
    [StringLength(10)]
    [Unicode(false)]
    public string? Gender { get; set; }

    [Column("admin_class")]
    [StringLength(100)]
    public string? AdminClass { get; set; }

    [Column("major_name")]
    [StringLength(255)]
    public string? MajorName { get; set; }

    [Column("intake_year")]
    [StringLength(20)]
    public string? IntakeYear { get; set; }

    [Column("admission_decision")]
    [StringLength(500)]
    public string? AdmissionDecision { get; set; }

    [Column("academic_status")]
    [StringLength(200)]
    public string? AcademicStatus { get; set; }

    [Column("academic_status_1")]
    [StringLength(200)]
    public string? AcademicStatus1 { get; set; }

    [InverseProperty("StudentCodeNavigation")]
    public virtual ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();

    [InverseProperty("StudentCodeNavigation")]
    public virtual ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();

    [InverseProperty("StudentCodeNavigation")]
    public virtual ICollection<FaceDatum> FaceData { get; set; } = new List<FaceDatum>();

    [ForeignKey("StudentCode")]
    [InverseProperty("Student")]
    public virtual Login StudentCodeNavigation { get; set; } = null!;

    [InverseProperty("StudentCodeNavigation")]
    public virtual StudentDetail? StudentDetail { get; set; }

    [InverseProperty("StudentCodeNavigation")]
    public virtual StudentIdentification? StudentIdentification { get; set; }
}
