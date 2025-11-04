using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[Table("majors")]
[Index("MajorName", Name = "UQ__majors__B2815F7AA8862F7D", IsUnique = true)]
public partial class Major
{
    [Key]
    [Column("major_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string MajorCode { get; set; } = null!;

    [Column("major_name")]
    [StringLength(255)]
    public string MajorName { get; set; } = null!;

    [Column("dept_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? DeptCode { get; set; }

    [InverseProperty("MajorCodeNavigation")]
    public virtual ICollection<Curriculum> Curricula { get; set; } = new List<Curriculum>();

    [ForeignKey("DeptCode")]
    [InverseProperty("Majors")]
    public virtual Department? DeptCodeNavigation { get; set; }
}
