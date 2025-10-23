using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("classes")]
public partial class Class
{
    [Key]
    [Column("class_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string ClassCode { get; set; } = null!;

    [Column("class_name")]
    [StringLength(255)]
    public string ClassName { get; set; } = null!;

    [Column("subject_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? SubjectCode { get; set; }

    [Column("lecturer_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? LecturerCode { get; set; }

    [Column("academic_year")]
    [StringLength(50)]
    [Unicode(false)]
    public string? AcademicYear { get; set; }

    [Column("semester")]
    [StringLength(20)]
    [Unicode(false)]
    public string? Semester { get; set; }

    [Column("max_students")]
    public int? MaxStudents { get; set; }

    [Column("class_start_date")]
    public DateOnly? ClassStartDate { get; set; }

    [Column("class_end_date")]
    public DateOnly? ClassEndDate { get; set; }

    [Column("schedule_summary")]
    [StringLength(255)]
    public string? ScheduleSummary { get; set; }

    [Column("default_location")]
    [StringLength(255)]
    public string? DefaultLocation { get; set; }

    [Column("class_type")]
    [StringLength(10)]
    [Unicode(false)]
    public string? ClassType { get; set; }

    [Column("class_status")]
    [StringLength(20)]
    [Unicode(false)]
    public string? ClassStatus { get; set; }

    [InverseProperty("ClassCodeNavigation")]
    public virtual ICollection<ClassSession> ClassSessions { get; set; } = new List<ClassSession>();

    [InverseProperty("ClassCodeNavigation")]
    public virtual ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();

    [ForeignKey("LecturerCode")]
    [InverseProperty("Classes")]
    public virtual Lecturer? LecturerCodeNavigation { get; set; }

    [ForeignKey("SubjectCode")]
    [InverseProperty("Classes")]
    public virtual Subject? SubjectCodeNavigation { get; set; }
}
