using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[Table("class_sessions")]
public partial class ClassSession
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("class_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? ClassCode { get; set; }

    [Column("title")]
    [StringLength(255)]
    public string? Title { get; set; }

    [Column("session_date")]
    public DateOnly? SessionDate { get; set; }

    [Column("start_time")]
    public TimeOnly? StartTime { get; set; }

    [Column("end_time")]
    public TimeOnly? EndTime { get; set; }

    [Column("session_location")]
    [StringLength(255)]
    public string? SessionLocation { get; set; }

    [Column("qr_code_data")]
    [Unicode(false)]
    public string? QrCodeData { get; set; }

    [Column("session_status")]
    [StringLength(15)]
    [Unicode(false)]
    public string? SessionStatus { get; set; }

    [InverseProperty("ClassSession")]
    public virtual ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();

    [ForeignKey("ClassCode")]
    [InverseProperty("ClassSessions")]
    public virtual Class? ClassCodeNavigation { get; set; }
}
