using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("attendance_records")]
public partial class AttendanceRecord
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("class_session_id")]
    public int? ClassSessionId { get; set; }

    [Column("student_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? StudentCode { get; set; }

    [Column("attendance_status")]
    [StringLength(10)]
    [Unicode(false)]
    public string AttendanceStatus { get; set; } = null!;

    [Column("check_in_time")]
    public DateTime? CheckInTime { get; set; }

    [Column("method")]
    [StringLength(10)]
    [Unicode(false)]
    public string? Method { get; set; }

    [Column("notes")]
    public string? Notes { get; set; }

    [ForeignKey("ClassSessionId")]
    [InverseProperty("AttendanceRecords")]
    public virtual ClassSession? ClassSession { get; set; }

    [ForeignKey("StudentCode")]
    [InverseProperty("AttendanceRecords")]
    public virtual Student? StudentCodeNavigation { get; set; }
}
