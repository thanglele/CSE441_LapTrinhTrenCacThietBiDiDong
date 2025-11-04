using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[PrimaryKey("MajorCode", "SubjectCode")]
[Table("curriculum")]
public partial class Curriculum
{
    [Key]
    [Column("major_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string MajorCode { get; set; } = null!;

    [Key]
    [Column("subject_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string SubjectCode { get; set; } = null!;

    [Column("required")]
    public bool? Required { get; set; }

    [Column("program_status")]
    [StringLength(20)]
    [Unicode(false)]
    public string? ProgramStatus { get; set; }

    [ForeignKey("MajorCode")]
    [InverseProperty("Curricula")]
    public virtual Major MajorCodeNavigation { get; set; } = null!;

    [ForeignKey("SubjectCode")]
    [InverseProperty("Curricula")]
    public virtual Subject SubjectCodeNavigation { get; set; } = null!;
}
