using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Models;

[Table("face_data")]
public partial class FaceDatum
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("student_code")]
    [StringLength(50)]
    [Unicode(false)]
    public string? StudentCode { get; set; }

    [Column("image_path")]
    [StringLength(255)]
    [Unicode(false)]
    public string? ImagePath { get; set; }

    [Column("face_embedding")]
    [Unicode(false)]
    public string? FaceEmbedding { get; set; }

    [Column("is_active")]
    public bool? IsActive { get; set; }

    [Column("upload_status")]
    [StringLength(20)]
    [Unicode(false)]
    public string? UploadStatus { get; set; }

    [Column("uploaded_at")]
    public DateTime? UploadedAt { get; set; }

    [ForeignKey("StudentCode")]
    [InverseProperty("FaceData")]
    public virtual Student? StudentCodeNavigation { get; set; }
}
