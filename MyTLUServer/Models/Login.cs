using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyTLUServer.Domain.Models;

[Table("login")]
[Index("Email", Name = "UQ__login__AB6E6164EEF18533", IsUnique = true)]
public partial class Login
{
    [Key]
    [Column("username")]
    [StringLength(50)]
    [Unicode(false)]
    public string Username { get; set; } = null!;

    [Column("password_hash")]
    [StringLength(255)]
    [Unicode(false)]
    public string? PasswordHash { get; set; }

    [Column("email")]
    [StringLength(255)]
    [Unicode(false)]
    public string Email { get; set; } = null!;

    [Column("account_status")]
    [StringLength(10)]
    [Unicode(false)]
    public string AccountStatus { get; set; } = null!;

    [Column("user_role")]
    [StringLength(20)]
    [Unicode(false)]
    public string UserRole { get; set; } = null!;

    [Column("created_at")]
    public DateTime? CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime? UpdatedAt { get; set; }

    [Column("updated_pos")]
    [StringLength(255)]
    [Unicode(false)]
    public string? LoginPosition { get; set; }

    [InverseProperty("LecturerCodeNavigation")]
    public virtual Lecturer? Lecturer { get; set; }

    [InverseProperty("StudentCodeNavigation")]
    public virtual Student? Student { get; set; }
}
