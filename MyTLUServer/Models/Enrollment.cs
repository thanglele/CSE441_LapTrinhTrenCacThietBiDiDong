using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[PrimaryKey("StudentCode", "ClassCode")]
[Table("enrollments")]
public partial class Enrollment
{
    [Key]
    [Column("student_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string StudentCode { get; set; } = null!;

    [Key]
    [Column("class_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string ClassCode { get; set; } = null!;

    [Column("enrollment_status")]
    [StringLength(20)]
    [Unicode(false)]
    public string? EnrollmentStatus { get; set; }

    [ForeignKey("ClassCode")]
    [InverseProperty("Enrollments")]
    public virtual Class ClassCodeNavigation { get; set; } = null!;

    [ForeignKey("StudentCode")]
    [InverseProperty("Enrollments")]
    public virtual Student StudentCodeNavigation { get; set; } = null!;
}
