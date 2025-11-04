using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[Table("subjects")]
public partial class Subject
{
    [Key]
    [Column("subject_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string SubjectCode { get; set; } = null!;

    [Column("subject_name")]
    [StringLength(255)]
    public string SubjectName { get; set; } = null!;

    [Column("credits")]
    public int Credits { get; set; }

    [Column("dept_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? DeptCode { get; set; }

    [Column("sessions_per_week")]
    public int? SessionsPerWeek { get; set; }

    [Column("session_duration_minutes")]
    public int? SessionDurationMinutes { get; set; }

    [Column("description")]
    public string? Description { get; set; }

    [InverseProperty("SubjectCodeNavigation")]
    public virtual ICollection<Class> Classes { get; set; } = new List<Class>();

    [InverseProperty("SubjectCodeNavigation")]
    public virtual ICollection<Curriculum> Curricula { get; set; } = new List<Curriculum>();

    [ForeignKey("DeptCode")]
    [InverseProperty("Subjects")]
    public virtual Department? DeptCodeNavigation { get; set; }
}
