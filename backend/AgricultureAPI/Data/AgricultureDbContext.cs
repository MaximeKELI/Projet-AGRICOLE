using Microsoft.EntityFrameworkCore;
using AgricultureAPI.Models;

namespace AgricultureAPI.Data
{
    public class AgricultureDbContext : DbContext
    {
        public AgricultureDbContext(DbContextOptions<AgricultureDbContext> options) : base(options)
        {
        }

        public DbSet<Region> Regions { get; set; }
        public DbSet<Prefecture> Prefectures { get; set; }
        public DbSet<Commune> Communes { get; set; }
        public DbSet<SoilType> SoilTypes { get; set; }
        public DbSet<Crop> Crops { get; set; }
        public DbSet<SoilTypeCrop> SoilTypeCrops { get; set; }
        public DbSet<CropActivity> CropActivities { get; set; }
        public DbSet<PlantingSchedule> PlantingSchedules { get; set; }
        public DbSet<WeatherAlert> WeatherAlerts { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<DocumentRecommendation> DocumentRecommendations { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<UserPurchase> UserPurchases { get; set; }
        public DbSet<AgriculturalMetrics> AgriculturalMetrics { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configuration des relations
            modelBuilder.Entity<Prefecture>()
                .HasOne(p => p.Region)
                .WithMany(r => r.Prefectures)
                .HasForeignKey(p => p.RegionId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Commune>()
                .HasOne(c => c.Prefecture)
                .WithMany(p => p.Communes)
                .HasForeignKey(c => c.PrefectureId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Commune>()
                .HasOne(c => c.SoilType)
                .WithMany(s => s.Communes)
                .HasForeignKey(c => c.SoilTypeId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<SoilTypeCrop>()
                .HasOne(sc => sc.SoilType)
                .WithMany(s => s.SoilTypeCrops)
                .HasForeignKey(sc => sc.SoilTypeId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SoilTypeCrop>()
                .HasOne(sc => sc.Crop)
                .WithMany(c => c.SoilTypeCrops)
                .HasForeignKey(sc => sc.CropId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<CropActivity>()
                .HasOne(ca => ca.Crop)
                .WithMany(c => c.Activities)
                .HasForeignKey(ca => ca.CropId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PlantingSchedule>()
                .HasOne(ps => ps.Crop)
                .WithOne(c => c.PlantingSchedule)
                .HasForeignKey<PlantingSchedule>(ps => ps.CropId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configuration des nouvelles relations
            modelBuilder.Entity<UserPurchase>()
                .HasOne(up => up.User)
                .WithMany(u => u.Purchases)
                .HasForeignKey(up => up.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserPurchase>()
                .HasOne(up => up.Document)
                .WithMany(d => d.Purchases)
                .HasForeignKey(up => up.DocumentId)
                .OnDelete(DeleteBehavior.Cascade);

            // Index pour améliorer les performances
            modelBuilder.Entity<Commune>()
                .HasIndex(c => new { c.Latitude, c.Longitude });

            modelBuilder.Entity<CropActivity>()
                .HasIndex(ca => ca.DayFromPlanting);

            modelBuilder.Entity<WeatherAlert>()
                .HasIndex(wa => new { wa.StartDate, wa.EndDate });

            modelBuilder.Entity<DocumentRecommendation>()
                .HasIndex(d => d.Category);

            modelBuilder.Entity<DocumentRecommendation>()
                .HasIndex(d => new { d.Region, d.Prefecture });

            modelBuilder.Entity<Payment>()
                .HasIndex(p => p.Status);

            modelBuilder.Entity<UserPurchase>()
                .HasIndex(up => new { up.UserId, up.DocumentId })
                .IsUnique();
        }
    }
}
