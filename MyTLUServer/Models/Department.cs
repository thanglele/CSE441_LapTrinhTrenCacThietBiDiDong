using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("departments")]
[Index("DeptName", Name = "UQ__departme__C7D39AE14318276A", IsUnique = true)]
public partial class Department
{
    [Key]
    [Column("dept_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string DeptCode { get; set; } = null!;

    [Column("dept_name")]
    [StringLength(255)]
    public string DeptName { get; set; } = null!;

    [Column("faculty_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? FacultyCode { get; set; }

    [ForeignKey("FacultyCode")]
    [InverseProperty("Departments")]
    public virtual Faculty? FacultyCodeNavigation { get; set; }

    [InverseProperty("DeptCodeNavigation")]
    public virtual ICollection<Lecturer> Lecturers { get; set; } = new List<Lecturer>();

    [InverseProperty("DeptCodeNavigation")]
    public virtual ICollection<Major> Majors { get; set; } = new List<Major>();

    [InverseProperty("DeptCodeNavigation")]
    public virtual ICollection<Subject> Subjects { get; set; } = new List<Subject>();
}
