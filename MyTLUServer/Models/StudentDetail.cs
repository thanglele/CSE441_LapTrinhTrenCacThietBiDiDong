using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("student_details")]
public partial class StudentDetail
{
    [Key]
    [Column("student_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string StudentCode { get; set; } = null!;

    [Column("ethnicity")]
    [StringLength(50)]
    public string? Ethnicity { get; set; }

    [Column("religion")]
    [StringLength(50)]
    public string? Religion { get; set; }

    [Column("contact_address")]
    [StringLength(500)]
    public string? ContactAddress { get; set; }

    [Column("father_full_name")]
    [StringLength(255)]
    public string? FatherFullName { get; set; }

    [Column("father_phone_number")]
    [StringLength(20)]
    [Unicode(false)]
    public string? FatherPhoneNumber { get; set; }

    [Column("mother_full_name")]
    [StringLength(255)]
    public string? MotherFullName { get; set; }

    [Column("mother_phone_number")]
    [StringLength(20)]
    [Unicode(false)]
    public string? MotherPhoneNumber { get; set; }

    [ForeignKey("StudentCode")]
    [InverseProperty("StudentDetail")]
    public virtual Student StudentCodeNavigation { get; set; } = null!;
}
