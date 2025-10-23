using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("student_identification")]
public partial class StudentIdentification
{
    [Key]
    [Column("student_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string StudentCode { get; set; } = null!;

    [Column("place_of_birth")]
    [StringLength(255)]
    public string? PlaceOfBirth { get; set; }

    [Column("national_id")]
    [StringLength(20)]
    [Unicode(false)]
    public string? NationalId { get; set; }

    [Column("id_issue_date")]
    public DateOnly? IdIssueDate { get; set; }

    [Column("id_issue_place")]
    [StringLength(255)]
    public string? IdIssuePlace { get; set; }

    [ForeignKey("StudentCode")]
    [InverseProperty("StudentIdentification")]
    public virtual Student StudentCodeNavigation { get; set; } = null!;
}
