using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("faculties")]
[Index("FacultyName", Name = "UQ__facultie__22BC13FB33FEDEFA", IsUnique = true)]
public partial class Faculty
{
    [Key]
    [Column("faculty_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string FacultyCode { get; set; } = null!;

    [Column("faculty_name")]
    [StringLength(255)]
    public string FacultyName { get; set; } = null!;

    [Column("office_location")]
    [StringLength(255)]
    public string? OfficeLocation { get; set; }

    [InverseProperty("FacultyCodeNavigation")]
    public virtual ICollection<Department> Departments { get; set; } = new List<Department>();
}
