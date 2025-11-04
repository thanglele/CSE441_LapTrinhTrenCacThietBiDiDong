// Helpers/GeoHelper.cs
using System;

public static class GeoHelper
{
    private const double EarthRadiusKm = 6371.0;

    /// <summary>
    /// Tính khoảng cách (mét) giữa 2 điểm tọa độ
    /// </summary>
    public static double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
        var dLat = ToRadians(lat2 - lat1);
        var dLon = ToRadians(lon2 - lon1);

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return (EarthRadiusKm * c) * 1000; // Trả về mét
    }

    private static double ToRadians(double angle)
    {
        return Math.PI * angle / 180.0;
    }

    /// <summary>
    /// Tách chuỗi "latitude,longitude"
    /// </summary>
    public static (double Lat, double Lon)? ParseCoordinates(string? coords)
    {
        if (string.IsNullOrEmpty(coords))
            return null;

        var parts = coords.Split(',');
        if (parts.Length != 2 ||
            !double.TryParse(parts[0], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out var lat) ||
            !double.TryParse(parts[1], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out var lon))
        {
            // Thêm CultureInfo.InvariantCulture để xử lý dấu '.' thập phân
            return null;
        }
        return (lat, lon);
    }

    /// <summary>
    /// HÀM MỚI: Kiểm tra tọa độ có nằm trong hình chữ nhật không
    /// </summary>
    public static bool IsWithinBoundingBox(string? coordString, double minLat, double maxLat, double minLon, double maxLon)
    {
        var coords = ParseCoordinates(coordString);
        if (coords == null)
            return false; // Tọa độ không hợp lệ

        var lat = coords.Value.Lat;
        var lon = coords.Value.Lon;

        return (lat >= minLat && lat <= maxLat) &&
               (lon >= minLon && lon <= maxLon);
    }

    /// <summary>
    /// Hàm kiểm tra chính: Tọa độ có nằm trong bán kính cho phép không
    /// </summary>
    public static bool IsWithinRadius(string? coordString, double targetLat, double targetLon, double radiusMeters)
    {
        var coords = ParseCoordinates(coordString);
        if (coords == null)
            return false; // Tọa độ không hợp lệ

        var distance = CalculateDistance(coords.Value.Lat, coords.Value.Lon, targetLat, targetLon);
        return distance <= radiusMeters;
    }
}