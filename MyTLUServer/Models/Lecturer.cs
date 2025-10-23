using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("lecturers")]
public partial class Lecturer
{
    [Key]
    [Column("lecturer_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string LecturerCode { get; set; } = null!;

    [Column("full_name")]
    [StringLength(255)]
    public string FullName { get; set; } = null!;

    [Column("phone_number")]
    [StringLength(20)]
    [Unicode(false)]
    public string? PhoneNumber { get; set; }

    [Column("avatar_url")]
    [StringLength(255)]
    [Unicode(false)]
    public string? AvatarUrl { get; set; }

    [Column("date_of_birth")]
    public DateOnly? DateOfBirth { get; set; }

    [Column("gender")]
    [StringLength(10)]
    [Unicode(false)]
    public string? Gender { get; set; }

    [Column("dept_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? DeptCode { get; set; }

    [Column("degree")]
    [StringLength(100)]
    public string? Degree { get; set; }

    [Column("academic_rank")]
    [StringLength(100)]
    public string? AcademicRank { get; set; }

    [Column("office_location")]
    [StringLength(255)]
    public string? OfficeLocation { get; set; }

    [InverseProperty("LecturerCodeNavigation")]
    public virtual ICollection<Class> Classes { get; set; } = new List<Class>();

    [ForeignKey("DeptCode")]
    [InverseProperty("Lecturers")]
    public virtual Department? DeptCodeNavigation { get; set; }

    [ForeignKey("LecturerCode")]
    [InverseProperty("Lecturer")]
    public virtual Login LecturerCodeNavigation { get; set; } = null!;
}
